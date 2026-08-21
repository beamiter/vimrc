vim9script

# ============================================================================
# 共享辅助
# ============================================================================
# 跨模块复用的小型入口；只有真正的全局函数放在这里，模块内部逻辑保持
# script-local。Vim9 重新 source 时会自动重定义，无需手动清理。

def g:VimrcWarn(message: string)
  echohl WarningMsg
  echomsg '[vimrc] ' .. message
  echohl None
enddef

def g:VimrcInfo(message: string)
  echomsg '[vimrc] ' .. message
enddef

# SimpleLine 在渲染时才解析段位表，因此注册顺序与插件加载顺序无关；按函数名
# 去重保证反复 source 幂等。段位函数本身必须只读缓存状态，绝不在重画时跑
# 外部命令。
def g:VimrcRegisterStatuslineSegment(segment: dict<any>)
  var segments = get(g:, 'simpleline_custom_right', [])
  if type(segments) != v:t_list
    segments = []
  endif
  g:simpleline_custom_right = filter(
    segments,
    (_, value) => type(value) != v:t_dict
      \ || get(value, 'fn', '') !=# get(segment, 'fn', '')) + [segment]
enddef
