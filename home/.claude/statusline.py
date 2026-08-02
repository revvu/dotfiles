#!/usr/bin/env python3
"""Claude Code status line: shows the active model, its version/id, and
current context-window usage as a percentage.

Context data comes from the `context_window` block Claude Code passes on
stdin (observed in v2.1.220), which carries the model's real window size
and current usage. Transcript parsing remains only as a fallback for
older Claude Code versions that omit that block.
"""
import json
import os
import sys


def human(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1000:.0f}k"
    return str(n)


def fallback_window_for(model_id):
    mid = (model_id or "").lower()
    if "1m" in mid:
        return 1_000_000
    return 200_000


def fallback_usage_from_transcript(transcript_path):
    if not transcript_path or not os.path.isfile(transcript_path):
        return 0
    try:
        with open(transcript_path, "r") as f:
            lines = f.readlines()
    except OSError:
        return 0
    for line in reversed(lines):
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        usage = (entry.get("message") or {}).get("usage")
        if usage:
            return (
                usage.get("input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
                + usage.get("cache_read_input_tokens", 0)
            )
    return 0


def context_stats(data):
    """Return (used_tokens, window_size) preferring harness-provided data."""
    cw = data.get("context_window") or {}
    window = cw.get("context_window_size")
    used = cw.get("total_input_tokens")
    if used is None:
        usage = cw.get("current_usage") or {}
        if usage:
            used = (
                usage.get("input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
                + usage.get("cache_read_input_tokens", 0)
            )
    if window and used is not None:
        return used, window

    model_id = (data.get("model", {}) or {}).get("id") or ""
    return (
        fallback_usage_from_transcript(data.get("transcript_path")),
        fallback_window_for(model_id),
    )


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        data = {}

    model = data.get("model", {}) or {}
    display_name = model.get("display_name") or model.get("id") or "unknown model"
    model_id = model.get("id") or ""

    used, window = context_stats(data)
    pct = min(100, round(used / window * 100)) if window else 0

    parts = [f"\U0001f916 {display_name}"]
    if model_id and model_id != display_name:
        parts.append(f"({model_id})")
    parts.append(f"| ctx {human(used)}/{human(window)} ({pct}%)")

    print(" ".join(parts))


if __name__ == "__main__":
    main()
