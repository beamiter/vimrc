let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ 'active': {
      \  'left': [ [ 'winnr', 'mode', 'paste' ],
      \            [ 'gitbranch', 'gitstatus', 'readonly',
      \              'filename', 'modified' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ],
      \             [ 'fileformat', 'fileencoding', 'filetype' ] ] },
      \ 'inactive': {
      \  'left': [ [ 'winnr', 'filename' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ] ] },
      \ 'tabline': {
		  \  'left': [ [ 'readonly', 'absolutepath', 'modified' ] ],
      \  'right': [ [ 'close' ] ] },
      \ 'component_function': {
      \  'gitbranch': 'FugitiveStatusline',
      \  'gitstatus': 'GitStatus',
      \ },
      \ 'component_expand': {
      \ },
      \ 'component_type': {
      \ 'buffers': 'tabsel',
      \ },
      \ }
      " \ 'gitbranch': 'FugitiveHead'

function! GitStatus() abort
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
