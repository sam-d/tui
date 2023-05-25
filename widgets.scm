#!r6rs
(library (tui widgets)
  (export repeat
		  horizontal
		  vertical
		  box)
  (import (rnrs base)
		  (rnrs control)
		  (tui base))

  (define (repeat n char)
    (let ((res (do ((i n (- i 1)) 
    				(lst '() (cons char lst)))
    			   ((= i 0) lst)))) 
  	  (if (list? char) (apply append res) res)))
  
  (define horizontal-line #\x2500)
  (define horizontal-line-thick #\x2501)
  (define vertical-line #\x2502)
  (define vertical-line-thick #\x2503)
  (define top-left-corner #\x250c)
  (define top-right-corner #\x2510)
  (define bottom-left-corner #\x2514)
  (define bottom-right-corner #\x2518)
  
  (define (horizontal width char) (repeat width char))
  (define (vertical height char) (apply append (repeat height `(,char ,@(cursor-down) ,@(cursor-back)))))
  
  (define (box width height)
    `(,top-left-corner ,@(repeat (- width 2) horizontal-line) ,top-right-corner ,@(cursor-down) ,@(cursor-back width) 
    ,@(repeat (- height 2) `(,vertical-line ,@(cursor-forward (- width 2)) ,vertical-line ,@(cursor-down) ,@(cursor-back width)))
    ,bottom-left-corner ,@(repeat (- width 2) horizontal-line) ,bottom-right-corner))
); end of library form  
