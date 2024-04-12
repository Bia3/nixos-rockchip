{ config, pkgs, lib, modulesPath, ... }: {
  config.boot.postBootCommands = lib.mkBefore ''
    ${config.boot.postBootCommands}

    random_mac() {
      printf '00:60:2F:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]'
    }

    if [[ ! -e /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules ]]; 
      echo "SUBSYSTEM==\"net\", ACTION==\"add\", KERNEL==\"eth0\", ATTR{address}==\"$(random_mac)\"" >> /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules
      echo "SUBSYSTEM==\"net\", ACTION==\"add\", KERNEL==\"eth1\", ATTR{address}==\"$(random_mac)\"" >> /etc/udev/rules.d/10-network-persistent-custom-mac-address.rules
    fi
  '';
}