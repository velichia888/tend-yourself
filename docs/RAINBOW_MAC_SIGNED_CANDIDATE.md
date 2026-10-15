# Rainbow Mac signed candidate using existing Tend signing identities

The read-only probe found matching Mac App Distribution and Mac Installer Distribution identities in Tend Yourself's encrypted `macos` Codemagic group. This manual workflow reuses those existing team identities for a **different bundle ID**—Rainbow of Serenity—without changing Tend Yourself's main branch or releases.

**Codemagic app:** Tend Yourself
**Branch:** `feat/rainbow-macos-signed-candidate-20261014`
**Workflow:** Rainbow macOS - signed candidate via Tend certificates
**Rainbow source commit:** `1b024e071e77987555a9b7d0aec6302ceeb21b4b` (pinned, never follows a moving branch)
**Expected package:** `RainbowOfSerenity-macOS-AppStore-candidate.pkg`

The workflow first fetches Rainbow's already existing Mac App Store provisioning profile with strict exact-bundle matching. If no such profile exists, it safely fails before signing; add the Rainbow-specific Mac App Store profile manually through Apple Developer with the existing Mac App Distribution certificate. Do not revoke Tend's certificates. No certificates or provisioning profiles are created, modified, or deleted by this workflow.

No Mac App Store upload, TestFlight submission, Apple notarization, or automatic triggers are enabled. The .pkg (if successful) will need signature verification, hands-on Mac acceptance, and outstanding Community moderation review before App Store submission. Secret keys and .p12 containers are not artifacts.

The original Rainbow test and preflight builds remain unchanged. The new Linux-generated Rainbow key does not match Apple's existing team distribution identity and is not used here.
