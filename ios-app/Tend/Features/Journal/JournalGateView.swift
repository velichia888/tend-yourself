import SwiftUI

/// Wraps JournalView behind Face ID/passcode. Re-locks whenever the app
/// backgrounds (if journalStore.lockEnabled), and falls through to
/// unlocked-with-a-banner rather than a hard lock-out if the device has
/// no passcode set at all (see BiometricAuthService).
struct JournalGateView: View {
    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var isUnlocked = false
    @State private var isAuthenticating = false
    @State private var showNoPasscodeBanner = false

    private let authService: BiometricAuthenticating

    init(authService: BiometricAuthenticating = BiometricAuthService()) {
        self.authService = authService
    }

    var body: some View {
        Group {
            if isUnlocked {
                JournalView()
            } else {
                lockedPlaceholder
            }
        }
        .onAppear(perform: attemptUnlock)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background, journalStore.lockEnabled {
                isUnlocked = false
            }
        }
    }

    private var lockedPlaceholder: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.accent)

            Text("Journal is locked")
                .font(Theme.Font.headline(20))
                .foregroundStyle(Theme.ink)

            if showNoPasscodeBanner {
                Text("Your device has no passcode set, so Tend can't verify it's you. Set a passcode in Settings to lock your journal.")
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
            }

            Button("Unlock", action: attemptUnlock)
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .disabled(isAuthenticating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
    }

    private func attemptUnlock() {
        guard journalStore.lockEnabled else {
            isUnlocked = true
            return
        }
        guard !isUnlocked, !isAuthenticating else { return }

        isAuthenticating = true
        Task {
            let result = await authService.authenticate(reason: "Unlock your journal")
            isAuthenticating = false
            switch result {
            case .success:
                isUnlocked = true
            case .failure:
                break
            case .unavailable:
                showNoPasscodeBanner = true
                isUnlocked = true
            }
        }
    }
}
