---
name: catch-me-up
description: Print Treadmill's health line and every need still open for Reevu, in one call to Treadmill's web app, with no clone. The Orchestrator on the server keeps the needs current. Use when he types /catch-me-up or asks what needs him, on the laptop (the Messenger runs it) or in the Orchestrator's session on the server.
---

# catch-me-up

1. Run `~/github/gallopify-playground/treadmill-main/bin/treadmill catch-up` (one call to the web app on the tailnet; it clones nothing and lists urgent first, then by stream, then oldest Since).
   No git runs before or during it.
   If the command is missing, that runner copy is older than the fast catch-up: say so and ask him to pull it once; do not pull it yourself.
2. Say the health line first, exactly as it comes, in one line.
   When it says `server unreachable`, add that nothing can be recorded until the server answers, and stop there.
3. Print every need with `for` reevu: urgent ones first, then grouped by stream. For each: what he decides or does (its first line), the working, the default (or "his to form" when it reads `Default: none`), the link, and since when. A need with an answer waiting reads "answered; the Orchestrator is on it", with his answer in one line.
4. Then one line counting the needs with `for` laptop, with their first lines, and offer to take them now.
5. Nothing else: no report of finished work, no history.

The three checks apply: show the working each need rests on in his terms; honour his lines; each item readable alone, never "as above".
He answers in this conversation; record each answer, verbatim, with one call: `~/github/gallopify-playground/treadmill-main/bin/treadmill need answer <slug> -`, his words on stdin and a last line `Settled with him: ...` only for what the conversation settled beyond them.
