#!r6rs
(library (tui widgets)
  (export repeat
	  horizontal
	  vertical
	  generic-box
	  ascii-box
	  light-box
	  light-rounded-box
	  heavy-box
	  double-box)
  (import (rnrs base)
	  (rnrs control)
	  (tui base))

  (define (horizontal width char) (repeat width char))
  (define (vertical height char) (repeat height `(,char ,@(cursor-down) ,@(cursor-back))))

  (define generic-box
    (case-lambda ((width height horizontal-char vertical-char corner-char) (generic-box width height horizontal-char vertical-char corner-char corner-char corner-char corner-char))
		 ((width height horizontal-char vertical-char top-left-corner-char top-right-corner-char bottom-left-corner-char bottom-right-corner-char)
		  `(,top-left-corner-char ,@(repeat (- width 2) horizontal-char) ,top-right-corner-char ,@(cursor-down) ,@(cursor-back) ,@(save-cursor) ,@(vertical (- height 2) vertical-char) ,@(restore-cursor) ,@(cursor-back (- width 1)) ,@(vertical (- height 2) vertical-char) ,bottom-left-corner-char ,@(repeat (- width 2) horizontal-char) ,bottom-right-corner-char))))

  (define (ascii-box width height) (generic-box width height #\- #\| #\+))
  (define (light-box width height) (generic-box width height #\x2500  #\x2502 #\x250c #\x2510 #\x2514 #\x2518))
  (define (light-rounded-box width height) (generic-box width height #\x2500  #\x2502 #\x256d #\x256e #\x2570 #\x256f))
  (define (heavy-box width height) (generic-box width height #\x2501  #\x2503 #\x250f #\x2513 #\x2517 #\x251b))
  (define (double-box width height) (generic-box width height #\x2550  #\x2551 #\x2554 #\x2557 #\x255a #\x255d))
  
); end of library form  
