# Tend — MVP Scope

Tend is a daily water-intake habit tracker. Log real water you drink; a
flower grows over the course of the day as a direct, deterministic
reflection of how close you are to your goal. Tend to your tasks, tend to
yourself, tend to your garden.

## Architecture decision: local-only, no backend

Every other app built this session (myemptycloset, Car Hopping) started
with a real Node/Express/Prisma backend and real auth, verified via curl
before any iOS code was written. Tend deliberately breaks that pattern:

**Tend has no backend, no auth, and no network calls in v1.** All data
(water log entries, daily goal) is stored locally on-device as JSON.

Reasoning:
- This is a single-user personal habit tracker, not a marketplace. There
  is no second party to transact with, message, or browse listings from
  — the entire feature set (log water, watch a flower grow, see a
  streak) is meaningful for exactly one person on exactly one device.
- Real auth/backend would add real engineering cost (deployment, a
  database, session handling) with no corresponding feature benefit for
  v1. It would be complexity for its own sake, which the design
  principle applied throughout this session explicitly warns against.
- Health/habit data arguably belongs on-device by default; local-only
  is the more privacy-respecting default, not just the cheaper one.
- The "real, not fabricated" rule that governs every other app's
  gimmick mechanic (Car Hopping's rarity score, its pack-opening
  endpoint) is about the *data* being real and the *computation* being
  transparent and deterministic — not about where the computation runs.
  A local, deterministic function over real on-device logged entries
  satisfies that rule exactly as well as a server-side one would.

If a future version adds multi-device sync or account recovery, that's
exactly when a real backend earns its keep — not before.

## What's real in v1

- **Water logging**: user logs an amount (ml) at a timestamp. Stored as
  a plain array of entries in a local JSON file (`WaterLogStore`).
- **Daily goal**: a real, user-editable target in ml (default 2000ml),
  stored in `UserDefaults`.
- **Growth stage**: a pure, deterministic function of
  (today's logged total ÷ today's goal) — see `docs/GROWTH.md`. Never
  randomized, never client-side-only decoration disconnected from real
  data.
- **Garden / streak**: a day "qualifies" (plants a permanent flower in
  the garden) only when its real logged total reaches 100% of goal.
  Current streak and longest streak are computed from real qualifying
  days, not fabricated or seeded with fake history.

## What's explicitly NOT in v1 (and why)

- **No accounts, no sign-in, no multi-device sync** — see architecture
  decision above.
- **No push notifications / reminders** — a reminder toggle that
  doesn't actually schedule anything is exactly the kind of fake
  feature this session's apps have deliberately avoided. Real local
  notification scheduling is a real feature; it's just not v1.
- **No fake points/currency, no leaderboards, no social feed** — there's
  no second user for a leaderboard to compare against, and no real
  spend mechanic for a points currency to back.
- **No health or medical claims.** Tend is a hydration habit tracker,
  not a medical device. It never diagnoses, never gives medical
  hydration advice, and the goal is just a number the user sets for
  themselves.
- **No custom illustrated flower art / app icon yet** — v1 uses a
  simple hand-drawn vector flower mark (`FlowerMark.swift`, scales with
  bloom progress) and SF Symbols, matching how Car Hopping's first pass
  shipped with placeholder visuals before a real design pass.

## Known v1 simplification (documented, not hidden)

Changing the daily goal changes how *past* days are evaluated too —
there's no per-day historical goal snapshot. If you raise your goal
today, a previously-"bloomed" day could stop qualifying when
recomputed. This keeps the data model simple (one current goal, not a
goal-history table) at the cost of retroactively reinterpreting old
days. Worth revisiting if it turns out to feel unfair in practice.
