# Codex Operators Skill

Install this skill in Codex to launch Codex Operators as a native-feeling training game.

This repo is only the skill launcher. The interactive trainer app lives separately, and the skill handles the boring setup: finding or installing the trainer, preparing the Desktop Field Kit, starting the local proof lab, and opening the mission screen.

```text
npx skills add https://github.com/sumaerjolly/codex-operators-skill --skill codex-operators
```

Then run:

```text
$codex-operators
```

The skill prepares the local trainer, creates the Desktop Field Kit, starts the app, and opens the interactive mission screen.

Beginner promise: the learner should paste one setup message into Codex, then learn from the browser mission screen while Codex creates real proof files locally.
