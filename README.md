# HYPRSETTINGS
A simple Control Panel designed for Hyprland. This project is for my own dotfiles but is open for everyone to use in their projects.

# OVERVIEW
This program is helpful for managing screen light, wallpaper, audio, and for fun, system information.

# INSTALL

>[!NOTE]
> The GIT version is currently the most stable due to the young age of the project, so if you want the newest
> bugfixes for now,
> it's in your best interest to clone the REPO
> and install with *make*

# DEPENDS
- python 3.11+
- python Gobject
- gtk4 not later
- Adwita Theme As default(or you may force it use your prefered GTK by modifying Source Code.)
- matugen for color generation
- swaybg wallpaper backend

after install required depends process with:

1)
```
git clone https://github.com/binarylinuxx
```
2)
```
$ make prepare
```
3)
```
# sudo make install
```
# Arch based
```
$ makepkg -si
```

# INSTALL SCRIPT(For void,fedora,arch)
```
chmod +x install.sh && ./install.sh
```

# Manual Via setup.py
**prebuild:**
```
python setup.py build
```

**install:**
```
sudo python setup.py install
```

# LAYOUTS OVERVIEW
<table>
  <tr>
    <td align="center">
      <img src="img/desk_layout.png" width="400"/><br/>
      <b>DESKTOP</b>
    </td>
    <td align="center">
      <img src="img/screen_layout.png" width="400"/><br/>
      <b>SCREEN</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="img/audiomixer_layout.png" width="400"/><br/>
      <b>AUDIO</b>
    </td>
    <td align="center">
      <img src="img/sysinfo_layout.png" width="400"/><br/>
      <b>SYSINFO</b>
    </td>
  </tr>
</table>

# DESK_LAYOUT
- change wallpaper 
- generate scheme with [Matugen](https://github.com/InioX/matugen).
- backend [Swaybg](https://github.com/swaywm/swaybg).

# SCREEN_LAYOUT
- Chose pressets as: Default,night light, candle light, etc..
- play with gamma and temperature to make what seems fine for you.
- hyprsunset for screen light modes

# AUDIO_LAYOUT
- mute change volume level
- using pamixer allowing use Pipewire or Pulseaudio wathever you have installed

# SYSINFO_LAYOUT
- OS NAME
- CPU NAME
- MEMORY(RAM)
- disk capcity and free space in %
- GPU INFO
- WM NAME

## CONTRIBUTE
Fork the repo, make your changes, and then create a PULL Request.

**Rules For Pull Requests:**
1) Describe what you added or changed.
2) Provide screenshots or video recordings to demonstrate changes.
3) Test it yourself before creating a Pull Request.

Or if you want simply create an Issue with a bug report.

Any help and support would be appreciated.

# Maintaining
If you would like to share info that you've become a Maintainer and leave yourself in Credits tab, or ask questions about the project, here are ways to contact me:

[My Gmail](mailto:nrw58886@gmail.com)
[Telegram](https://t.me/Binarnik_Linux)

Maintaining is also appreciated as support and distributing of the project to increase popularity.

# Credits For:
[iwnuplylo](https://github.com/IwnuplyNotTyan) -> Arch Linux Package

# TO-DO
- allow change brightness of screen(currently app handle only with light GAMMA and TEMPERATURE) []
- BLUETHOOTH Control []
- microphone control [] 

# Stars
[![Stargazers over time](https://starchart.cc/binarylinuxx/hyprsettings.svg?background=%231d1d1d&axis=%23ffffff&line=%23ff2525)](https://starchart.cc/binarylinuxx/hyprsettings)
