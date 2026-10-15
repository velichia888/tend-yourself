'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const yaml = fs.readFileSync('codemagic.yaml','utf8');
const bridge = (yaml.split('  rainbow-macos-upload-candidate:')[1] || '').split(/\n  (?=[a-z][a-z0-9-]*:)/)[0];

test('manual upload uses Tend existing signing credentials and independent workflow', () => {
  assert.match(bridge, /Rainbow macOS - upload signed candidate to App Store Connect \(no review\)/);
  assert.match(bridge, /feat\/rainbow-macos-upload-to-connect-20261014/);
  assert.match(bridge, /groups:\s*\n\s+- macos/);
  assert.match(bridge, /app_store_connect: myemptycloset-appstore/);
  assert.doesNotMatch(bridge, /\n    triggering:|\n    publishing:/);
});
test('same pinned Rainbow source and exact app-specific provisioning are used', () => {
  assert.match(bridge, /RAINBOW_SOURCE_COMMIT: "1b024e071e77987555a9b7d0aec6302ceeb21b4b"/);
  assert.match(bridge, /checkout --detach "\$RAINBOW_SOURCE_COMMIT"/);
  assert.match(bridge, /RAINBOW_BUNDLE_ID: "com.rainbowofserenity.companion"/);
  assert.match(bridge, /fetch-signing-files "\$RAINBOW_BUNDLE_ID"/);
  assert.match(bridge, /--strict-match-identifier/);
});
test('previously issued certificates only: no certificate or profile mutations', () => {
  assert.match(bridge, /certificates list --type MAC_INSTALLER_DISTRIBUTION --save/);
  assert.doesNotMatch(bridge, /--create\b|certificates create|certificates delete|profiles delete|--delete-stale-profiles/);
});
test('upload occurs after package build and uses package validation', () => {
  const buildPos = bridge.indexOf('bash macos/store/scripts/build-and-package.sh');
  const uploadPos = bridge.indexOf('app-store-connect publish --path "$PKG" --enable-package-validation');
  assert.ok(buildPos >= 0 && uploadPos > buildPos);
  assert.match(bridge, /PKG="\$CM_BUILD_DIR\/build\/rainbow-signed-candidate\/RainbowOfSerenity-macOS-AppStore-candidate\.pkg"/);
  assert.match(bridge, /test -s "\$PKG"/);
  assert.match(bridge, /env -u APP_STORE_CONNECT_SUBMIT_TO_APP_STORE/);
  assert.doesNotMatch(bridge, /^\s*app-store-connect publish.*(?:--app-store|--testflight)/m);
});
test('no app review or automatic submission is configured', () => {
  assert.doesNotMatch(bridge, /^\s*publishing:|^\s*triggering:|submit_to_app_store:|submit_to_testflight:/m);
  assert.doesNotMatch(bridge, /TendMac-Release|Tend\.xcodeproj/);
});
