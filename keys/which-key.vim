" Create map to add keys to
let @s = 'veS"'

let g:which_key_display_names = {'<CR>': '↵', '<TAB>': '⇆'}
" Define a separator
let g:which_key_sep = '→'
" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Register which key map
"autocmd VimEnter * call which_key#register('<Space>', "g:which_key_map")
"autocmd VimEnter * call which_key#register(',', "g:which_key_map0")

call which_key#register('<Space>', "g:which_key_map")
call which_key#register(',', "g:which_key_map0")

" register dictionary for the <Space>-prefix
"call which_key#register(' ', "g:space_prefix_dict")
" register dictionary for the ,-prefix
"call which_key#register(',', "g:comma_prefix_dict")

"nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
"vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
"nnoremap <localleader> :<c-u>WhichKey  ','<CR>
"vnoremap <localleader> :<c-u>WhichKeyVisual  ','<CR>

let g:which_key_map =  {}
let g:which_key_map0 = {}

" Map leader to which_key
nnoremap <silent> <leader> :silent <c-u> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Map localleader to which_key
nnoremap <silent> <localleader> :silent <c-u> :silent WhichKey ','<CR>
vnoremap <silent> <localleader> :silent <c-u> :silent WhichKeyVisual ','<CR>

let g:which_key_map0['o'] = ['<Plug>TFTPrompt', 'color eggs']

"" Hide status line
"autocmd! FileType which_key
"autocmd  FileType which_key set laststatus=0 noshowmode noruler
  "\| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" nnoremap <leader>gf :<C-u>Git log <C-R>=expand("%")<CR><CR>
function! GitCurrentFile()
  execute 'Git log '.expand('%:p')
endfunction
command! -nargs=0 GCurrent :call GitCurrentFile()


" a is for actions.
let g:which_key_map.a = {
      \ 'name' : '+actions' ,
      \ 'f' : [':Neoformat'                          , 'format files'],
      \ 'r' : ['<Plug>(lcn-rename)'                  , 'rename'],
      \ 'u' : 'random color scheme',
      \ 'v' : 'save color scheme',
      \ }

" b is for buffers.
let g:which_key_map.b = {
      \ 'name' : '+buffers',
      \ 'b' : [':LeaderfBuffer'                 , 'buffers'],
      \ 'd' : [':bwipeout'                      , 'wipeout buffer'],
      \ 'f' : [':LeaderfBuffer'                 , 'leaderf buffer'],
      \ 'z' : [':Buffers'                       , 'fzf buffer'],
      \}


" c is for comments.
let g:which_key_map.c = {
      \ 'name' : '+comment|format' ,
      \ }


" f is for files
let g:which_key_map.f = {
      \ 'name' : '+files',
      \ 'h' : [':History'                       , 'fzf history'],
      \ 'f' : [':LeaderfFile'                   , 'leaderf file'],
      \ 'm' : [':LeaderfMru'                    , 'leaderf mru'],
      \ 't' : [':LeaderfBufTag'                 , 'leaderf buf tag'],
      \ 's' : [':Vista!!'                       , 'vista toggle'],
      \ 'z' : [':Files'                         , 'fzf file'],
      \}


" g is for git
let g:which_key_map.g = {
      \ 'name' : '+git' ,
      \ 'b' : [':Git blame'                          , 'fzf blame'],
      \ 'B' : [':Gina blame'                         , 'gina blame'],
      \ 'c' : [':BCommits'                           , 'fzf buffer commits'],
      \ 'd' : [':Git diff'                           , 'git diff'],
      \ 'D' : [':Gina diff'                          , 'gina diff'],
      \ 'e' : [':Gina compare'                       , 'gina compare'],
      \ 'f' : [':GCurrent'                           , 'curent log'],
      \ 'g' : ['<Plug>(GitGutterPreviewHunk)'        , 'preview hunk'],
      \ 'h' : ['<Plug>(GitGutterStageHunk)'          , 'stage hunk'],
      \ 'H' : ['<Plug>(GitGutterLineHighlightsToggle)'      , 'highlight hunks'],
      \ 'j' : ['<Plug>(GitGutterNextHunk)'           , 'next hunk'],
      \ 'k' : ['<Plug>(GitGutterPrevHunk)'           , 'prev hunk'],
      \ 'l' : [':Git log'                            , 'git log'],
      \ 'm' : 'git messenger' ,
      \ 'o' : [':Commits'                            , 'fzf commits'],
      \ 's' : [':GFiles?'                            , 'git status'],
      \ 'S' : [':Gstatus'                            , 'fugitive status'],
      \ 'u' : ['<Plug>(GitGutterUndoHunk)'           , 'undo hunk'],
      \ 'V' : [':GV'                                 , 'view commits'],
      \ 'v' : [':GV!'                                , 'view buffer commits'],
      \ 'y' : [':Goyo'                               , 'goyo mode'],
      \ }

" m for menu
let g:which_key_map.m = {
      \ 'name' : '+menu' ,
      \ 'l' : ['<Plug>(lcn-menu)'                      , 'lcn menu'],
      \ }


" p is for projects
let g:which_key_map.p = {
      \ 'name' : '+project&util' ,
      \ }


noremap <Plug>RgPrompt :<C-U>Rg<Space>
noremap <Plug>AgPrompt :<C-U>Ag<Space>
" s is for search && replace.
let g:which_key_map.s = {
      \ 'name' : '+search&replace' ,
      \ 'a' : ['<Plug>AgPrompt'                                , 'ag search'],
      \ 'A' : [':Farr --source=agnvim'                         , 'farr agnvim'],
      \ 'f' : ['<Plug>LeaderfRgPrompt'                         , 'leaderf rg prompt'],
      \ 'r' : ['<Plug>RgPrompt'                                , 'rg search'],
      \ 'R' : [':Farr --source=rgnvim'                         , 'farr rgnvim'],
      \ 's' : [':CtrlSF'                                       , 'find in project'],
      \ 'w' : ['<Plug>LeaderfRgBangCwordLiteralBoundary'       , 'leaderf file cword'],
      \}


	nnoremap   <silent>   <F5>    :FloatermPrev<CR>
	tnoremap   <silent>   <F5>    <C-\><C-n>:FloatermPrev<CR>
	nnoremap   <silent>   <F6>    :FloatermNew<CR>
	tnoremap   <silent>   <F6>    <C-\><C-n>:FloatermNew<CR>
	nnoremap   <silent>   <F7>    :FloatermNext<CR>
	tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNext<CR>
	nnoremap   <silent>   <F8>    :FloatermToggle<CR>
	tnoremap   <silent>   <F8>    <C-\><C-n>:FloatermToggle<CR>


" w is for windows
let g:which_key_map.w = {
      \ 'name' : '+windows',
      \ 'f' : [':LeaderfWindow'                  , 'leaderf windows'],
      \ 's' : [':wincmd s'                       , 'horizontal split'],
      \ 'v' : [':wincmd v'                       , 'vertical split'],
      \ 'z' : [':Windows'                        , 'fzf windows'],
      \}
