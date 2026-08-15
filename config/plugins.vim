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

# 已有 SimplePlug 时自动补齐新加入的插件；管理器本身缺失时由
# bootstrap.vim 事务式安装，并在成功后接续一次完整的 :PlugUpdate。
if !exists('g:simpleplug_auto_install')
  g:simpleplug_auto_install = 1
endif
g:simpleplug_jobs = 8
g:simpleplug_window_width = 88

# SimpleFinder
# simplefinder_remote：直接搜索 SimpleRemote 当前 workspace（文件与 grep 都走
# agent，不要求本地投影）；粘贴进 prompt 的多行文本原样作为查询词。
g:simplefinder_remote = 1
g:simplefinder_max_results = 300
g:simplefinder_debounce_ms = 40
g:simplefinder_panel_width = 52
g:simplefinder_position = 'right'
g:simplefinder_root_markers = [
  '.git',
  'Cargo.toml',
  'Project.toml',
  'pyproject.toml',
  'package.json',
  'go.mod',
  'Makefile',
]

# SimpleTree
g:simpletree_set_default_mapping = 0
g:simpletree_width = 40
g:simpletree_auto_refresh_interval = 5000
g:simpletree_use_nerdfont = 1

# SimpleLine：Git 仅由事件驱动刷新，避免常驻轮询。
g:simpleline_enable_default_mappings = 0
g:simpleline_separator = 'arrow'
g:simpleline_nerdfont = 1
g:simpleline_git_interval = 0
g:simpleline_compact_width = 88
g:simpletabline_path_mode = 'abbr'

# SimpleMinimap
g:simpleminimap_set_default_mapping = 0
g:simpleminimap_width = 16
g:simpleminimap_debounce = 120
g:simpleminimap_ignore_filetypes = [
  'help',
  'qf',
  'startify',
  'simpletree',
  'simpleminimap',
]

# SimpleTreeSitter 同时负责语义高亮、彩虹括号，并用 Vim 自带 matchit 做块匹配。
g:simpletreesitter_rainbow_brackets = 1
g:simpletreesitter_match_words = 1
g:simpletreesitter_outline_width = 40
g:simpletreesitter_outline_fancy = 1
g:simpletreesitter_max_buffer_bytes = 5 * 1024 * 1024

# SimpleCC：统一接管键位，禁用自动下载语言服务器。
g:simplecc_no_default_maps = 1
g:simplecc_auto_install = 0
g:simplecc_auto_start = 1
g:simplecc_auto_complete = 1
g:simplecc_complete_delay = 80
g:simplecc_complete_max_items = 80
g:simplecc_inlay_hints = 1
g:simplecc_virtual_diag = 0
g:simplecc_semantic_tokens = 0
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
g:simpleclipboard_no_default_mappings = 1
g:simpleclipboard_auto_copy = has('unnamedplus') ? 0 : 1
g:simpleclipboard_daemon_autostart = has('unnamedplus') ? 0 : 1

# SimpleGit：键位统一由 mappings.vim 管理。
g:simplegit_enable_default_mappings = 0
# 默认关闭当前行 inlay blame，需要时用 <leader>gt 开启。
g:simplegit_line_blame = 0

# SimpleMarkdown：键位统一由 mappings.vim 管理；插件默认的 <leader>md 会落进
# minimap 的 m 前缀组，预览键位改挂在 <leader>p 下。
g:simplemarkdown_set_default_mapping = 0

# 编辑基础能力都由 simple* 提供。键位集中在 mappings.vim；SimplePairs 的
# insert expr 映射例外，因为每个字符都需要直接返回待插入文本。
g:simplecomment_default_mappings = 0
g:simplepairs_default_mappings = 1
g:simplemulti_default_mappings = 0
g:simpleedit_yank_highlight = get(g:, 'simpleedit_yank_highlight', 1)
g:simpleedit_yank_duration = get(g:, 'simpleedit_yank_duration', 220)
g:simpleeditorconfig_enable = get(g:, 'simpleeditorconfig_enable', 1)
g:simpleeditorconfig_remote = 1

# SimpleTerminal 会优先使用 SimpleRemote 当前 workspace；已有终端仍留在创建时
# 的 workspace，不因后来切换根目录而被悄悄挪走。
g:simpleterminal_prefer_remote = 1
g:simpleterminal_width = 82
g:simpleterminal_height = 76

# SimpleWhichKey：不止 leader，Vim 自己的前缀键也给提示面板。<leader> 下已经有
# 更长的映射，Vim 本来就会等 timeoutlen，所以那一档不再叠加自己的延时；g/z/
# <C-w> 这些 Vim 立刻分发的前缀才用 delay。
g:simplewhichkey_delay = 180
g:simplewhichkey_position = 'bottom'
g:simplewhichkey_sort = 'group'
# <leader>0…<leader>9 是 SimpleLine 的 buffer 索引，十个条目会把 leader 面板挤
# 满，留在键位里但不进面板。
g:simplewhichkey_ignore = range(0, 9)->mapnew((_, index) => '<leader>' .. index)

# SimpleStartify：每次进入启动页随机一套布局，并避免连续重复；session 仍只写
# XDG state。保留 filetype=startify，现有 sidebar/minimap 规则无需兼容分支。
g:simplestartify_style = 'random'
g:simplestartify_styles = ['minimal', 'boxed', 'centered', 'terminal']
g:simplestartify_avoid_repeat = 1
g:simplestartify_recent_count = 7
g:simplestartify_session_count = 4
# 启动页同时列出最近的 SimpleRemote workspace，点击直接重连。
g:simplestartify_remote_count = 3
g:simplestartify_change_to_dir = 0
g:simplestartify_change_to_vcs_root = 1
g:simplestartify_session_dir = session_dir
g:simplestartify_session_persistence = 1

# netrw 作为无插件时的可靠后备。
g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_fastbrowse = 2

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
    echohl WarningMsg
    echomsg '[vimrc] 插件层加载失败，已保留核心编辑能力: ' .. v:exception
    echohl None
  endtry
elseif plugins_enabled
  echohl WarningMsg
  if g:vimrc_simpleplug_auto_bootstrap
    echomsg '[vimrc] SimplePlug 尚未就绪；已安排自动 bootstrap，当前先使用核心模式'
  else
    echomsg '[vimrc] SimplePlug 尚未就绪且自动 bootstrap 已关闭；运行 '
          \ .. ':VimrcBootstrapRetry 可手动启动'
  endif
  echohl None
endif

if !plugins_ready
  filetype plugin indent on
  syntax enable
endif

C.plugins_ready = plugins_ready
g:vimrc_plugins_ready = plugins_ready ? 1 : 0

# ============================================================================
# 颜色
# ============================================================================
set background=dark
try
  colorscheme spacemacs
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme habamax
endtry
