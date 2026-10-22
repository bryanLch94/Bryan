#!/bin/bash
# Cloud environment setup: markitdown + auto-convert documents to Markdown.
# A non-zero exit would stop sessions from starting, so failures here are non-fatal.

# 1. Install markitdown with all format extras
pip install -q "markitdown[all]" || true

# 2. Hook script: PDFs read by Claude are converted to .md automatically
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/markitdown-read.sh <<'HOOK'
#!/bin/bash
# PreToolUse(Read): convert documents to Markdown with markitdown,
# then redirect Claude to read the generated .md file instead.
f=$(jq -r '.tool_input.file_path // empty')
[ -n "$f" ] && [ -f "$f" ] || exit 0
ext=$(printf '%s' "${f##*.}" | tr '[:upper:]' '[:lower:]')
case "$ext" in
  pdf|docx|doc|xlsx|xls|pptx|ppt|epub|msg) ;;
  *) exit 0 ;;
esac
md="${f%.*}.md"
# Reuse an existing conversion if it is newer than the source.
if [ ! -s "$md" ] || [ "$f" -nt "$md" ]; then
  markitdown "$f" -o "$md" 2>/dev/null || exit 0
fi
# Empty output (e.g. scanned PDF): fall back to the normal Read.
[ -s "$md" ] || exit 0
jq -n --arg md "$md" --arg f "$f" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Auto-converted " + $f + " to Markdown with markitdown. Read " + $md + " instead.")
  }
}'
HOOK
chmod +x ~/.claude/hooks/markitdown-read.sh

# 3. Register the hook in user settings (merge, don't overwrite)
s=~/.claude/settings.json
[ -s "$s" ] || echo '{}' > "$s"
jq '.hooks.PreToolUse = ((.hooks.PreToolUse // [])
      | map(select(.hooks[0].command != "~/.claude/hooks/markitdown-read.sh"))
      + [{"matcher":"Read","hooks":[{"type":"command","command":"~/.claude/hooks/markitdown-read.sh","timeout":120,"statusMessage":"Converting document to Markdown..."}]}])' \
  "$s" > "$s.tmp" && mv "$s.tmp" "$s"

# 4. Standing instruction for formats Read refuses before hooks run
if ! grep -q "## Documents → Markdown" ~/.claude/CLAUDE.md 2>/dev/null; then
  cat >> ~/.claude/CLAUDE.md <<'MD'

## Documents → Markdown
When you need to read a .docx, .doc, .xlsx, .xls, .pptx, .ppt, .epub or .msg file (e.g. one the user uploads), first convert it with `markitdown "<file>" -o "<same name>.md"` and read the .md. PDFs are converted automatically by a PreToolUse hook on Read (~/.claude/hooks/markitdown-read.sh).
MD
fi
