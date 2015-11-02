#!/bin/bash

# ==============================================================================
# wasta-core: app-adjustments.sh
#
#   2015-10-25 rik: initial script - pulled from other scripts
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Check to ensure running as root
# ------------------------------------------------------------------------------
#   No fancy "double click" here because normal user should never need to run
if [ $(id -u) -ne 0 ]
then
	echo
	echo "You must run this script with sudo." >&2
	echo "Exiting...."
	sleep 5s
	exit 1
fi

# ------------------------------------------------------------------------------
# Initial Setup
# ------------------------------------------------------------------------------

echo
echo " *** Script Entry: app-adjustments.sh"
echo

# Setup Diretory for later reference
DIR=/usr/share/wasta-core

# if 'auto' parameter passed, run non-interactively
if [ "$1" == "auto" ];
then
    AUTO="auto"
else
    AUTO=""
fi

# ------------------------------------------------------------------------------
# FIRST: Gnome Application Menu Cleanup
# ------------------------------------------------------------------------------
# backup gnome-applications.menu first (don't do time check: always static original to keep
if ! [ -e /etc/xdg/menus/gnome-applications.menu.save ];
then
    cp /etc/xdg/menus/gnome-applications.menu \
       /etc/xdg/menus/gnome-applications.menu.save
fi

# Delete 'Sundry' Category:
#   items here are duplicated in Accessories or System Tools so clean up to
#   just use those 2 categories: why do we want another category??
# Keeping for reference in case need to modify xml in the future:
#       xmlstarlet ed --inplace --delete '/Menu/Menu[Name="Sundry"]' \
#           /etc/xdg/menus/gnome-applications.menu

# get rid of gnome-applications.menu hard-coded category settings
#   (let desktops do that!!!)
sed -i -e "\@<Filename>@d" /etc/xdg/menus/gnome-applications.menu

# ------------------------------------------------------------------------------
# SECOND: Clean up individual applications that are in bad places
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Artha
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/artha.desktop ];
then
    # change category, comment
    desktop-file-edit --set-key=Categories --set-value="Education;" \
        /usr/share/applications/artha.desktop

    desktop-file-edit --set-comment="WordNet based thesaurus and dictionary" \
        /usr/share/applications/artha.desktop

    # Ensure system default is to show window on launch (or else starts
    #   minimized in the system tray
    xmlstarlet ed --inplace --update \
        "/interface/object/child/object/child/object/child/object[@id='chkBtnLaunchMin']/property[@name='receives_default']" \
        --value "True" /usr/share/artha/gui.glade

    # 2014-12-22 rik: artha skel below not needed since do system adjustment above??

    # Note: the ability to use the main window (not just a system notify event)
    #   when hilighting a word in another application and hitting the key combo
    #   (default is "ctrl + alt + w") is not in the gui.glade file, which only
    #   controls the "options dialog window settings" it seems.  So, we are just
    #   placing an /etc/skel/.config/arth.conf file that will NOT use the the
    #   system notifications (thus popping the full artha window).
    #su $(logname) -c "cp /etc/skel/.config/artha.conf /home/$(logname)/.config/artha.conf"
fi

# ------------------------------------------------------------------------------
# baobab
# ------------------------------------------------------------------------------
# Add to "Accessories" category (by removing from X-GNOME-Utilities)
if [ -e /usr/share/applications/org.gnome.baobab.desktop ];
then
    desktop-file-edit ---remove-category=X-GNOME-Utilities \
        /usr/share/applications/org.gnome.baobab.desktop
fi

# ------------------------------------------------------------------------------
# evince (pdf viewer)
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/evince.desktop ];
then
    # remove from "Graphics": already in "Office"
    desktop-file-edit --remove-category=Graphics \
        /usr/share/applications/evince.desktop
fi

# ------------------------------------------------------------------------------
# file-roller
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/file-roller.desktop ];
then
    # hide from menu: only needed on right click
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/file-roller.desktop
fi

# ------------------------------------------------------------------------------
# font-manager
# ------------------------------------------------------------------------------
# change to "Utility" ("Accessories"): default is "Graphics"

if [ -e /usr/share/applications/font-manager.desktop ];
then
    desktop-file-edit --add-category=Utility \
        /usr/share/applications/font-manager.desktop

    desktop-file-edit --remove-category=Graphics \
        /usr/share/applications/font-manager.desktop
fi

# ------------------------------------------------------------------------------
# gnome-control-center
# ------------------------------------------------------------------------------
# add items to "comments" so that found from gnomenu
#   having gnomenu look at "Keywords" would be better
if [ -e /usr/share/applications/gnome-control-center.desktop ];
then
    desktop-file-edit --set-comment="Control Center





applications
backgrounds
battery
brightness
bluetooth
colors
configuration
date
default
desktops
details
displays
effects
ethernet
extensions
fonts
general
hotcorners
ibus
info
input
keyboards
kmfl
languages
locales
menus
mouse
networks
notifications
panels
preferences
preferred
printers
privacy
power
regions
screensavers
settings
sound
system
themes
time
touchpad
trackpad
users
universal access
volume
wacom
wifi
wireless
windows
workspaces" \
        /usr/share/applications/gnome-control-center.desktop
fi

# ------------------------------------------------------------------------------
# gnome-font-viewer
# ------------------------------------------------------------------------------
# hide because font-manager better.  User will only need
#   gnome-font-viewer when double-clicking a font file.  Font-Manager installed
#   by install-default-apps.sh
if [ -e /usr/share/applications/org.gnome.font-viewer.desktop ] && [ -e /usr/share/applications/font-manager.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/org.gnome.font-viewer.desktop
fi

# ------------------------------------------------------------------------------
# gnome-power-statistics
# ------------------------------------------------------------------------------
# always show
if [ -e /usr/share/applications/gnome-power-statistics.desktop ];
then
    desktop-file-edit --remove-key=OnlyShowIn \
        /usr/share/applications/gnome-power-statistics.desktop
fi

# ------------------------------------------------------------------------------
# gnome-screenshot
# ------------------------------------------------------------------------------
# Add to "Accessories" category (by removing from X-GNOME-Utilities)
if [ -e /usr/share/applications/org.gnome.Screenshot.desktop ];
then
    desktop-file-edit ---remove-category=X-GNOME-Utilities \
        /usr/share/applications/org.gnome.Screenshot.desktop
fi

# ------------------------------------------------------------------------------
# gnome-search-tool
# ------------------------------------------------------------------------------
# add keyword "find" to comments for main menu search help
if [ -e /usr/share/applications/gnome-search-tool.desktop ];
then
    desktop-file-edit --set-comment="Find or Locate documents and folders on this computer by name or content" \
        /usr/share/applications/gnome-search-tool.desktop
fi

# ------------------------------------------------------------------------------
# image-magick
# ------------------------------------------------------------------------------
# we want command-line only
if [ -e /usr/share/applications/display-im6.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/display-im6.desktop
fi

if [ -e /usr/share/applications/display-im6.q16.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/display-im6.q16.desktop
fi

# ------------------------------------------------------------------------------
# input-method
# ------------------------------------------------------------------------------
# hide if found (we use ibus as default input method)
if [ -e /usr/share/applications/im-config.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/im-config.desktop
fi

# ------------------------------------------------------------------------------
# libreoffice-math
# ------------------------------------------------------------------------------
# remove from 'science and education' to reduce number of categories
if [ -e /usr/share/applications/libreoffice-math.desktop ];
then
    desktop-file-edit ---remove-category=Science \
        /usr/share/applications/libreoffice-math.desktop

    desktop-file-edit ---remove-category=Education \
        /usr/share/applications/libreoffice-math.desktop
fi

# ------------------------------------------------------------------------------
# modem-manager-gui
# ------------------------------------------------------------------------------
# change "Categories" to "Utility" ("Accessories"): default is "System

if [ -e /usr/share/applications/modem-manager-gui.desktop ];
then
    desktop-file-edit --add-category=Network \
        /usr/share/applications/modem-manager-gui.desktop

    desktop-file-edit --remove-category=System \
        /usr/share/applications/modem-manager-gui.desktop

    # show in all desktops
    desktop-file-edit --remove-key=OnlyShowIn \
        /usr/share/applications/modem-manager-gui.desktop
    
    # modify comment so easier to find on search
    desktop-file-edit --set-comment="3G USB Modem Manager" \
        /usr/share/applications/modem-manager-gui.desktop
fi

# ------------------------------------------------------------------------------
# onboard (on-screen keyboard)
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/onboard.desktop ];
then
    # remove from "Accessibility" (only 2 items there): already in "Utility"
    desktop-file-edit --remove-category=Accessibility \
        /usr/share/applications/onboard.desktop
fi

# ------------------------------------------------------------------------------
# OpenJDK Policy Tool: hide GUI from start menu
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/openjdk-7-policytool.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/openjdk-7-policytool.desktop
fi

# ------------------------------------------------------------------------------
# orca (screen reader)
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/orca.desktop ];
then
    # remove from "Accessibility" (only 2 items there): already in "Utility"
    desktop-file-edit --remove-category=Accessibility \
        /usr/share/applications/orca.desktop
fi

# ------------------------------------------------------------------------------
# PinguyBuilder: hide GUI from start menu
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/PinguyBuilder-gtk.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/PinguyBuilder-gtk.desktop
fi

# ------------------------------------------------------------------------------
# unity-lens-photos
# ------------------------------------------------------------------------------
#unity-lens-photos: only show in unity
if [ -e /usr/share/applications/unity-lens-photos.desktop ];
then
    desktop-file-edit --add-only-show-in=Unity \
        /usr/share/applications/unity-lens-photos.desktop
fi

# ------------------------------------------------------------------------------
# vim
# ------------------------------------------------------------------------------
if [ -e /usr/share/applications/vim.desktop ];
then
    # hide from main menu (terminal only)
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/vim.desktop
fi

# ------------------------------------------------------------------------------
# web2py
# ------------------------------------------------------------------------------
# hide if found (Paratext installs but don't want to clutter menu)
if [ -e /usr/share/applications/web2py.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/web2py.desktop
fi

# ------------------------------------------------------------------------------
# xdiagnose
# ------------------------------------------------------------------------------
# hide if found
if [ -e /usr/share/applications/xdiagnose.desktop ];
then
    desktop-file-edit --set-key=NoDisplay --set-value=true \
        /usr/share/applications/xdiagnose.desktop
fi

# ------------------------------------------------------------------------------
# Default Application Fixes: ??? better command to do this ???
# ------------------------------------------------------------------------------

echo
echo "*** Adjusting default applications"
echo
if ! [ -e /etc/gnome/defaults.list.save ];
then
    cp /etc/gnome/defaults.list /etc/gnome/defaults.list.save
fi

sed -i -e 's@\(audio.*\)=.*@\1=vlc.desktop@' \
    /etc/gnome/defaults.list
sed -i -e 's@\(video.*\)=.*@\1=vlc.desktop@' \
    /etc/gnome/defaults.list

# ???Needed 15.10 / 16.04
# set gnome-font-viewer as default app when double-clicking font file
#   font-manager good but seems a bug doesn't allow it to open with a specific
#   font file for easy installation
sed -i -e '$a application/x-font-ttf=org.gnome.font-viewer.desktop' \
    -i -e '\@application/x-font-ttf=org.gnome.font-viewer.desktop@d' \
    /etc/gnome/defaults.list


if ! [ -e /usr/share/applications/defaults.list.save ];
then
    cp /usr/share/applications/defaults.list \
        /usr/share/applications/defaults.list.save
fi
sed -i -e 's@\(audio.*\)=.*@\1=vlc.desktop@' \
    /usr/share/applications/defaults.list
sed -i -e 's@\(video.*\)=.*@\1=vlc.desktop@' \
    /usr/share/applications/defaults.list

# set gnome-font-viewer as default app when double-clicking font file
#   font-manager good but seems a bug doesn't allow it to open with a specific
#   font file for easy installation
sed -i -e '$a application/x-font-ttf=org.gnome.font-viewer.desktop' \
    -i -e '\@application/x-font-ttf=org.gnome.font-viewer.desktop@d' \
    /usr/share/applications/defaults.list


if [ -e /usr/share/gnome/applications/defaults.list ];
then
    if ! [ -e /usr/share/gnome/applications/defaults.list.save ];
    then
        cp /usr/share/gnome/applications/defaults.list \
            /usr/share/gnome/applications/defaults.list.save
    fi

    sed -i -e 's@\(audio.*\)=.*@\1=vlc.desktop@' \
        /usr/share/gnome/applications/defaults.list
    sed -i -e 's@\(video.*\)=.*@\1=vlc.desktop@' \
        /usr/share/gnome/applications/defaults.list

    # set gnome-font-viewer as default app when double-clicking font file
    #   font-manager good but seems a bug doesn't allow it to open with a specific
    #   font file for easy installation
    sed -i -e '$a application/x-font-ttf=org.gnome.font-viewer.desktop' \
        -i -e '\@application/x-font-ttf=org.gnome.font-viewer.desktop@d' \
        /usr/share/gnome/applications/defaults.list
fi

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------
echo
echo " *** Script Exit: app-adjustments.sh"
echo

exit 0