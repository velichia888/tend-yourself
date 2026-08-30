# Tend — Growth Formula

This is the complete, disclosed formula behind Tend's flower. Like Car
Hopping's rarity score, it is transparent and deterministic on purpose —
never randomized, never hidden, always derived from real logged data.

## Daily progress

```
percentOfGoal = (today's logged ml ÷ today's goal ml) × 100
```

Computed fresh each calendar day (local device timezone), from the real
sum of every water-log entry timestamped within that day. There is no
carry-over, no bonus, no penalty — just today's real logged total against
today's real goal.

## Growth stages

| percentOfGoal | Stage         |
|---------------|---------------|
| 0%            | Seed          |
| 1–24%         | Sprout        |
| 25–49%        | Stem          |
| 50–74%        | Bud           |
| 75–99%        | Opening Bloom |
| 100%+         | Full Bloom    |

The flower always starts each day as a Seed and grows through these
stages purely as a function of that day's real logged total. It never
regresses within the same day (logging more water only ever moves the
stage forward or holds it steady — deleting a logged entry can move it
back, since the stage is recomputed live from current data, not cached).

## Garden and streaks

A day **qualifies** — plants a permanent flower in the Garden — only when
it reaches **Full Bloom (100%+)**. Qualifying days are the only input to:

- **Current streak**: consecutive qualifying days ending today (or
  ending yesterday, if today hasn't reached Full Bloom yet — today is
  still in progress and isn't counted as "broken" until it's over).
- **Longest streak**: the longest run of consecutive qualifying days in
  the user's entire logged history.

Both are computed live from real stored entries every time they're
displayed — never stored as a separate, driftable counter.

## Disclosure

Tend's Home screen carries a persistent line, matching the transparency
requirement every gimmick mechanic in this session's apps has had:

> "Your flower grows from water you actually log — no points, no
> shortcuts. Missing a day just means a fresh seed tomorrow."

## Known simplification

The goal used to evaluate a day is always the **current** goal setting,
not whatever goal was active when that day was logged (see
`MVP_SCOPE.md`). There is no per-day historical goal snapshot in v1.
