contrib/kodi-gbm README.md
==========================

## General

This is a stand-alone port that will run from a vt to spawn a gbm buffer!
No need to install either a Wayland/X11 desktop.

You can't have `contrib/kodi-{,wayland}` and `contrib/kodi-gbm` installed at the same
time. You need to choose between one of them!

After installing, just run `/usr/bin/kodi` from a pty.

## Allow shutdown/suspend/hibernate

In order to allow Kodi to shutdown/suspend/hibernate the machine,
install dbus, polkit, consolekit, and upower.

Launch kodi like so:
```sh
ck-launch-session kodi
```
