# The foundations of a TUI library for R6RS scheme

This library is using ANSI terminal escape codes to 
The file ```base.scm```contains an interface to generate lists of ANSI codes and
characters. ```widgets.scm``` contains the definition of what should become
usable widgets to define user interfaces. The use of the library is documented
in the ```examples``` directory.

The core idea is that ANSI codes and Unicode characters can all be repesented as
a list of characters and drawn on the terminal using ```(for-each (lambda (c)
(put-char (current-output-port) c)) list-of-chars)```. The character lists are
generated at compile time through some macros to provide a natural interface.
With this approach, composition is trivial using ```append```.

# Compatibility

This library has only been briefly tested using Chez scheme and ```gnome-terminal```
