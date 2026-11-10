---
name: synchronized-ui-comparison
description: Record synchronized side-by-side before/after videos of web UIs using Playwright, Chromium and FFmpeg. Use when comparing UI refactors, old/new components, or branches through the same interactions, especially when the user wants a video walkthrough or visual regression comparison.
compatibility: Node.js 22+, npm, Playwright Chromium, FFmpeg with libx264, and ffprobe.
---

# Synchronized UI comparison

Use the bundled JavaScript recorder/exporter; do not reinvent recording or build a
generic action language. Read [README.md](README.md) for the scenario contract and prerequisites.
Resolve bundled paths relative to this skill directory, not the current project.

## Prepare

1. Identify the exact before/after revisions and existing uncommitted edits. Preserve
   them. Use isolated snapshots/worktrees/previews; never comment out the user's components.
   Record revisions and diff metadata in the task artifacts. State whether this is a real
   application or an isolated preview and whether APIs are mocked.
2. Inspect behavior differences BEFORE scripting. The main comparison must use valid
   data accepted by both versions and matching starting state. Put intentional validation
   or other divergent-flow demonstrations in a separate scenario/video. Never change app
   validation or behavior to force equivalence, or quietly reset one side to conceal a difference.
3. Use local/test data and avoid production side effects. Keep artifacts outside the
   skill and project source. Scenario modules are trusted executable code; review unfamiliar ones.
   Screenshots/traces can contain secrets. Do not upload or share them without permission.
4. Verify Node, the skill's pinned Playwright browser, FFmpeg/libx264, and ffprobe.
   Install dependencies INSIDE this skill with `npm ci --ignore-scripts` and
   `npx --no-install playwright install chromium` if needed. Do not modify global
   configuration or project dependencies to repair the recording environment.

## Discover and order the workflows

Before writing the recording scenario, inspect BOTH versions' code, existing tests,
and running UI. Discover the actual user workflows; do not assume a single happy path
or copy a click sequence from only one version.

Write an ordered workflow checklist in the task artifacts. For each workflow, record:
- The matching starting state and any required fixture/reset.
- The ordered user actions and exact input values/files.
- The expected outcomes and assertions on each side.

Cover the requested scope: primary completion paths, alternative methods, settings,
navigation/Back, cancellation, close/reopen, and removal/confirmation where present.
List unavailable or intentionally different workflows explicitly; do not invent parity.
Keep divergent validation/error demonstrations separate from the matching main flow.

Run the SAME workflow list in the SAME order on both versions. Within each workflow,
run the SAME user actions in the SAME order with the SAME data. Complete each paired
action and check both outcomes before moving to the next. Reset/seed BOTH sides to
matching state between independent workflows when needed; never reset just one side
to hide an unexpected difference.

## Record

Copy [examples/scenario.mjs](examples/scenario.mjs) into the task directory and adapt
normal Playwright selectors, fixtures, and assertions. No special locator wrapper is needed.

- Implement the discovered, ordered workflow checklist as one shared scenario.
  Use the same viewport, inputs, settings, and files on both sides.
- Await every `step()` and `both()`. One distinct user action per `both()`.
- Check both targets' readiness before dispatching the actual action. Use
  `click({ trial: true })` on both when useful. Do not add forced clicks to bypass failures.
- Use state/visibility assertions for readiness, not sleeps. Shared pauses are only for readability.
- Assert actual field values, focused editable fields, and expected outcomes on BOTH sides.
  Both documents need focus; different internal DOM tags alone are not a regression.
- Stop on unexpected divergence. Keep failure screenshots/traces; report it rather than
  editing away the failure or resynchronizing by resetting only one side.

```sh
node <skill-dir>/scripts/record.mjs --scenario <task-dir>/scenario.mjs --out <task-dir>/NEW-capture
node <skill-dir>/scripts/export.mjs --out <task-dir>/NEW-capture
```

The recorder uses independent browser contexts/pages, focus emulation, paired actions,
and timestamped CDP captures. It waits for both initial frames. The exporter creates one
shared-timeline side-by-side MP4 and a chapter player. Do not replace this with independently
paced videos or a player that requires the user to manually line them up.

## Verify and deliver

First run a SHORT smoke scenario: open, fill both, submit, export, inspect. Use
`examples/serve.mjs` and `examples/scenario.mjs` to check the tool independently of the app.

Before a long recording, inspect that smoke MP4 for full-frame capture, readable labels,
matching text-field focus, visible input on both sides, and both submissions. Captions must
not cover essential controls. Then run the complete scenario.

Inspect the FINAL exported MP4—not just logs or screenshots—at initial input, first
submission, loading, completion, and near the end. Verify player seeking. Successful
automation is not sufficient proof of a useful visual comparison.

Deliver the main video link first, then the optional chapter player. Summarize actual
coverage and any genuine differences. State the preview/API limitations. Keep divergence
clips separate. Never claim behavioral equivalence just because the capture completed.

Run `npm test` after changing the bundled scripts. In Pi, use `/reload` after installing
or changing this skill.
