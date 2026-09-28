vim9script

# 只有真正启动完的普通模式会话才测得到的两件事：
#   - Ex 模式下 mode() 恒为 ce，依赖 Visual 模式的行为测不了；
#   - VimEnter 之后重新 source vimrc，SimplePlug 才会把插件脚本再 source 一遍。
# 所以正文挂在 VimEnter 上，而不是直接写在这个 -S 脚本里。
#
# 没有终端时 Vim 从 stdin 读按键，读到 EOF 就在 VimEnter 之前退出了；调用方
# 因此要给一个开着却没有数据的 stdin（见 utils/check.sh）。正文整个包在 try
# 里，保证断言失败或抛错之后仍然走到退出。

set nomore

def YankProps(): list<dict<any>>
  return prop_list(1, {types: ['SimpleEditYank'], end_lnum: line('$')})
enddef

def ErrorMessages(): list<string>
  return split(execute('messages'), "\n")
    ->filter((_, line) => line =~# '^E\d\+:')
enddef

def Run()
  assert_equal(1, v:vim_did_enter)
  assert_equal(1, get(g:, 'vimrc_plugins_ready', 0))

  enew
  setline(1, ['one', 'two', 'three'])

  # 真正的 yank 照常反显。
  normal! ggyy
  assert_equal(1, len(YankProps()))
  SimpleEditClearYank

  # 'clipboard' 的 autoselect 在 Visual 模式里触发 TextYankPost，且不更新
  # '[ / ']：此刻两个 mark 还指着上面 yy 的第 1 行，不能把它重新反显。鼠标三击
  # 刚打开的文件时，这两个 mark 是首行到末行，整屏都会被反显。
  execute "normal! jV\<Cmd>doautocmd TextYankPost\<CR>\<Esc>"
  assert_equal([], YankProps())

  # <leader>vr：重新 source 之后插件的自动命令、命令补全都必须照常工作。
  messages clear
  execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
  doautocmd <nomodeline> CursorHold
  doautocmd <nomodeline> FocusGained
  doautocmd <nomodeline> User SimpleRemoteBufferRead
  assert_true(index(getcompletion('SimpleCCInstall ', 'cmdline'), 'pyright') >= 0)
  assert_equal([], ErrorMessages())

  # 标签栏里只有标签：点击区域的标记不能被当成文本画出来。
  badd live_smoke_other.txt
  var drawn = simpleline#Tabline()
    ->substitute('%#[^#]*#', '', 'g')
    ->substitute('%\d*\[[^\]]*\]', '', 'g')
  assert_notmatch('TablineClick', drawn)
enddef

def g:VimrcLiveSmoke()
  try
    Run()
  catch
    add(v:errors, v:throwpoint .. ': ' .. v:exception)
  endtry
  if !empty(v:errors)
    writefile(v:errors, $VIMRC_TEST_ERRORS)
    cquit 1
  endif
  qall!
enddef

autocmd VimEnter * ++once ++nested call g:VimrcLiveSmoke()
