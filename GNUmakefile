# If you see pwd_unknown showing up, this is why. Re-calibrate your system.
PWD ?= pwd_unknown

TIME									:= $(shell date +%s)
export TIME
# PROJECT_NAME defaults to name of the current directory.
# should not to be changed if you follow GitOps operating procedures.
PROJECT_NAME = docker_shell#$(notdir $(PWD))

# Note. If you change this, you also need to update docker-compose.yml.
# only useful in a setting with multiple services/ makefiles.
ifneq ($(target),)
SERVICE_TARGET := $(target)
else
SERVICE_TARGET := alpine-base
endif
export SERVICE_TARGET

ifeq ($(user),root)
HOST_USER := root
HOST_UID  := $(strip $(if $(uid),$(uid),0))
else
# allow override by adding user= and/ or uid=  (lowercase!).
# uid= defaults to 0 if user= set (i.e. root).
# USER retrieved from env, UID from shell.
HOST_USER :=  $(strip $(if $(USER),$(USER),nodummy))
HOST_UID  :=  $(strip $(if $(shell id -u),$(shell id -u),4000))
endif
ifneq ($(uid),)
HOST_UID  := $(uid)
endif

ifeq ($(ssh-pkey),)
SSH_PRIVATE_KEY := $(HOME)/.ssh/id_rsa
else
SSH_PRIVATE_KEY := $(ssh-pkey)
endif
export SSH_PRIVATE_KEY

ifeq ($(alpine),)
ALPINE_VERSION := 3.15
else
ALPINE_VERSION := $(alpine)
endif
export ALPINE_VERSION

ifeq ($(dind),)
DIND_VERSION := 20.10.16
else
DIND_VERSION := $(dind)
endif
export DIND_VERSION

ifeq ($(debian),)
DEBIAN_VERSION := bookworm
else
DEBIAN_VERSION := $(debian)
endif
export DEBIAN_VERSION

ifeq ($(ubuntu),)
UBUNTU_VERSION := jammy
else
UBUNTU_VERSION := $(ubuntu)
endif
export UBUNTU_VERSION

ifeq ($(nocache),true)
NO_CACHE := --no-cache
else
NO_CACHE :=
endif
export NO_CACHE

ifeq ($(verbose),true)
VERBOSE := --verbose
else
VERBOSE :=
endif
export VERBOSE

ifneq ($(passwd),)
PASSWORD := $(passwd)
else
PASSWORD := changeme
endif
export PASSWORD


THIS_FILE := $(lastword $(MAKEFILE_LIST))

ifeq ($(cmd),)
CMD_ARGUMENTS :=
else
CMD_ARGUMENTS := $(cmd)
endif
export CMD_ARGUMENTS

# export such that its passed to shell functions for Docker to pick up.
export PROJECT_NAME
export HOST_USER
export HOST_UID

DOCKER:=$(shell which docker)
export DOCKER
DOCKER_COMPOSE:=$(shell which docker-compose)
export DOCKER_COMPOSE

# all our targets are phony (no files to check).
.PHONY: debian build-debian rebuild-debian alpine shell help alpine-build alpine-rebuild build rebuild alpine-test service login  clean
# suppress makes own output
#.SILENT:

# Regular Makefile part for buildpypi itself
default:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?##/ {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
help:## print verbose help
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo 'Targets:'
	@echo ''
	@echo '  shell          user=root'
	@echo '  alpine         user=root'
	@echo '  debian         user=root'
	@echo '  debian-build   user=root'
	@echo '  debian-build   user=root nocache=true'
	@echo '  debian-build   user=root nocache=false debian=buster'
	@echo ''
	@echo '  make centos    user=root'
	@echo '  make centos7   user=root'
	@echo ''
	@echo ''
	@echo ''
	@echo 'Extra arguments:'
	@echo ''
	@echo '  cmd            make <service> cmd="whoami"'
	@echo '  user           make <service> user=root (no need to set uid=0)'
	@echo '  uid            make <service> user=dummy uid=4000 (defaults to 0 if user= set)'
	@echo ''
	@echo '  user=$(HOST_USER)'
	@echo '  uid=$(HOST_UID)'
	@echo ''
	@echo "Command Examples:"
	@echo ""
	@echo "make report user=root uid=4004"
	@echo "make service service=alpine user=root"
	@echo "make service service=ubuntu user=root"
	@echo ''
	@echo 'make service service=alpine cmd="     apk add python3 && python3" user=root'
	@echo 'make service service=alpine cmd="sudo apk add python3 && python3"'
	@echo 'make service service=alpine cmd="sudo apk add python3 && python3" uid=4001'
	@echo ''
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':	' |  sed -e 's/^/ /' ## verbose help ideas
	@sed -n 's/^## 	//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: report
report:## 	
	@echo ''
	@echo '	[ARGUMENTS]	'
	@echo '      args:'
	@echo '        - PWD=${PWD}'
	@echo '        - DOCKER=${DOCKER}'
	@echo '        - DOCKER_COMPOSE=${DOCKER_COMPOSE}'
	@echo '        - THIS_FILE=${THIS_FILE}'
	@echo '        - TIME=${TIME}'
	@echo '        - HOST_USER=${HOST_USER}'
	@echo '        - HOST_UID=${HOST_UID}'
	@echo '        - SERVICE_TARGET=${SERVICE_TARGET}'
	@echo '        - ALPINE_VERSION=${ALPINE_VERSION}'
	@echo '        - DIND_VERSION=${DIND_VERSION}'
	@echo '        - DEBIAN_VERSION=${DEBIAN_VERSION}'
	@echo '        - PROJECT_NAME=${PROJECT_NAME}'
	@echo '        - PASSWORD=${PASSWORD}'
	@echo '        - CMD_ARGUMENTS=${CMD_ARGUMENTS}'
	@echo ''

shell:## 	
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm ${SERVICE_TARGET} bash
else
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm $(SERVICE_TARGET) bash -c "$(CMD_ARGUMENTS)"
endif

checkbrew:## 	checkbrew
ifeq ($(HOMEBREW),)
	@/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	@type -P brew
endif


submodules:checkbrew## 	submodules
	@git submodule update --init --recursive
#	@git submodule foreach --recursive "git submodule update --init --recursive"

debian-build:## 	
	$(DOCKER_COMPOSE) build $(NO_CACHE) $(VERBOSE) debian

debian-rebuild:## 	
	$(DOCKER_COMPOSE) build --no-cache $(VERBOSE) debian
debian:## 	
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm debian bash
else
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm debian bash -c "$(CMD_ARGUMENTS)"
endif

ubuntu-build:## 	
	$(DOCKER_COMPOSE) build $(NO_CACHE) $(VERBOSE) ubuntu

ubuntu:## 	
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm ubuntu bash
else
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm ubuntu bash -c "$(CMD_ARGUMENTS)"
endif

service:## 	
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME)_$(HOST_UID) up -d ${SERVICE_TARGET}
else
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME)_$(HOST_UID) up -d $(SERVICE_TARGET)
	docker exec -it $(PROJECT_NAME)_$(HOST_UID) bash -c "${CMD_ARGUMENTS}"
endif

login: service
	# run as a service and attach to it
	docker exec -it $(PROJECT_NAME)_$(HOST_UID) sh
-include Makefile
#include golpe/rules.mk
