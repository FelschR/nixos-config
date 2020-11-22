{ config, pkgs, ... }:

let
  omnisharp-roslyn = pkgs.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
    pname = "omnisharp-roslyn";
    version = "1.37.3";

    src = pkgs.fetchurl {
      url =
        "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
      sha256 = "x0TRswtwlWWukx7fqjlfaV7/xF5ZMc0JT7zfzHX3BCY=";
    };
  });
in {
  home.packages = with pkgs; [
    # language servers
    omnisharp-roslyn
    rnix-lsp
    terraform-ls
    python3Packages.python-language-server
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.typescript-language-server
    nodePackages.dockerfile-language-server-nodejs
    haskellPackages.haskell-language-server
    nodePackages.diagnostic-languageserver

    # linters
    nodePackages.eslint
    # nodePackages.stylelint
    nodePackages.prettier
  ];

  # UseLegacySdkResolver: true is currently required
  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "MsBuild": {
          "UseLegacySdkResolver": true
        },
        "FormattingOptions": {
          "EnableEditorConfigSupport": true
        },
        "RoslynExtensionsOptions": {
          "EnableAnalyzersSupport": true
        }
      }
    '';
  };
}
