#!r6rs
(library (tui base)
  (export draw%
	  style
	  color
	  at
	  repeat
	  cursor-up
	  cursor-down
	  cursor-back
	  cursor-forward
	  save-cursor
	  restore-cursor
	  reset%
	  clear-screen%
	  clear-screen-forward%
	  clear-screen-backward%
	  enable-alternative-buffer%
	  disable-alternative-buffer%)
  (import (rnrs base)
	  (rnrs control)
	  (rnrs io ports))

  ;define everything through macros
  ; draw is a syntactic extension that expects a port and a list of characters and will output each character (some of which migh represent ANSI control sequences to port. Port is optional and defaults to (current-output-port)
  ; in case of incompatible values, the later ones take precedence
  (define-syntax draw%
    (syntax-rules ()
  	((_ lst) (for-each (lambda (char) (put-char (current-output-port) char)) lst))
  	((_ lst port) (for-each (lambda (char) (put-char port char)) lst))))
  
  (define-syntax style-helper
    (syntax-rules (bold dim italic underline slow-blink rapid-blink invert strike)
  	((_ bold) #\1)
	((_ dim) #\2)
  	((_ italic) #\3)
  	((_ underline) #\4)
  	((_ slow-blink) #\5)
  	((_ rapid-blink) #\6)
  	((_ invert) #\7)
  	((_ strike) #\9)))

  (define-syntax style-subsequent
    (syntax-rules ()
  	((_ text) `(,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'style "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))
  	((_ st text) `(,(style-helper st) #\m ,@(style-subsequent text)))
  	((_ e1 e2 e3 ...) `(,(style-helper e1) #\; ,@(style-subsequent e2 e3 ...)))))
  
  ;style is a macro that takes some keywords describing style and a text or list of characters and styles the text according the the style keywords provided by returning a list of characters with the respective ANSI control sequences for the style. The style is automatically cleared after the text
  (define-syntax style
    (syntax-rules ()
  	((_ text) `(,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'style "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))
  	((_ st text) `(#\esc #\[ ,(style-helper st) #\m ,@(style text)))
  	((_ e1 e2 e3 ...) `(#\esc #\[ ,(style-helper e1) #\; ,@(style-subsequent e2 e3 ...)))))
  
  ;color the following element. Once can specify foreground and background colors. color are either from the set of key words (black red green yellow blue magenta cyan white) or a single number between 16 and 255 or 3 integer red, green and blue each between 0 and 255
  (define-syntax color
	(syntax-rules (fg bg)
	  ((_ (fg e1 e2 ...) text) `(#\esc #\[ #\3 ,@(color-helper e1 e2 ...) #\m ,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'color "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))
	  ((_ (bg e1 e2 ...) text) `(#\esc #\[ #\4 ,@(color-helper e1 e2 ...) #\m ,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'color "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))
	  ((_ (fg e1 e2 ...) (bg e3 e4 ...) text) `(#\esc #\[ #\3 ,@(color-helper e1 e2 ...) #\; #\4 ,@(color-helper e3 e4 ...) #\m ,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'color "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))
	  ((_ (bg e3 e4 ...) (fg e1 e2 ...) text) `(#\esc #\[ #\3 ,@(color-helper e1 e2 ...) #\; #\4 ,@(color-helper e3 e4 ...) #\m ,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'color "text must be a list of characters or a string"))) #\esc #\[ #\0 #\m))))

  (define-syntax color-helper
    (syntax-rules (black red green yellow blue magenta cyan white)
  	  ((_ black) '(#\0))
  	  ((_ red) '(#\1))
	  ((_ green) '(#\2))
  	  ((_ yellow) '(#\3))
  	  ((_ blue) '(#\4))
  	  ((_ magenta) '(#\5))
  	  ((_ cyan) '(#\6))
  	  ((_ white) '(#\7))
	  ((_ number) `(#\8 #\; #\5 #\; ,@(string->list (number->string number))))
	  ((_ r g b) `(#\8 #\; #\2 #\; ,@(string->list (number->string r)) #\; ,@(string->list (number->string g)) #\; ,@(string->list (number->string b))))))

  ;at returns the control characters to move the cursor to row row and column col and prefixes them to the argument provided that can be a text or a list of characters
  (define-syntax at
    (syntax-rules ()
  	((_ row col text) `(#\esc #\[ ,@(string->list (number->string row)) #\; ,@(string->list (number->string col)) #\H ,@(if (list? text) text (if (string? text) (string->list text) (assertion-violation 'at "text must be a list of characters or a string")))))))
  
  ;repeat the character (or character list) n times. If repeat is used to repeat a styled or color object, exclude the style/color codes from the repetition as they are idempotent.
  (define-syntax repeat
    (syntax-rules (at style color)
      ((_ n char) (let ((res (do ((i n (- i 1)) 
				   (lst '() (cons char lst)))
    				  ((= i 0) lst)))) 
		    (if (list? char) (apply append res) res)))
      ((_ n (style e1 ... e2)) ((style e1 ...) (repeat n e2)))
      ((_ n (color e1 ... e2)) ((color e1 ...) (repeat n e2)))))

  ;move cursor
  (define-syntax cursor-up
    (syntax-rules ()
  	((_) '(#\esc #\[ #\1 #\A))
  	((_ n) `(#\esc #\[ ,@(string->list (number->string n)) #\A))))
  
  (define-syntax cursor-down
    (syntax-rules ()
  	((_) '(#\esc #\[ #\1 #\B))
  	((_ n) `(#\esc #\[ ,@(string->list (number->string n)) #\B))))
  
  (define-syntax cursor-forward
    (syntax-rules ()
  	((_) '(#\esc #\[ #\1 #\C))
  	((_ n) `(#\esc #\[ ,@(string->list (number->string n)) #\C))))
  
  (define-syntax cursor-back
    (syntax-rules ()
  	((_) '(#\esc #\[ #\1 #\D))
  	((_ n) `(#\esc #\[ ,@(string->list (number->string n)) #\D))))

  (define-syntax save-cursor
    (syntax-rules ()
      ((_) '(#\esc #\[ #\s))))

  (define-syntax restore-cursor
    (syntax-rules ()
      ((_) '(#\esc #\[ #\u))))

  ;;functions to clear the screen
  (define-syntax optional-port
    (syntax-rules ()
      ((_ name lst) 
       (define name
  	 (case-lambda (() (name (current-output-port)))
  		      ((port) (draw% lst port)))))))
  
  ;resets the terminal/port by sending the ANSI reset sequence #\esc #\c
  (optional-port reset% '(#\esc #\c))
  ;clears complete screen
  (optional-port clear-screen% '(#\esc #\[ #\2 #\J))
  (optional-port clear-screen-forward% '(#\esc #\[ #\0 #\J))
  (optional-port clear-screen-backward% '(#\esc #\[ #\1 #\J))
  (optional-port enable-alternative-buffer% '(#\esc #\[ #\? #\1 #\0 #\4 #\9 #\h))
  (optional-port disable-alternative-buffer% '(#\esc #\[ #\? #\1 #\0 #\4 #\9 #\l))
); end of library form  
