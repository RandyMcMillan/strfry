SHELL                                   := /bin/bash
PWD 									?= pwd_unknown
TIME 									:= $(shell date +%s)
export TIME

PERL=$(shell command -v perl)
export PERL
CPANM=$(shell command -v cpanm)
export CPANM

PYTHON                                  := $(shell which python)
export PYTHON
PYTHON2                                 := $(shell which python2)
export PYTHON2
PYTHON3                                 := $(shell which python3)
export PYTHON3

PIP                                     := $(notdir $(shell which pip))
export PIP
PIP2                                    := $(notdir $(shell which pip2))
export PIP2
PIP3                                    := $(notdir $(shell which pip3))
export PIP3

ifeq ($(PYTHON3),/usr/local/bin/python3)
PIP                                    := pip
PIP3                                   := pip
export PIP
export PIP3
endif

ifeq ($(project),)
PROJECT_NAME							:= $(notdir $(PWD))
else
PROJECT_NAME							:= $(project)
endif
export PROJECT_NAME
PYTHONPATH=$(PWD)/twitter
export PYTHONPATH
ifeq ($(port),)
PORT									:= 0
else
PORT									:= $(port)
endif
export PORT

#GIT CONFIG
GIT_USER_NAME							:= $(shell git config user.name)
export GIT_USER_NAME
GH_USER_NAME							:= $(shell git config user.name)
#MIRRORS
GH_USER_REPO							:= $(GH_USER_NAME).github.io
GH_USER_SPECIAL_REPO					:= $(GH_USER_NAME)
KB_USER_REPO							:= $(GH_USER_NAME).keybase.pub
#GITHUB RUNNER CONFIGS
ifneq ($(ghuser),)
GH_USER_NAME := $(ghuser)
GH_USER_SPECIAL_REPO := $(ghuser)/$(ghuser)
endif
export GIT_USER_NAME
export GH_USER_REPO
export GH_USER_SPECIAL_REPO

GIT_USER_EMAIL							:= $(shell git config user.email)
export GIT_USER_EMAIL
GIT_SERVER								:= https://github.com
export GIT_SERVER
GIT_SSH_SERVER							:= git@github.com
export GIT_SSH_SERVER
GIT_PROFILE								:= $(shell git config user.name)
export GIT_PROFILE
GIT_BRANCH								:= $(shell git rev-parse --abbrev-ref HEAD)
export GIT_BRANCH
GIT_HASH								:= $(shell git rev-parse --short HEAD)
export GIT_HASH
GIT_PREVIOUS_HASH						:= $(shell git rev-parse --short master@{1})
export GIT_PREVIOUS_HASH
GIT_REPO_ORIGIN							:= $(shell git remote get-url origin)
export GIT_REPO_ORIGIN
GIT_REPO_NAME							:= $(PROJECT_NAME)
export GIT_REPO_NAME
GIT_REPO_PATH							:= $(HOME)/$(GIT_REPO_NAME)
export GIT_REPO_PATH

BASENAME := $(shell basename -s .git `git config --get remote.origin.url`)
export BASENAME

.ONESHELL:
-: init

init: help

help:
	@echo ""
	@echo " init"
	@echo " help"
	@echo " report"
	@echo " env"
	@echo " local-lib"
	@echo ""
	@echo " install"
	@echo " install-all"

.PHONY: report
report:
	@echo ''
	@echo ' [MAKE VARIABLES]'
	@echo ''
	@echo '	TIME=${TIME}'
	@echo '	BASENAME=${BASENAME}'
	@echo '	PROJECT_NAME=${PROJECT_NAME}'
	@echo ''
	@echo '	PERL=${PERL}'
	@echo '	CPANM=${CPANM}'
	@echo ''
	@echo '	GIT_USER_NAME=${GIT_USER_NAME}'
	@echo '	GH_USER_REPO=${GH_USER_REPO}'
	@echo '	GH_USER_SPECIAL_REPO=${GH_USER_SPECIAL_REPO}'
	@echo '	GIT_USER_EMAIL=${GIT_USER_EMAIL}'
	@echo '	GIT_SERVER=${GIT_SERVER}'
	@echo '	GIT_PROFILE=${GIT_PROFILE}'
	@echo '	GIT_BRANCH=${GIT_BRANCH}'
	@echo '	GIT_HASH=${GIT_HASH}'
	@echo '	GIT_PREVIOUS_HASH=${GIT_PREVIOUS_HASH}'
	@echo '	GIT_REPO_ORIGIN=${GIT_REPO_ORIGIN}'
	@echo '	GIT_REPO_NAME=${GIT_REPO_NAME}'
	@echo '	GIT_REPO_PATH=${GIT_REPO_PATH}'
	@echo ''

.PHONY: super
super:
ifneq ($(shell id -u),0)
	@echo switch to superuser
	@echo cd $(TARGET_DIR)
	#sudo ln -s $(PWD) $(TARGET_DIR)
#.ONESHELL:
	sudo -s
endif

.PHONY: docs
docs: git-add awesome
	#@echo docs
	bash -c "if pgrep MacDown; then pkill MacDown; fi"
	#bash -c "curl https://raw.githubusercontent.com/sindresorhus/awesome/main/readme.md -o ./sources/AWESOME-temp.md"
	bash -c 'cat $(PWD)/sources/HEADER.md                >  $(PWD)/README.md'
	bash -c 'cat $(PWD)/sources/COMMANDS.md              >> $(PWD)/README.md'
	bash -c 'cat $(PWD)/sources/FOOTER.md                >> $(PWD)/README.md'
	#brew install pandoc
	bash -c "if hash pandoc 2>/dev/null; then echo; fi || brew install pandoc"
	#bash -c 'pandoc -s README.md -o index.html  --metadata title="$(GH_USER_SPECIAL_REPO)" '
	bash -c 'pandoc -s README.md -o index.html'
	#bash -c "if hash open 2>/dev/null; then open README.md; fi || echo failed to open README.md"
	git add --ignore-errors sources/*.md
	git add --ignore-errors *.md
	#git ls-files -co --exclude-standard | grep '\.md/$\' | xargs git

submodules:
#	@git submodule update --init --recursive
	@git submodule foreach --recursive "git submodule update --init --recursive"

.PHONY: failure
failure:
	@-/bin/false && ([ $$? -eq 0 ] && echo "success!") || echo "failure!"
.PHONY: success
success:
	@-/bin/true && ([ $$? -eq 0 ] && echo "success!") || echo "failure!"

-include Makefile
