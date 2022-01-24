#!/bin/bash

function install_protobuf_grpc_compilers(){
  dst_bin_dir="$1"

  mkdir -p ${dst_bin_dir}

  grpc_bin="${dst_bin_dir}/protoc-gen-go-grpc"
  gogo_bin="${dst_bin_dir}/protoc-gen-gogo"
  tmpdir=`mktemp -d`
  (
  cd $tmpdir

  if [[ ! -f  $grpc_bin ]] || [[ ! -x $grpc_bin  ]]; then
    echo "installing go-grpc compiler..."
    curl -L https://github.com/grpc/grpc-go/archive/refs/tags/v1.31.1.tar.gz -o grpc-go-v1.31.1.tar.gz
    tar -zxf grpc-go-v1.31.1.tar.gz
    (cd grpc-go-1.31.1/cmd/protoc-gen-go-grpc;go build;mv protoc-gen-go-grpc $dst_bin_dir)
    rm -rf grpc-go-v1.31.1.tar.gz grpc-go-1.31.1
  fi

  if [[ ! -f  $gogo_bin ]] || [[ ! -x $gogo_bin  ]]; then
    echo "installing gogo protobuf compiler..."
    curl -L https://github.com/gogo/protobuf/archive/refs/tags/v1.3.2.tar.gz -o gogo-protobuf-v1.3.2.tar.gz
    tar -zxf gogo-protobuf-v1.3.2.tar.gz
    (cd protobuf-1.3.2/protoc-gen-gogo; go build;mv protoc-gen-gogo $dst_bin_dir)
    rm -rf gogo-protobuf-v1.3.2.tar.gz protobuf-1.3.2
  fi
  )
  rm -rf $tmpdir
}
