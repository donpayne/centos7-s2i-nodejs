#!/bin/bash

set -ex

# Download and install a binary from nodejs.org
# Add the gpg keys listed at https://github.com/nodejs/node
# If you have a Proxy, you may not be able to ping the keyserver
gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5
gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E
gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8
gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9
gpg --keyserver pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE

# Get the node binary and it's shasum
if [ ! -z $HTTP_PROXY ]; then
    curl -O -sSL -x ${HTTP_PROXY} -U ${PROXY_USER}:${PROXY_PASS} https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
else
    curl -O -sSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
fi

# curl -O -sSL https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc
gpg --verify SHASUMS256.txt.asc

# Validate the release
grep " node-v${NODE_VERSION}-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -

# Unpack and install node/npm
tar -zxf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local --strip-components=1

# Update npm
if [ ! -z $HTTP_PROXY ]; then
    npm install -g --proxy=${HTTP_PROXY} npm@${NPM_VERSION} -s &>/dev/null
else
    npm install -g npm@${NPM_VERSION} -s &>/dev/null
fi

# Fix permissions for the npm update-notifier
if [ -f /opt/app-root/src/.config ]; then
   chmod -R 777 /opt/app-root/src/.config
fi

# Delete NPM things that we don't really need (like tests) from node_modules
find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf

# Clean up the stuff we downloaded
rm -rf ~/node-v${NODE_VERSION}-linux-x64.tar.gz
rm -rf ~/SHASUMS256.txt.asc
rm -rf /tmp/node-v${NODE_VERSION}
rm -rf ~/.npm
rm -rf ~/.node-gyp
rm -rf ~/.gnupg
rm -rf /usr/share/man
rm -rf /tmp/*
rm -rf /usr/local/lib/node_modules/npm/man
rm -rf /usr/local/lib/node_modules/npm/doc
rm -rf /usr/local/lib/node_modules/npm/html