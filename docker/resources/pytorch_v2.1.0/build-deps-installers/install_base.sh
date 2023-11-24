#!/bin/bash

set -ex

install_ubuntu() {
  # NVIDIA dockers for RC releases use tag names like `11.0-cudnn8-devel-ubuntu18.04-rc`,
  # for this case we will set UBUNTU_VERSION to `18.04-rc` so that the Dockerfile could
  # find the correct image. As a result, here we have to check for
  #   "$UBUNTU_VERSION" == "18.04"*
  # instead of
  #   "$UBUNTU_VERSION" == "18.04"
  if [[ "$UBUNTU_VERSION" == "18.04"* ]]; then
    #cmake3="cmake=3.10*"
    cmake3="3.10*"
  else
    #cmake3="cmake=3.19*" #update for ubuntu 20.04
    cmake3="3.24.1*"
  fi
  

  # Install common dependencies
  # apt-get update
  apt update && apt upgrade
  # TODO: Some of these may not be necessary
  # TODO: libiomp also gets installed by conda, aka there's a conflict
  ccache_deps="asciidoc docbook-xml docbook-xsl xsltproc"
  numpy_deps="gfortran"
  apt-get install -y --no-install-recommends \
    $ccache_deps \
    $numpy_deps \
    ${cmake3} \
    apt-transport-https \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    git \
    libatlas-base-dev \
    libc6-dbg \
    libyaml-dev \
    libz-dev \
    libjpeg-dev \
    libasound2-dev \
    libsndfile-dev \
    python \
    python-dev \
    python-setuptools \
    software-properties-common \
    sudo \
    wget \
    vim
    # python-wheel \
    # libiomp-dev \
    
  #install specific version of cmake
  wget https://github.com/Kitware/CMake/releases/download/v${cmake3}/cmake-${cmake3}-Linux-x86_64.sh \
  -q -O /tmp/cmake-install.sh \
  && chmod u+x /tmp/cmake-install.sh \
  && sudo mkdir /opt/cmake-${cmake3} \
  && sudo /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-${cmake3} \
  && rm /tmp/cmake-install.sh \
  && sudo ln -s /opt/cmake-${cmake3}/bin/* /usr/local/bin
    
  # TODO: THIS IS A HACK!!!
  # distributed nccl(2) tests are a bit busted, see https://github.com/pytorch/pytorch/issues/5877
  if dpkg -s libnccl-dev; then
    apt-get remove -y libnccl-dev libnccl2 --allow-change-held-packages
  fi

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

install_centos() {
  # Need EPEL for many packages we depend on.
  # See http://fedoraproject.org/wiki/EPEL
  yum --enablerepo=extras install -y epel-release

  ccache_deps="asciidoc docbook-dtds docbook-style-xsl libxslt"
  numpy_deps="gcc-gfortran"
  # Note: protobuf-c-{compiler,devel} on CentOS are too old to be used
  # for Caffe2. That said, we still install them to make sure the build
  # system opts to build/use protoc and libprotobuf from third-party.
  yum install -y \
    $ccache_deps \
    $numpy_deps \
    autoconf \
    automake \
    bzip2 \
    cmake \
    cmake3 \
    curl \
    gcc \
    gcc-c++ \
    gflags-devel \
    git \
    glibc-devel \
    glibc-headers \
    glog-devel \
    hiredis-devel \
    libstdc++-devel \
    make \
    opencv-devel \
    sudo \
    wget \
    vim

  # Cleanup
  yum clean all
  rm -rf /var/cache/yum
  rm -rf /var/lib/yum/yumdb
  rm -rf /var/lib/yum/history
}

# Install base packages depending on the base OS
ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
case "$ID" in
  ubuntu)
    install_ubuntu
    ;;
  centos)
    install_centos
    ;;
  *)
    echo "Unable to determine OS..."
    exit 1
    ;;
esac

# Install Valgrind separately since the apt-get version is too old.
mkdir valgrind_build && cd valgrind_build
VALGRIND_VERSION=3.15.0
if ! wget http://valgrind.org/downloads/valgrind-${VALGRIND_VERSION}.tar.bz2
then
  wget https://sourceware.org/ftp/valgrind/valgrind-${VALGRIND_VERSION}.tar.bz2
fi
tar -xjf valgrind-${VALGRIND_VERSION}.tar.bz2
cd valgrind-${VALGRIND_VERSION}
./configure --prefix=/usr/local
make -j 4
sudo make install
cd ../../
rm -rf valgrind_build
alias valgrind="/usr/local/bin/valgrind"

