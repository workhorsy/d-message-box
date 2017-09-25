# D Message Box
A simple message box for the D programming language

It should work without requiring any 3rd party GUI toolkits. But will work with what
it can find on your OS at runtime. It tries to use the following:
* DlangUI (win32 on Windows/SDL2 on Linux)
* SDL_ShowSimpleMessageBox (Derelict SDL2)
* MessageBoxW (Windows)
* Zenity (Gtk/Gnome)
* Kdialog (KDE)
* gxmessage (X11)

# Documentation

[https://workhorsy.github.io/d-message-box/0.1.0/](https://workhorsy.github.io/d-message-box/0.1.0/)

# Generate documentation

```
dub --build=docs
```


[![Dub version](https://img.shields.io/dub/v/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![Dub downloads](https://img.shields.io/dub/dt/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![License](https://img.shields.io/badge/license-BSL_1.0-blue.svg)](https://raw.githubusercontent.com/workhorsy/d-message-box/master/LICENSE)
