#!/usr/bin/env python3
"""Cross-model trigger precision/recall for knack skills.

Runs `claude -p` headless, ISOLATED so only knack is loaded (--setting-sources
project drops user-scope plugins like zimssa/superpowers; --plugin-dir injects
knack), for each trigger case. Detects which skill auto-triggered by parsing the
`Skill` tool call from the stream-json trace — deterministic, no LLM judge.

Scores precision / recall / accuracy per (skill, model). This is the cross-model
SMOKE TEST: the floor model (haiku) is the gate.

Spike findings baked in (2026-06-10, claude 2.1.170):
  - Headless auto-trigger WORKS (contradicts claude-code #32184; likely fixed).
  - Without isolation, zimssa:handoff wins the "핸드오프" trigger — knack must be
    tested in isolation, AND that real-env collision is a precision risk to note.

Usage:
  evals/trigger_eval.py --models haiku,sonnet,opus [--repeat 1]
                        [--skills handoff,retune] [--limit N]
                        [--gate --min-recall 0.8 --min-precision 0.8 --gate-model haiku]
Exit 0 = pass (or no gate) · 1 = gate failed · 2 = harness error.
"""
import argparse, json, subprocess, sys, tempfile, shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
PLUGIN = REPO / "plugins" / "knack"
CASES = HERE / "cases"


def load_cases(skill, limit=None):
    f = CASES / skill / "trigger.jsonl"
    out = []
    for line in f.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            out.append(json.loads(line))
    return out[:limit] if limit else out


def loaded_skills(prompt, model, timeout=150):
    """Run one isolated claude -p; return the set of skill names loaded, or None on timeout/error."""
    scratch = tempfile.mkdtemp()
    try:
        cmd = ["claude", "-p", prompt,
               "--plugin-dir", str(PLUGIN), "--model", model,
               "--setting-sources", "project",
               "--output-format", "stream-json", "--verbose",
               "--permission-mode", "dontAsk"]
        p = subprocess.run(cmd, cwd=scratch, capture_output=True, text=True,
                           timeout=timeout, stdin=subprocess.DEVNULL)
        loaded = set()
        for line in p.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                o = json.loads(line)
            except json.JSONDecodeError:
                continue
            if o.get("type") == "assistant":
                for b in o.get("message", {}).get("content", []):
                    if b.get("type") == "tool_use" and b.get("name") == "Skill":
                        loaded.add(b.get("input", {}).get("skill", ""))
        return loaded
    except subprocess.TimeoutExpired:
        return None
    finally:
        shutil.rmtree(scratch, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--models", default="haiku")
    ap.add_argument("--skills", default="handoff,retune")
    ap.add_argument("--repeat", type=int, default=1)
    ap.add_argument("--limit", type=int, default=None, help="cap cases per skill (quick validation)")
    ap.add_argument("--gate", action="store_true")
    ap.add_argument("--min-recall", type=float, default=0.8)
    ap.add_argument("--min-precision", type=float, default=0.8)
    ap.add_argument("--gate-model", default="haiku")
    args = ap.parse_args()

    models = [m.strip() for m in args.models.split(",") if m.strip()]
    skills = [s.strip() for s in args.skills.split(",") if s.strip()]
    gate_fail = False

    for model in models:
        print(f"\n{'='*60}\nMODEL: {model}\n{'='*60}")
        for skill in skills:
            target = f"knack:{skill}"
            cases = load_cases(skill, args.limit)
            tp = fp = fn = tn = errors = 0
            for c in cases:
                expect_trig = c["expect"] == "trigger"
                fired_count = 0
                for _ in range(args.repeat):
                    got = loaded_skills(c["prompt"], model)
                    if got is None:
                        errors += 1
                        continue
                    if target in got:
                        fired_count += 1
                # majority vote across repeats
                fired = fired_count > args.repeat / 2
                mark = "?"
                if expect_trig:
                    if fired: tp += 1; mark = "TP"
                    else:     fn += 1; mark = "FN"
                else:
                    if fired: fp += 1; mark = "FP"
                    else:     tn += 1; mark = "TN"
                print(f"  [{mark}] expect={c['expect']:<10} fired={fired}  «{c['prompt'][:42]}»")
            prec = tp / (tp + fp) if (tp + fp) else 1.0
            rec = tp / (tp + fn) if (tp + fn) else 1.0
            total = tp + fp + fn + tn
            acc = (tp + tn) / total if total else 0.0
            print(f"  → {skill}: precision={prec:.2f} recall={rec:.2f} accuracy={acc:.2f} "
                  f"(TP{tp} FP{fp} FN{fn} TN{tn}, errors={errors})")
            if args.gate and model == args.gate_model:
                if rec < args.min_recall or prec < args.min_precision:
                    print(f"  ✘ GATE FAIL on {model}/{skill}: "
                          f"recall {rec:.2f}<{args.min_recall} or precision {prec:.2f}<{args.min_precision}")
                    gate_fail = True

    if args.gate:
        print("\n" + ("✘ TRIGGER GATE FAILED" if gate_fail else "✓ TRIGGER GATE PASSED"))
        return 1 if gate_fail else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
