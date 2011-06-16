#lang racket
(require "xxexpr.rkt")
(require rackunit)

(display "Running xxexpr tests...")
(newline)

(check-equal? (xxexpr->string `((x ((y "\""))))) "<x y='&quot;'/>")
(check-equal? (parameterize ((xml-double-quotes-mode #t))
		(xxexpr->string `((x ((y "\""))))))
	      "<x y=\"&quot;\"/>")

(check-equal? (xxexpr->string `((x ((y "'"))))) "<x y='&apos;'/>")
(check-equal? (parameterize ((xml-double-quotes-mode #t))
		(xxexpr->string `((x ((y "'"))))))
	      "<x y=\"&apos;\"/>") ;; could get away with "'"

(check-equal? (xxexpr->string `((x ((y "<>&amp;")))))
	      "<x y='&lt;&gt;&amp;amp;'/>")
