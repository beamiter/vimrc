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

" Coc Search & refactor
nnoremap <leader>? :<C-u>CocSearch <C-R>=expand("<cword>")<CR><CR>

let g:which_key_map['?'] = 'search word'

"" Hide status line
"autocmd! FileType which_key
"autocmd  FileType which_key set laststatus=0 noshowmode noruler
  "\| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

let g:which_key_map0['s'] = [ '<C-W>s'                                          , 'split below']
let g:which_key_map0['v'] = [ '<C-W>v'                                          , 'split right']

" nnoremap <leader>gf :<C-u>Git log <C-R>=expand("%")<CR><CR>
function! GitCurrentFile()
  execute 'Git log '.expand('%')
endfunction
command GCurrent call GitCurrentFile()


" a is for action
let g:which_key_map.a = {
      \ 'name' : '+actions' ,
      \ ';' : ['<Plug>(coc-refactor)'                , 'refactor'],
      \ 'a' : ['<Plug>(coc-codeaction)'              , 'code action'],
      \ 'A' : ['<Plug>(coc-codeaction-selected)'     , 'selected action'],
      \ 'f' : ['<Plug>(coc-format-selected)'         , 'format selected'],
      \ 'F' : ['<Plug>(coc-format)'                  , 'format'],
      \ 'n' : ['<Plug>(coc-diagnostic-next)'         , 'next diagnostic'],
      \ 'N' : ['<Plug>(coc-diagnostic-next-error)'   , 'next error'],
      \ 'p' : ['<Plug>(coc-diagnostic-prev)'         , 'prev diagnostic'],
      \ 'P' : ['<Plug>(coc-diagnostic-prev-error)'   , 'prev error'],
      \ 'q' : ['<Plug>(coc-fix-current)'             , 'quickfix'],
      \ 'r' : ['<Plug>(coc-rename)'                  , 'rename'],
      \ 's' : [':CocList -I symbols'                 , 'symbols'],
      \ 'S' : [':CocList snippets'                   , 'snippets'],
      \ }


" c is for comment
let g:which_key_map.c = {
      \ 'name' : '+comment | format' ,
      \ }


" f is for find and replace
let g:which_key_map.f = {
      \ 'name' : '+find | replace' ,
      \ 'a' : [':Farr --source=agnvim'     , 'agnvim'],
      \ 'r' : [':Farr --source=rgnvim'     , 'rgnvim'],
      \ 'd' : [':CocFzfList diagnostics --current-buf', 'current diagnostics'],
      \ 'o' : [':CocFzfList outline', 'outline'],
      \ 's' : [':CocFzfList symbols', 'workspace outline'],
      \ 't' : [':CocFzfList tags', 'tags'],
      \ 'c' : [':CocFzfList bcommits', 'current buffer commits'],
      \ 'C' : [':CocFzfList commits', 'commits'],
      \ 'b' : [':CocFzfList buffers', 'buffer'],
      \ 'f' : [':CocFzfList files', 'file'],
      \ 'l' : [':CocFzfList lists', 'lists'],
      \ 'h' : [':CocFzfList mru', 'history'],
      \ 'w' : [':CocFzfList windows', 'w'],
      \ 'q' : [':CocFzfList quickfix', 'quickfix'],
      \ }


" g is for git
let g:which_key_map.g = {
      \ 'name' : '+git' ,
      \ 'b' : [':Git blame'                          , 'blame'],
      \ 'c' : [':BCommits'                           , 'commit'],
      \ 'd' : [':Git diff'                           , 'diff'],
      \ 'f' : [':GCurrent'                           , 'log curent file'],
      \ 's' : [':Gstatus'                            , 'status'],
      \ 'S' : ['<Plug>(GitGutterStageHunk)'          , 'stage hunk'],
      \ 'h' : [':GitGutterLineHighlightsToggle'      , 'highlight hunks'],
      \ 'j' : ['<Plug>(GitGutterNextHunk)'           , 'next hunk'],
      \ 'k' : ['<Plug>(GitGutterPrevHunk)'           , 'prev hunk'],
      \ 'l' : [':Git log'                            , 'log'],
      \ 'u' : ['<Plug>(GitGutterUndoHunk)'           , 'undo hunk'],
      \ 'V' : [':GV'                                 , 'view commits'],
      \ 'v' : [':GV!'                                , 'view buffer commits'],
      \ 'y' : [':Goyo'                               , 'goyo mode'],
      \ }


" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search l/f/d' ,
      \ 'l' : {
      \ 'name' : 'leaderf',
      \ 'b' : [':LeaderfBuffer', 'buffer'],
      \ 'f' : [':LeaderfFile', 'file'],
      \ 'p' : [':LeaderfFileCword', 'find in project'],
      \ 'h' : [':LeaderfMru', 'recent file'],
      \ 'r' : [':Leaderf rg', 'rg search'],
      \},
      \ 'f' : {
      \ 'name' : 'fzf',
      \ 'b' : [':Buffers', 'buffer'],
      \ 's' : [':GFiles?', 'git status'],
      \ 'f' : [':Files', 'file'],
      \ 'a' : [':Ag', 'ag search'],
      \ 'r' : [':Rg', 'rg search'],
      \ 'w' : [':Windows', 'windows'],
      \ 'h' : [':History', 'history'],
      \ 'V' : [':Commits', 'view commits'],
      \ 'v' : [':BCommits', 'view buffer commits'],
      \ 'm' : [':Maps', 'mappings'],
      \},
      \ 'd' : {
      \ 'name' : 'denite',
      \ 'b' : [':Denite buffer', 'buffer'],
      \ 'f' : [':Denite file', 'file'],
      \ 'o' : [':Denite outline', 'outline'],
      \ 'h' : [':Denite file/old', 'old file'],
      \ 'r' : [':Denite file/rec', 'recursive file'],
      \ 'g' : [':Denite grep', 'grep'],
      \},
      \}


" t is for terminal
let g:which_key_map.t = {
      \ 'name' : '+terminal' ,
      \ ';' : [':FloatermNew --wintype=normal --height=6'       , 'terminal'],
      \ 'f' : [':FloatermNew fzf'                               , 'fzf'],
      \ 'g' : [':FloatermNew lazygit'                           , 'git'],
      \ 'n' : [':FloatermNew node'                              , 'node'],
      \ 'p' : [':FloatermNew python'                            , 'python'],
      \ 'm' : [':FloatermNew lazynpm'                           , 'npm'],
      \ 'r' : [':FloatermNew ranger'                            , 'ranger'],
      \ 't' : [':FloatermToggle'                                , 'toggle'],
      \ 'y' : [':FloatermNew ytop'                              , 'ytop'],
      \ 's' : [':FloatermNew ncdu'                              , 'ncdu'],
      \ }


nnoremap <leader>rw :<C-u>CocCommand fzf-preview.ProjectGrep <C-R>=expand("<cword>")<CR><CR>

" r is for project
let g:which_key_map.r = {
      \ 'name' : '+preview util' ,
      \ 'f' : [':CocCommand fzf-preview.ProjectFiles',                     'project files'],
      \ 'g' : [':CocCommand fzf-preview.GitFiles',                         'git files'],
      \ 'd' : [':CocCommand fzf-preview.DirectoryFiles',                   'directory files'],
      \ 'b' : [':CocCommand fzf-preview.Buffers',                          'file buffers'],
      \ 'h' : [':CocCommand fzf-preview.ProjectOldFiles',                  'project old files'],
      \ 'm' : [':CocCommand fzf-preview.ProjectMruFiles',                  'project mru files'],
      \ 'H' : [':CocCommand fzf-preview.OldFiles',                         'old files'],
      \ 'M' : [':CocCommand fzf-preview.MruFiles',                         'mru files'],
      \ 'q' : [':CocCommand fzf-preview.QuickFix',                         'quick fix'],
      \ 'c' : [':CocCommand fzf-preview.GitActions',                       'git actions'],
      \ 'l' : [':CocCommand fzf-preview.GitCurrentLogs',                   'git current logs'],
      \ 'L' : [':CocCommand fzf-preview.GitLogs',                          'git logs'],
      \ 's' : [':CocCommand fzf-preview.GitStatus',                        'git status'],
      \ 'o' : [':CocCommand fzf-preview.BufferTags',                       'current buffer tags'],
      \ 'a' : [':CocCommand fzf-preview.CocCurrentDiagnostics',            'current diagnostics'],
      \ 'w' : 'grep current word',
      \ }

