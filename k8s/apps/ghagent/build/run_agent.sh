#!/usr/bin/env bash
set -euo pipefail

# Install GitHub Actions Runner
# https://github.com/organizations/certusone/settings/actions/runners/new
#
# We do this at startup because GitHub keeps breaking backwards compatibility and
# forces us to always run the latest version.
#

# Get latest release of https://github.com/actions/runner or use GHA_RUNNER_VERSION if set.
if [ -z "${GHA_RUNNER_VERSION:-}" ]; then
  GHA_RUNNER_VERSION=$(curl -sL "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name')
fi

# Strip leading "v" from tag
GHA_RUNNER_VERSION=${GHA_RUNNER_VERSION#v}

curl -Lo /tmp/actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${GHA_RUNNER_VERSION}/actions-runner-linux-x64-${GHA_RUNNER_VERSION}.tar.gz && \
  tar -C /home/ci -xzf /tmp/actions-runner.tar.gz && rm /tmp/actions-runner.tar.gz

! cp /config/.credentials* /home/ci
! cp /config/.runner /home/ci

cd /home/ci

! ./config.sh \
  --url https://github.com/monogon-dev \
  --token "${GHA_TOKEN}" \
  --labels gha-trusted \
  --unattended \
  --disableupdate

cp /home/ci/.credentials* /config/
cp /home/ci/.runner /config/

./run.sh
