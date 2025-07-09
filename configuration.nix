{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  time.timeZone = "Europe/London"; # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

  users.users = {
    root.hashedPassword = "!"; # Disable root login
    username = { # Replace 'username' with your desired username
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxqllr9tH4EJ8NBw0u698/DlLo6BGK8/oKaJfokJ8KvNM5NwescQcByWZFjhLOTcKBzwCLan0JYcUG38ojfenZW79PvyW9SxU8HyzwXZPPbTTbaVsV1ncjMyVJy/61j6fbavmOnAw/lsvVDuqVF36qMcsUwSx4EzOBalU2tst5+oWKgZhgPmAVF44f+Z2rqJszyH3q0WaZ4QOJlMEKfiRrZnVKxqNO7RQzwm9nb+qub65iqby663G9XmjgigEbIZzBT6HRhM0TGB4rfk9JcRMbu/+uAqaGPn4UEIdjrxyurSQxpju3qC6e4xyMmZAJXR65yM5pP2WbiIKHArTpSNOMa7HfYhloHhBwHh+KpU6sMQkm4t46wNpwcmnge58SSMOnCbr2bPuZWOLlrHyOIudOdwvplP605vCmhhrqkkPbm6I8I+dttJD9wYZNWMu0QDEcppoQBWpKP6FHuRJxw9/1eJTOfIykX+PPB1LiYf+mBKFt7fnBf72cSDiNR3ig223cx7AByOl1X8Yrc/MzmE4G0/dqdzudf9lzCD/CY4eNSeCkUFOnu8lNMhIjsIaKReaGtBkvxNboG6i8F8atDcdvTb7F/Vb7pBJWEDR95TCX+1AdrzimJh8fmEFWN1W1I49X4w7rcmzrcwH3lCj82B5EWQwlgYlFX1oHLf1YQRXvDw== daniel@funktional.dev"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.05";
}
