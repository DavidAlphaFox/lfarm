;;; Copyright (c) 2013, James M. Lawrence. All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;
;;;     * Redistributions in binary form must reproduce the above
;;;       copyright notice, this list of conditions and the following
;;;       disclaimer in the documentation and/or other materials provided
;;;       with the distribution.
;;;
;;;     * Neither the name of the project nor the names of its
;;;       contributors may be used to endorse or promote products derived
;;;       from this software without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package #:lfarm-common)

(defmacro import-now (&rest symbols)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (import ',symbols)))

(defmacro alias-macro (alias orig)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf (macro-function ',alias) (macro-function ',orig))
     ',alias))

(defmacro alias-function (alias orig)
  `(progn
     (setf (symbol-function ',alias) #',orig)
     (define-compiler-macro ,alias (&rest args)
       `(,',orig ,@args))
     ',alias))

(alias-macro with-gensyms alexandria:with-gensyms)
(alias-macro when-let alexandria:when-let)
(alias-macro when-let* alexandria:when-let*)
(alias-macro named-lambda alexandria:named-lambda)

(defmacro repeat (n &body body)
  `(loop :repeat ,n :do (progn ,@body)))

(defmacro with-tag (retry-tag &body body)
  "For those of us who forget RETURN-FROM inside TAGBODY."
  (with-gensyms (top)
    `(block ,top
       (tagbody
          ,retry-tag
          (return-from ,top (progn ,@body))))))

(defmacro dosequence ((var sequence &optional return) &body body)
  `(block nil
     (map nil (lambda (,var) ,@body) ,sequence)
     ,@(if return
           `((let ((,var nil))
               (declare (ignorable ,var))
               ,return))
           nil)))
