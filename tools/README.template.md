# D Message Box
A simple message box for the D programming language

# Documentation

[https://workhorsy.github.io/d-message-box/$VERSION/](https://workhorsy.github.io/d-message-box/$VERSION/)

# Generate documentation

```
dmd -c -D source/message_box.d -Df=docs/$VERSION/index.html
```

# Run unit tests

```
dub test --main-file=test/main.d
```

[![Dub version](https://img.shields.io/dub/v/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![Dub downloads](https://img.shields.io/dub/dt/d-message-box.svg)](https://code.dlang.org/packages/d-message-box)
[![License](https://img.shields.io/badge/license-BSL_1.0-blue.svg)](https://raw.githubusercontent.com/workhorsy/d-message-box/master/LICENSE)
