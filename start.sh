#!/bin/bash
# FILE: start.sh
set -e

# The token works with "Read and Write" access to organization "administration" and organization "self hosted runners"

# Validate input variables
if [ -z "$RUNNER_TYPE" ] || [ -z "$REPO_URL" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "=x= Error: RUNNER_TYPE, REPO_URL, and GITHUB_TOKEN must be set"
    exit 1
fi

echo "Extracting target identifier..."
TARGET_PATH=$(echo "$REPO_URL" | sed 's|https://github.com/||' | sed 's|/$||')

# Select API path based on explicit type variable
if [ "$RUNNER_TYPE" = "org" ]; then
    echo "Configuring as an Organization runner for: $TARGET_PATH"
    API_URL="https://api.github.com/orgs/${TARGET_PATH}/actions/runners/registration-token"
elif [ "$RUNNER_TYPE" = "repo" ]; then
    echo "Configuring as a Repository runner for: $TARGET_PATH"
    API_URL="https://api.github.com/repos/${TARGET_PATH}/actions/runners/registration-token"
else
    echo "=x= Error: RUNNER_TYPE must be either 'org' or 'repo'"
    exit 1
fi

echo "API_URL: $API_URL"

echo "Fetching registration token from GitHub API..."
REG_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$API_URL" | jq -r '.token')

if [ "$REG_TOKEN" = "null" ] || [ -z "$REG_TOKEN" ]; then
    echo "=x= Error: Failed to acquire a valid registration token from GitHub API"
    exit 1
fi

# We disable automatic updates
echo "Registering runner..."
./config.sh --url "$REPO_URL" --token "$REG_TOKEN" --name "${RUNNER_NAME}" --labels "${RUNNER_LABELS}" --unattended --replace --disableupdate

# Dynamic cleanup handler to catch container exits smoothly
cleanup() {
  echo "Acquiring removal token..."
  REM_TOKEN=$(curl -s -X POST -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "$API_URL" | jq -r '.token')

  echo "Unregistering runner from pool..."
  ./config.sh remove --token "$REM_TOKEN"
}
trap cleanup EXIT SIGTERM SIGINT

echo "=== Runner is ONLINE! ==="
./run.sh
