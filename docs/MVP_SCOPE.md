# Tend Yourself — Scope (v2)

Tend Yourself is a self-care companion: water intake, meditation, daily
tasks, medication tracking, a private journal, and mental-health
resources, in one place. "Small steps, brighter days" — every visual
(a growing flower, a completed checklist) is a direct, transparent
reflection of real data the user entered, never a fabricated or
decorative stand-in for it.

v1 was a single-purpose water tracker (see `GROWTH.md` for the growth
formula it still uses unchanged). v2 keeps that architecture decision
and its reasoning intact — local-only, no accounts, no backend — and
extends the same pattern across five more feature domains rather than
introducing a different one for each.

## Architecture decision: still local-only, no backend

**Tend has no accounts, no backend, and no network calls.** All data —
water log, tasks, medications, journal entries, support plan — is
stored locally on-device as JSON, one file per domain, following the
same `WaterLogStore` pattern v1 established.

This was re-examined, not just carried over, when v2's scope grew to
include real health-adjacent data (medication schedules, mood/journal
entries): the reasoning still holds. There's no second party to sync
with, health/journal data arguably belongs on-device by default, and a
real backend would add real engineering cost with no feature benefit
today. If multi-device sync or account recovery is ever wanted, that's
when a backend earns its keep — not before.

## Tab structure

Five tabs: **Home, Meditate, Tasks, Journal, You**. Water/Garden,
Medication, and Resources are deliberately not tabs — they're reached
from Home's glance row / Today's plan list, and from Hard Day Mode —
keeping the tab bar from being crowded as the feature set grew.

## What's real

- **Water, growth, and garden** — unchanged from v1. See `GROWTH.md`.
  Now reached from Home rather than being its own tab.
- **Tasks** — real recurring routines (`TaskEngine.rollForward`
  materializes today's instance of a daily task; it never backfills
  missed days, so a gap never builds an overwhelming backlog).
- **Medication** — real schedule, real Taken/Later/Skip status per
  dose, real refill tracking. Tend only records what the user tells
  it — it never infers, suggests, or second-guesses a dose (see the
  `MedicationCopy.disclosure` string, shown wherever medication status
  appears).
- **Journal** — real mood/energy/sleep entries, gated behind Face ID,
  Touch ID, or the device passcode (never biometrics-only — a device
  with no passcode at all falls through to unlocked-with-a-banner
  rather than a permanent lock-out).
- **Notifications** — real, per-category local reminders (water,
  medication, refill, tasks, meditation, daily check-in), each
  independently toggleable. A "Later" on a medication dose only ever
  changes that dose's status; it does not silently pretend to schedule
  a reminder that doesn't exist.
- **Hard Day Mode** — a simplified checklist wired to the same real
  stores as everywhere else (checking "drink water" there calls the
  same `WaterLogStore.logWater` Home and Water do) — not a separate,
  disconnected set of fake progress.

## What's explicitly NOT in v1 of this expansion (and why)

- **No accounts, no sign-in, no multi-device sync** — see above.
- **No fake points/currency, no leveling, no leaderboards.** The
  garden/streak mechanic is motivational, never competitive, and never
  punishes a missed day — see `GROWTH.md`'s disclosure text.
- **No background-audio meditation timer.** The timer is foreground-
  only (auto-pauses when the app backgrounds) — a real
  background-continuing, `AVAudioSession`-backed timer is a materially
  bigger feature than a foreground countdown and was deliberately
  descoped rather than half-built.
- **No health or medical claims, ever.** Medication tracking is a
  record-keeping tool, not a clinical one. Resources are supportive/
  educational content, not diagnosis or treatment — the one exception
  is the always-visible, non-alarmist crisis card (call/text 988),
  which stays present without making every ordinary low mood feel like
  a crisis.
- **No onboarding flow yet.** Every store just starts empty; there's no
  guided first-run setup (name, feature selection, goals) yet.
- **No data export.** "Clear All Data" (Face ID/passcode-gated, since
  it can destroy journal entries) is the only bulk data control today.
- **No custom illustrated app icon yet** for the v2 branding — the
  existing v1 flower+droplet icon is still in place pending a real
  asset pass.

## Known v1 simplification (documented, not hidden)

Changing the daily water goal changes how *past* days are evaluated
too — there's no per-day historical goal snapshot. This is unchanged
from v1; see `GROWTH.md` for the full explanation.
