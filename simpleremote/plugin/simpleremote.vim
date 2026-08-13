vim9script

if exists('g:loaded_simpleremote')
  finish
endif
g:loaded_simpleremote = 1

if v:version < 901
  echoerr '[SimpleRemote] Vim 9.1 or newer is required'
  finish
endif

if !exists('g:simpleremote_profiles')
  g:simpleremote_profiles = []
endif
if !exists('g:simpleremote_workspace_mode')
  g:simpleremote_workspace_mode = 'auto'
endif
if !exists('g:simpleremote_use_sshfs')
  g:simpleremote_use_sshfs = 'auto'
endif
if !exists('g:simpleremote_change_directory')
  g:simpleremote_change_directory = 'tab'
endif
if !exists('g:simpleremote_open_tree_on_connect')
  g:simpleremote_open_tree_on_connect = 1
endif
if !exists('g:simpleremote_tree_width')
  g:simpleremote_tree_width = 40
endif
if !exists('g:simpleremote_default_root')
  g:simpleremote_default_root = '/'
endif

const PLUGIN_ROOT = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'source ' .. fnameescape(PLUGIN_ROOT .. '/autoload/simpleremote.vim')

command! -nargs=0 SimpleRemote call g:SimpleRemoteUI()
command! -nargs=* -complete=customlist,SimpleRemoteComplete SimpleRemoteConnect call g:SimpleRemoteConnectCommand(<f-args>)
command! -nargs=0 SimpleRemoteDisconnect call g:VimrcRemoteDisconnect()
command! -nargs=0 SimpleRemoteReconnect call g:SimpleRemoteReconnect()
command! -nargs=0 SimpleRemoteHosts call g:SimpleRemoteUI()
command! -nargs=0 SimpleRemoteContainers call g:SimpleRemoteUI()
command! -nargs=? SimpleRemoteWorkspace call g:SimpleRemoteWorkspace(<q-args>)
command! -nargs=0 SimpleRemoteTree call g:SimpleRemoteTreeToggle()
command! -nargs=0 SimpleRemoteTreeReveal call g:SimpleRemoteTreeReveal()
command! -nargs=1 SimpleRemoteOpen call g:VimrcRemoteOpen(<q-args>)
command! -nargs=+ SimpleRemoteExec call g:VimrcRemoteExec(<q-args>)
command! -nargs=1 SimpleRemoteFind call g:VimrcRemoteFind(<q-args>)
command! -nargs=+ SimpleRemoteGit call g:VimrcRemoteGit(<q-args>)
command! -nargs=0 SimpleRemoteTerminal call g:SimpleRemoteTerminal()
command! -nargs=0 SimpleRemoteInstallAgent call g:SimpleRemoteInstallAgent()
command! -nargs=0 SimpleRemoteHealth call g:VimrcRemoteHealth()
command! -nargs=0 SimpleRemoteReloadConfig call g:VimrcRemoteReloadConfig()
command! -nargs=0 SimpleRemoteStatus call g:SimpleRemoteShowStatus()

nnoremap <silent> <Plug>(simpleremote-open) <Cmd>SimpleRemote<CR>
nnoremap <silent> <Plug>(simpleremote-connect) <Cmd>SimpleRemoteConnect<CR>
nnoremap <silent> <Plug>(simpleremote-disconnect) <Cmd>SimpleRemoteDisconnect<CR>
nnoremap <silent> <Plug>(simpleremote-reconnect) <Cmd>SimpleRemoteReconnect<CR>
nnoremap <silent> <Plug>(simpleremote-tree-toggle) <Cmd>SimpleRemoteTree<CR>
nnoremap <silent> <Plug>(simpleremote-status) <Cmd>SimpleRemoteStatus<CR>
