{ config, pkgs, lib, modulesPath, ... }: {
  config.boot.postBootCommands = lib.mkForce ''
    # On the first boot do some maintenance tasks
    if [ -f /nix-path-registration ]; then
      set -euo pipefail
      set -x
      # Figure out device names for the boot device and root filesystem.
      rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
      bootDevice=$(lsblk -npo PKNAME $rootPart)
      partNum=2 # HARDCODED

      # Resize the root partition and the filesystem to fit the disk
      echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
      ${pkgs.parted}/bin/partprobe
      ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

      

      # Register the contents of the initial Nix store
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

      # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

      # Prevents this from running on later boots.
      rm -f /nix-path-registration
    fi

    random_mac() {
      printf '00:60:2F:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]
    }

    if [[ ! -e /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules ]]; then
      echo "SUBSYSTEM==\"net\", ACTION==\"add\", KERNEL==\"eth0\", ATTR{address}==\"$(random_mac)\"" >> /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules
      echo "SUBSYSTEM==\"net\", ACTION==\"add\", KERNEL==\"eth1\", ATTR{address}==\"$(random_mac)\"" >> /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules
    fi
  '';
}