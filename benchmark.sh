#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

results=results.txt
#_dependencies=(build-essential ca-certificates devscripts autoconf autoconf-archive automake bison cmake doxygen)
_dependencies=(build-essential devscripts)

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
    #sync; sysctl -q vm.drop_caches=3
  done
  echo Total ${booster:-regular}: $(( $(date +%s) - T0 )) s | tee -a "$results"
}

sudo mkdir -p /etc/apt/apt.conf.d
echo 'Binary::apt::APT::Keep-Downloaded-Packages "1";' | sudo tee /etc/apt/apt.conf.d/10apt-keep-downloads

sudo apt update -qqq
_clean_pkgs
sudo apt install --download-only -qqqy "${_dependencies[@]}"
#sync; sysctl -q vm.drop_caches=3
rm -f "$results" ||:

_run_tests ""
_run_tests eatmydata

cat "$results"
