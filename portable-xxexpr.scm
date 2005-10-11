;;; <portable-xxexpr.scm> ---- Manipulation of eXtended Xml EXPRessions.
;;; Copyright (C) 2004 by Tony Garnock-Jones.

;;; This is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public
;;; License as published by the Free Software Foundation; either
;;; version 2.1 of the License, or (at your option) any later version.

;;; This software is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.

;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this software; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

;;; Author: Tony Garnock-Jones <tonyg@kcbbs.gen.nz>

;; Requires: SRFI-1, SRFI-6, SRFI-13, SRFI-23, SRFI-39
;;
;; Exports:
;;         xml-empty-tags-mode
;;         xml-double-quotes-mode
;;         xxexpr->string
;;         xxexpr->string/notags
;;         write-xxexpr
;;         pretty-print-xxexpr
;;         write-xxexpr/notags)

;; Simplified grammar (omits entities ("special") etc.) for XXEXPRs
;;
;; XXEXPR     :== node
;; node       :== (child . node) | ()
;; child      :== edge | atom | special
;; edge       :== (tag . node) | (tag ((attr atom) ...) . node)
;;                | (tag (@ (attr atom) ...) . node)
;; atom       :== <non-list>
;;
;; Note in particular that write-xxexpr and friends take a /node/
;; as their argument, not an /edge/!

(define xml-empty-tags-mode (make-parameter #t))
(define xml-double-quotes-mode (make-parameter #f))

(define (xxexpr-external-representation datum)
  (cond
   ((string? datum)	datum)
   ((char? datum)	(string datum))
   ((symbol? datum)	(symbol->string datum))
   ((number? datum)	(number->string datum))
   (else		(let ((o (open-output-string)))
			  (display datum o)
			  (get-output-string o)))))

(define make-show-node
  (let ((make-escaper (lambda (alist)
			(lambda (orig)
			  (reverse!
			   (string-fold
			    (lambda (ch acc)
			      (cond
			       ((assv ch alist) => (lambda (p) (cons (cdr p) acc)))
			       (else (cons ch acc))))
			    '()
			    orig))))))
    (define xml-escaper (make-escaper '((#\< . "&lt;")
					(#\> . "&gt;")
					(#\& . "&amp;"))))
    (define xml-attribute-escaper (make-escaper '((#\" . "&quot;")
						  (#\' . "&apos;"))))

    (define (show-attrs alist)
      (map (lambda (p)
	     (list " " (car p) (if (xml-double-quotes-mode) "=\"" "='")
		   (map (lambda (v) (xml-attribute-escaper (xxexpr-external-representation v)))
			(cdr p))
		   (if (xml-double-quotes-mode) "\"" "'")))
	   alist))

    (define (show-edge show-node tag attrs body)
      (if (and (xml-empty-tags-mode) (null? body))
	  (vector 'open-close (list "<" tag (show-attrs attrs) "/>"))
	  (list (vector 'open (list "<" tag (show-attrs attrs) ">"))
		(map show-node body)
		(vector 'close (list "</" tag ">")))))

    (define (show-edge/notags show-node tag attrs body)
      (map show-node body))

    (define (show-pi tag attrs)
      (vector 'open-close
	      (list "<?" tag
		    (show-attrs attrs)
		    "?>")))

    (define (show-external-id x)
      (case (car x)
	((public) (list "PUBLIC \"" (cadr x) "\" \"" (caddr x) "\""))
	((system) (list "SYSTEM \"" (cadr x) "\""))
	(else (error "Unknown external-id kind" x))))

    (define (show-PEDef def)
      (if (string? def)
	  def
	  (show-external-id def)))

    (define (show-entity-def body)
      (vector 'open-close
	      (if (eq? (car body) '%)
		  (list "<!ENTITY % " (cadr body) " "
			(show-PEDef (caddr body)) ">")
		  (list "<!ENTITY " (car body) " "
			(show-PEDef (cadr body)) ">"))))

    (define (show-internal-dtd body0)
      (list " ["
	    (map (lambda (x)
		   (let ((tag (car x))
			 (body (cdr x)))
		     (case tag
		       ((*entity*) (show-entity-def body))
		       ((*literal*) body)
		       (else (error "Unsupported internal-dtd clause" x)))))
		 body0)
	    "]>"))

    (define (show-doctype basetag decltype body)
      (vector 'open-close
	      (list "<!DOCTYPE " basetag " "
		    (show-external-id decltype)
		    (show-internal-dtd body))))

    (define (show-entity-ref tag x)
      (list tag x ";"))

    (define (tag-attributes x)
      (and (pair? (cdr x))
	   (let ((a (cadr x)))
	     (cond
	      ((and (pair? a) (pair? (car a))) a)
	      ((and (pair? a) (eq? (car a) '@)) (cdr a))
	      ((null? a) a)
	      (else #f)))))

    (lambda (exclude-structure)
      (define (show-node x)
	(cond
	 ((pair? x)
	  (let* ((tag (car x))
		 (attrs* (tag-attributes x))
		 (body (if attrs*
			   (cddr x)
			   (cdr x)))
		 (attrs (or attrs* '())))
	    (if (not (or (symbol? tag)
			 (string? tag)))
		(error "Tag must be string or symbol" tag))
	    (case tag
	      ((& %)		(show-entity-ref tag (car body)))
	      ((*literal*)	(cdr x))
	      ((*pi*)		(show-pi (car body) (cdr body)))
	      ((*doctype*)	(show-doctype (car body) (cadr body) (cddr body)))
	      (else		((if exclude-structure
				     show-edge/notags
				     show-edge) show-node tag attrs body)))))
	 ((string? x)
	  (xml-escaper x))
	 (else
	  (xml-escaper (xxexpr-external-representation x)))))
      show-node)))

(define (xxexpr->string* s pretty)
  (string-concatenate
   (reverse!
    (let walk ((acc '())
	       (s s))
      (cond
       ((null? s) acc)
       ((pair? s) (walk (walk acc (car s)) (cdr s)))
       ((vector? s) (walk acc (vector-ref s 1))) ;; ignore pretty flag for now
       (else (cons (xxexpr-external-representation s) acc)))))))

(define (xxexpr->string x)
  (xxexpr->string* (map (make-show-node #f) x)
		   #f))

(define (xxexpr->string/notags x)
  (xxexpr->string* (map (make-show-node #t) x)
		   #f))

(define write-xxexpr*
  (let ()
    (define (walk-show pretty p v)
      (let ((last-was-tag #f)
	    (at-beginning #t)
	    (indent 0)
	    (*delta* 4))
	(define (newline-and-indent)
	  (if at-beginning
	      (set! at-beginning #f)
	      (if pretty
		  (begin
		    (p #\newline)
		    (p (make-string indent #\space))))))
	(define (bump-indent! up)
	  (set! indent ((if up + -) indent *delta*)))
	(let walk ((v v))
	  (cond
	   ((null? v))
	   ((pair? v)	(walk (car v))
	    (walk (cdr v)))
	   ((vector? v)
	    (case (vector-ref v 0)
	      ((open)
	       (newline-and-indent)
	       (bump-indent! #t))
	      ((open-close)
	       (newline-and-indent)
	       (set! last-was-tag #t))
	      ((close)
	       (bump-indent! #f)
	       (if last-was-tag (newline-and-indent)))
	      (else (error "Unknown pretty-printing directive in xxexpr" (vector-ref v 0))))
	    (walk (vector-ref v 1))
	    (set! last-was-tag #t))
	   (else
	    (set! last-was-tag #f)
	    (p v))))))

    (lambda (pretty show-result port)
      (if port
	  (walk-show pretty (lambda (v) (display v port)) show-result)
	  (walk-show pretty display show-result)))))

(define (write-xxexpr x . port)
  (write-xxexpr* #f (map (make-show-node #f) x) (and (pair? port) (car port))))

(define (pretty-print-xxexpr x . port)
  (write-xxexpr* #t (map (make-show-node #f) x) (and (pair? port) (car port))))

(define (write-xxexpr/notags x . port)
  (write-xxexpr* #f (map (make-show-node #t) x) (and (pair? port) (car port))))
