import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, access, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { execFileSync, execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
import { recordScenario } from '../scripts/record.mjs';
import { exportRecording } from '../scripts/export.mjs';
import { startFixture } from '../examples/serve.mjs';

const exampleUrl = new URL('../examples/scenario.mjs', import.meta.url).href;

async function fixture(t) {
  const dir = await mkdtemp(join(tmpdir(), "ui compare's "));
  const server = await startFixture(0);
  t.after(async () => { await server.close(); await rm(dir, { recursive: true, force: true }); });
  async function scenario(name, body, extra = '') {
    const file = join(dir, name + '.mjs');
    await writeFile(file, `import example from ${JSON.stringify(exampleUrl)};
export default {...example,beforeUrl:${JSON.stringify(server.url + '/?version=before')},afterUrl:${JSON.stringify(server.url + '/?version=after')},viewport:{width:640,height:480},pauseMs:80,${extra}run:${body}};`);
    return file;
  }
  return { dir, server, scenario };
}

test('records matching input focus and independent storage; exports a playable shared timeline', { timeout: 60000 }, async t => {
  const f = await fixture(t);
  const scenarioPath = await f.scenario('success', `async api => {
    await api.pages.before.evaluate(() => localStorage.setItem('only-before', 'yes'));
    const {default: assert} = await import('node:assert/strict');
    assert.equal(await api.pages.after.evaluate(() => localStorage.getItem('only-before')), null);
    await example.run(api);
  }`);
  const outDir = join(f.dir, 'recording');
  const record = await recordScenario({ scenarioPath, outDir });
  assert(record.success);
  assert.equal(record.steps.length, 3);
  assert(record.steps.every(s => s.focus.every(f => f.documentFocused)));
  assert(record.captures.every(frames => frames.length > 1));
  assert(record.firstFrameReceived.every(t => Number.isFinite(t) && record.steps[0].seconds >= t), 'Both first frames must arrive before any scenario step starts');
  assert(record.actions.every(a => Math.abs(a.before - a.after) < 0.05));
  for (const side of ['before', 'after']) await access(join(outDir, side + '-trace.zip'));
  await exportRecording({ outDir });
  const probe = JSON.parse(execFileSync('ffprobe', ['-v', 'error', '-show_streams', '-show_format', '-of', 'json', join(outDir, 'comparison.mp4')], { encoding: 'utf8' }));
  const video = probe.streams.find(s => s.codec_type === 'video');
  assert.equal(video.width, 1280); assert.equal(video.height, 480);
  assert(Math.abs(Number(probe.format.duration) - record.end) < 0.12);
  assert((await readFile(join(outDir, 'comparison.html'), 'utf8')).includes('Enter the same valid name'));
  await assert.rejects(exportRecording({ outDir }), /already exists/);
  const { readdir } = await import('node:fs/promises');
  assert(!(await readdir(outDir)).some(name => name.startsWith('.export-')), 'Temporary export files must be removed');
});

test('preserves failed scenario evidence and refuses to export it as a completed comparison', { timeout: 30000 }, async t => {
  const f = await fixture(t);
  const scenarioPath = await f.scenario('failure', `async ({step,both}) => {
    await step('Deliberately fail', () => both(page => page.locator('#missing').waitFor({timeout:100})));
  }`);
  const outDir = join(f.dir, 'failed');
  await assert.rejects(recordScenario({ scenarioPath, outDir }), /missing|Deliberately fail/);
  const record = JSON.parse(await readFile(join(outDir, 'record.json'), 'utf8'));
  assert.equal(record.success, false); assert(record.error);
  for (const side of ['before', 'after']) {
    await access(join(outDir, side + '-failure.png'));
    await access(join(outDir, side + '-trace.zip'));
  }
  await assert.rejects(exportRecording({ outDir }), /failed|unsuccessful/i);
  await assert.rejects(access(join(outDir, 'comparison.mp4')));
});

test('rejects existing outputs without changing them', { timeout: 10000 }, async t => {
  const f = await fixture(t);
  const scenarioPath = await f.scenario('existing', 'example.run');
  const sentinel = join(f.dir, 'sentinel.txt'); await writeFile(sentinel, 'keep');
  await assert.rejects(recordScenario({ scenarioPath, outDir: f.dir }), /exist|fresh/i);
  assert.equal(await readFile(sentinel, 'utf8'), 'keep');
});

test('unhandled browser errors make a recording unsuccessful', { timeout: 30000 }, async t => {
  const f = await fixture(t);
  const scenarioPath = await f.scenario('crash', 'example.run', `afterUrl:${JSON.stringify(f.server.url + '/?version=after&crash=1')},`);
  const outDir = join(f.dir, 'crash');
  await assert.rejects(recordScenario({ scenarioPath, outDir }), /Deliberate fixture error/);
  assert.equal(JSON.parse(await readFile(join(outDir, 'record.json'), 'utf8')).success, false);
});

test('deadline failure closes the browser so the CLI exits without an external kill', { timeout: 15000 }, async t => {
  const f = await fixture(t);
  const scenarioPath = await f.scenario('deadline', 'example.run', 'maxDurationMs:20,');
  const outDir = join(f.dir, 'deadline');
  const script = fileURLToPath(new URL('../scripts/record.mjs', import.meta.url));
  await assert.rejects(promisify(execFile)(process.execPath, [script, '--scenario', scenarioPath, '--out', outDir], { timeout: 5000 }), error => {
    assert.equal(error.killed, false, 'Recorder must exit itself, not wait for test timeout');
    assert.equal(error.code, 1); assert.match(error.stderr, /maxDurationMs/); return true;
  });
  const record = JSON.parse(await readFile(join(outDir, 'record.json'), 'utf8'));
  assert.equal(record.success, false); assert(record.end < 10);
});
