{
  description = "Terraform secure pipeline dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            opentofu
            terraform-ls
            tflint
            checkov
            conftest
            go
            docker
            docker-compose
            act
            go-task
            git
            jq
	    awscli
          ];

          shellHook = ''
            echo "Check tool versions!"
            tofu version
            go version
            checkov --version
            conftest --version
            git --version
            aws --version
            docker --version || echo "Docker not available or requires sudo"
            act --version
            driftctl version

            if [ -f .env.localstack ]; then
              source .env.localstack
            fi
            echo "Dev shell ready"
          '';
        };
      });
}
