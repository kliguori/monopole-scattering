{
  # With each update re-pin with "nix develop --profile ./.gcroot"
  description = "Python and Ocaml dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs }:
    let
      # define system
      system = "x86_64-linux";
      
      # define packages
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pythonPkgs = pkgs.python312;
      ocamlPkgs = pkgs.ocaml-ng.ocamlPackages_5_3;
      
      # define dependencies
      pythonDeps = with pythonPkgs; [
        numpy
        scipy
        sympy
        pandas
        scikit-learn
        torch-bin
        torchvision-bin
        jupyterlab
        matplotlib
        seaborn
        ffmpeg
        tqdm
      ];
      ocamlDeps = with ocamlPkgs; [
        ocaml
        dune_3
        findlib
        utop
        odoc
        base
        core
      ];

      # define package specifications 
      mypkg = ocamlPkgs.buildDunePackage {
        pname = "scattering";
        version = "0.1.0";
        src = ./.;
        duneVersion = "3";
        buildInputs = ocamlDeps;
        meta.mainProgram = "scattering";
      };
    in
    {
      packages.${system}.default = mypkg;
      devShells.${system}.default = pkgs.mkShell {
        name = "pycaml";
        packages = (pythonPkgs.withPackages pythonDeps) ++ ocamlDeps;
        shellHook = ''
          export NIX_DEV_SHELL_NAME=pycaml
          export SHELL=${pkgs.zsh}/bin/zsh
          exec ${pkgs.zsh}/bin/zsh --login
        '';
      };
    };
}
