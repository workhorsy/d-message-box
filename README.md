# D Message Box
A simple message box for the D programming language

Tries to make a message box with:
* SDL_ShowSimpleMessageBox (Derelict SDL2)
* MessageBoxW (Windows)
* Zenity (Gtk/Gnome)
* Kdialog (KDE)
* gxmessage (X11)

# Documentation

[https://workhorsy.github.io/d-message-box/1.0.0/](https://workhorsy.github.io/d-message-box/1.0.0/)

# Generate documentation

```
dmd -c -D source/message_box.d -Df=docs/1.0.0/index.html
```


[![Dub version](https://img.shields.io/dub/v/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![Dub downloads](https://img.shields.io/dub/dt/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![License](https://img.shields.io/badge/license-BSL_1.0-blue.svg)](https://raw.githubusercontent.com/workhorsy/d-message-box/master/LICENSE)
