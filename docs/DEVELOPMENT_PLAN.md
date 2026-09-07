# Tend Yourself — Development Plan

## v1 (water tracker) — done

See git history before the v2 rebuild commit for the original 9-step
plan. `GrowthEngine`/`GardenEngine` and their tests are unchanged by
v2; the rest of v1's Home/Garden/Settings screens were reskinned or
relocated rather than rebuilt from scratch (Water/Garden moved under
`Features/Water/`, Settings became `Features/You/YouView.swift`).

## v2 (self-care companion rebuild) — done in this pass

Real product scope, driven by a set of ChatGPT-generated UI mockups
("Small Steps, Brighter Days" cream/forest-green botanical style — see
`MVP_SCOPE.md`), treated as visual references rather than exact specs:
generated-image inconsistencies (fake dates, a tab bar that disagreed
with itself across different mockup images, an account+XP progression
system that contradicted this app's existing no-fake-progress
philosophy) were resolved against the canonical architecture rather
than reproduced literally.

Build order actually followed:

1. Design system: `Theme.swift` re-toned to cream/forest-green;
   `FeatureCategory.swift` (the category-color system); botanical
   `Shape`s (`LeafSprigMark`, `VineDividerMark`, `BotanicalFrame`),
   hand-vectored like `FlowerMark` rather than image assets;
   `IconBadge`/`IconBadgeCard` (the one reusable row component); a
   bundled Caveat script font (`Theme.Font.script`) alongside a
   system-serif `Theme.Font.display`.
2. Models + pure engines + tests, mirroring `GrowthEngine`/
   `GardenEngine`'s style: `TaskItem`/`TaskEngine` (recurrence
   expansion that never backfills missed days), `Medication`/
   `MedicationLogEntry`/`MedicationEngine` (dose expansion, refill
   check). `JournalEntry`, `MeditationSession`, `ResourceCategory`,
   `SupportContact`/`SupportPlan` needed no separate engine — just
   date filtering or static content.
3. Stores, one per domain, all following `WaterLogStore`'s JSON-in-
   Documents (+ UserDefaults for settings) pattern: `TaskStore`,
   `MedicationStore`, `JournalStore`, `SupportPlanStore`.
   `MeditationPreferencesStore`/`NotificationPreferencesStore` are
   UserDefaults-only, a deliberate exception since neither has a
   growing log to persist.
4. `BiometricAuthService` (Face ID/Touch ID/passcode via
   `.deviceOwnerAuthentication`, falling through to
   unlocked-with-a-banner if no passcode exists) + `JournalGateView`.
5. `NotificationService` (thin `UNUserNotificationCenter` wrapper) +
   `NotificationPreferencesStore` (per-category toggles/times) +
   `NotificationCoordinator` (Combine-driven sync from stores/prefs to
   scheduled notifications) — added mid-build after the user
   reprioritized real notification scheduling into this same pass
   rather than a follow-up.
6. Feature screens: Water/Garden reskin → Home (aggregates Tasks +
   Medication into one chronological "Today's plan", mood check-in,
   glance row, Hard Day Mode entry) → Tasks → Medication → Resources
   (crisis card, My Support Plan) → Hard Day Mode (wired to the real
   stores) → Meditate (foreground-only timer) → Journal → You (renamed
   from Settings; notification settings, Face ID toggle, Face
   ID-gated "Clear All Data" covering every store).
7. Navigation: real 5-tab `MainTabView` (Home, Meditate, Tasks,
   Journal, You); `RootView` extended with a DEBUG-only deep-screen
   presenter for the screens that are no longer tabs.
8. CI automation extension: `IOS_TEST_INITIAL_TAB` now covers 5 tabs;
   new `IOS_TEST_DEEP_SCREEN` and `IOS_TEST_SKIP_FACEID` env vars;
   `codemagic.yaml`'s `capture_tab`/`capture_deep_screen` produce 10
   screenshots per build.
9. Docs rewrite (this pass): `ARCHITECTURE.md`, `MVP_SCOPE.md`,
   `GROWTH.md` (relocation note only — formula unchanged),
   `DEVELOPMENT_PLAN.md`.

Verified via a real Codemagic `ios-simulator` run (no local Xcode on
this machine) rather than just a self-review pass — same constraint
v1 had, resolved the same way.

## Explicitly stopped short of, pending user go-ahead

- No onboarding flow (name/nickname, feature selection, goals).
- No data export — "Clear All Data" (reset) exists; export doesn't yet.
- No new app icon for the v2 branding — v1's flower+droplet icon is
  still in place.
- No background-audio meditation timer — foreground-only, deliberately
  descoped rather than half-built (see `MVP_SCOPE.md`).

## Deferred to a later phase

- Onboarding + data export, once prioritized.
- A real illustrated app icon and any further illustration pass beyond
  the hand-vectored botanical Shapes already in place.
- Background-continuing meditation audio, if ever wanted.
- Deeper garden progression / analytics — the user's own instruction
  for this pass was to prioritize Home/Tasks/Water/Medication/
  Meditation/Journal/Resources/Hard-Day-Mode/notifications/persistence
  first and treat garden depth and analytics as follow-ups.
