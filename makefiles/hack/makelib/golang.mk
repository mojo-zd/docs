DEBUG ?= false

MONITOR ?= $(wildcard ${ROOT_DIR}/pkg/main)
EXECDIR = $(notdir $(MONITOR))

GO_GCFLAGS ?=
FN_SET_PKG_VERSION = \
GO_LDFLAGS += $(foreach pkg,$(VERSION_PACKAGES),$(call FN_SET_PKG_VERSION,$(pkg)))
ifeq ($(GOOS),windows)
GO_OUT_EXT := .exe
endif

.PHONY: monitor.go.build
monitor.go.build:
	@$(MAKE) $(addprefix go.build.,$(addprefix $(PLATFORM).,$(EXECDIR)))

GO_BUILD_TRIMPATH ?= -trimpath

.PHONY: go.build.%
go.build.%:
	$(eval PLATFORM := $(word 1,$(subst ., ,$*)))
	$(eval COMMAND := $(word 2,$(subst ., ,$*)))
	$(eval OS := $(word 1,$(subst _, ,$(PLATFORM))))
	$(eval ARCH := $(word 2,$(subst _, ,$(PLATFORM))))
	$(eval OUTPUT := $(OUTPUT_DIR)/$(OS)/$(ARCH)/$(COMMAND)$(GO_OUT_EXT))
	@echo "=======> start build binary, output:$(OUTPUT)"
	@mkdir -p $(OUTPUT_DIR)/$(OS)/$(ARCH)
	@CGO_ENABLED=0 GOOS=$(OS) GOARCH=$(ARCH) \
		go build $(if $(filter $(DEBUG),true),-gcflags all="-N -l",$(GO_BUILD_TRIMPATH)) \
		$(if $(strip $(GO_GCFLAGS)),-gcflags '$(GO_GCFLAGS)',) \
		-ldflags '$(GO_LDFLAGS)' \
		-o $(OUTPUT) \
		$(MONITOR)