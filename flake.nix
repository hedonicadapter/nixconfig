{
  description = "Your new nix config";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = { url = "github:Aylur/ags"; };

    spicetify-nix = { url = "github:the-argus/spicetify-nix"; };

    nixneovimplugins = { url = "github:jooooscha/nixpkgs-vim-extra-plugins"; };

    stylix = { url = "github:danth/stylix"; };

    nur = { url = "github:nix-community/NUR"; };

    matugen = {
      url = "github:/InioX/Matugen";
      # ref = "refs/tags/matugen-v0.10.0";
    };

    awesome-neovim-plugins = {
      url = "github:m15a/flake-awesome-neovim-plugins";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      # Accessible through 'nix build', 'nix shell', etc
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            # > Our main nixos configuration file <
            ./nixos/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      homeConfigurations = {
        "hedonicadapter@default" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };

          modules = [ ./home-manager/home.nix ];
        };
      };

      devShell.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
          gst_all_1.gstreamer
          # Common plugins like "filesrc" to combine within e.g. gst-launch
          gst_all_1.gst-plugins-base
          # Specialized plugins separated by quality
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
          # Plugins to reuse ffmpeg to play almost every video format
          gst_all_1.gst-libav
          # Support the Video Audio (Hardware) Acceleration API
          gst_all_1.gst-vaapi
          #...
        ];
      };
    };
}
