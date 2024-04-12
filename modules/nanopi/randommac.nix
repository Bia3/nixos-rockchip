{ config, pkgs, lib, modulesPath, ... }: {
  config.boot.postBootCommands = ''
    ${config.boot.postBootCommands}

    if [[ ! -e /var/lib/private/lan_mac ]]; 
      printf '00:60:2F:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] > /var/lib/private/lan_mac
    fi
    if [[ ! -e /var/lib/private/wan_mac ]];
      printf '00:60:2F:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] > /var/lib/private/wan_mac
    fi
  '';
}