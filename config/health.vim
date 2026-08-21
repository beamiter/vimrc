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

  var editorconfig_enabled = get(g:, 'simpleeditorconfig_enable', 1) != 0
  var editorconfig_ok = !editorconfig_enabled
        \ || exists(':SimpleEditorConfigReload') == 2
  HealthLine(
    editorconfig_ok ? (editorconfig_enabled ? 'ok' : 'skip') : 'warn',
    'SimpleEditorConfig',
    editorconfig_enabled ? 'local + SimpleRemote' : 'disabled')
  warnings += editorconfig_ok ? 0 : 1

  var hlyank_enabled = get(g:, 'simpleedit_yank_highlight', 1) != 0
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

  var lsp_install_is_explicit = get(g:, 'simplecc_auto_install', 1) == 0
  HealthLine(
        lsp_install_is_explicit ? 'ok' : 'warn',
        'language-server install',
        lsp_install_is_explicit ? 'explicit' : 'automatic')
  warnings += lsp_install_is_explicit ? 0 : 1

  g:vimrc_health_last = {fail: failures, warn: warnings}
  echomsg printf(
        'vimrc health: %d failure(s), %d warning(s)',
        failures,
        warnings)
enddef

command! VimrcHealth call g:VimrcHealth()
