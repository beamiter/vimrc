" Required for operations modifying multiple buffers like rename.
set hidden
set signcolumn=yes

augroup filetype_rust
    autocmd!
    autocmd BufReadPost *.rs setlocal filetype=rust
augroup END

" Always draw sign column. Prevent buffer moving when adding/deleting sign.
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'stable', 'rls'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'cpp': ['clangd'],
    \ }

let $RUST_BACKTRACE = 1
let g:LanguageClient_virtualTextPrefix = ''
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_loggingFile =  expand('~/.local/share/nvim/LanguageClient.log')
let g:LanguageClient_serverStderr = expand('~/.local/share/nvim/LanguageServer.log')

" note that if you are using Plug mapping you should not use `noremap` mappings.
" Or map each action separately
nmap <silent>K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> gr <Plug>(lcn-references)
nmap <silent> gi <Plug>(lcn-implementation)
nmap <silent> gs <Plug>(lcn-symbols)
nmap <silent> gf <Plug>(lcn-format)
