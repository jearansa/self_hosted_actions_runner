
# Generating self hosted runners for GitHub Actions as docker containers

Scripts to automatically deploy self hosted runners in a GitHub Actions organization by means of Docker Compose.

In order to make it work follow the steps:

1. Clone the repository into a machine with Docker installed.
2. Build the starting image: ```docker buildx build -t actions_runner:2.338.0 .``` for version "2.338.0" of the runner application. Check [https://github.com/actions/runner/releases](https://github.com/actions/runner/releases) for latest release.
3. Edit the file .env.org with your own variables:
    - GITHUB_TOKEN: it should be a token with Administration access (both read and write) to your organization repositories and for self hosted runners (also read and write).
    - REPO_URL: the url of your organization (for instance, [https://github.com/POOC2627](https://github.com/POOC2627)).
    - RUNNER_LABELS: whatever labels you are using for your self hosted runners ('Default' works).
    - RUNNER_TYPE: either 'org' or 'repo'. The scripts are checked for 'org', they should work also for 'repo' with minor changes.  
4. Run ```docker compose up --detach```.
