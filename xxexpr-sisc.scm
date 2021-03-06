;;; <xxexpr.ss> ---- Manipulation of eXtended Xml EXPRessions.
;;; Copyright (C) 2004 by Tony Garnock-Jones.
;;; Copyright (C) 2005 by LShift Ltd. <query@lshift.net>

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

;;; Author: Tony Garnock-Jones <tonygarnockjones@gmail.com>

(require-library 'sisc/libs/srfi/srfi-1)
(require-library 'sisc/libs/srfi/srfi-13)

(module xxexpr
    (xml-empty-tags-mode
     xml-double-quotes-mode
     xxexpr->string
     xxexpr->string/notags
     write-xxexpr
     pretty-print-xxexpr
     write-xxexpr/notags)
  
  (import srfi-1)
  (import srfi-13)
  (import string-io)
  
  (include "portable-xxexpr.scm")
)
