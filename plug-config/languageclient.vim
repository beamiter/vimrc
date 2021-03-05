" 自启动
let g:deoplete#enable_at_startup = 1

call deoplete#custom#option({
\ 'auto_complete_delay': 200,
\ 'smart_case': v:true,
\ })

" 用户输入至少两个字符时再开始提示补全
call deoplete#custom#source('LanguageClient',
            \ 'min_pattern_length',
            \ 2)

" 字符串中不补全
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['String']
            \ )

" 补全结束或离开插入模式时，关闭预览窗口
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" 为每个语言定义completion source
" 是的vim script和zsh script都有，这就是deoplete
call deoplete#custom#option('sources', {
            \ 'cpp': ['LanguageClient'],
            \ 'c': ['LanguageClient'],
            \ 'vim': ['vim'],
            \ 'zsh': ['zsh']
            \})

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" abandoned的Buffer隐藏起来，这是vim的设置。
" 如果没有这个设置，修改过的文件需要保存了才能换buffer
" 这会影响全局重命名，因为Vim提示保存因此打断下一个文件的重命名。
set hidden
" 告诉LS那个文件夹才是project root，同时也告诉它compile_commands在哪里
let g:LanguageClient_rootMarkers = {
            \ 'cpp': ['compile_commands.json', 'build'],
            \ 'c': ['compile_commands.json', 'build']
            \ }
" 为语言指定Language server和server的参数
let g:LanguageClient_serverCommands = {
            \ 'cpp': ['clangd', '--log-file=/tmp/cq.log'],
            \ 'c': ['clangd', '--log-file=/tmp/cq.log'],
            \ 'python': ['pyls'],
            \ }

" 是否为Language server载入配置文件，其实默认就是1,可以忽略
let g:LanguageClient_loadSettings = 1
" server配置文件的位置
"let g:LanguageClient_settingsPath = '你自己看看放那里咯'

" 把Server的补全API提交给Vim
" 一般有deoplete就可以用了，加上一条以防万一。
set completefunc=LanguageClient#complete
" 把Server的格式化API提交给Vim
set formatexpr=LanguageClient_textDocument_rangeFormatting()
"```
"最后，因为默认Deoplete的补全是`ctrl-n`下翻和`ctrl-p`上翻，如果喜欢`tab`还可以加上两行：
"```vim
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><S-tab> pumvisible() ? "\<c-p>" : "\<tab>"

nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gi :call LanguageClient_textDocument_implementation()<CR>
nnoremap <silent> gx :call LanguageClient#textDocument_references()<CR>

nnoremap <leader>li :call LanguageClient_textDocument_implementation()<CR>
nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
nnoremap <leader>lc :call LanguageClient_textDocument_codeAction()<CR>
nnoremap <leader>lu :call *LanguageClient#textDocument_documentHighlight()<CR>
nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
nnoremap <leader>pc :pc<CR>
