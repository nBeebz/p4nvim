# p4nvim

A plugin to help manage your perforce connection. Can maintain an "active" client and change list for file edits as well as support for most of the common perforce commands (see p4_commands.lua).

### Installation
LazyVim:
```
return { 'nbeebz/p4nvim' }
```

As it maintains a local cache of data it is recommended to bind to a global in your init.lua
```
P4 = require('p4nvim').setup()
```
