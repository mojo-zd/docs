#!/bin/bash

set -e

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
ROOT_PATH="$(cd "${SCRIPT_PATH}/.." && pwd)"

cd $ROOT_PATH

source $ROOT_PATH/hack/lib.sh

TOOLS_BIN_DIR="$ROOT_PATH/output/tools"
export PATH=$TOOLS_BIN_DIR:$PATH

install_protobuf_grpc_compilers $TOOLS_BIN_DIR

mkdir -p proto/gen-go

go_proto_compiler=gogo
proto_dir=proto

#We don't fix "option go_package" inside a proto file. Instead, it is set at compile time via the M option of protoc-gen-go on the command line.
protos=$(cd $proto_dir; find platform -name '*.proto')
pb_sources=()
source_go_opts=()
grpc_sources=()
source_go_grpc_opts=()
proto_go_package=git.woa.com/khaos/pkg/proto/gen-go

for pbfile in ${protos[@]}; do
  #module_path_name=`echo $pbfile | xargs -n1 dirname | tr -d / `
  module_path_name=`dirname $pbfile`
  module_opt="M${pbfile}=${proto_go_package}/$module_path_name"
  source_go_opts+=("--${go_proto_compiler}_opt=$module_opt")
  pb_sources+=("$pbfile") #virtual fs, don't prepend the $proto_dir which has specified as import dir
  grpc_sources+=("$pbfile")
  source_go_grpc_opts+=("--go-grpc_opt=$module_opt;`basename $module_path_name`")
done

common_modules=(
k8s.io/apimachinery/pkg/api/resource/generated.proto=k8s.io/apimachinery/pkg/api/resource
k8s.io/apimachinery/pkg/runtime/generated.proto=k8s.io/apimachinery/pkg/runtime
k8s.io/apimachinery/pkg/runtime/schema/generated.proto=k8s.io/apimachinery/pkg/runtime/schema
k8s.io/apimachinery/pkg/apis/meta/v1/generated.proto=k8s.io/apimachinery/pkg/apis/meta/v1
k8s.io/apimachinery/pkg/util/intstr/generated.proto=k8s.io/apimachinery/pkg/util/intstr
k8s.io/api/core/v1/generated.proto=k8s.io/api/core/v1
git.woa.com/khaos/pkg/apis/khaos/v1alpha2/generated.proto=git.woa.com/khaos/pkg/apis/khaos/v1alpha2
)

proto_go_pb_common_opts=()
grpc_go_pb_common_opts=()
for o in ${common_modules[@]};do
  proto_go_pb_common_opts+=("--${go_proto_compiler}_opt=M${o}")
  grpc_go_pb_common_opts+=("--go-grpc_opt=M${o}")
done


#./staging is used to import other protos with prefix 'git.woa.com/khaos/pkg/proto'

for pb_source in ${pb_sources[@]};do
protoc \
  -I proto/gen-go \
  -I third_party \
  -I $proto_dir \
  -I ./staging \
  "${proto_go_pb_common_opts[@]}" \
  "${source_go_opts[@]}" \
  --${go_proto_compiler}_opt=module=$proto_go_package \
  --${go_proto_compiler}_out=proto/gen-go \
  $pb_source
# "${pb_sources[@]}"
done

protoc \
  -I proto/gen-go \
  -I third_party \
  -I $proto_dir \
  -I ./staging \
  "${grpc_go_pb_common_opts[@]}" \
  "${source_go_grpc_opts[@]}" \
  --go-grpc_opt=paths=source_relative \
  --go-grpc_out=proto/gen-go \
  "${grpc_sources[@]}"

for gofile in `find proto/gen-go -name "*.go"`;do
  cat hack/boilerplate/boilerplate.go.txt $gofile > $gofile.tmp
  mv $gofile.tmp $gofile
done
