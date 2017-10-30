FROM jetbrains/teamcity-minimal-agent:2017.1.5

LABEL maintainer="@stas_natalenko"

# Dockerfile dependencies
# - python-pip for AWS CLI
# build script dependencies
# - zip for lambda deployment packages creation
# - ssh for npm pakages installed from git
# - build-essential for node-gyp make
RUN apt-get update && \
	apt-get install -y --no-install-recommends python-pip zip ssh git ca-certificates build-essential jq && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# aws cli
RUN curl -o "awscli-bundle.zip" "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" && \
	unzip "awscli-bundle.zip" && \
	./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
	rm "awscli-bundle.zip"

RUN update-ca-certificates

# add github and bitbucket signatures to known_hosts
RUN	mkdir -p /root/.ssh/ && \
	ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts && \
	ssh-keyscan -t rsa bitbucket.org >> /root/.ssh/known_hosts

# docker
RUN curl -fsSL get.docker.com -o get-docker.sh

# nodejs
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
	gpg --keyserver pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE

ENV NODE_VERSION 8.8.1

RUN curl -o "node-v$NODE_VERSION-linux-x64.tar.gz" -SL "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
	curl -o "SHASUMS256.txt.asc" -SL "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
	gpg --verify "SHASUMS256.txt.asc" && \
	grep "node-v$NODE_VERSION-linux-x64.tar.gz\$" "SHASUMS256.txt.asc" | sha256sum -c - && \
	tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
	rm "node-v$NODE_VERSION-linux-x64.tar.gz" "SHASUMS256.txt.asc"

RUN npm install -g eslint eslint-plugin-react istanbul@next mocha apidoc

VOLUME "/data/teamcity_agent/conf"
VOLUME "/var/run/docker.sock"