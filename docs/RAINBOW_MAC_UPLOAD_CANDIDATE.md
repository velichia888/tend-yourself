# Rainbow macOS upload to App Store Connect — controlled manual experiment

**Codemagic app:** Tend Yourself (because its existing `macos` secret group contains matching Mac distribution and installer signing private key).
**Branch:** `feat/rainbow-macos-upload-to-connect-20261014`
**Workflow:** **Rainbow macOS - upload signed candidate to App Store Connect (no review)**

This sibling workflow reproduces the already-qualified signed Mac candidate using the **same pinned Rainbow source commit** `1b024e071e77987555a9b7d0aec6302ceeb21b4b`, verifies code signing, saves the .pkg artifact, then uploads it through the Codemagic CLI:
```
app-store-connect publish --path "$PKG" --enable-package-validation
```
Upload is to App Store Connect for **processing only**. The command does **not** pass `--app-store` or `--testflight`; these are separate review submission actions per Codemagic CLI documentation. There is no YAML `publishing` section, no auto build triggers, and no beta distribution. The app will not become publicly available without additional deliberate action.

**Why rebuild?** Codemagic's previous run's artifacts do not automatically exist in subsequent isolated CI runs. A new signed package is built from the *same immutable source commit*, not fetched from the old run. Build results may differ in timestamps/bytes; verify this new artifact.

**Security and boundaries:** Tend Yourself's main branch and release workflows remain untouched. This bridge uses Apple certificates and app-specific Rainbow Mac provisioning profile that already exist. It does not create/revoke certificates or profiles, modify Apple's certificates, edit the existing Tend Yourself app, copy signing keys to Rainbow's repo, or upload macOS builds to Tend Yourself's store record.

**Preconditions:** An appropriate Mac platform app record must exist in App Store Connect for Rainbow's bundle ID, with API integration permission for upload. Apple may reject duplicates, unsupported app architecture, missing Mac platform, or metadata issues. A successful CLI upload does not mean Apple's processing has completed or Apple has reviewed/approved the app.

**Readout:** Report Codemagic's final upload log and inspect the Rainbow app's macOS build in App Store Connect. Do not submit to App Review pending macOS hands-on acceptance and Community moderation review.
