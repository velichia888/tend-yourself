# Tend — Architecture

Single-target native iOS app. No backend, no network stack, no auth —
see `MVP_SCOPE.md` for why.

```
ios-app/
  project.yml              XcodeGen spec (no hand-maintained .xcodeproj)
  Tend/
    App/
      TendApp.swift         @main entry point
      Info.plist            hand-written (GENERATE_INFOPLIST_FILE: NO)
    Models/
      WaterLogEntry.swift    Codable log entry (id, amountML, loggedAt)
      GrowthStage.swift      Seed...Full Bloom enum
    Services/
      GrowthEngine.swift     pure functions: percent -> stage, day qualifies
      GardenEngine.swift     pure functions: streak/longest-streak from
                              a set of qualifying days
    Storage/
      WaterLogStore.swift    ObservableObject; loads/saves entries as
                              JSON in the app's Documents directory;
                              daily goal in UserDefaults
    Shared/
      Theme.swift
      Components/
        FlowerMark.swift     vector Shape, bloom fraction -> flower shape
        FlowerView.swift     FlowerMark + stage color/label
    Features/
      Root/
        RootView.swift
        MainTabView.swift    tabs: Home, Garden, Settings
      Home/
        HomeView.swift       today's flower, log-water controls, streak
      Garden/
        GardenView.swift     calendar grid of qualifying days
      Settings/
        SettingsView.swift   edit daily goal, clear data
    Assets.xcassets/
  TendTests/
    GrowthEngineTests.swift  XCTest, mirrors carhopping's rarity.test.ts
                              pattern (boundary cases per stage)
```

## Deployment target and known iOS 16 pitfalls

`IPHONEOS_DEPLOYMENT_TARGET: 16.0`, same as myemptycloset and Car
Hopping, and the same pitfalls already burned through twice this session
apply and were checked for here:

- No `navigationDestination(item:)` (iOS 17+) — Tend's navigation is
  shallow enough (three flat tabs, no push-based detail screens) that
  this doesn't come up at all in v1.
- `ForEach` over the `GrowthStage`/day-grid views uses `id: \.self` or a
  real `Identifiable` (`WaterLogEntry` has a real `id: UUID`).
- `.onChange(of:)` uses the single-parameter iOS 16 closure form
  everywhere.
- `GENERATE_INFOPLIST_FILE: NO` + hand-written `Info.plist` with the
  five manually-declared keys Xcode would otherwise auto-inject.

## No Keychain, no CI auth workaround needed

Every other app in this session needed a DEBUG-only in-memory-session
fallback because Codemagic's cloud simulator can't write to Keychain.
Tend has no login and no Keychain usage at all, so that entire class of
CI problem doesn't exist here. The CI script only needs to wait for a
single `IOS_TEST_APP_LAUNCHED` print marker before screenshotting.
