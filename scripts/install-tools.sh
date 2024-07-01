#!/usr/bin/env sh

if [ ! -d "" ]; then
  mkdir tools -p
fi

if [ ! -d "./tools/vcpkg" ]; then
  cd tools
  git clone https://github.com/microsoft/vcpkg.git
  cd vcpkg
  ./bootstrap-vcpkg.sh
  cd ../..
fi
