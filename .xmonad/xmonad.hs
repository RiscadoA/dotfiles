import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import System.IO

import qualified Graphics.X11.ExtraTypes.XF86 as XF86

myManageHook = composeAll
    [ className =? "Gimp"    --> doFloat
    , className =? "Code"    --> doShift (myWorkspaces !! 1)
    , className =? "firefox" --> doShift (myWorkspaces !! 2)
    , className =? "discord" --> doShift (myWorkspaces !! 3)
    , className =? "Spotify" --> doShift (myWorkspaces !! 6)
    , className =? "zoom"    --> doShift (myWorkspaces !! 4)
    ]

myPlaceHook = placeHook (withGaps (16,0,16,0) (smart (0.5, 0.5)))

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks defaultConfig
        { manageHook = myManageHook <+> myPlaceHook  <+> manageHook defaultConfig
        , layoutHook = avoidStruts (noBorders Full)
                       ||| noBorders Full
                       ||| (avoidStruts (spacingRaw False (Border 5 5 5 5) True (Border 5 5 5 5) True $ Tall 1 (10/100) (50/100)))
        , logHook    = dynamicLogWithPP xmobarPP
                           { ppOutput          = hPutStrLn xmproc
                           , ppCurrent         = xmobarColor "#6693f5" ""
                           , ppHidden          = xmobarColor "#abd1f3" ""
                           , ppHiddenNoWindows = xmobarColor "#abd1f3" ""
                           , ppTitle           = xmobarColor "#6693f5" "" . shorten 50
                           , ppUrgent          = xmobarColor "red" "yellow"
                           }
        , modMask            = mod4Mask
        , terminal           = "alacritty"
        , focusFollowsMouse  = True
        , clickJustFocuses   = True
        , borderWidth        = 2
        , normalBorderColor  = "#444444"
        , focusedBorderColor = "#aaaaaa" 
        , workspaces         = myWorkspaces
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_l), spawn "slock -m \"Screen locked\"")
        , ((mod4Mask .|. controlMask, xK_Left), spawn "playerctl previous")
        , ((mod4Mask .|. controlMask, xK_Right), spawn "playerctl next")
        , ((mod4Mask .|. controlMask, xK_Down), spawn "playerctl play-pause")
        , ((mod4Mask .|. controlMask, xK_F1), spawn "setxkbmap -model 'pc105aw-sl' -layout 'us(cmk_ed_dh)' -option 'misc:extend,lv5:caps_switch_lock,misc:cmk_curl_dh';xmodmap -e 'keycode 135=space';xmodmap -e 'keycode 65='") 
        , ((mod4Mask .|. controlMask, xK_F2), spawn "setxkbmap -model 'pc105' -layout pt -option '';xmodmap -e 'keycode 135=space';xmodmap -e 'keycode 65='")
        , ((0, XF86.xF86XK_MonBrightnessUp), spawn "lux -a 5%")
        , ((0, XF86.xF86XK_MonBrightnessDown), spawn "lux -s 5%")
        , ((0, xK_Print), spawn "flameshot gui")
        ]


myWorkspaces :: [WorkspaceId]
myWorkspaces =
    [ "\xf120"
    , "\xf1c9"
    , "\xf269"
    , "\xf392"
    , "\xf008"
    , "\xf0eb"
    , "\xf001"
    ]

workspaceNames =
    [ "Terminal"
    , "Development"
    , "Network"
    , "Chatting"
    , "Video"
    , "Other"
    , "Music"
    ]

