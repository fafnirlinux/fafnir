# contrib/pulseeffects README

## Building pulseeffects

Building and successfully using pulseeffects requires you to build pipewire
including pulseaudio support. Therefor, pulseaudio needs to be around before
you install pipewire. After that, pulseeffects can be successfully installed
and used.

It's recommended to set the following setting in `/etc/pkgmk.conf`:
```sh
PKGMK_IGNORE_NEW="yes"
```
This will ignore any *new* files found in a footprint. This is needed, because
it's expected to produce more files than a minimal build for some individual
ports, e.g. `contrib/pipewire`, `contrib/gst-plugins-bad`, etc..

Another setting to consider is the following in `/etc/prt-get.conf`:
```sh
runscripts yes
```
Alternatively, you will need to watch out for ports that would run
pre-/post-install scripts yourself and execute them in order to expect a
fault-free environment.

After considering those steps, if you manually want to ensure that everything
will be fine, the steps should be as follow:
 1. `prt-get depinst pulseaudio`
 2. `prt-get depinst pipewire`
 3. `prt-get depinst pulseeffects`

Please take a look at `contrib/pipewire/README` for more instructions on how
to setup a pipewire environment. Make sure to enable it for handling
`pulseaudio` requests and you are good to go.

## Optional dependencies:
About the optional dependencies (list borrowed and enhanced from archs
[PKGBUILD](https://github.com/archlinux/svntogit-community/blob/packages/pulseeffects/trunk/PKGBUILD)
):
 * calf - limiter, compressor, exciter, bass enhancer, and others
 * lsp-plugins - equalizer
 * mda.lv2 - loudness
 * rubberband - pitch shifting
 * rnnoise - noise supression using a recurrent neural network
 * zam-plugins: maximizer

You will need to rebuild gst-plugins-bad after installing most of any of
those optional dependencies, pulseeffects will then pick them up and make
them available, otherwise, all the plugins are shown but none of them are
useable.

## Issues
 - If you run into issues, please try removing GStreamer's cache
`rm -rf ~/.cache/gstreamer-1.0` and have a look at the debug output with
`G_MESSAGES_DEBUG=pulseeffects pulseeffects`.
 - You can check what plugins your current gstreamer build offers with
`gst-inspect-1.0 | grep -i calf | grep -i limiter`

## Additional information
Additional info from the official FAQ over at the projects
[official wiki](https://github.com/wwmm/pulseeffects/wiki/FAQ)

// vim:filetype=markdown

// End of file
