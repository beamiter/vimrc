function! myspacevim#before() abort
    set nocompatible
    let &t_TI = ""
    let &t_TE = ""
    let g:mapleader = ','
    set clipboard+=unnamedplus
    " let g:neomake_c_enabled_makers = ['clang']
    " nnoremap jk <Esc>
endfunction

function! myspacevim#after() abort
    " let g:Lf_UseCache = 0
    " let g:Lf_UseMemoryCache = 0
    " iunmap jk
    " call SpaceVim#custom#SPCGroupName(['G'], '+TestGroup')
    " call SpaceVim#custom#SPC('nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)
    " call SpaceVim#custom#LangSPCGroupName('python', ['G'], '+TestGroup')
    " call SpaceVim#custom#LangSPC('python', 'nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)
    nmap <space>ac <Plug>(coc-codeaction)

    """""""""""""""" gitgutter
    nmap [g <Plug>(GitGutterPrevHunk)
    nmap ]g <Plug>(GitGutterNextHunk)
  endfunction
