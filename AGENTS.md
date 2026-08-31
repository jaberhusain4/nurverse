# NurVerse Coding Agent Instructions

## Autonomous execution

When given a coding task, work through the task to completion instead of stopping after analysis or presenting a proposed patch.

1. Inspect the relevant project code and search for duplicate or competing implementations before editing.
2. Make the smallest production-safe changes that fully solve the task.
3. Run the appropriate formatter, analyzer, tests, and validation commands.
4. If validation exposes errors, fix them and rerun validation.
5. Check the final diff for accidental changes, debug code, generated files, secrets, or unrelated edits.
6. Prefer existing NurVerse architecture and services over creating parallel implementations.
7. Preserve offline-first behavior for core Islamic functionality.
8. Preserve Bangla/English localization and existing theme conventions.
9. Do not stop merely because one model/provider fails or is rate-limited; continue using an available configured fallback when possible.
10. Only report the task as complete after the implementation and validation are actually finished.

## Prayer architecture

Prayer calculation must remain centralized through SettingsProvider, PrayerCalculationConfig, PrayerEngineService, and the active PrayerController flow. Do not introduce a second prayer-calculation pipeline or duplicate service for the same responsibility.

## Git discipline

Keep changes focused. Before finishing, run `git diff --check` and ensure the working tree contains only intentional changes. Commit completed work with a clear message when the task is explicitly delegated as an autonomous coding task.
