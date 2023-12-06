#!/bin/bash

set -ex

if [ -n "$VERIFICARLO_VERSION" ]; then

  echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu focal main universe" >> /etc/apt/sources.list
  sudo apt-get update
  #sudo apt-get install -y --no-install-recommends libmpfr-dev libtool gcc-7 g++-7 parallel
  #pip install bigfloat pandas scipy GitPython tables jinja2 bokeh

  
  sudo apt-get install -y libmpfr-dev clang-9 flang-7 llvm-7-dev parallel\
       gcc-7 g++-7 autoconf automake libtool build-essential python3 python3-numpy \
       python3-pip
  
  pip install bigfloat pandas scipy GitPython tables jinja2 bokeh
  git clone https://github.com/verificarlo/verificarlo
  cd verificarlo #use latest version
  #git checkout 936bec5ab9e496e64f46f9037e8340209b7fd6ec

  ./autogen.sh
  ./configure --without-flang --with-llvm=$(llvm-config-${CLANG_VERSION} --prefix) CC=gcc-7 CXX=g++-7
  make
  sudo make install


  #git clone https://github.com/verificarlo/verificarlo
  #cd verificarlo
  #git checkout 936bec5ab9e496e64f46f9037e8340209b7fd6ec
  #export PATH="$PATH:/usr/lib/llvm-9/bin/"
  #./autogen.sh
  #./configure --without-flang CC=gcc-7 CXX=g++-7
  #make
  #sudo make install
  cd ..
  rm -rf verificarlo

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi
