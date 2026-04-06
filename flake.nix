{
  description = "Helm 4 - installed as 'helm4' alongside Helm 3";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          version = "4.1.3";

          sources = {
            x86_64-linux = {
              url = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz";
              sha256 = "02ce9722d541238f81459938b84cf47df2fdf1187493b4bfb2346754d82a4700";
              subdir = "linux-amd64";
            };
            aarch64-linux = {
              url = "https://get.helm.sh/helm-v${version}-linux-arm64.tar.gz";
              sha256 = "5db45e027cc8de4677ec869e5d803fc7631b0bab1c1eb62ac603a62d22359a43";
              subdir = "linux-arm64";
            };
            x86_64-darwin = {
              url = "https://get.helm.sh/helm-v${version}-darwin-amd64.tar.gz";
              sha256 = "742132e11cc08a81c97f70180cd714ae8376f8c896247a7b14ae1f51838b5a0b";
              subdir = "darwin-amd64";
            };
            aarch64-darwin = {
              url = "https://get.helm.sh/helm-v${version}-darwin-arm64.tar.gz";
              sha256 = "21c02fe2f7e27d08e24a6bf93103f9d2b25aab6f13f91814b2cfabc99b108a5e";
              subdir = "darwin-arm64";
            };
          };

          src = sources.${system};

        in
        {
          default = self.packages.${system}.helm4;

          helm4 = pkgs.stdenvNoCC.mkDerivation {
            pname = "helm4";
            inherit version;

            src = pkgs.fetchurl {
              url = src.url;
              sha256 = src.sha256;
            };

            nativeBuildInputs = [ pkgs.gnutar ];

            unpackPhase = ''
              tar xf $src
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp ${src.subdir}/helm $out/bin/helm4
            '';

            meta = with pkgs.lib; {
              description = "The Kubernetes package manager (v4), installed as helm4";
              homepage = "https://helm.sh";
              license = licenses.asl20;
              platforms = builtins.attrNames sources;
              mainProgram = "helm4";
            };
          };
        });

      # Convenience: expose as an overlay too
      overlays.default = final: prev: {
        helm4 = self.packages.${final.system}.helm4;
      };
    };
}