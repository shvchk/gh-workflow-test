#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

results=results.txt
_dependencies=(
  autoconf
  autoconf-archive
  automake
  autopoint
  bison
  build-essential
  cmake
  doxygen
  fakeroot
  flex
  gettext
  git
  help2man
  libblkid-dev
  libc-ares-dev
  libcurl4-openssl-dev
  libdevmapper-dev
  libev-dev
  libevent-dev
  libexif-dev
  libflac-dev
  libgmp3-dev
  libid3tag0-dev
  libjpeg-dev
  libkeyutils-dev
  libltdl-dev
  libmpc-dev
  libmpfr-dev
  libncurses5-dev
  libogg-dev
  libsqlite3-dev
  libssl-dev
  libtool
  libtool-bin
  libudev-dev
  libvorbis-dev
  libxml2-dev
  ppp-dev
  texinfo
  xxd
  zstd
)

_clean_pkgs() {
  sudo eatmydata apt purge -qqqy "${_dependencies[@]}"
  sudo eatmydata apt autoremove --purge -qqqy
}

_install_pkgs() {
  booster=${1:-}
  sudo $booster apt install -qqqy "${_dependencies[@]}"
}

_run_tests() {
  booster=${1:-}
  T0=$(date +%s)
  for i in {1..2}; do
    t0=$(date +%s)
    _install_pkgs $booster
    echo ${booster:-regular}: $(( $(date +%s) - t0 )) s | tee -a "$results"
    _clean_pkgs
    sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
  done
  echo Total ${booster:-regular}: $(( $(date +%s) - T0 )) s | tee -a "$results"
}

sudo mkdir -p /etc/apt/apt.conf.d
echo 'Binary::apt::APT::Keep-Downloaded-Packages "1";' | sudo tee /etc/apt/apt.conf.d/10apt-keep-downloads

sudo apt update -qqq
_clean_pkgs
sudo apt install --download-only -qqqy "${_dependencies[@]}"
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
rm -f "$results" ||:

_run_tests ""
_run_tests eatmydata

cat "$results"
