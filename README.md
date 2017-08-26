# OpenShift Builder Images for Node.js Applications

This repository contains sources for an [s2i](https://github.com/openshift/source-to-image) builder image, based on CentOS7 and Node.js releases from nodejs.org.  For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.openshift.org/latest/using_images/s2i_images/nodejs.html).

## Versions
Node.js versions

* **latest**: 8.4.0
* **8.4.0**
* **7.10.1**
* **Boron**: 6.11.2
* **6.11.2**
* **5.12.0**
* **Argon**: 4.8.4
* **4.8.4**

## System Dependencies for Building Images
- Currently using an Enterprise version of Openshift
- Install [docker](https://docs.docker.com/engine/installation/#supported-platforms)
- Install [python 2.x and 3.x](https://www.python.org/downloads/)
- Install docker-squash `pip install docker-squash`
- Install [oc command-line tool](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html)
- Install [s2i source-to-image tool](https://github.com/openshift/source-to-image/releases)

## Environment variables
Use the following environment variables to configure the runtime behavior of the
application image created from this builder image.

Name         | Description
-------------|-------------
NODE_ENV     | Node.js runtime mode (default: production)
DOCKER_REPO  | Docker registry
DOCKER_USER  | Docker credentials
DOCKER_PASS  | Docker credentials
PROXY        | Corporate proxy
PROXY_USER   | Corporate credentials
PROXY_PASS   | Corporate credentials
OC_MASTER    | OpenShift master url
OC_PROJECT   | OpenShift project 

```sh
$ export NODE_ENV=production
$ export DOCKER_REPO=dockerrepo.company.com
$ export DOCKER_USER=username
$ export DOCKER_PASS=password
$ export PROXY=http://proxy.company.com:0000
$ export PROXY_USER=username
$ export PROXY_PASS=password
$ export OC_MASTER=https://openshift.company.com:0000
$ export OC_PROJECT=donpayne
```

## Usage
There is a great article on the OpenShift blog: [How to Create an S2I Builder Image](https://blog.openshift.com/create-s2i-builder-image/)

```sh
$ make build       --> This will build the image locally
$ make all         --> This will build, sqaush, and test the image locally
$ make tag publish --> This will build, sqaush, test, tag, and publish the image to dockerrepo
```