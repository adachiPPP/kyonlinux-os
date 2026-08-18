#!/usr/bin/env bash
set -e -u

# Runs at build time inside the airootfs chroot, AFTER the `calamares` package
# has been installed (it comes from the [endeavouros] repo; the kyonrepo
# does not carry calamares).
#
# WHY this extra step exists:
#   The EndeavourOS *release* calamares package (26.03.2.3) is built with only
#   a subset of the fork's modules. It ships 32 modules and is MISSING
#   shellprocess, partition, unpackfs, users, umount, packages, welcome,
#   summary and services-systemd - i.e. almost everything Kyon's
#   /etc/calamares/settings.conf uses (including the shellprocess job that
#   installs the bootloader). With the release package alone, Calamares fails
#   at startup with "Module X not found in module search paths" (the
#   "bootloader" step included), so the installer errors out constantly.
#
#   EndeavourOS's own ISO never uses the release package on its own: it
#   overlays a full-module build (their "calamares-git" devel package, built
#   from the same fork with all modules enabled) over it. We do the same here:
#   download that full build and install it over the release package BEFORE
#   copying the Kyon configs below.
#
# NOTE on ordering: the devel package also installs its own /etc/calamares
# files (EOS settings_*.conf, module configs and scripts). The Kyon configs
# must therefore be copied LAST, which the block at the bottom does.
pacman-key --init

# Sanity check: every module settings.conf relies on must now exist. Fail the
# build loudly instead of silently producing an ISO whose installer cannot run.
for m in shellprocess partition unpackfs users umount packages welcome summary services-systemd initcpiocfg localecfg; do
  [ -d "/usr/lib/calamares/modules/$m" ] || {
    echo "FATAL: calamares module '$m' missing after full-module install - the installer would be broken" >&2
    exit 1
  }
done

# Replace the stock /etc/calamares configs (from the calamares package) with
# the Kyon Linux ones. This must run AFTER the full-module install so the
# Kyon configs win over the package's own /etc/calamares files.
rm -rf /etc/calamares
cp -a /root/kyon-calamares-configs /etc/calamares
rm -rf /root/kyon-calamares-configs

# /etc/skel/.zshrc cannot ship directly in the airootfs: grml-zsh-config
# installs the same path, and pacman's file-conflict CHECK (before
# extraction) does not consult NoExtract, so the ISO build aborts. Ship it
# under /root/dotfiles instead and install it here, AFTER packages are
# installed, so pacstrap never sees a collision.
install -Dm644 /root/dotfiles/.zshrc /etc/skel/.zshrc
rm -rf /root/dotfiles

# Give the live root session (SDDM autologin -> Plasma) the same dotfiles as
# /etc/skel: the live ISO is the first place the user sees their setup, and
# without this /root has no kitty / zsh / ... configs at all, so e.g. kitty
# opens with its default config on the live system. New users created during
# install get the same files via the copy_skel calamares step.
cp -a /etc/skel/. /root/

# The live root session also needs the Oh My Zsh + plugin setup that
# shell-setup applies to new users during install (the .zshrc sources
# ~/.oh-my-zsh and starship/fastfetch binaries). Mirror it here so the live
# ISO's zsh prompt works, not just the installed system. Non-fatal: a build
# without network must not fail because of this.
if [ -x /bin/zsh ] && command -v curl >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
    CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    if [ -d /root/.oh-my-zsh ]; then
        omz_plugins="/root/.oh-my-zsh/custom/plugins"
        mkdir -p "$omz_plugins"
        for p in zsh-autosuggestions zsh-syntax-highlighting; do
            [ -d "/usr/share/zsh/plugins/$p" ] && ln -sfn "/usr/share/zsh/plugins/$p" "$omz_plugins/$p"
        done
        if [ ! -e "$omz_plugins/fast-syntax-highlighting" ]; then
            git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting \
                "$omz_plugins/fast-syntax-highlighting" &>/dev/null || true
        fi
    fi
fi
