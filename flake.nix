{
  description =
    "Get up and running with Llama 2, Mistral, and other large language models locally";

  inputs = {
    nixpkgs.url = "github:abysssol/nixpkgs/update-ollama-0.1.24";
    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unfree, ... }:
    let
      inherit (nixpkgs) lib;

      forAllSystems = systems: function:
        lib.genAttrs systems (system:
          function
            nixpkgs.legacyPackages.${system}
            nixpkgs-unfree.legacyPackages.${system});

      unixPackages = (forAllSystems lib.platforms.unix (pkgs: _: {
        default = pkgs.ollama;
        cpu = pkgs.ollama;
      }));

      linuxPackages = (forAllSystems lib.platforms.linux (pkgs: pkgsUnfree: {
        default = pkgsUnfree.ollama.override { enableRocm = true; enableCuda = true; };
        gpu = pkgsUnfree.ollama.override { enableRocm = true; enableCuda = true; };
        rocm = pkgs.ollama.override { enableRocm = true; };
        cuda = pkgsUnfree.ollama.override { enableCuda = true; };
        cpu = pkgs.ollama;
      }));
    in
    {
      packages = unixPackages // linuxPackages;
    };
}
