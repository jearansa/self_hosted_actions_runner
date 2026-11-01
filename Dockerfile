# FILE: Dockerfile
FROM ubuntu:26.04

# Don't ask for user input during install
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION=2.338.0

# Install general dependencies (curl, jq, sudo, etc.)
RUN apt-get update && apt-get install -y \
    curl git jq sudo unzip ca-certificates python3-pip \
    libicu-dev libssl-dev libkrb5-3 zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install own dependencies (JDK25, Maven, CMake)

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y universe && apt-get update

RUN apt-get install -y openjdk-25-jdk

RUN apt-get install -y maven

RUN apt-get install -y cmake

# Create a safe non-root user called "runner"
RUN useradd -m -s /bin/bash runner \
    && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/runner

#Download the latest runner package

RUN curl -o "runner.tar.gz" -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
	&& tar xzf 'runner.tar.gz' \
	&& rm 'runner.tar.gz'

# Optional: Validate the hash
# echo "70920811a4f8ad4328818682bca5c6469c1c942fab52448868071d0063816613  actions-runner-linux-x64-2.337.0.tar.gz" | shasum -a 256 -c# Extract the installer

RUN './bin/installdependencies.sh'

COPY start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh \
	&& chown -R runner:runner /home/runner

# We create the folder that will be later mounted on an external volume.
# Otherwise, it would be assigned to root, and runner would have no permissions.

RUN mkdir /home/runner/_work
RUN chown -R runner:runner /home/runner/_work

USER runner

ENV PATH="/home/runner/.local/bin:${PATH}"
ENTRYPOINT ["/home/runner/start.sh"]
