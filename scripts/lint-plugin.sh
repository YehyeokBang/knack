#!/usr/bin/env bash
# knack plugin lint — catches drift the official `claude plugin validate` does not cover.
# Usage: ./scripts/lint-plugin.sh   (run from anywhere; cd's to repo root)
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
err() { echo "✘ $1"; FAIL=1; }
ok()  { echo "✓ $1"; }

PLUGIN_DIR="plugins/knack"
SKILLS_DIR="$PLUGIN_DIR/skills"

echo "== 1. README skill tables vs skills/ directory =="
SKILLS=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
for README in README.md README.ko.md "$PLUGIN_DIR/README.md"; do
  for s in $SKILLS; do
    grep -q "/knack:$s" "$README" || err "$README: skill '/knack:$s' missing from table"
  done
  for cmd in $(grep -o '/knack:[a-z0-9-]*' "$README" | sed 's|/knack:||' | sort -u); do
    [ -d "$SKILLS_DIR/$cmd" ] || err "$README: lists '/knack:$cmd' but skills/$cmd/ does not exist"
  done
done
[ "$FAIL" -eq 0 ] && ok "README tables in sync"

echo "== 2. plugin.json vs marketplace.json version sync =="
python3 - <<'PYEOF' || FAIL=1
import json, sys
pv = json.load(open("plugins/knack/.claude-plugin/plugin.json")).get("version")
mv = json.load(open(".claude-plugin/marketplace.json"))["plugins"][0].get("version")
if pv != mv:
    print(f"✘ version mismatch: plugin.json={pv} marketplace.json={mv}"); sys.exit(1)
print(f"✓ version sync: {pv}")
PYEOF

echo "== 3. SKILL.md line budget (<=500) =="
for f in "$SKILLS_DIR"/*/SKILL.md; do
  n=$(wc -l < "$f")
  if [ "$n" -gt 500 ]; then err "$f: $n lines (>500, split into references/)"; else ok "$f: $n lines"; fi
done

echo "== 4. SKILL.md frontmatter whitelist =="
python3 - <<'PYEOF' || FAIL=1
import glob, re, sys
ALLOWED = {"name","description","when_to_use","disable-model-invocation","user-invocable",
           "allowed-tools","disallowed-tools","context","model","effort","paths","hooks",
           "argument-hint","arguments","license"}
bad = False
for f in sorted(glob.glob("plugins/knack/skills/*/SKILL.md")):
    lines = open(f, encoding="utf-8").read().split("\n")
    if not lines or lines[0].strip() != "---":
        print(f"✘ {f}: missing frontmatter"); bad = True; continue
    keys = []
    for line in lines[1:]:
        if line.strip() == "---": break
        m = re.match(r"^([A-Za-z_-]+):", line)
        if m: keys.append(m.group(1))
    unknown = sorted(set(keys) - ALLOWED)
    if unknown:
        print(f"✘ {f}: non-standard frontmatter fields {unknown}"); bad = True
    else:
        print(f"✓ {f}: frontmatter ok")
sys.exit(1 if bad else 0)
PYEOF

echo "== 5. eval grader self-test (deterministic, no model calls) =="
if [ -f evals/run-graders.sh ]; then
  bash evals/run-graders.sh || FAIL=1
else
  echo "(evals/run-graders.sh 없음 — skip)"
fi

echo
if [ "$FAIL" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "LINT FAILED"; exit 1; fi
