with (import <nixpkgs> {});
mkShell {
    shellHook = ''
        export FOO=bar
    '';
    buildInputs = [
        ripgrep
        neovim
        vim
        clang
    ];
}
