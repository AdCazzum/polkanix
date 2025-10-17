{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "";
        flake-compat.follows = "";
        gitignore.follows = "";
      };
    };
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = ["x86_64-linux"];

        imports =
          lib.filesystem.listFilesRecursive ./.
          |> lib.map builtins.toString
          |> lib.filter (lib.hasSuffix ".nix")
          |> lib.filter (f: !lib.hasSuffix "flake.nix" f)
          |> lib.filter (f: !lib.hasInfix "/_" f);

        _module.args.rootPath = ./.;
      }
    );
}
