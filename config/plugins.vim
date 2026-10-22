vim9script

var C = g:vimrc_context
var root = C.root
var plugin_home = C.plugin_home
var session_dir = C.session_dir
var simplecc_user_config = C.simplecc_user_config
var plugins_enabled = C.plugins_enabled
var plugins_ready = false

# ============================================================================
# 插件加载前配置
# ============================================================================

# .vimrc.before and values changed interactively remain authoritative on reload.
# All simple* options below are defaults, including plugin mapping switches.
def Default(name: string, value: any)
  if !has_key(g:, name)
    g:[name] = value
  endif
enddef

# Environment-derived defaults follow a changed XDG state or project-marker
# policy on reload. A value that the user replaced has independent ownership.
def ManagedDefault(name: string, value: any)
  var managed = get(g:, 'vimrc_managed_plugin_defaults', {})
  if !has_key(g:, name)
        || (has_key(managed, name) && g:[name] ==# managed[name])
    g:[name] = deepcopy(value)
    managed[name] = deepcopy(value)
  elseif has_key(managed, name)
    remove(managed, name)
  endif
  g:vimrc_managed_plugin_defaults = managed
enddef

# 已有 SimplePlug 时自动补齐新加入的插件；管理器本身缺失时由
# bootstrap.vim 事务式安装，并在成功后接续一次完整的 :PlugUpdate。
Default('simpleplug_auto_install', 1)
Default('simpleplug_jobs', 8)
Default('simpleplug_window_width', 88)

# SimpleFinder
# simplefinder_remote：直接搜索 SimpleRemote 当前 workspace（文件与 grep 都走
# agent，不要求本地投影）；粘贴进 prompt 的多行文本原样作为查询词。
Default('simplefinder_remote', 1)
Default('simplefinder_max_results', 300)
Default('simplefinder_debounce_ms', 40)
Default('simplefinder_panel_width', 52)
Default('simplefinder_position', 'right')
ManagedDefault('simplefinder_root_markers', get(g:, 'vimrc_root_markers', ['.git']))

# SimpleTree
Default('simpletree_set_default_mapping', 0)
Default('simpletree_width', 40)
Default('simpletree_auto_refresh_interval', 5000)
Default('simpletree_use_nerdfont', 1)

# SimpleLine：Git 仅由事件驱动刷新，避免常驻轮询。
Default('simpleline_enable_default_mappings', 0)
Default('simpleline_separator', 'arrow')
Default('simpleline_nerdfont', 1)
Default('simpleline_git_interval', 0)
Default('simpleline_compact_width', 88)
Default('simpletabline_path_mode', 'abbr')

# SimpleMinimap
Default('simpleminimap_set_default_mapping', 0)
Default('simpleminimap_width', 16)
Default('simpleminimap_debounce', 120)
Default('simpleminimap_ignore_filetypes', [
  'help',
  'qf',
  'startify',
  'simpletree',
  'simpleminimap',
])

# SimpleTreeSitter 同时负责语义高亮、彩虹括号，并用 Vim 自带 matchit 做块匹配。
Default('simpletreesitter_rainbow_brackets', 1)
Default('simpletreesitter_match_words', 1)
Default('simpletreesitter_outline_width', 40)
Default('simpletreesitter_outline_fancy', 1)
Default('simpletreesitter_max_buffer_bytes', 5 * 1024 * 1024)

# SimpleCC：统一接管键位，禁用自动下载语言服务器。
Default('simplecc_no_default_maps', 1)
Default('simplecc_auto_install', 0)
Default('simplecc_auto_start', 1)
Default('simplecc_auto_complete', 1)
Default('simplecc_complete_delay', 80)
Default('simplecc_complete_max_items', 80)
ManagedDefault('simplecc_inlay_hints', g:VimrcNativeIde() ? 0 : 1)
ManagedDefault('simplecc_signature_help', g:VimrcNativeIde() ? 0 : 1)
Default('simplecc_virtual_diag', 0)
Default('simplecc_semantic_tokens', 0)
# Project SimpleCC files can choose executable commands.  Default to a trusted,
# explicit user/repository config; project-first discovery is opt-in.
var default_simplecc_config = filereadable(simplecc_user_config)
      \ ? simplecc_user_config
      \ : root .. '/simplecc.json'
var managed_config_existed = get(g:, 'vimrc_simplecc_config_is_managed', 0) == 1
var config_was_user_set = exists('g:simplecc_config_path')
      \ && (!managed_config_existed
        \ || g:simplecc_config_path !=# get(
          g:,
          'vimrc_simplecc_managed_config',
          ''))
if !config_was_user_set
  g:simplecc_config_path = default_simplecc_config
  g:vimrc_simplecc_managed_config = default_simplecc_config
  g:vimrc_simplecc_config_is_managed = 1
else
  g:vimrc_simplecc_config_is_managed = 0
endif

# 原生 +clipboard 可直接工作；否则由 SimpleClipboard daemon/OSC52 降级。
Default('simpleclipboard_no_default_mappings', 1)
Default('simpleclipboard_auto_copy', has('unnamedplus') ? 0 : 1)
Default('simpleclipboard_daemon_autostart', has('unnamedplus') ? 0 : 1)

# SimpleGit：键位统一由 mappings.vim 管理。
Default('simplegit_enable_default_mappings', 0)
# 默认关闭当前行 inlay blame，需要时用 <leader>gt 开启。
Default('simplegit_line_blame', 0)

# SimpleMarkdown：键位统一由 mappings.vim 管理；插件默认的 <leader>md 会落进
# minimap 的 m 前缀组，预览键位改挂在 <leader>p 下。
Default('simplemarkdown_set_default_mapping', 0)

# 编辑基础能力都由 simple* 提供。键位集中在 mappings.vim；SimplePairs 的
# insert expr 映射例外，因为每个字符都需要直接返回待插入文本。
Default('simplecomment_default_mappings', 0)
Default('simplepairs_default_mappings', 1)
Default('simplemulti_default_mappings', 0)
Default('simpleedit_yank_highlight', 1)
Default('simpleedit_yank_duration', 220)
Default('simpleeditorconfig_enable', 1)
Default('simpleeditorconfig_remote', 1)

# SimpleTerminal 会优先使用 SimpleRemote 当前 workspace；已有终端仍留在创建时
# 的 workspace，不因后来切换根目录而被悄悄挪走。
Default('simpleterminal_prefer_remote', 1)
Default('simpleterminal_width', 82)
Default('simpleterminal_height', 76)

# SimpleWhichKey：不止 leader，Vim 自己的前缀键也给提示面板。<leader> 下已经有
# 更长的映射，Vim 本来就会等 timeoutlen，所以那一档不再叠加自己的延时；g/z/
# <C-w> 这些 Vim 立刻分发的前缀才用 delay。
Default('simplewhichkey_delay', 180)
Default('simplewhichkey_position', 'bottom')
Default('simplewhichkey_sort', 'group')
# <leader>0…<leader>9 是 SimpleLine 的 buffer 索引，十个条目会把 leader 面板挤
# 满，留在键位里但不进面板。
Default('simplewhichkey_ignore', range(0, 9)->mapnew((_, index) => '<leader>' .. index))

# SimpleStartify：每次进入启动页随机一套布局，并避免连续重复；session 仍只写
# XDG state。保留 filetype=startify，现有 sidebar/minimap 规则无需兼容分支。
Default('simplestartify_style', 'random')
Default('simplestartify_styles', ['minimal', 'boxed', 'centered', 'terminal'])
Default('simplestartify_avoid_repeat', 1)
Default('simplestartify_recent_count', 7)
Default('simplestartify_session_count', 4)
# 启动页同时列出最近的 SimpleRemote workspace，点击直接重连。
Default('simplestartify_remote_count', 3)
Default('simplestartify_change_to_dir', 0)
Default('simplestartify_change_to_vcs_root', 1)
ManagedDefault('simplestartify_session_dir', session_dir)
Default('simplestartify_session_persistence', 1)

# netrw 作为无插件时的可靠后备。
Default('netrw_banner', 0)
Default('netrw_liststyle', 3)
Default('netrw_fastbrowse', 2)

# ============================================================================
# 插件管理
# ============================================================================
var simpleplug_home = plugin_home .. '/simpleplug'

if plugins_enabled && g:VimrcSimplePlugReady()
  if index(split(&runtimepath, ','), simpleplug_home) < 0
    &runtimepath = simpleplug_home .. ',' .. &runtimepath
  endif

  try
    simpleplug#Begin(plugin_home)

    # 管理器自身也注册为插件，:PlugUpdate 才能更新 SimplePlug 并重建 daemon。
    simpleplug#Plug('beamiter/simpleplug', {do: './install.sh'})

    # UI
    simpleplug#Plug('beamiter/simpleline', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpleminimap', {do: './install.sh'})
    simpleplug#Plug('beamiter/simplestartify')

    # 导航和搜索
    simpleplug#Plug('beamiter/simplefinder', {do: './install.sh'})
    simpleplug#Plug('beamiter/simplemotion')

    # 编辑增强
    simpleplug#Plug('beamiter/simplecomment')
    simpleplug#Plug('beamiter/simplepairs')
    simpleplug#Plug('beamiter/simpleedit')
    simpleplug#Plug('beamiter/simplemulti')
    simpleplug#Plug('beamiter/simpleeditorconfig')

    # Git
    simpleplug#Plug('beamiter/simplegit', {do: './install.sh'})

    # 终端和键位提示
    simpleplug#Plug('beamiter/simpleterminal')
    simpleplug#Plug('beamiter/simplewhichkey')

    # beamiter/simple* 工作台
    simpleplug#Plug('beamiter/simpleclipboard', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpleremote', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpletree', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpletreesitter', {do: './install.sh'})
    simpleplug#Plug('beamiter/simplecc', {do: './install.sh'})
    simpleplug#Plug('beamiter/simplemarkdown', {do: './install.sh'})

    simpleplug#End()
    plugins_ready = true
  catch
    g:VimrcWarn('插件层加载失败，已保留核心编辑能力: ' .. v:exception)
  endtry
elseif plugins_enabled
  if g:vimrc_simpleplug_auto_bootstrap
    g:VimrcWarn('SimplePlug 尚未就绪；已安排自动 bootstrap，当前先使用核心模式')
  else
    g:VimrcWarn(
      'SimplePlug 尚未就绪且自动 bootstrap 已关闭；运行 :VimrcBootstrapRetry 可手动启动')
  endif
endif

if !plugins_ready
  filetype plugin indent on
  syntax enable
endif

C.plugins_ready = plugins_ready
g:vimrc_plugins_ready = plugins_ready ? 1 : 0

# SimpleLine already shows the current mode; keep Vim's duplicate -- INSERT --
# only as a no-plugin fallback.
if plugins_ready
  set noshowmode
else
  set showmode
endif

# ============================================================================
# 颜色
# ============================================================================
Default('vimrc_colorscheme', 'spacemacs')
Default('vimrc_background', 'dark')
&background = g:vimrc_background
try
  execute 'colorscheme ' .. fnameescape(g:vimrc_colorscheme)
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme habamax
endtry
