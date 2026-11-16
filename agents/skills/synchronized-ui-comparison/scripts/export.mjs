import assert from 'node:assert/strict';
import { readFile, writeFile, realpath, lstat, mkdtemp, copyFile, rm } from 'node:fs/promises';
import { constants } from 'node:fs';
import { resolve, join, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { spawnSync } from 'node:child_process';

// The first image holds from shared time zero, including time before its arrival.
// Every subsequent image holds until the next browser timestamp, not a guessed FPS.
export function frameConcat(side, frames, end) {
  assert(['before', 'after'].includes(side));
  assert(Number.isFinite(end) && end > 0, 'Invalid recording duration');
  assert(Array.isArray(frames) && frames.length > 0, `No ${side} frames captured`);
  let previous = -1;
  for (const frame of frames) {
    assert(new RegExp(`^${side}/[0-9]{6,}\\.jpg$`).test(frame.file), 'Invalid frame path');
    assert(Number.isFinite(frame.seconds) && frame.seconds >= previous && frame.seconds >= 0 && frame.seconds <= end, 'Invalid frame timestamp');
    previous = frame.seconds;
  }
  assert(frames[0].seconds < end, 'No frames within recording');
  const lines = ['ffconcat version 1.0'];
  frames.forEach((frame, i) => {
    const start = i === 0 ? 0 : frame.seconds;
    const stop = frames[i + 1]?.seconds ?? end;
    if (stop > start) lines.push(`file '${frame.file}'`, 'option framerate 1000', `duration ${(stop - start).toFixed(6)}`);
  });
  lines.push(`file '${frames.at(-1).file}'`, 'option framerate 1000');
  return `${lines.join('\n')}\n`;
}

function command(executable, args) {
  const result = spawnSync(executable, args, { encoding: 'utf8', timeout: 180000, maxBuffer: 8 * 1024 * 1024 });
  if (result.error || result.status !== 0) throw new Error(`${executable}: ${result.error?.message ?? result.stderr ?? result.signal}`);
  return result.stdout;
}

export async function exportRecording({ outDir, ffmpeg = 'ffmpeg', ffprobe = 'ffprobe' }) {
  outDir = await realpath(resolve(outDir));
  const record = JSON.parse(await readFile(join(outDir, 'record.json'), 'utf8'));
  assert(record.version === 1 && record.success === true, 'Cannot export an unsuccessful or unsupported recording');
  assert(Array.isArray(record.steps) && record.steps.length > 0 && record.steps.every(s => s.success && typeof s.title === 'string' && Number.isFinite(s.seconds) && s.seconds >= 0 && s.seconds < record.end), 'Invalid/incomplete chapters');
  assert(Array.isArray(record.captures) && record.captures.length === 2, 'Expected two frame streams');
  const concats = record.captures.map((frames, i) => frameConcat(i ? 'after' : 'before', frames, record.end));
  // The manifest is input, not permission to read arbitrary files through symlinks.
  for (const frames of record.captures) for (const frame of frames) {
    const file = join(outDir, frame.file);
    assert((await realpath(file)).startsWith(outDir + sep) && (await lstat(file)).isFile(), 'Frame must be a regular file inside the recording directory');
  }
  for (const name of ['comparison.mp4', 'comparison.html']) {
    await lstat(join(outDir, name)).then(() => { throw new Error(`Export already exists: ${name}`); }, error => { if (error.code !== 'ENOENT') throw error; });
  }
  command(ffmpeg, ['-version']); command(ffprobe, ['-version']);
  const work = await mkdtemp(join(outDir, '.export-'));
  try {
    const inputs = [];
    for (let i = 0; i < 2; i++) {
      const file = join(work, `${i}.ffconcat`);
      // Work files are one directory below the captures; paths stay relative so
      // spaces and quotes in the user's output directory never enter concat text.
      await writeFile(file, concats[i].replaceAll("file '", "file '../"));
      inputs.push('-safe', '0', '-f', 'concat', '-i', file);
    }
    const metadata = [';FFMETADATA1', 'title=Synchronized UI comparison'];
    record.steps.forEach((step, i) => {
      const stop = record.steps[i + 1]?.seconds ?? record.end;
      assert(stop >= step.seconds, 'Chapter timestamps must be ordered');
      const title = step.title.replace(/\\/g, '\\\\').replace(/[\r\n]/g, ' ').replace(/[=;#]/g, '\\$&');
      metadata.push('[CHAPTER]', 'TIMEBASE=1/1000', `START=${Math.round(step.seconds * 1000)}`, `END=${Math.round(stop * 1000)}`, `title=${i + 1}. ${title}`);
    });
    const meta = join(work, 'chapters.ffmeta'), video = join(work, 'comparison.mp4');
    await writeFile(meta, metadata.join('\n') + '\n');
    command(ffmpeg, ['-hide_banner', '-loglevel', 'error', '-n', ...inputs, '-i', meta, '-filter_complex', '[0:v]fps=25,setpts=PTS-STARTPTS[a];[1:v]fps=25,setpts=PTS-STARTPTS[b];[a][b]hstack=inputs=2[v]', '-map', '[v]', '-map_metadata', '2', '-map_chapters', '2', '-t', String(record.end), '-c:v', 'libx264', '-preset', 'fast', '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', '-an', video]);
    const probe = JSON.parse(command(ffprobe, ['-v', 'error', '-show_streams', '-show_format', '-of', 'json', video]));
    const stream = probe.streams.find(s => s.codec_type === 'video');
    assert(stream?.codec_name === 'h264' && stream.width === record.viewport.width * 2 && stream.height === record.viewport.height, 'Export dimensions/codec do not match capture');
    assert(Math.abs(Number(probe.format.duration) - record.end) < 0.2, 'Export duration does not match capture timeline');
    await copyFile(video, join(outDir, 'comparison.mp4'), constants.COPYFILE_EXCL);
    await writeFile(join(outDir, 'comparison.html'), playerHtml(record.steps), { flag: 'wx' });
    return { video: join(outDir, 'comparison.mp4'), player: join(outDir, 'comparison.html'), duration: Number(probe.format.duration) };
  } finally {
    // Only delete this process's private mkdtemp work directory, never captures.
    await rm(work, { recursive: true, force: true });
  }
}

const escapeHtml = text => String(text).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);

export function playerHtml(steps) {
  const options = steps.map((step, i) => `<option value="${Number(step.seconds)}">${i + 1}. ${escapeHtml(step.title)}</option>`).join('\n');
  return `<!doctype html><html lang="en"><meta charset="utf-8"><title>Before and after</title>
<style>body{font:16px system-ui;margin:24px;background:#f4f6f9;color:#182439}video{display:block;width:100%;max-height:78vh;margin:18px 0;background:#182439}button,select{font:inherit;padding:8px}</style>
<h1>Before and after</h1><p>Before on the left; after on the right. Both follow one shared action schedule.</p>
<select id="chapters" aria-label="Interaction">${options}</select> <button id="jump">Jump to interaction</button>
<video id="video" src="comparison.mp4" controls preload="metadata"></video>
<p>See <a href="record.json">record.json</a> for scenario, timing, and assertions. Capture does not prove equivalence; inspect the video and scenario checks.</p>
<script>document.getElementById('jump').onclick=()=>{const v=document.getElementById('video');v.pause();v.currentTime=Number(document.getElementById('chapters').value)}</script></html>`;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const { values } = parseArgs({ options: { out: { type: 'string' }, ffmpeg: { type: 'string', default: 'ffmpeg' }, ffprobe: { type: 'string', default: 'ffprobe' }, help: { type: 'boolean' } } });
    if (values.help) console.log('node export.mjs --out /path/recording [--ffmpeg /path/ffmpeg] [--ffprobe /path/ffprobe]');
    else { assert(values.out, 'Required: --out (use --help)'); console.log(await exportRecording({ outDir: values.out, ffmpeg: values.ffmpeg, ffprobe: values.ffprobe })); }
  } catch (error) { console.error(error.stack ?? error); process.exitCode = 1; }
}
