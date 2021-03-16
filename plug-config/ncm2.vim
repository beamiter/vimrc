" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

let ncm2#popup_delay = 5

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:

au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'python',
        \ 'priority': 9,
        \ 'subscope_enable': 1,
        \ 'scope': ['python'],
        \ 'mark': 'python',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': '\.',
        \ 'on_complete': ['ncm2#on_complete#delay', 1000,
        \ 'ncm2#on_complete#omni', 'python3complete#Complete'],
        \ })

" path to directory where libclang.so can be found
"let g:python3_host_prog = '/usr/bin/python3'
