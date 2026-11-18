---
name: catch-me-up
description: Print every need still open for Reevu, from the tasks repo's needs/ folder, which the Shepard keeps current. Use when he types /catch-me-up or asks what needs him.
---

# catch-me-up

1. Run `bin/treadmill need list --json` in ~/github/gallopify-playground/treadmill (a fresh read of the tasks repo; it lists urgent first, then by stream, then oldest Since).
2. If needs-you/_treadmill-down.html exists in the tasks repo, or the need shepard-down is open, say that first, in one line.
3. Print every need with `for` reevu: urgent ones first, then grouped by stream. For each: what he decides or does (its first line), the working, the default (or "his to form" when it reads `Default: none`), the link, and since when. A need with an answer waiting reads "answered; the Shepard is on it", with his answer in one line.
4. Then one line counting the needs with `for` laptop, with their first lines, and offer to take them now.
5. Nothing else: no report of finished work, no history.

The three checks apply: show the working each need rests on in his terms; honour his lines; each item readable alone, never "as above".
He answers in this conversation; record each answer with `treadmill need answer` (orchestrate skill, "His answers").
