{
  description = "Emacs Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = {
      url = "github:/nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      emacs-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues emacs-overlay.overlays;
        };

        nativeBuildInputs = with pkgs; [ ];
        buildInputs = with pkgs; [ ];
        myEmacs = pkgs.emacsWithPackagesFromUsePackage {
          # Your Emacs config file. Org mode babel files are also
          # supported.
          # NB: Config files cannot contain unicode characters, since
          #     they're being parsed in nix, which lacks unicode
          #     support.
          #config = ./emacs.org;
          config = pkgs.replaceVarsWith {
            src = ./emacs.org;
            replacements = {
              #Any variables defined here will replace matchinv @VARIABLENAME@ blocks in the input file
              # inherit (config.xdg) configHome dataHome;
              username = "mrhappy200";
            };
          };

          # Whether to include your config as a default init file.
          # If being bool, the value of config is used.
          # Its value can also be a derivation like this if you want to do some
          # substitution:
          defaultInitFile = true;
          #defaultInitFile = {
          #  config = pkgs.replaceVarsWith {
          #    src = pkgs.tangleOrgBabelFile "init.el" ./emacs.org {
          #      languages = [
          #        "emacs-lisp"
          #        "elisp"
          #      ];
          #    };
          #    replacements = {
          #      #Any variables defined here will replace matchinv @VARIABLENAME@ blocks in the input file
          #      # inherit (config.xdg) configHome dataHome;
          #    };
          #  };
          #};
          #defaultInitFile = pkgs.replaceVarsWith {
          #  src = pkgs.tangleOrgBabelFile "init.el" ./emacs.org {
          #    languages = [
          #      "emacs-lisp"
          #      "elisp"
          #    ];
          #  };
          #  replacements = {
          #    #Any variables defined here will replace matchinv @VARIABLENAME@ blocks in the input file
          #    #inherit (config.xdg) configHome dataHome;
          #  };
          #};

          # Package is optional, defaults to pkgs.emacs
          package = pkgs.emacs-unstable-pgtk;

          # By default emacsWithPackagesFromUsePackage will only pull in
          # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
          # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
          # and pulls in all use-package references not explicitly disabled via
          # `:ensure nil` or `:disabled`.
          # Note that this is NOT recommended unless you've actually set
          # `use-package-always-ensure` to `t` in your config.
          alwaysEnsure = true;

          # For Org mode babel files, by default only code blocks with
          # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
          # will include all code blocks missing the `:tangle` argument,
          # defaulting it to `yes`.
          # Note that this is NOT recommended unless you have something like
          # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
          # which defaults `:tangle` to `yes`.
          alwaysTangle = true;

          # Optionally provide extra packages not in the configuration file.
          # This can also include extra executables to be run by Emacs (linters,
          # language servers, formatters, etc)
          extraEmacsPackages = epkgs: [
            epkgs.cask
            pkgs.shellcheck
          ];
        };

      in
      {
        packages.default = myEmacs;
        devShells.default = pkgs.mkShell { inherit myEmacs nativeBuildInputs buildInputs; };
      }
    );
}
