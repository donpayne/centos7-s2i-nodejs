FROM=openshift/base-centos7
IMAGE_NAME=donpayne/centos7-s2i-nodejs

# These values are changed in each version branch
# This is the only place they need to be changed
# other than the README.md file.
include versions.mk

TARGET=$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: all
all: build squash test

.PHONY: build
build:
	docker build \
	--build-arg http_proxy=$(PROXY) \
	--build-arg https_proxy=$(ROXY) \
	--build-arg HTTP_PROXY=$(PROXY) \
	--build-arg HTTPS_PROXY=$(PROXY) \
	--build-arg PROXY_USER=$(PROXY_USER) \
	--build-arg PROXY_PASS=$(PROXY_PASS) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	--build-arg V8_VERSION=$(V8_VERSION) \
	-t $(TARGET) .

.PHONY: squash
squash: 
	docker-squash -f $(FROM) $(TARGET) -t $(TARGET)

.PHONY: test
test: build squash
	 BUILDER=$(TARGET) NODE_VERSION=$(NODE_VERSION) ./test/run

.PHONY: clean
clean:
	docker rmi `docker images $(TARGET) -q`

.PHONY: tag
tag:
	if [ ! -z $(LTS_TAG) ]; then docker tag $(TARGET) $(IMAGE_NAME):$(LTS_TAG); fi

.PHONY: publish
publish: all
	docker login --username $(DOCKER_USER) --password $(DOCKER_PASS) $(DOCKER_REPO)
	docker push $(TARGET)
	if [ ! -z $(LTS_TAG) ]; then docker push $(IMAGE_NAME):$(LTS_TAG); fi
# oc login --username $(DOCKER_USER) --password $(DOCKER_PASS) $(OC_MASTER)
# oc project $(OC_PROJECT)
# oc import-image $(TARGET)