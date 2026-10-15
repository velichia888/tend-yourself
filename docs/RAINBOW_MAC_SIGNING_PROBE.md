# Rainbow macOS signing probe (Tend Yourself)

This is a read-only, manual experiment **inside Tend Yourself's Codemagic app**.
Branch: `chore/rainbow-macos-signing-probe-20261014`.
Workflow: **Rainbow macOS - existing certificate/key match (read-only)**.

It imports Tend Yourself's app-scoped encrypted `macos` group, including `CERTIFICATE_PRIVATE_KEY`, and asks Apple for existing **Mac App Distribution / Apple Distribution** and **Mac Installer Distribution** certificate details. It tests whether matching private-key-backed signing containers can be saved *locally*. It makes no Apple certificate creation, revocation, provisioning, submission or publication requests. Existing Tend release workflows remain unchanged.

Only `build/rainbow-macos-signing-probe/result.txt` is an artifact. The private key, the temporary certificate files and any .p12 data stay in a temporary directory removed when the step ends. The test does not fetch or run Rainbow source.

Success on **both** checks supports building a separate Rainbow signed candidate using this existing environment; one matching identity alone is insufficient to sign an installer. A negative or failed lookup is not permission to revoke Tend certificates. A later workflow must use a provisioning profile for Rainbow's own bundle ID, and still requires testing before App Review.
