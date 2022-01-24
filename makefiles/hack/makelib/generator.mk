# Tencent is pleased to support the open source community by making DevOps
# available.
#
# Copyright (C) 2014 THL A29 Limited, a Tencent company. All rights reserved.

# Licensed under the BSD 3-Clause License (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the
# License at
#
# https://opensource.org/licenses/BSD-3-Clause
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.


FN_API_GROUP_NAME = $(firstword $(subst $(COLON), ,$(1)))
FN_API_VERSION_LIST = $(subst $(COMMA), ,$(lastword $(subst $(COLON), , $(1))))
FN_API_GROUP_VERSION = $(foreach ver,$(call FN_API_VERSION_LIST,$(2)),$(1)/$(call FN_API_GROUP_NAME,$(2))/$(ver))

APIS_INTERNAL_PKG := $(foreach api,$(API_GROUPS),$(APIS_PKG)/$(call FN_API_GROUP_NAME,$(api)))
APIS_EXTERNAL_PKG := $(foreach api,$(API_GROUPS),$(call FN_API_GROUP_VERSION,$(APIS_PKG),$(api)))

APIS_INTERNAL_PKG := $(subst $(SPACE),$(COMMA),$(APIS_INTERNAL_PKG))
APIS_EXTERNAL_PKG := $(subst $(SPACE),$(COMMA),$(APIS_EXTERNAL_PKG))

SELF_LINK_PATH := $(ROOT_DIR)/.self-pkg
ROOT_PKG_LASTNAME := $(lastword $(subst /, ,$(ROOT_PACKAGE)))
ROOT_PKG_PREFIX := $(subst /$(ROOT_PKG_LASTNAME),,$(ROOT_PACKAGE))

#grep -o '^\s\+k8s.io/code-generator\s\+v.\+$' go.mod|awk '{print $2}'
KUBE_TOOLS := $(TOOLS_DIR)/k8s-code-gen/$(shell grep -o '\s\+k8s.io/code-generator\s\+v.\+$$' go.mod|head -n 1|awk '{print $$2}')

GENERATOR_ROUTINES:=

ifeq (,$(filter-out all,$(GENERATORS)))
GENERATOR_ROUTINES:=deepcopy-gen,conversion-gen,defaulter-gen,client-gen,lister-gen,informer-gen,go-to-protobuf
else
GENERATOR_ROUTINES:=$(GENERATORS)
endif

.PHONY: generator.run
generator.run: generator.prepare $(foreach routine,$(subst $(COMMA),$(SPACE),$(GENERATOR_ROUTINES)),generator.$(routine))
	@rm -rf $(SELF_LINK_PATH)

.PHONY: generator.prepare
generator.prepare:
	@(rm -rf $(SELF_LINK_PATH); \
		mkdir -p $(SELF_LINK_PATH)/$(ROOT_PKG_PREFIX); \
		cd $(SELF_LINK_PATH)/$(ROOT_PKG_PREFIX); \
		rspath=`echo -n $(ROOT_PACKAGE) | sed 's/[[:digit:][:alpha:]._-]*/\.\./g'`; \
		ln -sf $${rspath} $(ROOT_PKG_LASTNAME))
	@mkdir -p $(KUBE_TOOLS)
	@echo "===========> Installing kubernetes code generator"
	@for cmd in $(subst $(COMMA), ,$(GENERATOR_ROUTINES));do \
		if [[ -x "$(KUBE_TOOLS)/$$cmd" ]]; then : ; else \
			echo "installing k8s code generator: $$cmd"; \
			GOBIN=$(KUBE_TOOLS) go install k8s.io/code-generator/cmd/$$cmd; \
		fi; \
	done
	@echo "===========> done"

define _internal_apimachinery_packages
-k8s.io/apimachinery/pkg/util/intstr,
-k8s.io/apimachinery/pkg/api/resource,
-k8s.io/apimachinery/pkg/runtime/schema,
-k8s.io/apimachinery/pkg/runtime,
-k8s.io/api/core/v1,
-k8s.io/apimachinery/pkg/apis/meta/v1,
-k8s.io/apimachinery/pkg/apis/meta/v1beta1
endef

_APIMACHINERY_PACKAGES := $(shell echo "$(_internal_apimachinery_packages)")
ifneq (,$(PROTO_PACKAGES))
_APIMACHINERY_PACKAGES := $(_APIMACHINERY_PACKAGES),$(PROTO_PACKAGES)
endif

define _internal_proto_drop_embeds
endef
#k8s.io/apimachinery/pkg/apis/meta/v1.TypeMeta
#,k8s.io/api/core/v1.Affinity

_PROTO_DROP_EMBEDS:=$(shell echo "$(_internal_proto_drop_embeds)")

ifndef PROTO_IMPORTS
define PROTO_IMPORTS
$(ROOT_DIR)/third_party
endef
endif
_PROTO_IMPORT=$(shell echo "$(PROTO_IMPORTS)")

.PHONY: generator.go-to-protobuf
generator.go-to-protobuf:
	@echo -n "Generating protobuf..."
	@PATH=$(TOOLS_DIR):$(KUBE_TOOLS):$${PATH} $(KUBE_TOOLS)/go-to-protobuf \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--proto-import=$(_PROTO_IMPORT) \
		$(if $(strip $(_PROTO_DROP_EMBEDS)),--drop-embedded-fields="$(_PROTO_DROP_EMBEDS)",) \
		--apimachinery-packages="$(_APIMACHINERY_PACKAGES)" \
		--packages=$(APIS_INTERNAL_PKG),$(APIS_EXTERNAL_PKG) \
		--output-base '$(SELF_LINK_PATH)'

.PHONY: generator.deepcopy-gen
generator.deepcopy-gen:
	@echo -n "Generating deepcopy code... "
	@$(KUBE_TOOLS)/deepcopy-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--bounding-dirs "$(APIS_PKG)" \
		-i "$(APIS_INTERNAL_PKG),$(APIS_EXTERNAL_PKG)" \
		--output-base '$(SELF_LINK_PATH)' \
		--output-file-base zz_generated.deepcopy
	@echo done

.PHONY: generator.client-gen
generator.client-gen:
	@echo -n "Generating external clientset code... "
	@$(KUBE_TOOLS)/client-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--clientset-name versioned \
		--input-base "" \
		--input "$(APIS_EXTERNAL_PKG)" \
		--output-base '$(SELF_LINK_PATH)' \
		--output-package $(GEN_CLIENTSET_PKG)
	@echo done
	@echo -n "Generating internal clientset code... "
	@$(KUBE_TOOLS)/client-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--clientset-name internalversion \
		--input "$(foreach p,$(APIS_INTERNAL_PKG),$(p)/)" \
		--input-base "" \
		--output-base '$(SELF_LINK_PATH)' \
		--output-package $(GEN_CLIENTSET_PKG)
	@echo done

FN_MODIFY_GENCODE_DEFAULTS_UP = $(shell \
	find $(1) -name 'defaults.go' | xargs sed -i.bak 's/SetDefaults\([^_]\)/SetDefaults_\1/g'; \
	find $(1) -name '*.bak' -delete)
FN_MODIFY_GENCODE_DEFAULTS_DOWN = $(shell \
	find $(1) -name '*defaults.go' | xargs sed -i.bak 's/Defaults_*/Defaults/g';\
	find $(1) -name '*.bak' -delete)

.PHONY: gen.defaulter.modify
gen.defaulter.modify:
	@echo -n "Generating defaulter code... "
	@#$(foreach pkg,$(subst $(COMMA),$(SPACE),$(APIS_EXTERNAL_PKG)),$(call FN_MODIFY_GENCODE_DEFAULTS_UP,$(SELF_LINK_PATH)/$(pkg)))
	@$(KUBE_TOOLS)/defaulter-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--input-dirs "$(APIS_EXTERNAL_PKG)" \
		--output-base "$(SELF_LINK_PATH)" \
		--output-file-base zz_generated.defaults
	@echo done

.PHONY: generator.defaulter-gen
generator.defaulter-gen: gen.defaulter.modify
#revise name
	@#$(foreach pkg,$(subst $(COMMA),$(SPACE),$(APIS_EXTERNAL_PKG)),$(call FN_MODIFY_GENCODE_DEFAULTS_DOWN,$(SELF_LINK_PATH)/$(pkg)))

.PHONY: generator.conversion-gen
generator.conversion-gen:
	@echo -n "Generating conversion code... "
	@$(KUBE_TOOLS)/conversion-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--input-dirs "$(APIS_EXTERNAL_PKG)" \
		--output-base "$(SELF_LINK_PATH)" \
		--output-file-base zz_generated.conversion
	@echo done

.PHONY: generator.lister-gen
generator.lister-gen:
	@echo -n "Generating lister code... "
	@$(KUBE_TOOLS)/lister-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--input-dirs "$(APIS_INTERNAL_PKG),$(APIS_EXTERNAL_PKG)" \
		--output-base '$(SELF_LINK_PATH)' \
		--output-package $(GEN_LISTERS_PKG)
	@echo done

.PHONY: generator.informer-gen
generator.informer-gen:
	@echo -n "Generating informer code... "
	@$(KUBE_TOOLS)/informer-gen \
		--go-header-file "$(ROOT_DIR)/hack/boilerplate/boilerplate.go.txt" \
		--input-dirs "$(APIS_EXTERNAL_PKG)" \
		--output-base "$(SELF_LINK_PATH)" \
		--output-package $(GEN_INFORMERS_PKG) \
		--listers-package $(GEN_LISTERS_PKG) \
		--versioned-clientset-package $(GEN_CLIENTSET_PKG)/versioned \
		--internal-clientset-package $(GEN_CLIENTSET_PKG)/internalversion
	@echo done
