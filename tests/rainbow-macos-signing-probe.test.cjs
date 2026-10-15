'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const yaml = fs.readFileSync('codemagic.yaml', 'utf8');
const script = fs.readFileSync('ci/rainbow-macos-signing-probe.sh', 'utf8');
const probe = (yaml.split('  rainbow-macos-signing-probe:')[1] || '').split(/\n  (?=[a-z][a-z0-9-]*:)/)[0];

test('separate manual Tend workflow imports its existing macos secret group', () => {
  assert.match(probe, /name: Rainbow macOS - existing certificate\/key match \(read-only\)/);
  assert.match(probe, /chore\/rainbow-macos-signing-probe-20261014/);
  assert.match(probe, /app_store_connect: myemptycloset-appstore/);
  assert.match(probe, /groups:\s*\n\s+- macos/);
  assert.doesNotMatch(probe, /\n    publishing:|\n    triggering:/);
});
test('only existing Apple certificates are queried, no creates or revocations', () => {
  assert.match(script, /app-store-connect certificates list/);
  assert.match(script, /MAC_APP_DISTRIBUTION DISTRIBUTION/);
  assert.match(script, /MAC_INSTALLER_DISTRIBUTION/);
  assert.match(script, /--save/);
  assert.doesNotMatch(script, /\s--create\b|certificates create|certificates delete|profiles delete|fetch-signing-files/);
});
test('CI keeps private key and signing containers out of build artifacts', () => {
  assert.match(script, /CERTIFICATE_PRIVATE_KEY/);
  assert.match(script, /mktemp -d/);
  assert.match(script, /trap 'rm -rf "\$SCRATCH"' EXIT/);
  assert.match(script, /result\.txt/);
  assert.match(probe, /build\/rainbow-macos-signing-probe\/result\.txt/);
  assert.doesNotMatch(probe, /\.p12|\.pfx/);
});
