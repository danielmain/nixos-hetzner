{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    deploy-rs.url = "github:serokell/deploy-rs";
    visitflow.url = "github:danielmain/visitflow-backend";
  };
  
  outputs = { nixpkgs, deploy-rs, visitflow, ... }: {
    nixosConfigurations = {
      hetzner-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          {
            # Use the app package from your repo
            systemd.services.visitflow.serviceConfig.ExecStart = 
              "${visitflow.packages.x86_64-linux.default}/bin/visitflow-backend";
          }
        ];
      };
    };
    
    deploy.nodes.hetzner = {
      hostname = "static.120.186.55.162.clients.your-server.de";
      sshUser = "daniel";
      user = "root";
      
      profiles.system = {
        path = deploy-rs.lib.x86_64-linux.activate.nixos 
          self.nixosConfigurations.hetzner-x86_64;
      };
    };
    
    checks = builtins.mapAttrs 
      (system: deployLib: deployLib.deployChecks self.deploy) 
      deploy-rs.lib;
  };
}
