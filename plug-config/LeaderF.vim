let g:Lf_WindowPosition = 'popup'
let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg', '.cache'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
        \}
let g:Lf_ShortcutF = ''
let g:Lf_ShortcutB = ''
let g:Lf_DefaultExternalTool = "rg"
let g:Lf_PopupWidth = &columns * 3 / 4
let g:Lf_PopupHeight = float2nr(&lines * 0.3)
