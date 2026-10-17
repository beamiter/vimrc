vim9script

var C = g:vimrc_context

# ============================================================================
# 健康检查
# ============================================================================
def HealthLine(state: string, label: string, detail: string = '')
  var icon = state ==# 'ok' ? '[OK]'
        \ : state ==# 'fail' ? '[FAIL]'
        \ : state ==# 'warn' ? '[WARN]'
        \ : '[SKIP]'
  var hl = state ==# 'ok' ? 'MoreMsg'
        \ : state ==# 'fail' ? 'ErrorMsg'
        \ : state ==# 'warn' ? 'WarningMsg'
        \ : 'Comment'
  echohl {hl}
  echomsg printf('  %-6s %-24s %s', icon, label, detail)
  echohl None
enddef

def g:VimrcHealth()
  var failures = 0
  var warnings = 0

  echomsg 'vimrc health — ' .. C.root

  HealthLine(v:version >= 901 ? 'ok' : 'fail', 'Vim 9.1+', v:progpath)
  failures += v:version >= 901 ? 0 : 1
  HealthLine('ok', 'config load', printf('%.2f ms / %d modules',
    get(g:, 'vimrc_load_ms', 0.0), len(get(g:, 'vimrc_load_timings', []))))
  HealthLine('ok', 'colorscheme', get(g:, 'colors_name', 'default')
    .. ' / ' .. &background .. (&termguicolors ? ' / truecolor' : ' / terminal palette'))

  var features = [
    'vim9script',
    'job',
    'channel',
    'timers',
    'popupwin',
    'textprop',
    'persistent_undo',
  ]
  for feature in features
    var ok = has(feature)
    HealthLine(ok ? 'ok' : 'fail', '+' .. feature)
    if !ok
      failures += 1
    endif
  endfor

  var json_ok = exists('*json_encode') && exists('*json_decode')
  HealthLine(json_ok ? 'ok' : 'fail', 'JSON functions')
  failures += json_ok ? 0 : 1

  var matchit_ok = exists('g:loaded_matchit')
  HealthLine(matchit_ok ? 'ok' : 'warn', 'matchit',
        matchit_ok ? 'packadd' : 'not loaded')
  warnings += matchit_ok ? 0 : 1

  var encodings_ok = stridx(&fileencodings, 'gb18030') >= 0
        && stridx(&fileencodings, 'utf-8') >= 0
  HealthLine(encodings_ok ? 'ok' : 'warn', 'fileencodings', &fileencodings)
  warnings += encodings_ok ? 0 : 1

  if get(g:, 'simpleline_nerdfont', 0)
        && &ambiwidth ==# 'double'
    HealthLine('warn', 'ambiwidth',
          'double 与 Nerd Font 同时开启，图标可能错位')
    warnings += 1
  else
    HealthLine('ok', 'ambiwidth', &ambiwidth)
  endif

  var editorconfig_enabled = !!get(g:, 'simpleeditorconfig_enable', 1)
  var editorconfig_ok = !editorconfig_enabled
        \ || exists(':SimpleEditorConfigReload') == 2
  HealthLine(
    editorconfig_ok ? (editorconfig_enabled ? 'ok' : 'skip') : 'warn',
    'SimpleEditorConfig',
    editorconfig_enabled ? 'local + SimpleRemote' : 'disabled')
  warnings += editorconfig_ok ? 0 : 1

  var hlyank_enabled = !!get(g:, 'simpleedit_yank_highlight', 1)
  var hlyank_ok = !hlyank_enabled || exists(':SimpleEditClearYank') == 2
  HealthLine(
    hlyank_ok ? (hlyank_enabled ? 'ok' : 'skip') : 'warn',
    'SimpleEdit yank highlight',
    hlyank_enabled ? 'text properties' : 'disabled')
  warnings += hlyank_ok ? 0 : 1

  for tool in ['git', 'rg', 'cargo', 'rustc']
    var ok = executable(tool)
    HealthLine(ok ? 'ok' : 'warn', tool, ok ? exepath(tool) : '未找到')
    warnings += ok ? 0 : 1
  endfor

  for dir in [C.undo_dir, C.swap_dir, C.backup_dir, C.session_dir]
    var ok = isdirectory(dir) && filewritable(dir) == 2
    HealthLine(ok ? 'ok' : 'fail', fnamemodify(dir, ':t') .. ' state', dir)
    failures += ok ? 0 : 1
  endfor

  var active_config = get(g:, 'simplecc_config_path', '')
  var config_ok = !empty(active_config) && filereadable(active_config)
  var config_detail = empty(active_config)
        \ ? '项目配置发现已启用；其中 command/args 会执行'
        \ : active_config
  HealthLine(config_ok ? 'ok' : 'warn', 'SimpleCC config', config_detail)
  warnings += config_ok ? 0 : 1

  if C.plugins_enabled
    var simpleplug_home = C.plugin_home .. '/simpleplug'
    var manager_ok = g:VimrcSimplePlugReady()
    var bootstrap_phase = get(
          get(g:, 'vimrc_simpleplug_bootstrap_state', {}),
          'phase',
          'idle')
    HealthLine(
          manager_ok ? 'ok' : 'warn',
          'SimplePlug',
          manager_ok ? simpleplug_home : simpleplug_home .. ' (' .. bootstrap_phase .. ')')
    warnings += manager_ok ? 0 : 1

    var daemons = [
      ['simpleplug', 'simpleplug-daemon'],
      ['simplefinder', 'simplefinder-daemon'],
      ['simpletree', 'simpletree-daemon'],
      ['simpleline', 'simpleline-daemon'],
      ['simpleminimap', 'simpleminimap-daemon'],
      ['simpleclipboard', 'simpleclipboard-daemon'],
      ['simpletreesitter', 'ts-hl-daemon'],
      ['simplecc', 'simplecc-daemon'],
    ]
    for daemon in daemons
      var path = C.plugin_home .. '/' .. daemon[0] .. '/lib/' .. daemon[1]
      var ok = executable(path)
      HealthLine(ok ? 'ok' : 'warn', daemon[0] .. ' backend', path)
      warnings += ok ? 0 : 1
    endfor

    var suite_health_commands = [
      'SimpleCommentHealth',
      'SimpleMotionHealth',
      'SimplePairsHealth',
      'SimpleEditHealth',
      'SimpleMultiHealth',
      'SimpleEditorConfigHealth',
      'SimpleTerminalHealth',
    ]
    var missing_commands = filter(
          copy(suite_health_commands),
          (_, name) => exists(':' .. name) != 2)
    HealthLine(
          empty(missing_commands) ? 'ok' : 'warn',
          'Simple suite health',
          empty(missing_commands)
            ? printf('%d/%d commands', len(suite_health_commands),
                len(suite_health_commands))
            : 'missing: ' .. join(missing_commands, ', '))
    warnings += empty(missing_commands) ? 0 : 1
  else
    HealthLine('skip', 'plugins', 'VIMRC_SKIP_PLUGINS=1')
  endif

  var clipboard_ok = has('unnamedplus')
        \ || executable('wl-copy')
        \ || executable('xclip')
        \ || executable('xsel')
        \ || executable(C.plugin_home .. '/simpleclipboard/lib/simpleclipboard-daemon')
  HealthLine(clipboard_ok ? 'ok' : 'warn', 'clipboard provider')
  warnings += clipboard_ok ? 0 : 1

  var lsp_install_is_explicit = !get(g:, 'simplecc_auto_install', 1)
  HealthLine(
        lsp_install_is_explicit ? 'ok' : 'warn',
        'language-server install',
        lsp_install_is_explicit ? 'explicit' : 'automatic')
  warnings += lsp_install_is_explicit ? 0 : 1

  HealthLine('ok', 'project root', g:VimrcProjectRoot())
  var large = get(b:, 'vimrc_large_file', 0)
  HealthLine(large ? 'skip' : 'ok', 'large-file protection',
    large ? 'active — :VimrcLargeFile 查看 / on|off|auto 调整' : 'normal buffer')
  var grep_state = get(g:, 'vimrc_grep_state', {})
  HealthLine(executable('rg') ? 'ok' : 'warn', 'native async search',
    get(grep_state, 'phase', 'idle') .. ' — :VimrcGrep / :VimrcGrepStop')
  var update_state = get(g:, 'vimrc_update_status', {})
  if type(update_state) == v:t_dict && has_key(update_state, 'error')
    HealthLine('warn', 'config update', update_state.error .. ' — :VimrcUpdateCheck')
    warnings += 1
  else
    HealthLine('ok', 'config update', 'asynchronous; :VimrcUpdateStop 可取消')
  endif

  g:vimrc_health_last = {fail: failures, warn: warnings}
  echomsg printf(
        'vimrc health: %d failure(s), %d warning(s)',
        failures,
        warnings)
enddef

def OpenReport(name: string, lines: list<string>)
  var report_buffer = -1
  for info in getbufinfo()
    if getbufvar(info.bufnr, 'vimrc_report_name', '') ==# name
      report_buffer = info.bufnr
      break
    endif
  endfor
  if report_buffer > 0
    var windows = win_findbuf(report_buffer)
    if !empty(windows)
      win_gotoid(windows[0])
    else
      execute 'botright sbuffer ' .. report_buffer
    endif
    setlocal modifiable
    silent! :%delete _
  else
    botright new
    # A user's real file may have the same display name. Ownership is the
    # buffer tag above; choose a fresh label without reusing that real file.
    var names = getbufinfo()->mapnew((_, info) => info.name)
    var display_name = name
    var suffix = 1
    while index(names, fnamemodify(display_name, ':p')) >= 0
      display_name = name .. '-' .. suffix
      suffix += 1
    endwhile
    execute 'file ' .. fnameescape(display_name)
    b:vimrc_report_name = name
  endif
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal filetype=vimrcreport
  setlocal nowrap nonumber norelativenumber nolist signcolumn=no
  setlocal foldmethod=manual nofoldenable
  setline(1, lines)
  setlocal nomodified nomodifiable
  nnoremap <buffer> <silent> q <Cmd>close<CR>
enddef

def g:VimrcHealthReport()
  var lines = split(execute('call g:VimrcHealth()'), "\n")
  OpenReport('[vimrc-health]', ['Vimrc health report — q closes this window', ''] + lines)
enddef

def g:VimrcProfile()
  var timings = copy(get(g:, 'vimrc_load_timings', []))
  var lines = [
    'Vimrc load profile — q closes this window',
    '',
    printf('Last configuration load: %.2f ms', get(g:, 'vimrc_load_ms', 0.0)),
    'Includes .vimrc.before/.vimrc.local; excludes later plugin jobs and Vim startup.',
    'Use vim --startuptime startup.log for the complete editor startup trace.',
    '',
    printf('%-24s %10s', 'Module', 'ms'),
  ]
  for entry in sort(timings, (left, right) => left.ms == right.ms ? 0
        : left.ms < right.ms ? 1 : -1)
    add(lines, printf('%-24s %10.3f', entry.module, entry.ms))
  endfor
  OpenReport('[vimrc-profile]', lines)
enddef

def ShowHealth(report: bool)
  if report
    g:VimrcHealthReport()
  else
    g:VimrcHealth()
  endif
enddef

command! -bang VimrcHealth call ShowHealth(<bang>0 ? true : false)
command! VimrcProfile call g:VimrcProfile()
