vim9script

# Vim 9.1 is the common baseline for this configuration and the simple*
# workbench.  Stop before loading modules that use newer options.
if v:version < 901
  echoerr '[vimrc] Vim 9.1 or newer is required'
  finish
endif

# Resolve an absolute path to its canonical form without a trailing slash.
# Relative, empty, and root paths all collapse to '' so callers can fall back.
def NormalizePath(path: string): string
  if empty(path) || path !~# '^/'
    return ''
  endif
  return substitute(
    resolve(fnamemodify(path, ':p')),
    '[\/\\]\+$',
    '',
    '')
enddef

const HOME_DIR = NormalizePath($HOME)
if empty(HOME_DIR) || !isdirectory(HOME_DIR)
  echoerr '[vimrc] HOME must resolve to an existing, non-root directory'
  finish
endif

const ROOT = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const LOCAL_BEFORE = HOME_DIR .. '/.vimrc.before'
const LOCAL_AFTER = HOME_DIR .. '/.vimrc.local'
g:vimrc_root = ROOT

# Settings that must exist before plugins are sourced belong here.  This makes
# plugin options, the plugin directory and even leader keys genuinely
# overridable without editing the tracked vimrc.
if filereadable(LOCAL_BEFORE)
  execute 'source ' .. fnameescape(LOCAL_BEFORE)
endif

if !exists('g:mapleader')
  g:mapleader = ' '
endif
if !exists('g:maplocalleader')
  g:maplocalleader = ','
endif

const DEFAULT_PLUGIN_HOME = HOME_DIR .. '/.vim/plugged'
const STATE_CANDIDATE = NormalizePath($XDG_STATE_HOME)
const CONFIG_CANDIDATE = NormalizePath($XDG_CONFIG_HOME)
const PLUGIN_CANDIDATE = NormalizePath(
      get(g:, 'vimrc_plugin_home', DEFAULT_PLUGIN_HOME))
const STATE_HOME = empty(STATE_CANDIDATE)
      \ ? HOME_DIR .. '/.local/state'
      \ : STATE_CANDIDATE
const CONFIG_HOME = empty(CONFIG_CANDIDATE)
      \ ? HOME_DIR .. '/.config'
      \ : CONFIG_CANDIDATE
const PLUGIN_HOME = empty(PLUGIN_CANDIDATE)
      \ ? DEFAULT_PLUGIN_HOME
      \ : PLUGIN_CANDIDATE
const VIM_STATE = STATE_HOME .. '/vim'

g:vimrc_plugin_home = PLUGIN_HOME
g:vimrc_plugins_ready = 0
g:vimrc_context = {
  root: ROOT,
  state_home: STATE_HOME,
  config_home: CONFIG_HOME,
  vim_state: VIM_STATE,
  undo_dir: VIM_STATE .. '/undo',
  swap_dir: VIM_STATE .. '/swap',
  backup_dir: VIM_STATE .. '/backup',
  session_dir: VIM_STATE .. '/session',
  simplecc_user_config: CONFIG_HOME .. '/simplecc/simplecc.json',
  plugin_home: PLUGIN_HOME,
  local_before: LOCAL_BEFORE,
  local_after: LOCAL_AFTER,
  plugins_enabled: get(g:, 'vimrc_skip_plugins', 0) == 0
        \ && $VIMRC_SKIP_PLUGINS !=# '1',
  plugins_ready: false,
}

for module in [
  'core.vim',
  'plugins.vim',
  'behavior.vim',
  'workflow.vim',
  'mappings.vim',
  'update.vim',
]
  execute 'source ' .. fnameescape(ROOT .. '/config/' .. module)
endfor

# Host-specific settings stay outside version control and intentionally run
# after the shared defaults.
if filereadable(LOCAL_AFTER)
  execute 'source ' .. fnameescape(LOCAL_AFTER)
endif
