#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
xrandr --dpi 96

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi


if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xset r rate 200 25
#setxkbmap -layout pt
setxkbmap -model 'pc105aw-sl' -layout 'us(cmk_ed_dh)' -option 'misc:extend,lv5:caps_switch_lock,misc:cmk_curl_dh'
xmodmap -e 'keycode 135=space'
xmodmap -e 'keycode 65='
picom -b
unclutter &
dunst &
feh --bg-scale ~/pictures/wallpapers/gruvbox_1.png
alacritty --class spotify,spotify --title Spotify -e spt &
discord &
mattermost-desktop &
slack &
firefox &

exec xmonad
