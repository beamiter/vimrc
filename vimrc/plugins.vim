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

# SimplePlug：默认启动绝不联网，安装和更新必须显式执行。
g:simpleplug_auto_install = 0
g:simpleplug_jobs = 8
g:simpleplug_window_width = 88

# SimpleFinder
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

# SimpleTreeSitter：matchup 已负责括号反馈，避免重复彩虹高亮。
g:simpletreesitter_rainbow_brackets = 0
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

# 其他插件
g:gitgutter_map_keys = 0
g:gitgutter_async = 1
g:EasyMotion_do_mapping = 0
g:EasyMotion_smartcase = 1
g:matchup_matchparen_offscreen = {method: 'popup'}
g:lexima_accept_pum_with_enter = 0

g:startify_change_to_dir = 0
g:startify_change_to_vcs_root = 1
g:startify_session_dir = session_dir
g:startify_session_persistence = 1
g:startify_custom_header = []

# Julia/Haskell
g:haskell_enable_quantification = 1
g:haskell_enable_recursivedo = 1
g:haskell_enable_arrowsyntax = 1
g:haskell_enable_pattern_synonyms = 1
g:haskell_enable_typeroles = 1
g:haskell_enable_static_pointers = 1
g:haskell_backpack = 1

# netrw 作为无插件时的可靠后备。
g:netrw_banner = 0
g:netrw_liststyle = 3
g:netrw_fastbrowse = 2

# ============================================================================
# 插件管理
# ============================================================================
var simpleplug_home = plugin_home .. '/simpleplug'

if plugins_enabled && isdirectory(simpleplug_home)
  if index(split(&runtimepath, ','), simpleplug_home) < 0
    &runtimepath = simpleplug_home .. ',' .. &runtimepath
  endif

  try
    simpleplug#Begin(plugin_home)

    # 语言支持；重型语言插件按 filetype 延迟。
    simpleplug#Plug('JuliaEditorSupport/julia-vim', {for: 'julia'})
    simpleplug#Plug('kdheepak/JuliaFormatter.vim', {for: 'julia'})
    simpleplug#Plug('neovimhaskell/haskell-vim', {for: 'haskell'})

    # UI
    simpleplug#Plug('ryanoasis/vim-devicons')
    simpleplug#Plug('beamiter/simpleline', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpleminimap', {do: './install.sh'})
    simpleplug#Plug('mhinz/vim-startify')

    # 导航和搜索
    simpleplug#Plug('beamiter/simplefinder', {do: './install.sh'})
    simpleplug#Plug('easymotion/vim-easymotion')

    # 编辑增强
    simpleplug#Plug('cohama/lexima.vim')
    simpleplug#Plug('tomtom/tcomment_vim')
    simpleplug#Plug('andymass/vim-matchup')
    simpleplug#Plug('mg979/vim-visual-multi')

    # Git
    simpleplug#Plug('tpope/vim-fugitive')
    simpleplug#Plug('airblade/vim-gitgutter')

    # 终端和键位提示
    simpleplug#Plug('voldikss/vim-floaterm')
    simpleplug#Plug('liuchengxu/vim-which-key')

    # beamiter/simple* 工作台
    simpleplug#Plug('beamiter/simpleclipboard', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpletree', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpletreesitter', {do: './install.sh'})
    simpleplug#Plug('beamiter/simpleplug', {do: './install.sh'})
    simpleplug#Plug('beamiter/simplecc', {do: './install.sh'})

    simpleplug#End()
    plugins_ready = true
  catch
    echohl WarningMsg
    echomsg '[vimrc] 插件层加载失败，已保留核心编辑能力: ' .. v:exception
    echohl None
  endtry
elseif plugins_enabled
  echohl WarningMsg
  echomsg '[vimrc] SimplePlug 未安装；当前使用核心模式。运行 '
        \ .. root .. '/utils/install.sh --bootstrap-simpleplug'
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
