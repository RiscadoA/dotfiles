import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import System.IO
import Data.List
import Data.Maybe

import qualified Graphics.X11.ExtraTypes.XF86 as XF86

myManageHook = composeAll
    [ className =? "Gimp"    --> doFloat
    , className =? "Code"    --> doShift "code"
    , className =? "firefox" --> doShift "network"
    , className =? "discord" --> doShift "discord"
    , className =? "Slack" --> doShift "team"
    , className =? "Mattermost" --> doShift "team"
    , className =? "zoom"    --> doShift "video"
    , className =? "spotify" --> doShift "music"
    ]

myPlaceHook = placeHook (withGaps (16,0,16,0) (smart (0.5, 0.5)))

layoutFull = (noBorders Full)
layoutSingle = (avoidStruts (noBorders Full))
layoutTiled = (avoidStruts (spacingRaw False (Border 5 5 5 5) True (Border 5 5 5 5) True $ Tall 1 (10/100) (50/100)))
layoutAll = (layoutSingle ||| layoutFull ||| layoutTiled)

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks defaultConfig
        { manageHook = myManageHook <+> myPlaceHook  <+> manageHook defaultConfig
        , layoutHook = onWorkspace "terminal" layoutTiled $
		       onWorkspace "network" layoutAll $
		       onWorkspaces ["video", "code"] (layoutSingle ||| layoutFull) $
		       layoutSingle
        , logHook    = dynamicLogWithPP xmobarPP
                           { ppOutput          = hPutStrLn xmproc
                           , ppCurrent         = xmobarColor "#e3a84e" "" . workspaceIcon
                           , ppHidden          = xmobarColor "#dfbf8e" "" . workspaceIcon
                           , ppHiddenNoWindows = xmobarColor "#dfbf8e" "" . workspaceIcon
                           , ppUrgent          = xmobarColor "red" "yellow" . workspaceIcon
                           , ppTitle           = xmobarColor "#e3a84e" "" . shorten 50
                           }
        , modMask            = mod4Mask
        , terminal           = "alacritty"
        , focusFollowsMouse  = True
        , clickJustFocuses   = True
        , borderWidth        = 2
        , normalBorderColor  = "#665c54"
        , focusedBorderColor = "#e3a84e" 
        , workspaces         = myWorkspaces
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_l), spawn "slock -m \"Screen locked\"")
        , ((mod4Mask .|. controlMask, xK_Left), spawn "playerctl previous")
        , ((mod4Mask .|. controlMask, xK_Right), spawn "playerctl next")
        , ((mod4Mask .|. controlMask, xK_Up), spawn "playerctl play")
        , ((mod4Mask .|. controlMask, xK_Down), spawn "playerctl pause")
        , ((mod4Mask .|. controlMask, xK_F1), spawn "setxkbmap -model 'pc105aw-sl' -layout 'us(cmk_ed_dh)' -option 'misc:extend,lv5:caps_switch_lock,misc:cmk_curl_dh';xmodmap -e 'keycode 135=space';xmodmap -e 'keycode 65='") 
        , ((mod4Mask .|. controlMask, xK_F2), spawn "setxkbmap -model 'pc105' -layout pt -option '';xmodmap -e 'keycode 135=space';xmodmap -e 'keycode 65='")
        , ((0, XF86.xF86XK_MonBrightnessUp), spawn "lux -a 5%")
        , ((0, XF86.xF86XK_MonBrightnessDown), spawn "lux -s 5%")
        , ((0, xK_Print), spawn "flameshot gui")
        ]


myWorkspaces :: [WorkspaceId]
myWorkspaces =
    [ "terminal"
    , "code"
    , "network"
    , "discord"
    , "team"
    , "video"
    , "other"
    , "music"
    ]

workspaceIcons =
    [ "\xf120"
    , "\xf1c9"
    , "\xf269"
    , "\xf392"
    , "\xf0c0"
    , "\xf008"
    , "\xf0eb"
    , "\xf001"
    ]

workspaceIcon :: String -> String
workspaceIcon id = workspaceIcons !! (fromJust $ elemIndex id myWorkspaces)

