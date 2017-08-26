FROM openshift/base-centos7

MAINTAINER Don Payne <don.payne@imail.org>

# This image will be initialized with "npm run $NPM_RUN"
# See https://docs.npmjs.com/misc/scripts, and your repo's package.json
# file for possible values of NPM_RUN
ARG PROXY_USER
ARG PROXY_PASS
ARG NODE_VERSION
ARG NPM_VERSION
ARG V8_VERSION

ENV NPM_RUN=start \
    NODE_VERSION=${NODE_VERSION} \
    NPM_VERSION=${NPM_VERSION} \
    V8_VERSION=${V8_VERSION} \
    NODE_LTS=false \
    NPM_CONFIG_LOGLEVEL=info \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    DEBUG_PORT=5858 \
    NODE_ENV=production \
    DEV_MODE=false

LABEL io.k8s.description="Platform for building and running Node.js applications" \
      io.k8s.display-name="Node.js $NODE_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs-$NODE_VERSION" \
      com.redhat.deployments-dir="/opt/app-root/src"

EXPOSE 8080

COPY ./s2i/bin/ $STI_SCRIPTS_PATH
COPY ./lib/ /opt/app-root

RUN chmod -R 777 /opt/app-root/etc
RUN /opt/app-root/etc/install_node.sh

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage
CMD ${STI_SCRIPTS_PATH}/usage