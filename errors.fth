\ This code defines error reporting for C system calls.

\c #include <errno.h>
c-function errno __errno_location -- a

: explain ( n -- ) strerror ;
: report ( n -- ) cr explain type ;
: ?err ( -- )
  errno @ 0<> if
    errno @ report
  then
  0 errno ! ;
