# Tend

A daily water-intake habit tracker. Log real water; watch a flower grow
over the day as a direct, deterministic reflection of how close you are
to your goal. Tend to your tasks, tend to yourself, tend to your garden.

See `docs/MVP_SCOPE.md` for the full scope and the (deliberate) decision
to ship this as a local-only app with no backend and no accounts, and
`docs/GROWTH.md` for the disclosed, transparent growth formula.

## Status

Local codebase only — not yet pushed to GitHub, deployed, or built via
CI. See `docs/DEVELOPMENT_PLAN.md` for what's been built and what's
explicitly stopped short of pending the next go-ahead.

## Building

```bash
xcodegen generate --spec ios-app/project.yml
```

Then open the generated `ios-app/Tend.xcodeproj` in Xcode, or use
`codemagic.yaml`'s `ios-simulator` workflow once this is pushed to a
repo Codemagic can see.
