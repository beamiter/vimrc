vim9script

# Vim 9.1 is the common baseline for this configuration and the simple*
# workbench.  Stop before loading modules that use newer options.
if v:version < 901
  echoerr '[vimrc] Vim 9.1 or newer is required'
  finish
endif

if empty($HOME) || $HOME !~# '^/' || $HOME ==# '/'
  echoerr '[vimrc] HOME must be an absolute, non-root directory'
  finish
endif

const HOME_DIR = substitute(
      resolve(fnamemodify($HOME, ':p')),
      '[\/\\]\+$',
      '',
      '')
if empty(HOME_DIR) || HOME_DIR ==# '/' || !isdirectory(HOME_DIR)
  echoerr '[vimrc] HOME must resolve to an existing, non-root directory'
  finish
endif

g:mapleader = ' '
g:maplocalleader = ','

const ROOT = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const DEFAULT_STATE_HOME = HOME_DIR .. '/.local/state'
const DEFAULT_CONFIG_HOME = HOME_DIR .. '/.config'
const STATE_CANDIDATE = empty($XDG_STATE_HOME) || $XDG_STATE_HOME !~# '^/'
      \ ? ''
      \ : substitute(
        resolve(fnamemodify($XDG_STATE_HOME, ':p')),
        '[\/\\]\+$',
        '',
        '')
const CONFIG_CANDIDATE = empty($XDG_CONFIG_HOME) || $XDG_CONFIG_HOME !~# '^/'
      \ ? ''
      \ : substitute(
        resolve(fnamemodify($XDG_CONFIG_HOME, ':p')),
        '[\/\\]\+$',
        '',
        '')
const PLUGIN_CANDIDATE = get(
      g:,
      'vimrc_plugin_home',
      HOME_DIR .. '/.vim/plugged')
const PLUGIN_RESOLVED = PLUGIN_CANDIDATE !~# '^/'
      \ ? ''
      \ : substitute(
        resolve(fnamemodify(PLUGIN_CANDIDATE, ':p')),
        '[\/\\]\+$',
        '',
        '')
const STATE_HOME = empty(STATE_CANDIDATE)
      \ ? DEFAULT_STATE_HOME
      \ : STATE_CANDIDATE
const CONFIG_HOME = empty(CONFIG_CANDIDATE)
      \ ? DEFAULT_CONFIG_HOME
      \ : CONFIG_CANDIDATE
const PLUGIN_HOME = empty(PLUGIN_RESOLVED)
      \ ? HOME_DIR .. '/.vim/plugged'
      \ : PLUGIN_RESOLVED
const VIM_STATE = STATE_HOME .. '/vim'

g:vimrc_root = ROOT
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
  plugins_enabled: get(g:, 'vimrc_skip_plugins', 0) == 0
        \ && $VIMRC_SKIP_PLUGINS !=# '1',
  plugins_ready: false,
}

for module in ['core.vim', 'plugins.vim', 'behavior.vim', 'mappings.vim']
  execute 'source ' .. fnameescape(ROOT .. '/vimrc/' .. module)
endfor

# Host-specific settings stay outside version control and intentionally run
# after the shared defaults.
const LOCAL_VIMRC = HOME_DIR .. '/.vimrc.local'
if filereadable(LOCAL_VIMRC)
  execute 'source ' .. fnameescape(LOCAL_VIMRC)
endif
