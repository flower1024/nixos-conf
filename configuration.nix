# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./duckdns.nix
      ./samba.nix
      ./nzb.nix
      ./nginx.nix
      ./twitch.nix
      ./borg.nix
      ./docker.nix
      ./mail.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.sensor.hddtemp.enable = true;
  hardware.sensor.hddtemp.drives = [
    "/dev/sda" "/dev/sdb"
  ];

  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 5d";
  nix.gc.dates = "daily";

  nixpkgs.config.allowUnfree = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.dates = "06:00";

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "10%";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
  boot.kernelModules = [ "amd-pstate"  ];
  boot.initrd.secrets = {
    "/etc/cryptkey.d/zfs" = "/etc/cryptkey.d/zfs";
  };
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_min=1073741824 zfs_arc_max=34359738368 zfs_txg_timeout=30 zfs_prefetch_disable=0 zfs_vdev_scheduler=deadline zfs_dirty_data_max_percent=25
  '';  

  security.sudo.wheelNeedsPassword = false;
  environment.etc."machine-id".source = "/state/etc/machine-id";
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.memoryPercent = 10;
  security.lockKernelModules = false;
  security.protectKernelImage = true;
  security.forcePageTableIsolation = false;
  environment.systemPackages = with pkgs; [ nftables iptables htop  ];

  services.journald.extraConfig = ''
    Storage=volatile
    RateLimitInterval=30s
    RateLimitBurst=10000
    RuntimeMaxUse=16M
    SystemMaxUse==16M
  '';

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "yes";
  services.openssh.extraConfig = ''
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
  '';
  services.fwupd.enable = true;

  networking.hostId = "HOSTID";
  networking.firewall.enable = true;
  networking.hostName = "nixos";
  networking.useDHCP = false;
  networking.bridges.br0.interfaces = [ "enp36s0f1" ];
  networking.interfaces.br0.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 445 139 5357 8080 ];
  networking.firewall.allowedUDPPorts = [ 137 138 3702 ];
  networking.firewall.allowPing = false;

  time.timeZone = "Europe/Berlin";

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "zroot" "zdata" ];
  services.zfs.autoScrub.interval = "weekly";
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoSnapshot.frequent = 2;
  services.zfs.autoSnapshot.hourly = 2;
  services.zfs.autoSnapshot.weekly = 0;
  services.zfs.autoSnapshot.monthly = 0;
  services.zfs.trim.enable = true;
  services.zfs.trim.interval = "weekly";

  users.groups.data = {};

  users.users.root.password = "PASS";
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa KEY==" ];

  users.users.flower.password = "PASS";
  users.users.flower.openssh.authorizedKeys.keys = [ "ssh-rsa KEY==" ];
  users.users.flower.isSystemUser = true;
  users.users.flower.group = "data";

  users.users.aileen.password = "PASS";
  users.users.aileen.openssh.authorizedKeys.keys = [ "ssh-rsa KEY==" ];
  users.users.aileen.isSystemUser = true;
  users.users.aileen.group = "data";

  system.stateVersion = "22.05";
}

