{ config, pkgs, ... }:

let
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
    version = "2020-09-30";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "e5d98d85693245fec811307e5a2ccfdea3a350cd";
      sha256 = "119537lcrqn84n3sqj917jql4nrczk85idj27yqhp0dafc21raa8";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.utf8proc ];
  });

  buildVimPluginFrom2Nix = pkgs.vimUtils.buildVimPluginFrom2Nix;

  # not very stable yet, no existing netcoredbg config
  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "2020-09-14";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "d3af0f3b470ee8a46aabb3837b97193dc16046e0";
      sha256 = "0j09i8hhls8y5xd57vp4sbpp0gvdmwd6wmb355w5j2cda84xagmd";
    };
  };

  vimLua = lua: ''
    lua << EOF
    ${lua}
    EOF
  '';
in {
  home.packages = with pkgs; [ graphviz ];

  programs.neovim = {
    enable = true;
    package = neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
      editorconfig-vim
      direnv-vim
      fzf-vim
      lightline-vim
      nerdtree
      vim-startify
      vim-polyglot
      vim-visual-multi
      vim-surround
      vim-commentary
      vim-easymotion
      vim-which-key
      vim-peekaboo
      vim-gitgutter
      vim-fugitive
      vim-test
      camelcasemotion
      argtextobj-vim
      wmgraphviz-vim

      nvim-lspconfig
      nvim-dap

      # might require :UpdateRemotePlugins
      deoplete-nvim
      deoplete-lsp

      vim-orgmode
    ];
    extraConfig = with builtins;
      readFile ./init.vim + readFile ./vim-surround-fix.vim
      + readFile ./which-key.vim + readFile ./test.vim
      + vimLua (readFile ./lsp/extensions.lua) + readFile ./lsp/lsp.vim + ''
        packloadall " https://github.com/neovim/neovim/issues/11409
        ${vimLua (readFile ./lsp/lsp.lua)}
      '';
    withNodeJs = true;
    withPython = false;
  };
}