
let g:lightline#bufferline#show_number = 2
"let g:lightline#bufferline#composed_number_map = {
"\ 1:  '⑴ ', 2:  '⑵ ', 3:  '⑶ ', 4:  '⑷ ', 5:  '⑸ ',
"\ 6:  '⑹ ', 7:  '⑺ ', 8:  '⑻ ', 9:  '⑼ ', 10: '⑽ ',
"\ 11: '⑾ ', 12: '⑿ ', 13: '⒀ ', 14: '⒁ ', 15: '⒂ ',
"\ 16: '⒃ ', 17: '⒄ ', 18: '⒅ ', 19: '⒆ ', 20: '⒇ '}
let g:lightline#bufferline#composed_number_map = {
\ 1:  '1 ', 2:  '2 ', 3:  '3 ', 4:  '4 ', 5:  '5 ',
\ 6:  '6 ', 7:  '7 ', 8:  '8 ', 9:  '9 ', 10: '10 ',
\ 11: '11 ', 12: '12 ', 13: '13 ', 14: '14 ', 15: '15 ',
\ 16: '16 ', 17: '17 ', 18: '18 ', 19: '19 ', 20: '20 '}
let g:lightline#bufferline#number_map = {
\ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
\ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
"let g:lightline#bufferline#enable_devicons = 1
"let g:lightline#bufferline#enable_nerdfont = 1

nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nmap <Leader>d1 <Plug>lightline#bufferline#delete(1)
nmap <Leader>d2 <Plug>lightline#bufferline#delete(2)
nmap <Leader>d3 <Plug>lightline#bufferline#delete(3)
nmap <Leader>d4 <Plug>lightline#bufferline#delete(4)
nmap <Leader>d5 <Plug>lightline#bufferline#delete(5)
nmap <Leader>d6 <Plug>lightline#bufferline#delete(6)
nmap <Leader>d7 <Plug>lightline#bufferline#delete(7)
nmap <Leader>d8 <Plug>lightline#bufferline#delete(8)
nmap <Leader>d9 <Plug>lightline#bufferline#delete(9)
nmap <Leader>d0 <Plug>lightline#bufferline#delete(10)

"" Magic buffer-picking mode
"nnoremap <silent> <C-s> :BufferPick<CR>
"" Sort automatically by...
"nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
"nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
"" Move to previous/next
"nnoremap <silent>    <A-,> :BufferPrevious<CR>
"nnoremap <silent>    <A-.> :BufferNext<CR>
"" Re-order to previous/next
"nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
"nnoremap <silent>    <A->> :BufferMoveNext<CR>
"" Goto buffer in position...
"nnoremap <silent>    <A-1> :BufferGoto 1<CR>
"nnoremap <silent>    <A-2> :BufferGoto 2<CR>
"nnoremap <silent>    <A-3> :BufferGoto 3<CR>
"nnoremap <silent>    <A-4> :BufferGoto 4<CR>
"nnoremap <silent>    <A-5> :BufferGoto 5<CR>
"nnoremap <silent>    <A-6> :BufferGoto 6<CR>
"nnoremap <silent>    <A-7> :BufferGoto 7<CR>
"nnoremap <silent>    <A-8> :BufferGoto 8<CR>
"nnoremap <silent>    <A-9> :BufferLast<CR>
"" Close buffer
"nnoremap <silent>    <A-c> :BufferClose<CR>
"" Wipeout buffer
""                          :BufferWipeout<CR>
"" Close commands
""                          :BufferCloseAllButCurrent<CR>
""                          :BufferCloseBuffersRight<CR>

"" Other:
"" :BarbarEnable - enables barbar (enabled by default)
"" :BarbarDisable - very bad command, should never be used


" this if for the powerline in terminal
"POWERLINE_SCRIPT=/usr/share/powerline/bindings/bash/powerline.sh
"if [ -f $POWERLINE_SCRIPT ]; then
   "source $POWERLINE_SCRIPT
"fi


"let g:airline_powerline_fonts = 1   " 使用powerline打过补丁的字体
"let g:airline_theme="dark"      " 设置主题
"" 开启tabline
"let g:airline#extensions#tabline#enabled = 1
""tabline中当前buffer两端的分隔字符
"let g:airline#extensions#tabline#left_sep = ' '
""tabline中未激活buffer两端的分隔字符
"let g:airline#extensions#tabline#left_alt_sep = '|'
""tabline中buffer显示编号
"let g:airline#extensions#tabline#buffer_nr_show = 1
"let g:airline#extensions#tabline#formatter = 'default'
"let g:airline_theme='badwolf'  "可以自定义主题，这里使用 badwolf
"" jsformatter  unique_tail  unique_tail_improved
"" 设置字体
"set guifont=DroidSansMono\ Nerd\ Font\ 11   "must set same terminal font with this"
"" set guifont=3270\ Nerd\ Font\ 11
