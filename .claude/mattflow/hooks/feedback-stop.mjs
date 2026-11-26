#!/usr/bin/env node
// Stop: when code changed since the last green run, run the repo's feedback loops.
// Red → block the stop and hand the agent the failure tail. Capped per session so it can never loop forever.
import { join } from 'node:path';
import { readStdinJson, repoRoot, gitDir, resolveChecks, runChecks, worktreeFingerprint, readJson, writeJson, tail, deferToProjectCopy } from '../lib/core.mjs';

if (deferToProjectCopy(import.meta.url, 'feedback-stop.mjs')) process.exit(0);
if (process.env.MATTFLOW_SKIP_STOP === '1') process.exit(0);

const MAX_BLOCKS = Number(process.env.MATTFLOW_MAX_STOP_BLOCKS || 2);
const input = await readStdinJson();
const root = repoRoot(input.cwd || process.env.CLAUDE_PROJECT_DIR || process.cwd());
if (!root) process.exit(0);

const { cmds, timeoutSec } = resolveChecks(root, 'stop');
if (!cmds.length) process.exit(0);

const stateFile = join(gitDir(root) || join(root, '.git'), 'mattflow-state.json');
const state = readJson(stateFile, {});
const fp = worktreeFingerprint(root);
const session = String(input.session_id || 'unknown');
if (state.fp === fp) process.exit(0); // nothing changed since the last run (green or already reported)
if (state.base?.[session] === fp) process.exit(0); // this session hasn't changed anything yet

const results = runChecks(root, cmds, timeoutSec);
const failed = results.filter((r) => !r.ok && !r.skipped);
const skipped = results.filter((r) => r.skipped).map((r) => r.cmd);
const blocks = { ...(state.blocks || {}) };

if (!failed.length) {
  writeJson(stateFile, { ...state, fp, ok: true, at: new Date().toISOString(), blocks: {} });
  emit({ systemMessage: `mattflow: feedback loops green (${results.filter((r) => !r.skipped).map((r) => r.cmd).join(' · ') || 'nothing ran'})${skipped.length ? ` · skipped, tool not installed: ${skipped.join(' · ')}` : ''}` });
  process.exit(0);
}

const used = blocks[session] || 0;
const report = failed
  .map((r) => `### ${r.cmd} ${r.timedOut ? `(timed out after ${timeoutSec}s)` : 'failed'}\n${tail(r.out, 40)}`)
  .join('\n\n');

if (used >= MAX_BLOCKS) {
  // Give up blocking: remember this state so we don't re-run until code changes, and tell the human.
  writeJson(stateFile, { ...state, fp, ok: false, at: new Date().toISOString(), blocks });
  emit({ systemMessage: `mattflow: feedback loops still red after ${used} fix attempts: ${failed.map((r) => r.cmd).join(' · ')}. Left for you.` });
  process.exit(0);
}

blocks[session] = used + 1;
writeJson(stateFile, { ...state, fp: null, ok: false, at: new Date().toISOString(), blocks });
emit({
  decision: 'block',
  reason:
    `Feedback loops are red (attempt ${used + 1}/${MAX_BLOCKS}). Fix the cause, then finish. ` +
    'If the failure predates your change or needs a human decision, say so plainly instead of papering over it ' +
    '(no skipped tests, no `any`, no disabled rules).\n\n' + report,
});

function emit(obj) {
  process.stdout.write(JSON.stringify(obj));
}
