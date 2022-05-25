let g:ctrlsf_auto_close = {
    \ "normal" : 0,
    \ "compact": 0
    \}

let g:ctrlsf_auto_focus = {
    \ "at": "start"
    \ }
"" or
"let g:ctrlsf_auto_focus = {
    "\ "at": "done",
    "\ "duration_less_than": 1000
    "\ }

let g:ctrlsf_auto_preview = 0

let g:ctrlsf_case_sensitive = 'yes'

let g:ctrlsf_context = '-B 5 -A 3'

"let g:ctrlsf_default_root = 'project'
let g:ctrlsf_default_root = 'cwd'

"let g:ctrlsf_default_view_mode = 'compact'

"let g:ctrlsf_extra_backend_args = {
    "\ 'pt': '--home-ptignore'
    "\ }

let g:ctrlsf_extra_root_markers = ['.root']

let g:ctrlsf_mapping = {
    \ "next": "n",
    \ "prev": "N",
    \ }

let g:ctrlsf_populate_qflist = 1

let g:ctrlsf_regex_pattern = 1

let g:ctrlsf_search_mode = 'async'

"let g:ctrlsf_position = 'bottom'

"let g:ctrlsf_winsize = '30%'
"" or
"let g:ctrlsf_winsize = '100'
