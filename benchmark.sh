#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

results=results.txt
#DEPS=(build-essential ca-certificates devscripts autoconf autoconf-archive automake bison cmake doxygen)
DEPS=(build-essential ca-certificates devscripts)

_clean_pkgs() {
  sudo apt purge -y "${DEPS[@]}"
  sudo apt autoremove --purge -y
}

_install_pkgs() {
  booster=${1:-}
  sudo $booster apt install -y "${DEPS[@]}"
}

_run_tests() {
  booster=${1:-}
  T0=$(date +%s)
  for i in {1..2}; do
    t0=$(date +%s)
    _install_pkgs $booster
    echo ${booster:-regular}: $(( $(date +%s) - t0 )) s | tee -a "$results"
    _clean_pkgs
    #sync; sysctl -q vm.drop_caches=3
  done
  echo Total ${booster:-regular}: $(( $(date +%s) - T0 )) s | tee -a "$results"
}

sudo mkdir -p /etc/apt/apt.conf.d
echo 'Binary::apt::APT::Keep-Downloaded-Packages "1";' | sudo tee /etc/apt/apt.conf.d/10apt-keep-downloads

sudo apt update
_clean_pkgs
sudo apt install --download-only -y "${DEPS[@]}"
#sync; sysctl -q vm.drop_caches=3

_run_tests ""
_run_tests eatmydata

cat $results
