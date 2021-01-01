" in millisecond, used for both CursorHold and CursorHoldI,
" use updatetime instead if not defined
let g:cursorhold_updatetime = 100

map <silent> <F4> :Fern . -reveal=% -width=40 -drawer -toggle<CR>

function! s:init_fern() abort
  " Use 'select' instead of 'edit' for default 'open' action
  nmap <buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
endfunction

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END

" Disable listing ignored files/directories
let g:fern_git_status#disable_ignored = 1

" Disable listing untracked files
let g:fern_git_status#disable_untracked = 0

" Disable listing status of submodules
let g:fern_git_status#disable_submodules = 1

" Disable listing status of directories
let g:fern_git_status#disable_directories = 0

"let g:fern#renderer = "nerdfont"

"augroup my-glyph-palette
  "autocmd! *
  "autocmd FileType fern call glyph_palette#apply()
  "autocmd FileType nerdtree,startify call glyph_palette#apply()
"augroup END
