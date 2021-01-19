let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ 'active': {
      \  'left': [ [ 'winnr', 'mode', 'paste' ],
      \            [ 'gitbranch', 'gitstatus', 'readonly',
      \              'filename', 'modified',
      \              'cocstatus' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ],
      \             [ 'fileformat', 'fileencoding', 'filetype' ] ] },
      \ 'inactive': {
      \  'left': [ [ 'filename' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ] ] },
      \ 'tabline': {
      \  'left': [ [ 'tabs' ] ],
      \  'right': [ [ 'close' ] ] },
      \ 'component_function': {
      \  'cocstatus': 'coc#status',
      \  'gitbranch': 'FugitiveStatusline',
      \  'gitstatus': 'GitStatus',
      \ },
      \ 'component_expand': {
      \ 'tabs': 'lightline#tabs',
      \ },
      \ 'component_type': {
      \ 'tabs': 'tabsel',
      \ },
      \ }
      " \ 'gitbranch': 'FugitiveHead'
      " \   'buffers': 'lightline#bufferline#buffers',

autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
