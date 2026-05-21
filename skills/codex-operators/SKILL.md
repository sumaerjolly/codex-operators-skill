---
name: codex-operators
description: Launch and operate Codex Operators, an interactive Codex-native training game. Use when the user asks to start Codex Operators, install or open the trainer, learn Codex through missions, create the Desktop Field Kit, run the local verifier, or continue a Codex Operators mission.
---

# Codex Operators

Use this skill to make Codex Operators feel native inside Codex. The user should not need to understand git, npm, Vite, local servers, or project setup before the interactive trainer opens.

This skill is the launcher and operator helper. The interactive trainer app is the mission control surface, and the Desktop Field Kit is the learner's practice workspace.

## Start Workflow

1. Find or create the local trainer repo.
   - If the current workspace is already the trainer repo, use it.
   - Otherwise look for `codex-operators-interactive` or `codex-interactive` in common project folders such as Desktop, Documents, and `~/Desktop/fun-projects`.
   - If no local copy exists, clone `https://github.com/sumaerjolly/codex-operators-interactive.git` into a sensible project folder.
2. From the trainer repo root, install dependencies with `npm install` if `node_modules` is missing.
3. Create or refresh the Desktop Field Kit:
   - Target: `~/Desktop/Codex Operators Field Kit`
   - The Field Kit is the user-facing practice workspace.
   - Preserve user outputs unless the user explicitly asks to reset the run.
4. Start the trainer app with `npm run dev`.
   - Keep the dev server running.
   - Read the printed localhost URL. It usually starts at `http://localhost:3000`.
5. Open the localhost URL in the Codex in-app browser when Browser is available.
6. Tell the user:
   - The browser is mission control.
   - Codex chat is where they run mission prompts.
   - The Desktop Field Kit is where practice files and proof artifacts live.

## Reset Workflow

When the user asks to restart, reset, or start from scratch:

1. Use the trainer app reset route if the local server is running: open `http://localhost:3000/?reset=1` or the active localhost port with `?reset=1`.
2. If the server is not running, start it first with `npm run dev`, then open the reset URL.
3. Explain that reset clears generated proof artifacts and progress but keeps the trainer code.

## Mission Workflow

When the user is completing a mission:

1. Read the current mission instructions from the browser app or mission prompt.
2. Do the requested real work in Codex.
3. Write proof artifacts exactly where the mission asks.
4. Keep original sample inputs unchanged unless the mission explicitly asks to modify them.
5. Return to the browser app and run verification, or tell the user to click the verifier button.

## Positioning

Use this wording with beginners:

- Codex Operators is a skill that opens an interactive learning game.
- The browser app gives the missions.
- Codex does the work.
- The Desktop Field Kit is the practice workspace.
- Proof files are how the app knows the work happened.

Avoid telling beginners to clone repos, run npm commands, or reason about implementation details unless setup breaks and they need a plain-English repair.
