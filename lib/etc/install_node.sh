#!/bin/bash

set -ex

KEYSERVER_PROXY=""
CURL_PROXY=""
NPM_PROXY=""
GPG_KEYS=(
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE
)

set_proxy() {
    if [ ! -z $HTTP_PROXY ]; then
        KEYSERVER_PROXY="--keyserver-options http-proxy=${HTTP_PROXY%%://*}://${PROXY_USER}:${PROXY_PASS}@${HTTP_PROXY##*://}";
        CURL_PROXY="-x ${HTTP_PROXY} -U ${PROXY_USER}:${PROXY_PASS}";
        NPM_PROXY="--proxy=${HTTP_PROXY}";
    fi
}

download_node_gpg_keys() {
    for KEY in ${GPG_KEYS[@]}; do
        gpg -q --keyserver pool.sks-keyservers.net $KEYSERVER_PROXY --recv-keys $KEY
        echo $KEY:6 | gpg --import-ownertrust
    done
}

download_node_binary() {
    curl -O -sSL $CURL_PROXY https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
}

download_node_shasum() {
    curl -O -sSL $CURL_PROXY https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc
}

validate_unpack_binary() {
    gpg --verify SHASUMS256.txt.asc
    grep "node-v${NODE_VERSION}-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -
    tar -zxf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local --strip-components=1
}

install_latest_npm() {
    npm install -g $NPM_PROXY npm@${NPM_VERSION} -s &>/dev/null
}

set_permissions() {
    if [ -f /opt/app-root/src/.config ]; then chmod -R 777 /opt/app-root/src/.config; fi
}

cleanup() {
    find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf
    rm -rf ~/node-v${NODE_VERSION}-linux-x64.tar.gz \
        ~/SHASUMS256.txt.asc \
        ~/.npm \
        ~/.node-gyp \
        ~/.gnupg \
        /usr/share/man \
        /usr/local/lib/node_modules/npm/man \
        /usr/local/lib/node_modules/npm/doc \
        /usr/local/lib/node_modules/npm/html \
        /tmp/*
}

main() {
    set_proxy
    download_node_gpg_keys
    download_node_binary
    download_node_shasum
    validate_unpack_binary
    install_latest_npm
    set_permissions
    cleanup
}

main