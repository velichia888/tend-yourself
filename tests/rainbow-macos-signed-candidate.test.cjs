'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const yaml = fs.readFileSync('codemagic.yaml','utf8');
const bridge = (yaml.split('  rainbow-macos-signed-candidate:')[1] || '').split(/\n  (?=[a-z][a-z0-9-]*:)/)[0];

test('candidate uses Tend signing environment but cannot change existing releases',()=>{
  assert.match(bridge,/Rainbow macOS - signed candidate via Tend certificates/);
  assert.match(bridge,/feat\/rainbow-macos-signed-candidate-20261014/);
  assert.match(bridge,/app_store_connect: myemptycloset-appstore/);
  assert.match(bridge,/groups:\s*\n\s+- macos/);
  assert.doesNotMatch(bridge,/\n    publishing:|\n    triggering:/);
});
test('source pinned to reviewed Rainbow commit',()=>{
  assert.match(bridge,/RAINBOW_SOURCE_COMMIT: "1b024e071e77987555a9b7d0aec6302ceeb21b4b"/);
  assert.match(bridge,/git clone --no-checkout https:\/\/github\.com\/velichia888\/rainbow-of-serenity-slaa\.git/);
  assert.match(bridge,/checkout --detach "\$RAINBOW_SOURCE_COMMIT"/);
  assert.match(bridge,/ACTUAL/);
});
test('uses exact profile and existing certs without creating or revoking',()=>{
  assert.match(bridge,/fetch-signing-files "\$RAINBOW_BUNDLE_ID"/);
  assert.match(bridge,/--platform MAC_OS/);
  assert.match(bridge,/--type MAC_APP_STORE/);
  assert.match(bridge,/--strict-match-identifier/);
  assert.match(bridge,/certificates list --type MAC_INSTALLER_DISTRIBUTION --save/);
  assert.doesNotMatch(bridge,/--create\b|certificates create|certificates delete|profiles delete|--delete-stale-profiles/);
});
test('only signed Rainbow pkg and entitlements are uploaded as artifacts',()=>{
  assert.match(bridge,/build-and-package\.sh/);
  assert.match(bridge,/RainbowOfSerenity-macOS-AppStore-candidate\.pkg/);
  assert.match(bridge,/signed-entitlements\.plist/);
  assert.match(bridge,/env -u CERTIFICATE_PRIVATE_KEY -u APP_STORE_CONNECT_PRIVATE_KEY/);
  assert.doesNotMatch(bridge,/TendMac-Release|Tend\.xcodeproj|submit_to_testflight|submit_to_app_store/);
});
