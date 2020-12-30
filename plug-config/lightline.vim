
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste', 'scroll' ], [ 'gitbranch', 'gitstatus', 'readonly',
      \               'filename', 'modified' ] ],
      \ },
      \ 'tabline': {
      \   'left': [ ['buffers'] ],
      \   'right': [ ['close'] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveStatusline',
      \   'gitstatus': 'GitStatus',
      \   'readonly': 'LightlineReadonly',
      \   'modified': 'LightlineModified',
      \   'tabnum': 'lightline#tab#tabnum',
      "\   'scroll': 'ScrollStatus',
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

let g:scrollstatus_size = 10
let g:scrollstatus_symbol_track = '-'
let g:scrollstatus_symbol_bar = '|'

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
function! LightlineReadonly()
	return &readonly ? 'RO' : 'RW'
endfunction
function! LightlineModified()
	return &modifiable && &modified ? '+' : ''
endfunction
