import Foundation
import LocalAuthentication

enum BiometricAuthResult {
    case success
    case failure
    /// No passcode is set on the device at all, so no policy could even
    /// be evaluated — treated as unlocked-with-a-banner by callers
    /// rather than a hard lock-out.
    case unavailable
}

protocol BiometricAuthenticating {
    func authenticate(reason: String) async -> BiometricAuthResult
}

/// Gates Journal content and "Clear All Data" behind Face ID/Touch ID
/// or the device passcode (`.deviceOwnerAuthentication`, not
/// biometrics-only) — if the device has no passcode configured at all,
/// evaluation itself isn't possible, so callers fall through to
/// unlocked with a one-time banner rather than permanently locking
/// someone out of their own journal.
struct BiometricAuthService: BiometricAuthenticating {
    func authenticate(reason: String) async -> BiometricAuthResult {
        #if DEBUG
        if ProcessInfo.processInfo.environment["IOS_TEST_AUTOMATION"] == "1",
           ProcessInfo.processInfo.environment["IOS_TEST_SKIP_FACEID"] == "1" {
            return .success
        }
        #endif

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .unavailable
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                continuation.resume(returning: success ? .success : .failure)
            }
        }
    }
}
