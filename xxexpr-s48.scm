;;; <xxexpr-s48.scm> ---- Scheme48 glue for portable-xxexpr.scm.
;;; Copyright (C) 2011 by Tony Garnock-Jones.

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

(define-structure xxexpr
  (export xml-empty-tags-mode
	  xml-double-quotes-mode
	  xxexpr->string
	  xxexpr->string/notags
	  write-xxexpr
	  pretty-print-xxexpr
	  write-xxexpr/notags)
  (open scheme)
  (open srfi-1)
  (open srfi-6)
  (open srfi-13)
  (open srfi-23)
  (open srfi-39)
  (files "portable-xxexpr.scm"))
