#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="kyonlinux"
iso_label="ARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Kyon Linux <https://adachippp.github.io/kyonlinux/>"
iso_application="Kyon Linux Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
  'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/etc/sddm.conf.d/autologin.conf"]="0:0:644"
  ["/etc/polkit-1/rules.d/49-calamares.rules"]="0:0:644"
  ["/root"]="0:0:750"
  ["/root/.config"]="0:0:750"
  ["/root/.config/plasma-org.kde.plasma.desktop-appletsrc"]="0:0:644"
  ["/usr/share/wallpapers/KyonDefault"]="0:0:755"
)
systemd_services=(
  'gpm.service'
  'NetworkManager.service'
  'systemd-resolved.service'
  'sddm.service'
)
