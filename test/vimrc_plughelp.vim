vim9script

set nomore

const ROOT = g:vimrc_root
const TMP = tempname() .. " plugin's path"
const PLUGINS = TMP .. '/plugins'
const HOME = PLUGINS .. '/simpleplug'
const DOC = HOME .. '/doc'
const CACHE = TMP .. '/state/simpleplug-help'
const SAVED_CONTEXT = deepcopy(g:vimrc_context)
const SAVED_RTP = &runtimepath

def Git(arguments: list<string>): list<string>
  var command = 'git -C ' .. shellescape(HOME)
  for argument in arguments
    command ..= ' ' .. shellescape(argument)
  endfor
  var result = systemlist(command .. ' 2>&1')
  assert_equal(0, v:shell_error, command .. ': ' .. join(result, "\n"))
  return result
enddef

def Generate()
  execute 'silent helptags ' .. fnameescape(DOC)
enddef

def Reset()
  Git(['reset', '--hard', '--quiet', 'HEAD'])
  delete(HOME .. '/local-work')
  delete(DOC .. '/extra.txt')
enddef

def Configure()
  g:vimrc_context = deepcopy(SAVED_CONTEXT)
  g:vimrc_context.plugins_enabled = true
  g:vimrc_context.plugin_home = PLUGINS
  g:vimrc_context.vim_state = TMP .. '/state'
  execute 'source ' .. fnameescape(ROOT .. '/config/plughelp.vim')
enddef

def RunTests()
  mkdir(DOC, 'p')
  mkdir(TMP .. '/state', 'p')
  Git(['init', '--quiet'])
  Git(['config', 'user.name', 'Vimrc Test'])
  Git(['config', 'user.email', 'vimrc-test@example.invalid'])
  Git(['config', 'commit.gpgsign', 'false'])
  Git(['config', 'core.autocrlf', 'false'])
  writefile(['*simpleplug-test-old* old help'], DOC .. '/simpleplug.txt')
  Generate()
  Git(['add', 'doc'])
  Git(['commit', '--quiet', '-m', 'help with tracked tags'])
  var original_tags = readfile(DOC .. '/tags', 'b')
  writefile(['*simpleplug-test-new* new help'], DOC .. '/simpleplug.txt', 'a')
  Git(['add', 'doc/simpleplug.txt'])
  Git(['commit', '--quiet', '-m', 'upstream help edit without refreshed tags'])
  Generate()
  var generated_tags = readfile(DOC .. '/tags', 'b')
  assert_notequal(original_tags, generated_tags)
  assert_equal([' M doc/tags'], Git(['status', '--porcelain=v1']))

  # Startup repairs the installed checkout, while newly added help remains usable.
  Configure()
  assert_equal([], Git(['status', '--porcelain=v1']))
  assert_equal(original_tags, readfile(DOC .. '/tags', 'b'))
  assert_equal(generated_tags, readfile(CACHE .. '/doc/tags', 'b'))
  help simpleplug-test-new
  assert_equal(CACHE .. '/doc/simpleplug.txt', expand('%:p'))
  close

  # Every completed batch can generate the stale tracked index again. The same
  # event hook handles it without wrapping or changing any PlugUpdate command.
  for repeat in range(2)
    Generate()
    doautocmd <nomodeline> User SimplePlugComplete
    assert_equal([], Git(['status', '--porcelain=v1']))
    Configure()
    assert_equal(1, count(split(&runtimepath, ','), CACHE))
  endfor

  # A manual help-index edit must stay dirty even when it resembles tags data.
  Generate()
  writefile(['manual-tag\tsimpleplug.txt\t/*manual-tag*'], DOC .. '/tags', 'a')
  var manual = readfile(DOC .. '/tags', 'b')
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal(manual, readfile(DOC .. '/tags', 'b'))
  assert_equal([' M doc/tags'], Git(['status', '--porcelain=v1']))
  Reset()

  # Staged generated tags belong to the user too, with or without a further diff.
  Generate()
  Git(['add', 'doc/tags'])
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal(['M  doc/tags'], Git(['status', '--porcelain=v1']))
  writefile(['manual'], DOC .. '/tags', 'a')
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal(['MM doc/tags'], Git(['status', '--porcelain=v1']))
  Reset()

  # Both source edits and unrelated untracked work retain normal dirty protection.
  writefile(['*local-help* local work'], DOC .. '/simpleplug.txt', 'a')
  Generate()
  var source = readfile(DOC .. '/simpleplug.txt', 'b')
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal(source, readfile(DOC .. '/simpleplug.txt', 'b'))
  assert_true(len(Git(['status', '--porcelain=v1'])) > 1)
  Reset()
  Generate()
  writefile(['keep me'], HOME .. '/local-work')
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal(generated_tags, readfile(DOC .. '/tags', 'b'))
  assert_equal(['keep me'], readfile(HOME .. '/local-work'))
  Reset()

  # An ignored extra help source and a symlink are outside the fixed generator.
  writefile(['doc/extra.txt'], HOME .. '/.git/info/exclude')
  writefile(['*extra-help* extra'], DOC .. '/extra.txt')
  Generate()
  assert_false(g:VimrcRepairSimplePlugHelptags())
  Reset()
  delete(DOC .. '/tags')
  writefile(generated_tags, TMP .. '/linked-tags', 'b')
  system('ln -s ' .. shellescape(TMP .. '/linked-tags') .. ' '
    .. shellescape(DOC .. '/tags'))
  assert_equal(0, v:shell_error)
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal('link', getftype(DOC .. '/tags'))
  assert_equal(generated_tags, readfile(TMP .. '/linked-tags', 'b'))
  Reset()

  # A clean upstream help change invalidates the previous cached runtime entry.
  Configure()
  assert_equal(1, count(split(&runtimepath, ','), CACHE))
  writefile(['*new-upstream-help* updated'], DOC .. '/simpleplug.txt', 'a')
  Git(['add', 'doc/simpleplug.txt'])
  Git(['commit', '--quiet', '-m', 'another upstream help change'])
  Configure()
  assert_equal(0, count(split(&runtimepath, ','), CACHE))

  Generate()
  g:vimrc_context.plugins_enabled = false
  assert_false(g:VimrcRepairSimplePlugHelptags())
  assert_equal([' M doc/tags'], Git(['status', '--porcelain=v1']))
enddef

try
  RunTests()
finally
  g:vimrc_context = SAVED_CONTEXT
  &runtimepath = SAVED_RTP
  unlet! g:vimrc_simpleplug_help_runtime
  execute 'source ' .. fnameescape(ROOT .. '/config/plughelp.vim')
  delete(TMP, 'rf')
endtry

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
