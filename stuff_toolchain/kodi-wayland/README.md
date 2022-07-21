contrib/kodi-wayland README.md
==============================

## General

This is a stand-alone port that will use kodis native wayland backend, which
will not work from an X11 session.

You can't have `contrib/kodi{,-gbm}` and `contrib/kodi-wayland` installed at
the same time. You need to choose between one of them!

## Allow shutdown/suspend/hibernate

In order to allow Kodi to shutdown/suspend/hibernate the machine,
install dbus, polkit, consolekit, and upower.

Launch kodi like so:
```sh
ck-launch-session kodi
```

If using a window manager or desktop environment that uses polkit and
consolekit already, this is usually unnecessary.
