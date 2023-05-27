(import (rnrs)(tui base) (tui widgets))
(enable-alternative-buffer%)
(clear-screen%)

(define term-width 20)
(define term-height 30)
;draw a box at the center of the screen
(draw% (at 1 1 (style slow-blink underline (color (fg red) (bg 155) "press any key to exit..."))))
(draw% (append (cursor-down 4) (light-box 20 10)))
(draw% (append (cursor-down 2) (horizontal 40 #\-)))
(draw% (append (at (/ term-height 2) (/ term-width 2) (style invert (light-box 20 10)))
			  (at (+ (/ term-height 2) 10) (+ (/ term-width 2) 5) (style bold invert "My box"))))

(define my-box (double-box 10 10))
(define (multiple n lst)
  (if (> n 0) (append (at (+ 1 n) (+ 1 n) (multiple (- n 1) lst)) lst) lst))
(draw% (multiple 5 my-box))
(when (read-char) (disable-alternative-buffer%)) ;press any key to exit and restore previous buffer
