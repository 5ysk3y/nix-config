{
  description = "Gibson - NixOS Flake";

  inputs = {

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # nixPkgs Stable
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/23.11";
    };

    # Other Stuff

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      #url = "github:hyprwm/Hyprlock";
      url = "git+file:./customPkgs/hyprlock";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.39.1";
    };

    hypridle = {
      url = "github:hyprwm/Hypridle";
    };

    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

    # Secrets Repo

    nix-secrets = {
      url="git+ssh://git@github.com/5ysk3y/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, emacs-overlay, hyprlock, hypridle, home-manager, doomemacs, sops-nix, ... } @inputs: {

nixosConfigurations = {
    nixpkgs.overlays = [ (import self.inputs.emacs-overlay) ];

    # Begin Main Machine (Gibson)
    "gibson" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };

        inherit system inputs;
      };

      modules = [
        ./hosts/gibson/configuration.nix
        sops-nix.nixosModules.sops # System-wide sops-nix

        # Begin Home Manager Setup
        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = {
            vars = {
              hostname = "gibson";
              username = "rickie";
            };
            pkgs-stable = import nixpkgs-stable {
              system = system;
              config.allowUnfree = true;
            };
            inherit inputs system doomemacs;
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops # home-manager sops-nix
          ];

          home-manager.users.rickie = {
            imports = [
              ./hosts/gibson/home.nix
            ];
          };

        } # End Home-Manager
      ]; # End modules
    }; # End gibson

    # Begin Testing VM (macbook)
    "macbook" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };

	vars = {
	  hostname = "macbook";
	  username = "rickie";
        };
        inherit inputs system;
      };

      modules = [
        ./hosts/macbook/configuration.nix

        # Begin Home Manager Setup
        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = {
            pkgs-stable = import nixpkgs-stable {
              system = system;
              config.allowUnfree = true;
            };

            vars = {
              hostname = "macbook";
              username = "rickie";
            };

            inherit inputs doomemacs;
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops # home-manager sops-nix
          ];

          home-manager.users.rickie = {
            imports = [
              ./hosts/macbook/home.nix
            ];
          };

        } # End Home-Manager
      ]; # End modules
    }; # End macbook
  };
};
}

