#!/usr/bin/env bash
set -e -u

# ... your existing customize_airootfs.sh content ...

# Overwrite calamares configs with kyon linux versions (after package install)
rm -rf /etc/calamares/*
cp -rf /root/kyon-calamares-configs/. /etc/calamares/
rm -rf /root/kyon-calamares-configs
