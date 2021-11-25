IMAGE_REPOSITORY ?= ccr.ccs.tencentyun.com/graph
IMAGES_DIR ?= $(wildcard $(ROOT_DIR)/build/docker/*)
IMAGES ?= $(foreach image,$(IMAGES_DIR),$(notdir $(image)))
TAGEXT ?=
TAG ?=
ONLY_BUILD_CONTEXT ?=
IMAGE_REPO_PREFIX := $(IMAGE_REPOSITORY)

ifneq (${IMAGE_REPOSITORY},)
ifneq ($(word $(words $(IMAGE_REPOSITORY)),$(IMAGE_REPOSITORY)), /)
	IMAGE_REPO_PREFIX := $(IMAGE_REPO_PREFIX)/
endif
endif

.PHONY: image.build
image.build: $(addprefix image.build., $(IMAGES))
ifeq (${IMAGES},)
	$(error Could not determine IMAGES, set ROOT_DIR or run in source dir)
endif

.PHONY: image.build.%
image.build.%: go.build.linux_amd64.%
	$(eval _DIRNAME:=$*)
	$(eval _BUILD_TMP_DIR:=$(OUTPUT_DIR)/image-build-contexts/$(_DIRNAME))
	$(eval _TAG:=$(VERSION)$(if $(filter $(DEBUG),true),-dev,$(if $(TAGEXT),-$(TAGEXT),)))
	@echo "===========> Building docker image ($(IMAGE_REPO_PREFIX)$(_DIRNAME):$(_TAG))"
	$(eval _HOOK_DIRS:=$(ROOT_DIR)/build/docker/$(_DIRNAME)/ $(ROOT_DIR)/build/hooks/$(_DIRNAME)/ $(ROOT_DIR)/build/hooks/docker/)
	@rm -rf $(_BUILD_TMP_DIR)
	@mkdir -p $(_BUILD_TMP_DIR)/bin
	$(eval OS:=$(word 1,$(subst _, ,$(PLATFORM))))
	$(eval ARCH:=$(word 2,$(subst _, ,$(PLATFORM))))
	@cp ${OUTPUT_DIR}/$(OS)/$(ARCH)/$(_DIRNAME) $(_BUILD_TMP_DIR)/bin/ || true

	@for hookdir in $(_HOOK_DIRS); do \
	(if [[ -f $${hookdir}pre-build.sh ]]; then \
	  cd $${hookdir}; \
	  DST_DIR=$(_BUILD_TMP_DIR) \
	  ROOT_DIR=$(ROOT_DIR) \
	  bash $${hookdir}pre-build.sh; \
	fi) ;\
	done

ifeq ($(strip $(ONLY_BUILD_CONTEXT)),)
	@docker build --pull \
		-t $(IMAGE_REPO_PREFIX)$(_DIRNAME):$(_TAG) \
		-f $(ROOT_DIR)/build/docker/$(_DIRNAME)/Dockerfile $(_BUILD_TMP_DIR)
endif

ifneq ($(strip $(TAG)),)
	@docker tag $(IMAGE_REPO_PREFIX)$(_VERNAME):$(_TAG) $(IMAGE_REPO_PREFIX)$(_VERNAME):$(TAG) && \
	echo "tagged $(IMAGE_REPO_PREFIX)$(_VERNAME):$(TAG)"
endif

	@for hookdir in $(_HOOK_DIRS); do \
	(if [[ -x $${hookdir}/post-build.sh ]]; then \
	  cd $${hookdir}; \
	  ROOT_DIR=$(ROOT_DIR) \
	  DST_DIR=$(_BUILD_TMP_DIR) \
	  OUTPUT_DIR=$(OUTPUT_DIR)/ \
	  IMAGE_REPOSITORY=$(IMAGE_REPOSITORY) \
	  IMAGE_NAME=$(_VERNAME) \
	  IMAGE_CANONICAL_TAG=$(_TAG) \
	  IMAGE_TAGS="$(_TAG) $(TAG)" \
	  $${hookdir}/post-build.sh; \
	fi) ;\
	done

.PHONY: image.push
image.push: $(addprefix image.push., $(IMAGES))
ifeq (${IMAGES},)
	$(error Could not determine IMAGES, set ROOT_DIR or run in source dir)
endif

.PHONY: image.push.%
image.push.%: image.build.%
	$(eval _NAME:=$*)
	$(eval _VERNAME:=$(if $(filter $(STEP),true),khaos-steps-$(_NAME),$(_NAME)))
	$(eval _TAG:=$(VERSION)$(if $(filter $(DEBUG),true),-dev,$(if $(TAGEXT),-$(TAGEXT),)))
	@echo "===========> Pushing docker image ($(IMAGE_REPO_PREFIX)$(_VERNAME):$(_TAG))"
	docker push $(IMAGE_REPO_PREFIX)$(_VERNAME):$(_TAG)
ifneq ($(strip $(TAG)),)
	docker push $(IMAGE_REPO_PREFIX)$(_VERNAME):$(TAG)
endif