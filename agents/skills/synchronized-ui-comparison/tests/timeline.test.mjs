import test from 'node:test';
import assert from 'node:assert/strict';
import { frameConcat, playerHtml } from '../scripts/export.mjs';

test('both frame streams use a shared zero and hold their last frame until the same end', () => {
  const a = frameConcat('before', [{ file: 'before/000000.jpg', seconds: 0.1 }, { file: 'before/000001.jpg', seconds: 1.2 }], 3);
  const b = frameConcat('after', [{ file: 'after/000000.jpg', seconds: 0.3 }, { file: 'after/000001.jpg', seconds: 2 }], 3);
  assert.match(a, /duration 1\.200000/);
  assert.match(a, /duration 1\.800000/);
  assert.match(b, /duration 2\.000000/);
  assert.match(b, /duration 1\.000000/);
});

test('rejects missing, invalid, out-of-order, or injected frame data', () => {
  for (const frames of [
    [],
    [{ file: '../secret.jpg', seconds: 0 }],
    [{ file: "before/000000.jpg'\nfile '/etc/passwd", seconds: 0 }],
    [{ file: 'after/000000.jpg', seconds: 0 }],
    [{ file: 'before/000000.jpg', seconds: NaN }],
    [{ file: 'before/000000.jpg', seconds: -1 }],
    [{ file: 'before/000000.jpg', seconds: 2 }, { file: 'before/000001.jpg', seconds: 1 }],
    [{ file: 'before/000000.jpg', seconds: 4 }],
  ]) assert.throws(() => frameConcat('before', frames, 3));
});

test('accepts duplicate timestamps without negative durations', () => {
  const concat = frameConcat('before', [
    { file: 'before/000000.jpg', seconds: 0 },
    { file: 'before/000001.jpg', seconds: 0 },
  ], 1);
  assert.match(concat, /duration 1\.000000/);
  assert.doesNotMatch(concat, /duration -/);
});

test('chapter labels are HTML text, not executable markup', () => {
  const html = playerHtml([{ seconds: 1, title: '</option><img src=x onerror=alert(1)>' }]);
  assert(!html.includes('<img'));
  assert(html.includes('&lt;img'));
  assert(html.includes('comparison.mp4'));
});
