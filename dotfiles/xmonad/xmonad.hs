import XMonad
import XMonad.Hooks.DynamicLog (xmobar)
import XMonad.Util.SpawnOnce

myConfig = def
  { modMask     = mod1Mask -- set 'Mod' to windows key
  , terminal    = "terminator" -- for Mod + Shift + Enter
  , startupHook = spawnOnce "bash ~/.config/xmonad/autostart.sh"
  }

main = xmonad =<< xmobar myConfig

