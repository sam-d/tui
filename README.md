# The foundations of a TUI library for R6RS scheme

This library is using ANSI terminal escape codes to 
The file ```base.scm```contains an interface to generate lists of ANSI codes and
characters. ```widgets.scm``` contains the definition of what should become
usable widgets to define user interfaces. The use of the library is documented
in the ```examples``` directory.

# Compatibility

This library has only been briefly tested using Chez scheme and ```gnome-terminal```
