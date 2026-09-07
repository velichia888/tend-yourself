# Tend Yourself — Architecture

Single-target native iOS app. No backend, no network stack, no auth —
see `MVP_SCOPE.md` for why.

```
ios-app/
  project.yml                 XcodeGen spec (no hand-maintained .xcodeproj)
  Tend/
    App/
      TendApp.swift            @main entry point; owns every store +
                                NotificationCoordinator, injects them via
                                .environmentObject
      Info.plist               hand-written (GENERATE_INFOPLIST_FILE: NO)
    Resources/
      Fonts/
        Caveat-Regular.ttf     bundled OFL script font (registered via
                                Info.plist's UIAppFonts)
    Models/                    Codable structs/enums, one file per domain
      WaterLogEntry.swift, GrowthStage.swift
      TaskItem.swift, Medication.swift, MedicationLogEntry.swift
      JournalEntry.swift, MeditationSession.swift
      ResourceCategory.swift, SupportContact.swift, SupportPlan.swift
    Content/                   static, unpersisted catalog data
      MeditationCatalog.swift, ResourceCatalog.swift
    Services/                  pure functions/testable logic, or a thin
                                system-framework wrapper — never SwiftUI
      GrowthEngine.swift, GardenEngine.swift   (v1, unchanged)
      TaskEngine.swift, MedicationEngine.swift  (pure, tested)
      BiometricAuthService.swift               (LocalAuthentication wrapper)
      NotificationService.swift                (UNUserNotificationCenter wrapper)
      NotificationCoordinator.swift            (Combine: stores + prefs -> scheduled notifications)
    Storage/                   ObservableObject stores, one per domain,
                                all following WaterLogStore's pattern:
                                JSON-in-Documents for logs, UserDefaults
                                for settings/preferences
      WaterLogStore.swift, TaskStore.swift, MedicationStore.swift,
      JournalStore.swift, MeditationPreferencesStore.swift (UserDefaults-only —
      no growing log exists for Meditation), SupportPlanStore.swift
      (persists a single SupportPlan struct, not an array),
      NotificationPreferencesStore.swift (UserDefaults-only)
    Shared/
      Theme.swift              colors/spacing/radii/typography/cardStyle
      FeatureCategory.swift    category-color system (sage/coral/sky/
                                lavender/golden-yellow/soft-peach), reused
                                by IconBadge/IconBadgeCard everywhere
      Components/
        FlowerMark.swift, FlowerView.swift        (v1, unchanged)
        IconBadge.swift, IconBadgeCard.swift       (v2's one reusable
                                                     "icon + title/subtitle
                                                     + trailing" row)
        Botanical/
          LeafSprigMark.swift, VineDividerMark.swift, BotanicalFrame.swift
    Features/
      Root/
        RootView.swift          also hosts CI-only deep-screen presentation
        MainTabView.swift        tabs: Home, Meditate, Tasks, Journal, You
      Home/
        HomeView.swift           aggregates today's Tasks + Medication doses
                                  into one chronological list; mood check-in;
                                  glance row (Water/Meds/Tasks); Hard Day Mode
                                  entry point
      Meditate/
        MeditateView.swift, MeditationPlayerView.swift  (foreground-only timer)
      Tasks/
        TasksView.swift, AddTaskView.swift
      Medication/
        MedicationView.swift, AddMedicationView.swift, MedicationHistoryView.swift
      Journal/
        JournalGateView.swift    (Face ID/passcode gate), JournalView.swift
      Resources/
        ResourcesView.swift, ResourceDetailView.swift, SupportPlanView.swift
      Water/                     reached from Home, no longer a tab
        WaterView.swift (was Home/HomeView.swift in v1), GardenView.swift
      HardDay/
        HardDayModeView.swift    wired to the real stores, not fake progress
      You/
        YouView.swift (was Settings/SettingsView.swift), NotificationSettingsView.swift
    Assets.xcassets/
  TendTests/
    GrowthEngineTests.swift, GardenEngineTests.swift   (v1, unchanged)
    TaskEngineTests.swift, MedicationEngineTests.swift  (v2, same
                                                          boundary-case style)
```

## Deployment target and known iOS 16 pitfalls

`IPHONEOS_DEPLOYMENT_TARGET: 16.0`. Pitfalls checked for as the
navigation grew from three flat tabs to five tabs plus pushed detail
screens:

- No `navigationDestination(item:)` (iOS 17+) — `NavigationLink`s push
  simple root destinations directly; anything needing a
  `navigationDestination(for:)`-style route enum would use that
  (iOS-16-safe), not the `item:` variant.
- `ForEach` uses a real `Identifiable` (`TaskItem`, `MedicationEngine.Dose`,
  etc. all have a real `id`) or `id: \.self` for value types.
- `.onChange(of:)` uses the single-parameter iOS 16 closure form
  everywhere, including the new `scenePhase` observers in
  `JournalGateView` and `MeditationPlayerView`.
- `GENERATE_INFOPLIST_FILE: NO` + hand-written `Info.plist`, now with
  two usage-adjacent additions beyond v1's five Xcode-mandatory keys:
  `NSFaceIDUsageDescription` (Journal's lock) and `UIAppFonts` (the
  bundled Caveat font). Local notifications need neither an
  Info.plist key nor an entitlement.

## Face ID and notifications in CI: the same class of problem, twice

v1's note that Tend had no Keychain/auth CI workaround to worry about no
longer holds now that Journal is Face ID-gated and notifications request
authorization. An unhandled system permission/biometric prompt on
Codemagic's unattended cloud simulator would hang the whole screenshot
workflow until timeout, not just fail one screenshot — so both
`BiometricAuthService.authenticate` and `NotificationService.requestAuthorization`
check for `IOS_TEST_AUTOMATION=1` + a skip flag (`IOS_TEST_SKIP_FACEID`
for the former; the latter simply returns `true` without ever calling
the real API under automation) and short-circuit before either system
prompt can appear. `codemagic.yaml` sets
`SIMCTL_CHILD_IOS_TEST_SKIP_FACEID="1"` unconditionally on every launch,
not just Journal's, so a future tab reorder can't silently reintroduce
the hang.

## CI screenshot automation: tabs and non-tab "deep screens"

The v1 pattern — `TendApp.swift`'s `.task` block reads DEBUG-only env
vars to print an `IOS_TEST_APP_LAUNCHED` marker, preset the selected
tab, and seed fixture data once — is extended, not replaced:

- `IOS_TEST_INITIAL_TAB` now ranges 0–4 for the five tabs.
- `IOS_TEST_DEEP_SCREEN` (read by `RootView`, DEBUG-only) presents
  Medication/Resources/Water/Garden/Hard-Day-Mode via a
  `.fullScreenCover(item:)`, since none of them are tabs anymore and
  there's no XCUITest/idb set up to drive real UI taps in CI.
- `codemagic.yaml`'s `capture_tab()`/`capture_deep_screen()` bash
  functions launch the app once per screen with the matching
  `SIMCTL_CHILD_IOS_TEST_*` env vars, producing 10 screenshots per
  build (5 tabs + 5 deep screens).
