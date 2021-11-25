# include the common make file
COMMON_SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(origin ROOT_DIR),undefined)
ROOT_DIR = $(abspath $(shell cd $(COMMON_SELF_DIR)/../.. && pwd -P))
endif

ifeq ($(origin OUTPUT_DIR),undefined)
OUTPUT_DIR = $(ROOT_DIR)/output
endif

# set the version number. you should not need to do this
# for the majority of scenarios.
ifeq ($(origin VERSION), undefined)
VERSION = $(shell git describe --dirty --always --tags | sed 's/-/./2' | sed 's/-/./2' )
endif

export VERSION

GIT_TREE_STATE="dirty"
ifeq (, $(shell git status --porcelain 2>/dev/null))
	GIT_TREE_STATE="clean"
endif

PLATFORM ?= $(shell go env GOOS)_$(shell go env GOARCH)