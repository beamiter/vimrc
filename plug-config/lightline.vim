
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'winnr', 'mode', 'paste' ],
      \             [ 'gitbranch', 'gitstatus', 'readonly',
      \               'filename', 'modified', 'cocstatus' ] ],
      \ },
		  \ 'inactive': {
		  \ 'left': [ [ 'winnr' ], ['winnr'] ],
		  \ 'right': [ [ 'lineinfo' ],
		  \            [ 'percent' ],
      \            [ 'filename' ] ],
      \ },
      \ 'tabline': {
      \   'left': [ ['buffers'] ],
      \   'right': [ ['close'] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveStatusline',
      \   'gitstatus': 'GitStatus',
      \   'tabnum': 'lightline#tab#tabnum',
			\   'cocstatus': 'coc#status',
      \ },
      \ 'component_expand': {
      \   'buffers': 'lightline#bufferline#buffers',
      \ },
      \ 'component_type': {
      \   'buffers': 'tabsel'
      \ }
      \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
