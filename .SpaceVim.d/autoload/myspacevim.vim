function! myspacevim#before() abort
    set nocompatible
    " let g:neomake_c_enabled_makers = ['clang']
    " nnoremap jk <Esc>
endfunction

function! myspacevim#after() abort
    " iunmap jk
    " call SpaceVim#custom#SPCGroupName(['G'], '+TestGroup')
    " call SpaceVim#custom#SPC('nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)
    " call SpaceVim#custom#LangSPCGroupName('python', ['G'], '+TestGroup')
    " call SpaceVim#custom#LangSPC('python', 'nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)
endfunction
