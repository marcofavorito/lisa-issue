#!/usr/bin/env bash

ROOT_DIR="$(pwd)"

function build_cmake() {
  path="$1"
  cmake_cmd="$2"
  make_cmd="$3"
  echo "Entering ${path}..."
  cd "$path"
  rm -rf build
  mkdir build && cd build 
  cmake .. ${cmake_cmd}
  make -j4 ${make_cmd}
  make install

  echo "Returning to ${ROOT_DIR}..."
  cd "${ROOT_DIR}"
}


function build_spot() {
  path="$1"
  echo "Entering ${path}..."
  cd "$path"

  echo "pre-configure Spot"
  libtoolize --force
  aclocal
  autoheader
  automake --force-missing --add-missing
  autoconf

  echo "pre-configure Buddy"
  cd buddy
  libtoolize --force
  aclocal
  autoheader
  automake --force-missing --add-missing
  autoconf
  ./configure
  cd ..

  ./configure --disable-python --disable-doc --disable-tl
  make -j4
  make install
  cd "${ROOT_DIR}"
}

function build_lisa(){
  path="$1"
  echo "Entering ${path}..."
  cd "$path"
  cd src
  make T1
  echo "Returning to ${ROOT_DIR}..."
  cd "${ROOT_DIR}"
}

function build_autotools(){
  path="$1"
  command="${2:-./configure && make install}"
  echo "Using autotools command: '${command}'"
  echo "Entering ${path}..."
  cd "$path"

  # pre-configure  
  libtoolize --force
  aclocal
  autoheader
  automake --force-missing --add-missing
  autoconf

  bash -c "$command"

  echo "Returning to ${ROOT_DIR}..."
  cd "${ROOT_DIR}"
}

set -e

build_autotools "third_party/cudd" "./configure --enable-silent-rules --enable-obj --enable-dddmp && make install"
build_autotools "third_party/MONA"
build_cmake "third_party/Syft"
build_spot "third_party/spot" 
build_lisa "third_party/lisa"

set +e

