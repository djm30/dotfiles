import assert from 'node:assert/strict';
import { mkdir, writeFile, copyFile } from 'node:fs/promises';
import { writeFileSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { setTimeout as sleep } from 'node:timers/promises';
import { chromium } from 'playwright';

const sides = ['before', 'after'];
const bounded = (n, min, max, name) => assert(Number.isInteger(n) && n >= min && n <= max, `Invalid ${name}`);
function httpUrl(value) {
  const url = new URL(value);
  assert(['http:', 'https:'].includes(url.protocol) && !url.username && !url.password, 'Use HTTP(S) URLs without embedded credentials');
  return url;
}

// Display-only annotations. They do not intercept input or change app layout.
function annotations() {
  const install = () => {
    if (!document.body) return;
    const caption = document.createElement('ui-comparison-caption');
    caption.id = '__ui_compare_caption'; caption.setAttribute('aria-hidden', 'true');
    caption.style.cssText = 'display:block;position:fixed;top:0;left:0;right:0;height:32px;padding:7px 12px;box-sizing:border-box;background:#182439;color:white;font:14px system-ui;z-index:2147483647;pointer-events:none;white-space:nowrap;overflow:hidden';
    const pointer = document.createElement('ui-comparison-pointer');
    pointer.setAttribute('aria-hidden', 'true');
    pointer.style.cssText = 'display:none;position:fixed;width:22px;height:22px;border:2px solid #f15a24;background:#f15a2440;border-radius:50%;transform:translate(-50%,-50%);z-index:2147483646;pointer-events:none';
    document.body.append(caption, pointer);
    document.addEventListener('pointermove', e => { pointer.style.display = 'block'; pointer.style.left = `${e.clientX}px`; pointer.style.top = `${e.clientY}px`; });
    document.addEventListener('pointerdown', () => { pointer.style.width = pointer.style.height = '30px'; });
    document.addEventListener('pointerup', () => { pointer.style.width = pointer.style.height = '22px'; });
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', install, { once: true });
  else install();
}

export async function recordScenario({ scenarioPath, outDir }) {
  scenarioPath = resolve(scenarioPath); outDir = resolve(outDir);
  const config = (await import(pathToFileURL(scenarioPath).href)).default;
  assert(config && typeof config.run === 'function', 'Scenario must default-export an object with run()');
  const urls = [httpUrl(config.beforeUrl), httpUrl(config.afterUrl)];
  const viewport = config.viewport ?? { width: 1280, height: 1000 };
  bounded(viewport.width, 320, 3840, 'viewport width'); bounded(viewport.height, 240, 2160, 'viewport height');
  assert(viewport.height % 2 === 0, 'Viewport height must be even for H.264');
  const pauseMs = config.pauseMs ?? 600, timeoutMs = config.timeoutMs ?? 15000, maxDurationMs = config.maxDurationMs ?? 300000;
  bounded(pauseMs, 0, 5000, 'pauseMs'); bounded(timeoutMs, 1, 120000, 'timeoutMs'); bounded(maxDurationMs, 1, 1800000, 'maxDurationMs');
  assert(config.setup === undefined || typeof config.setup === 'function', 'setup must be a function');
  assert(config.allowedOrigins === undefined || Array.isArray(config.allowedOrigins), 'allowedOrigins must be an array');
  const allowed = new Set([...urls.map(u => u.origin), ...(config.allowedOrigins ?? []).map(value => httpUrl(value).origin)]);
  await mkdir(dirname(outDir), { recursive: true });
  await mkdir(outDir, { mode: 0o700 }).catch(error => { if (error.code === 'EEXIST') throw new Error('Output already exists; choose a fresh directory'); throw error; });
  await Promise.all(sides.map(side => mkdir(join(outDir, side))));
  await copyFile(scenarioPath, join(outDir, 'scenario-source.mjs'));
  const record = { version: 1, success: false, scenarioPath, urls: urls.map(String), viewport, allowedOrigins: [...allowed], steps: [], actions: [], captures: [[], []], firstFrameReceived: [null, null], errors: [], blockedOrigins: [] };
  let browser, pages = [], contexts = [], sessions = [], timer, inStep = false, active = true, failure;
  const started = Date.now();
  const elapsed = () => (Date.now() - started) / 1000;
  let abort;
  const stopped = new Promise((_, reject) => { abort = reject; });
  // A signal can arrive during browser launch, before Promise.race is attached.
  stopped.catch(() => {});
  const interrupted = () => abort(new Error('Recording interrupted'));
  const blocked = new Set();
  process.once('SIGINT', interrupted); process.once('SIGTERM', interrupted);
  try {
    // Own the browser before racing the deadline. Otherwise a late launch can
    // finish after finally has run and leave an unowned Chromium process alive.
    browser = await chromium.launch({ headless: true, timeout: 15000 });
    timer = setTimeout(() => abort(new Error('Recording exceeded maxDurationMs')), maxDurationMs);
    await Promise.race([(async () => {
      // Separate contexts prevent cookies/localStorage leaking between versions.
      for (const side of sides) {
        const context = await browser.newContext({ viewport, deviceScaleFactor: 1 }); contexts.push(context);
        assert(active, 'Recording cancelled during startup');
        await context.route('**/*', route => {
          const url = new URL(route.request().url());
          if (['data:', 'blob:'].includes(url.protocol) || allowed.has(url.origin)) return route.continue();
          blocked.add(url.origin); return route.abort();
        });
        await context.tracing.start({ screenshots: true, snapshots: true, sources: false });
        await context.addInitScript(annotations);
        const page = await context.newPage(); pages.push(page); assert(active, 'Recording cancelled during startup'); page.setDefaultTimeout(timeoutMs); page.setDefaultNavigationTimeout(timeoutMs);
        page.on('pageerror', error => record.errors.push(`${side}: ${error.message}`));
        const session = await context.newCDPSession(page); sessions.push(session); assert(active, 'Recording cancelled during startup');
        await session.send('Emulation.setFocusEmulationEnabled', { enabled: true });
      }
      const both = async fn => {
        assert(active, 'Recording is no longer active');
        const action = { step: record.steps.length, before: null, after: null };
        const results = await Promise.allSettled(pages.map((page, i) => { action[sides[i]] = elapsed(); return Promise.resolve().then(() => fn(page)); }));
        action.end = elapsed(); record.actions.push(action);
        const failures = results.flatMap((r, i) => r.status === 'rejected' ? [`${sides[i]}: ${r.reason?.stack ?? r.reason}`] : []);
        if (failures.length) throw new Error(failures.join('\n'));
        return results.map(r => r.value);
      };
      const step = async (title, fn) => {
        assert(active && !inStep, 'Await steps sequentially; nested/parallel steps are unsupported');
        assert(typeof title === 'string' && title.trim() && title.length <= 200, 'Step title must contain 1–200 characters');
        inStep = true;
        const entry = { title, seconds: elapsed() }; record.steps.push(entry);
        console.log(`${record.steps.length}. ${title}`);
        try {
          await Promise.all(pages.map((page, i) => page.locator('#__ui_compare_caption').evaluate((el, text) => { el.textContent = text; }, `${sides[i].toUpperCase()} | ${title}`)));
          await sleep(200); await fn(); await sleep(pauseMs);
          entry.focus = await Promise.all(pages.map(page => page.evaluate(() => ({ documentFocused: document.hasFocus(), activeTag: document.activeElement?.tagName }))));
          assert(entry.focus.every(f => f.documentFocused), 'Both pages must retain document focus');
          await Promise.all(pages.map((page, i) => page.screenshot({ path: join(outDir, `${String(record.steps.length).padStart(2, '0')}-${sides[i]}.png`) })));
          entry.end = elapsed(); entry.success = true;
        } finally { inStep = false; }
      };
      const api = { pages: { before: pages[0], after: pages[1] }, both, step };
      if (config.setup) await config.setup(api);
      assert(active, 'Recording cancelled during setup');
      await Promise.all(pages.map((page, i) => page.goto(String(urls[i]), { waitUntil: 'load' })));
      await Promise.all(pages.map(page => page.evaluate(() => document.fonts.ready.then(() => undefined))));
      assert(active, 'Recording cancelled during navigation');
      const firstFrames = [];
      for (let i = 0; i < sessions.length; i++) {
        const session = sessions[i], frames = record.captures[i];
        let firstFrame;
        firstFrames.push(new Promise(resolve => { firstFrame = resolve; }));
        session.on('Page.screencastFrame', async event => {
          try {
            assert(Number.isFinite(event.metadata.timestamp), 'Browser supplied an invalid frame timestamp');
            const file = `${sides[i]}/${String(frames.length).padStart(6, '0')}.jpg`;
            writeFileSync(join(outDir, file), Buffer.from(event.data, 'base64'));
            frames.push({ file, seconds: event.metadata.timestamp - started / 1000 });
            if (frames.length === 1) { record.firstFrameReceived[i] = elapsed(); firstFrame(); }
          } catch (error) { record.errors.push(`Capture: ${error.message}`); }
          finally { await session.send('Page.screencastFrameAck', { sessionId: event.sessionId }).catch(() => {}); }
        });
        await session.send('Page.startScreencast', { format: 'jpeg', quality: 90, maxWidth: viewport.width, maxHeight: viewport.height, everyNthFrame: 1 });
      }
      // Command completion is not frame readiness: never run inputs before
      // both streams have delivered their initial, pre-interaction image.
      await Promise.all(firstFrames);
      assert(active, 'Recording cancelled before scenario');
      await config.run(api);
      assert(record.steps.length > 0 && record.steps.every(s => s.success), 'Scenario must await at least one completed step');
      assert.deepEqual(record.errors, [], 'Browser/capture errors occurred');
    })(), stopped]);
    record.success = true;
  } catch (error) {
    failure = error; record.error = error.stack ?? String(error);
    await Promise.all(pages.map((page, i) => page.screenshot({ path: join(outDir, `${sides[i]}-failure.png`), timeout: 3000 }).catch(() => {})));
  } finally {
    active = false; clearTimeout(timer);
    process.removeListener('SIGINT', interrupted); process.removeListener('SIGTERM', interrupted);
    const cleanup = await Promise.allSettled(sessions.map(s => s.send('Page.stopScreencast')));
    // Compositor timestamps can be a few milliseconds ahead of Date.now().
    // End on the actual capture clock and retain the final frame for one tick.
    record.end = record.captures.reduce((end, frames) => frames.reduce((max, f) => Math.max(max, f.seconds), end), elapsed()) + 1 / 25;
    cleanup.push(...await Promise.allSettled(contexts.map((c, i) => c.tracing.stop({ path: join(outDir, `${sides[i]}-trace.zip`) }))));
    if (browser) cleanup.push(...await Promise.allSettled([browser.close()]));
    for (const result of cleanup) if (result.status === 'rejected') record.errors.push(`Cleanup: ${result.reason?.message ?? result.reason}`);
    if (record.errors.length || record.captures.some(frames => frames.length === 0)) {
      record.success = false; failure ??= new Error(record.errors.join('\n') || 'No frames captured'); record.error ??= failure.stack;
    }
    record.blockedOrigins = [...blocked];
    await writeFile(join(outDir, 'record.json'), JSON.stringify(record, null, 2) + '\n');
  }
  if (failure) throw failure;
  return record;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const { values } = parseArgs({ options: { scenario: { type: 'string' }, out: { type: 'string' }, help: { type: 'boolean' } } });
    if (values.help) console.log('node record.mjs --scenario /path/scenario.mjs --out /path/NEW-output-directory');
    else {
      assert(values.scenario && values.out, 'Required: --scenario and --out (use --help)');
      await recordScenario({ scenarioPath: values.scenario, outDir: values.out });
      console.log(`Capture complete: ${resolve(values.out)}`);
    }
  } catch (error) { console.error(error.stack ?? error); process.exitCode = 1; }
}
