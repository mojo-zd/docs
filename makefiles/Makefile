#
# Copyright (C) 2018 THL A29 Limited, a Tencent company. All rights reserved.
#
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


# grep '^module\s\+.\+$' go.mod|sed 's/module[[:blank:]]*//'
ROOT_PACKAGE=$(shell grep '^module\s\+.\+$$' go.mod|sed 's/module[[:blank:]]*//')

API_GROUPS ?= foo:v1alpha2 #foo:v1,v2
APIS_PKG=$(ROOT_PACKAGE)/apis
GEN_CLIENTSET_PKG=$(ROOT_PACKAGE)/clientset
GEN_LISTERS_PKG=$(ROOT_PACKAGE)/listers
GEN_INFORMERS_PKG=$(ROOT_PACKAGE)/informers

GENERATORS ?= defaulter-gen,conversion-gen,deepcopy-gen,client-gen,lister-gen,informer-gen,go-to-protobuf
#GENERATORS ?= go-to-protobuf
GOIMPORTS_EXCLUDES ?= clientset,informers,listers,third_party,proto/gen-go
GOFMT_SOURCES ?= app,client,log,scope,starlark,util,version

default: gen-all

gengrpc:
#I don't known how to specify go package_name for buf name.
#It seems that the buf generated a go package_name automatically which would be conflict if we specified a different one (by M opt).
#	@buf generate --path=proto/platform
	@rm -rf proto/gen-go
	@hack/update-proto.sh

gen-all: codegen gengrpc


clean::
	rm -rf proto/gen-go clientset informers listers

include hack/makelib/common.mk
include hack/makelib/golang.mk
include hack/makelib/image.mk