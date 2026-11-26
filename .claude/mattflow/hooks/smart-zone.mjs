#!/usr/bin/env node
// UserPromptSubmit: warn when the session's context nears the dumb zone (~120-150k tokens).
// Reads the latest assistant usage from the transcript; warns once per 20k-token bucket.
import { existsSync, openSync, readSync, fstatSync, closeSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { readStdinJson, deferToProjectCopy } from '../lib/core.mjs';

if (deferToProjectCopy(import.meta.url, 'smart-zone.mjs')) process.exit(0);

const WARN = Number(process.env.MATTFLOW_SMART_ZONE_WARN || 120000);
const EDGE = Number(process.env.MATTFLOW_SMART_ZONE_EDGE || 150000);
const BUCKET = 20000;

const input = await readStdinJson();
const tokens = contextTokens(input.transcript_path);
if (!tokens || tokens < WARN) process.exit(0);

const stateFile = join(tmpdir(), `mattflow-smartzone-${String(input.session_id || 'x').replace(/[^\w-]/g, '')}.json`);
let state = {};
try { state = JSON.parse(readFileSync(stateFile, 'utf8')); } catch {}
const bucket = Math.floor(tokens / BUCKET);
if (state.bucket === bucket) process.exit(0);
try { writeFileSync(stateFile, JSON.stringify({ bucket })); } catch {}

const k = Math.round(tokens / 1000);
const zone = tokens >= EDGE ? 'past the smart-zone edge' : 'nearing the smart-zone edge';
process.stdout.write(JSON.stringify({
  systemMessage: `mattflow: context ~${k}k tokens (${zone}). At the next phase boundary: continue → /clear → /handoff → subagent → /compact <focus>.`,
  hookSpecificOutput: {
    hookEventName: 'UserPromptSubmit',
    additionalContext:
      `Context is ~${k}k tokens, ${zone} (~${EDGE / 1000}k). If this prompt starts a new phase, briefly recommend one move to the human, ` +
      'in this order: continue (next phase needs this one verbatim and fits), /clear (context irrelevant), /handoff (new harness/dir/person), ' +
      'subagent (task can run AFK), else /compact <focus>. Mid-phase: finish the phase and push exploration into subagents.',
  },
}));

function contextTokens(path) {
  if (!path || !existsSync(path)) return 0;
  const fd = openSync(path, 'r');
  try {
    const size = fstatSync(fd).size;
    const len = Math.min(size, 512 * 1024);
    const buf = Buffer.alloc(len);
    readSync(fd, buf, 0, len, size - len);
    const lines = buf.toString('utf8').split('\n').reverse();
    for (const line of lines) {
      if (!line.includes('"usage"')) continue;
      try {
        const u = JSON.parse(line)?.message?.usage;
        if (u) return (u.input_tokens || 0) + (u.cache_read_input_tokens || 0) + (u.cache_creation_input_tokens || 0);
      } catch {}
    }
    return 0;
  } finally { closeSync(fd); }
}
