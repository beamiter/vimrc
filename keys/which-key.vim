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
autocmd VimEnter * call which_key#register("<Space>", "g:which_key_map")
autocmd VimEnter * call which_key#register("\\", "g:which_key_map0")



let g:which_key_map =  {}
let g:which_key_map0 = {}

" Map leader to which_key
nnoremap <silent> <leader> :silent <c-u> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Map localleader to which_key
nnoremap <silent> <localleader> :silent <c-u> :silent WhichKey "\\"<CR>
vnoremap <silent> <localleader> :silent <c-u> :silent WhichKeyVisual "\\"<CR>

" Coc Search & refactor
nnoremap <leader>? :<C-u>CocSearch <C-R>=expand("<cword>")<CR><CR>

let g:which_key_map['?'] = 'search word'

"" Hide status line
"autocmd! FileType which_key
"autocmd  FileType which_key set laststatus=0 noshowmode noruler
  "\| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

let g:which_key_map['h'] = [ '<C-W>s'                                          , 'split below']
let g:which_key_map['v'] = [ '<C-W>v'                                          , 'split right']

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
      \ 'a' : [':Git add .'                          , 'add all'],
      \ 'b' : [':Git blame'                          , 'blame'],
      \ 'c' : [':Git commit'                         , 'commit'],
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
      \ }




" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search l/f/d' ,
      \ 'l' : {
      \ 'name' : 'leaderf',
      \ 'b' : [':LeaderfBuffer', 'buffer'],
      \ 'f' : [':LeaderfFile', 'file'],
      \ 'p' : [':LeaderfFileCword', 'find in project'],
      \ 'o' : [':LeaderfFunction', 'function'],
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
      \ 't' : [':Denite tag', 'tag'],
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
      \ 'd' : [':FloatermNew lazydocker'                        , 'docker'],
      \ 'n' : [':FloatermNew node'                              , 'node'],
      \ 'N' : [':FloatermNew nnn'                               , 'nnn'],
      \ 'p' : [':FloatermNew python'                            , 'python'],
      \ 'm' : [':FloatermNew lazynpm'                           , 'npm'],
      \ 'r' : [':FloatermNew ranger'                            , 'ranger'],
      \ 't' : [':FloatermToggle'                                , 'toggle'],
      \ 'y' : [':FloatermNew ytop'                              , 'ytop'],
      \ 's' : [':FloatermNew ncdu'                              , 'ncdu'],
      \ }


" r is for project
let g:which_key_map.r = {
      \ 'name' : '+preview util' ,
      \ 'f' : [':CocCommand fzf-preview.ProjectFiles',                     'project files'],
      \ 'g' : [':CocCommand fzf-preview.GitFiles',                         'git files'],
      \ 'd' : [':CocCommand fzf-preview.DirectoryFiles',                   'directory files'],
      \ 'b' : [':CocCommand fzf_preview.Buffers',                          'file buffers'],
      \ 'h' : [':CocCommand fzf_preview.ProjectOldFiles',                  'project old files'],
      \ 'm' : [':CocCommand fzf_preview.ProjectMruFiles',                  'project mru files'],
      \ 'w' : [':CocCommand fzf_preview.ProjectGrep {word}',               'grep current word'],
      \ 'H' : [':CocCommand fzf_preview.OldFiles',                         'old files'],
      \ 'M' : [':CocCommand fzf_preview.MruFiles',                         'mru files'],
      \ 'q' : [':CocCommand fzf_preview.QuickFix',                         'quick fix'],
      \ 'a' : [':CocCommand fzf_preview.GitActions',                       'git actions'],
      \ 's' : [':CocCommand fzf_preview.GitStatus',                        'git status'],
      \ 't' : [':CocCommand fzf_preview.VistaBufferCtags',                 'vista current tags'],
      \ 'c' : [':CocCommand fzf_preview.CocCurrentDiagnostics',            'current diagnostics'],
      \ }

