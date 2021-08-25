import XMonad

--main :: IO ()
--main = xmonad def

import XMonad
import XMonad.Hooks.DynamicLog (xmobar)

myConfig = def
  { modMask     = mod1Mask -- set 'Mod' to windows key
  , terminal    = "gnome-terminal" -- for Mod + Shift + Enter
  }

main = xmonad =<< xmobar myConfig

