# Tend — Development Plan

1. Docs (this pass): `ARCHITECTURE.md`, `MVP_SCOPE.md`, `GROWTH.md`,
   `DEVELOPMENT_PLAN.md` — done.
2. Models + pure engines: `WaterLogEntry`, `GrowthStage`,
   `GrowthEngine`, `GardenEngine`. Unit-testable with no I/O.
3. `GrowthEngineTests.swift` — boundary cases per stage, streak/longest
   streak cases, mirroring `rarity.test.ts`'s style. Written now; not
   yet executed (no local Xcode on this machine — same constraint every
   other iOS target in this session has had. Real feedback comes from
   the first Codemagic `ios-simulator` run).
4. `WaterLogStore` — local JSON persistence + daily goal in
   `UserDefaults`.
5. Shared UI: `Theme.swift`, `FlowerMark` (vector shape), `FlowerView`.
6. Features: Home (log water, see today's flower + streak), Garden
   (calendar grid of qualifying days), Settings (edit goal, clear
   data), Root/MainTabView.
7. `project.yml` + hand-written `Info.plist`, mirroring the exact
   hard-won settings from myemptycloset/Car Hopping.
8. `codemagic.yaml`: `ios-simulator` (XcodeGen → build → boot sim →
   launch → wait for `IOS_TEST_APP_LAUNCHED` → screenshot) and
   `ios-device-unsigned` (unsigned .ipa for Sideloadly), same proven
   shape as the other two apps' configs, simplified since there's no
   backend to pre-warm and no login to wait on.
9. Self-review every Swift file against the known iOS16/SwiftUI
   pitfalls list before calling it done (see `ARCHITECTURE.md`).

## Explicitly stopped short of, pending user go-ahead

- No GitHub repo created, no push.
- No Codemagic build triggered.
- No Render/backend deployment (there is no backend).
- No real app icon / illustrated flower art — placeholder vector mark
  and SF Symbols only.
- No push notifications — real local notification scheduling is a
  legitimate future feature, just not built now (see `MVP_SCOPE.md`).

## Deferred to a later phase

- Optional real backend + auth, only if/when multi-device sync or
  account recovery is actually wanted.
- Local notification reminders (real scheduling, not a fake toggle).
- Illustrated flower/garden art once the user provides real design
  mockups, the same way myemptycloset and Car Hopping got a visual
  pass after their first working builds.
