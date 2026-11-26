// Claude Code settings.json hook wiring shared by the global and per-repo installers.
export const HOOKS = [
  ['PreToolUse', 'Bash|PowerShell', 'git-guardrails.mjs', 15],
  ['SessionStart', null, 'session-context.mjs', 20],
  ['UserPromptSubmit', null, 'smart-zone.mjs', 10],
  ['Stop', null, 'feedback-stop.mjs', 900],
];

/** Remove any previous mattflow hook entries, then (unless remove) add the current ones. Other hooks are untouched. */
export function mergeHooks(settings, commandFor, remove = false) {
  const hooks = { ...(settings.hooks || {}) };
  for (const [event] of HOOKS) {
    if (!hooks[event]) continue;
    hooks[event] = hooks[event]
      .map((g) => ({ ...g, hooks: (g.hooks || []).filter((h) => !String(h.command || '').includes('mattflow/hooks/')) }))
      .filter((g) => g.hooks.length);
    if (!hooks[event].length) delete hooks[event];
  }
  if (!remove) {
    for (const [event, matcher, file, timeout] of HOOKS) {
      const group = { ...(matcher ? { matcher } : {}), hooks: [{ type: 'command', command: commandFor(file), timeout }] };
      hooks[event] = [...(hooks[event] || []), group];
    }
  }
  const next = { ...settings, hooks };
  if (!Object.keys(hooks).length) delete next.hooks;
  return next;
}
