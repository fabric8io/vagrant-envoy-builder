#!/bin/sh

set -x
set -e

NUM_CPUS=`grep -c ^processor /proc/cpuinfo`

echo "building using $NUM_CPUS CPUs"

ENVOY_DIR=/opt/envoy_env

ENVOY_VERSION='v1.2.0'

cd $ENVOY_DIR

THIRDPARTY_DIR=$PWD/thirdparty
THIRDPARTY_BUILD=$PWD/thirdparty_build

export PATH=$PWD/gcc-4.9.4/bin:$PATH
export CC=`which gcc`
export CXX=`which g++`

export LD_LIBRARY_PATH=$PWD/gcc-4.9.4/lib64:$LD_LIBRARY_PATH

# download envoy sources ( do clean download )

if [ -d "$PWD/envoy" ]; then 
  rm -rf "$PWD/envoy"
fi

git clone https://github.com/lyft/envoy.git
cd envoy && git fetch && git checkout $ENVOY_VERSION
mkdir -p build && cd build

cmake \
-DENVOY_DEBUG:BOOL=OFF \
-DENVOY_STRIP:BOOL=ON \
-DCLANG-FORMAT:FILEPATH=clang-format \
-DCMAKE_CXX_FLAGS=-static-libstdc++ \
-DENVOY_COTIRE_MODULE_DIR:FILEPATH=$THIRDPARTY_DIR/cotire-cotire-1.7.8/CMake \
-DENVOY_GMOCK_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_GPERFTOOLS_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_GTEST_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_HTTP_PARSER_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_LIBEVENT_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_NGHTTP2_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_SPDLOG_INCLUDE_DIR:FILEPATH=$THIRDPARTY_DIR/spdlog-0.11.0/include \
-DENVOY_TCLAP_INCLUDE_DIR:FILEPATH=$THIRDPARTY_DIR/tclap-1.2.1/include \
-DENVOY_OPENSSL_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_LIGHTSTEP_TRACER_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_PROTOBUF_INCLUDE_DIR:FILEPATH=$THIRDPARTY_BUILD/include \
-DENVOY_PROTOBUF_PROTOC:FILEPATH=$THIRDPARTY_BUILD/bin/protoc \
-DENVOY_GCOVR:FILEPATH=$THIRDPARTY_DIR/gcovr-3.3/scripts/gcovr \
-DENVOY_RAPIDJSON_INCLUDE_DIR:FILEPATH=$THIRDPARTY_DIR/rapidjson-1.1.0/include \
-DENVOY_GCOVR_EXTRA_ARGS:STRING="-e test/* -e build/*" \
-DENVOY_EXE_EXTRA_LINKER_FLAGS:STRING=-L$THIRDPARTY_BUILD/lib \
-DENVOY_TEST_EXTRA_LINKER_FLAGS:STRING=-L$THIRDPARTY_BUILD/lib \
 ..

cmake -L || /bin/true

make -j $NUM_CPUS envoy

sudo mkdir -p /vagrant/bin
  
sudo cp $ENVOY_DIR/envoy/build/source/exe/envoy /vagrant/bin