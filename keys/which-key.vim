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

let g:which_key_map0['1'] = 'win-1'
let g:which_key_map0['2'] = 'win-2'
let g:which_key_map0['3'] = 'win-3'
let g:which_key_map0['4'] = 'win-4'
let g:which_key_map0['5'] = 'win-5'
let g:which_key_map0['6'] = 'win-6'
let g:which_key_map0['7'] = 'win-7'
let g:which_key_map0['8'] = 'win-8'
let g:which_key_map0['9'] = 'win-9'
let g:which_key_map0['0'] = 'win-10'

let g:which_key_map0['o'] = ['<Plug>TFTPrompt', 'color eggs']

let g:which_key_map['1'] = 'tab-1'
let g:which_key_map['2'] = 'tab-2'
let g:which_key_map['3'] = 'tab-3'
let g:which_key_map['4'] = 'tab-4'
let g:which_key_map['5'] = 'tab-5'
let g:which_key_map['6'] = 'tab-6'
let g:which_key_map['7'] = 'tab-7'
let g:which_key_map['8'] = 'tab-8'
let g:which_key_map['9'] = 'tab-9'
let g:which_key_map['0'] = 'tab-10'

" Coc Search & refactor
nnoremap <leader>? :<C-u>CocSearch <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>rw :<C-u>CocCommand fzf-preview.ProjectGrep <C-R>=expand("<cword>")<CR><CR>

let g:which_key_map['?'] = 'search word'

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
      \ ';' : ['<Plug>(coc-refactor)'                , 'refactor'],
      \ 'a' : ['<Plug>(coc-codeaction)'              , 'code action'],
      \ 'A' : ['<Plug>(coc-codeaction-selected)'     , 'selected action'],
      \ 'c' : ['UpdateLocalCS'                       , 'save color scheme'],
      \ 'C' : ['RandomLocalCS'                       , 'random color scheme'],
      \ 'f' : ['<Plug>(coc-format-selected)'         , 'format selected'],
      \ 'F' : ['<Plug>(coc-format)'                  , 'format'],
      \ 'l' : [':CocList lists'                      , 'lists'],
      \ 'm' : [':Maps'                               , 'mappings'],
      \ 'n' : ['<Plug>(coc-diagnostic-next)'         , 'next diagnostic'],
      \ 'N' : ['<Plug>(coc-diagnostic-next-error)'   , 'next error'],
      \ 'P' : ['<Plug>(coc-diagnostic-prev-error)'   , 'prev error'],
      \ 'p' : ['<Plug>(coc-diagnostic-prev)'         , 'prev diagnostic'],
      \ 'q' : ['<Plug>(coc-fix-current)'             , 'quickfix'],
      \ 'r' : ['<Plug>(coc-rename)'                  , 'rename'],
      \ 's' : [':CocList -I symbols'                 , 'symbols'],
      \ 'S' : [':CocList snippets'                   , 'snippets'],
      \ 'w' : [':CocList words'                      , 'words']
      \ }


" b is for buffers.
let g:which_key_map.b = {
      \ 'name' : '+buffers',
      \ 'b' : [':LeaderfBuffer'                 , 'buffers'],
      \ 'c' : [':CocList buffers'               , 'coc buffers'],
      \ 'd' : [':bwipeout'                      , 'wipeout buffer'],
      \ 'e' : [':Denite buffer'                 , 'denite buffers'],
      \ 'f' : [':LeaderfBuffer'                 , 'leaderf buffer'],
      \ 'm' : [':CocList bcommits'              , 'coc buffer commits'],
      \ 'M' : [':BCommits'                      , 'fzf buffer commits'],
      \ 'o' : [':CocList outline'               , 'coc outline'],
      \ 'O' : [':Denite outline'                , 'denite outline'],
      \ 'z' : [':Buffers'                       , 'fzf buffer'],
      \}


" c is for comments.
let g:which_key_map.c = {
      \ 'name' : '+comment|format' ,
      \ }


" f is for files
let g:which_key_map.f = {
      \ 'name' : '+files',
      \ 'c' : [':CocList files'                 , 'coc file'],
      \ 'd' : [':Denite file/rec'               , 'denite file/rec'],
      \ 'h' : [':History'                       , 'fzf history'],
      \ 'H' : [':Denite file/old'               , 'denite file/old'],
      \ 'f' : [':LeaderfFile'                   , 'leaderf file'],
      \ 'm' : [':CocList mru'                   , 'coc mru'],
      \ 'M' : [':LeaderfMru'                    , 'leaderf mru'],
      \ 't' : [':LeaderfBufTag'                 , 'leaderf buf tag'],
      \ 'z' : [':Files'                         , 'fzf file'],
      \}


" g is for git
let g:which_key_map.g = {
      \ 'name' : '+git' ,
      \ 'b' : [':Git blame'                          , 'fzf blame'],
      \ 'B' : [':Gina blame'                         , 'gina blame'],
      \ 'c' : [':CocList bcommits'                   , 'coc buffer commits'],
      \ 'C' : [':BCommits'                           , 'fzf buffer commits'],
      \ 'd' : [':SignifyDiff'                        , 'signify diff'],
      \ 'D' : [':Git diff'                           , 'git diff'],
      \ 'e' : [':Gina compare'                       , 'gina compare'],
      \ 'E' : [':Gina diff'                          , 'gina diff'],
      \ 'f' : [':GCurrent'                           , 'curent log'],
      \ 'g' : ['<Plug>(GitGutterPreviewHunk)'        , 'preview hunk'],
      \ 'h' : ['<Plug>(GitGutterStageHunk)'          , 'stage hunk'],
      \ 'H' : ['<Plug>(GitGutterLineHighlightsToggle)'      , 'highlight hunks'],
      \ 'j' : ['<Plug>(GitGutterNextHunk)'           , 'next hunk'],
      \ 'k' : ['<Plug>(GitGutterPrevHunk)'           , 'prev hunk'],
      \ 'l' : [':Git log'                            , 'git log'],
      \ 'm' : 'git messenger' ,
      \ 'o' : [':CocList commits'                    , 'coc commits'],
      \ 'O' : [':Commits'                            , 'fzf commits'],
      \ 's' : [':GFiles?'                            , 'git status'],
      \ 'S' : [':Gstatus'                            , 'fugitive status'],
      \ 'u' : ['<Plug>(GitGutterUndoHunk)'           , 'undo hunk'],
      \ 'V' : [':GV'                                 , 'view commits'],
      \ 'v' : [':GV!'                                , 'view buffer commits'],
      \ 'y' : [':Goyo'                               , 'goyo mode'],
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
      \ 'd' : [':CocList diagnostics --current-buf'            , 'current diagnostics'],
      \ 'f' : ['<Plug>LeaderfRgPrompt'                         , 'leaderf rg prompt'],
      \ 'g' : [':Denite grep'                                  , 'denite grep'],
      \ 'q' : [':CocList quickfix'                             , 'quickfix'],
      \ 'r' : ['<Plug>RgPrompt'                                , 'rg search'],
      \ 'R' : [':Farr --source=rgnvim'                         , 'farr rgnvim'],
      \ 's' : [':CtrlSF'                                       , 'find in project'],
      \ 'w' : ['<Plug>LeaderfRgBangCwordLiteralNoBoundary'     , 'leaderf file cword'],
      \}


" t is for terminal
let g:which_key_map.t = {
      \ 'name' : '+terminal' ,
      \ ';' : [':FloatermNew --wintype=normal --height=6'       , 'terminal'],
      \ 'n' : [':FloatermNewNew'                                , 'new'],
      \ 'j' : [':FloatermNewNext'                               , 'next'],
      \ 'k' : [':FloatermNewPrev'                               , 'prev'],
      \ 't' : [':FloatermToggle'                                , 'toggle'],
      \ }


" r is for previews
let g:which_key_map.r = {
      \ 'name' : '+preview' ,
      \ 'a' : [':CocCommand fzf-preview.CocCurrentDiagnostics'      , 'current diagnostics'],
      \ 'b' : [':CocCommand fzf-preview.Buffers'                    , 'file buffers'],
      \ 'c' : [':CocCommand fzf-preview.GitActions'                 , 'git actions'],
      \ 'd' : [':CocCommand fzf-preview.DirectoryFiles'             , 'directory files'],
      \ 'f' : [':CocCommand fzf-preview.ProjectFiles'               , 'project files'],
      \ 'g' : [':CocCommand fzf-preview.GitFiles'                   , 'git files'],
      \ 'h' : [':CocCommand fzf-preview.ProjectOldFiles'            , 'project old files'],
      \ 'H' : [':CocCommand fzf-preview.OldFiles'                   , 'old files'],
      \ 'l' : [':CocCommand fzf-preview.GitCurrentLogs'             , 'git current logs'],
      \ 'L' : [':CocCommand fzf-preview.GitLogs'                    , 'git logs'],
      \ 'm' : [':CocCommand fzf-preview.ProjectMruFiles'            , 'project mru files'],
      \ 'M' : [':CocCommand fzf-preview.MruFiles'                   , 'mru files'],
      \ 'q' : [':CocCommand fzf-preview.QuickFix'                   , 'quick fix'],
      \ 's' : [':CocCommand fzf-preview.GitStatus'                  , 'git status'],
      \ 't' : [':CocCommand fzf-preview.BufferTags'                 , 'current buffer tags'],
      \ 'w' : 'grep current word',
      \ }


" w is for windows
let g:which_key_map.w = {
      \ 'name' : '+windows',
      \ 'c' : [':CocList windows'                , 'coc windows'],
      \ 'f' : [':LeaderfWindow'                  , 'leaderf windows'],
      \ 's' : [':wincmd s'                       , 'horizontal split'],
      \ 'v' : [':wincmd v'                       , 'vertical split'],
      \ 'z' : [':Windows'                        , 'fzf windows'],
      \}
