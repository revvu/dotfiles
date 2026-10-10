#!/usr/bin/env python3
"""Claude Code status line: shows the active model, its version/id, and
current context-window usage as a percentage.

Context data comes from the `context_window` block Claude Code passes on
stdin, which carries the model's real window size and current usage.
"""
import json
import sys


def human(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1000:.0f}k"
    return str(n)


def context_stats(data):
    """Return (used_tokens, window_size); window_size is None if absent."""
    cw = data.get("context_window") or {}
    window = cw.get("context_window_size")
    used = cw.get("total_input_tokens")
    if used is None:
        usage = cw.get("current_usage") or {}
        used = (
            usage.get("input_tokens", 0)
            + usage.get("cache_creation_input_tokens", 0)
            + usage.get("cache_read_input_tokens", 0)
        )
    return used, window


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        data = {}

    model = data.get("model", {}) or {}
    display_name = model.get("display_name") or model.get("id") or "unknown model"
    model_id = model.get("id") or ""

    parts = [f"\U0001f916 {display_name}"]
    if model_id and model_id != display_name:
        parts.append(f"({model_id})")

    used, window = context_stats(data)
    if window:
        pct = min(100, round(used / window * 100))
        parts.append(f"| ctx {human(used)}/{human(window)} ({pct}%)")

    print(" ".join(parts))


if __name__ == "__main__":
    main()
