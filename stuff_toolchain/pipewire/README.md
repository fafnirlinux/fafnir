contrib/pipewire how to
====================

## Breaking changes

Since pipewire 0.3.39, the default „example“ session manager was outsourced to be it's own subproject.
Right now, you have two choices: the example `media-session` or `wireplumber`.
This port does not decide for you, instead it builds with none and you are free to choose yours.

Note that you **need to choose**. Without a session manager, your audio and video setup **will stop working**!

## Intro
`pipewire` is a modern multimedia server. Quoting gentoo wiki, it's strenghts are:
>  -  Minimal latency capture/playback of audio and video
>  -  Real-time multimedia processing
>  -  Multi-process architecture allowing multimedia content sharing between applications
>  -  Seamless support for PulseAudio, JACK, ALSA, and GStreamer
>  -  applications sandboxing support with Flatpak

Getting `pipewire` to run is relatively easy on `CRUX`. This is a simple guide and relies on further reading upon official and unofficial resources.

This might also be considered a WIP entry. You can help by sharing your experiences and thoughts.

## Prerequisites
  - working kernel with alsa audio
  - `opt/alsa-utils` will be installed by default as a dependency and needs to be configured by the user
  - currently, pipewires default config makes use of `opt/alsa-ucm-conf`, consider installing that alongside the default dependency `opt/alsa-utils`
  - pipewire requires a session-manager to run to operate correctly. You can choose between `contrib/media-session` and `contrib/wireplumber` freely.

### Optional prerequisites
  - pipewire needs pulseaudio to be built with xorg-libxtst around to have the pulseaudio portal available
    - `prt-get depinst xorg-libxtst && prt-get update -fr pulseaudio`
  - `contrib/rtkit` and a realtime compatible kernel to help with latency, add your user to `rtkit group` to be able to make use of it
    - [an stackoverflow question on the topic](https://stackoverflow.com/questions/817059/what-is-preemption-what-is-a-preemtible-kernel-what-is-it-good-for)
    - [Real-Time Linux collaborative project](https://wiki.linuxfoundation.org/realtime/start)
    - [Arch wiki](https://wiki.archlinux.org/index.php/Realtime_kernel_patchset)
    - [linuxaudio.org wiki](https://wiki.linuxaudio.org/wiki/system_configuration#the_kernel)
  - please look at `contrib/pipewire/Pkgfile` for further optional dependencies listed and rebuild the package after installing new optional dependencies

## Running pipewire
`pipewire` will always leverage `alsa`, so you should configure that first. Use `alsactl store` to store those settings, and configure `/etc/rc.conf` to start `/etc/rc.d/alsa` by default. While you are in `rc.conf`, make sure you start `/etc/rc.d/dbus` too, if you haven't already.

Resources:
  - [Official ALSA wiki](https://alsa-project.org/wiki/Main_Page)
  - [Gentoo wiki](https://wiki.gentoo.org/wiki/ALSA)
  - [Arch wiki](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture)

Currently, pipewires default config format might always change, so it is advised to keep an eye on `rejmerge` to keep your configs updated.
The default config can be copied from `/usr/share/pipewire` to `/etc/pipewire` to be modified. The configuration of `/etc/pipewire` can be copied over to `$XDG_CONFIG_HOME/pipewire`, which should most likely point you to `$HOME/config/pipewire`. There you will need to enable a session manager and optionally enable pulseaudio support for example.

With your configuration in place you need to run `/usr/bin/pipewire` from a users shell or script (for example I have this in my `i3` config: `exec "/usr/bin/pipewire"`), just make sure that whatever session you are running will be executed as a `dbus-user-session` too (for example from my `~/.xinitrc`: `exec dbus-run-session -- i3`).

You can verify your running pipewire session by examining the output of `pw-dump`.

## Running pipewire-pulse as a pulseaudio-server
If you are a `pulseaudio`-user, make sure it won't autostart with your session. For `pipewire` to handle `pulse-clients`, you will need to run `/usr/bin/pipewire-pulse` as well. Verify that it is working with `pactl info` which should now report: `Server Name: PulseAudio (on PipeWire 0.3.22)`. Now you can use tools like `contrib/pavucontrol` or `contrib/ncpamixer` to control your typical sources and sink settings, ports like `opt/firefox-bin` and whatever else uses `pulseaudio` should work ootb for you too.

## Running jack applications through pipewire
to be expanded

## Debbuging pipewire
You can run pipewire like that from a terminal: `PIPEWIRE_DEBUG=3 pipewire`

# Further configuration and fine-tuning
To help configuring, consider reading through the following resources alongside the extensive comments in the default config:
 - [Official pipewire wiki](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/home)
 - [Advanced Configuration notes by jasker5183 (pipewire dev)](https://gitlab.freedesktop.org/jasker5183/test/-/blob/master/Advanced%20Configuration.md)
 - [Arch wiki](https://wiki.archlinux.org/index.php/PipeWire)
 - [Gentoo wiki](https://wiki.gentoo.org/wiki/PipeWire)

# tl;dr
> „I don't have any time to read up on stuff myself, tell me what I need to do right now to get this hot mess!“ -some user

 - optional: `prt-get depinst xorg-libxtst pulseaudio` et al, see Pkgfile
 - install `prt-get depinst pipewire`
 - install a session manager, you don't need both!
   - `prt-get depinst media-session` or `prt-get depinst wireplumber`
 - make changes to your config per usual
 - execute while starting your X11/Wayland-Session: `/usr/bin/pipewire`
 - optional: execute in addition to have pulseaudio-server support: `/usr/bin/pipewire-pulse`

// vim:filetype=markdow
// End of file
