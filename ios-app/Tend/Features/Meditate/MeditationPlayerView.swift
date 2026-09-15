import SwiftUI

/// Foreground-only timer, deliberately descoped from background-audio
/// continuation (see plan risk #1) — auto-pauses whenever the app
/// backgrounds rather than half-building AVAudioSession support.
/// Elapsed time is computed from a wall-clock `endDate`, not a naive
/// per-tick counter, so a delayed tick never causes drift.
struct MeditationPlayerView: View {
    let session: MeditationSession
    let durationMinutes: Int

    @EnvironmentObject private var preferences: MeditationPreferencesStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    @State private var totalSeconds: Int
    @State private var remainingSeconds: Int
    @State private var endDate: Date?
    @State private var isRunning = false
    @State private var isComplete = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(session: MeditationSession, durationMinutes: Int) {
        self.session = session
        self.durationMinutes = durationMinutes
        let seconds = durationMinutes * 60
        _totalSeconds = State(initialValue: seconds)
        _remainingSeconds = State(initialValue: seconds)
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(session.title)
                    .font(Theme.Font.display(28))
                    .foregroundStyle(Theme.ink)
                Text(session.subtitle)
                    .font(Theme.Font.body(14))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                Circle().stroke(Theme.canvasSoft, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(FeatureCategory.mentalWellness.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                Text(timeString)
                    .font(Theme.Font.display(36))
                    .foregroundStyle(Theme.ink)
            }
            .frame(width: 220, height: 220)

            if isComplete {
                VStack(spacing: Theme.Spacing.md) {
                    Text("A little slower. A little kinder.")
                        .font(Theme.Font.script(22))
                        .foregroundStyle(Theme.accent)
                    Button("Done") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent)
                }
            } else {
                Button(action: toggleRunning) {
                    Label(playButtonTitle, systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(Theme.Font.headline(16))
                        .frame(maxWidth: 200)
                        .padding(.vertical, Theme.Spacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        #if os(iOS)
	.navigationBarTitleDisplayMode(.inline)
	#endif
        .onReceive(ticker) { _ in tick() }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background { pause() }
        }
        .onAppear {
            preferences.lastUsedDurationMin = durationMinutes
        }
    }

    private var playButtonTitle: String {
        if isRunning { return "Pause" }
        return remainingSeconds == totalSeconds ? "Start Breathing" : "Resume"
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / Double(totalSeconds)
    }

    private var timeString: String {
        String(format: "%d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    private func toggleRunning() {
        isRunning ? pause() : start()
    }

    private func start() {
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
    }

    private func pause() {
        isRunning = false
        endDate = nil
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        let remaining = Int(ceil(endDate.timeIntervalSinceNow))
        if remaining <= 0 {
            remainingSeconds = 0
            isRunning = false
            isComplete = true
            self.endDate = nil
        } else {
            remainingSeconds = remaining
        }
    }
}

#Preview {
    NavigationStack {
        MeditationPlayerView(session: MeditationCatalog.sessions[0], durationMinutes: 3)
            .environmentObject(MeditationPreferencesStore())
    }
}
