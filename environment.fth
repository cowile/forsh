\ This code defines shell functionality relating to the working
\ environment. It allows changing the working directory and
\ manipulating environment variables.

require errors.fth

\ This function converts a counted string into a null
\ terminated one for consumption by C libraries.
: count>term ( a1 a2 u -- )
  2dup + 0 swap c! move ;
: cstring ( a1 u -- a2 )
  pad swap count>term pad ;

\c #include <unistd.h>
c-function cchdir chdir a -- n

\ The function must convert to a null terminated string first.
\ Move it to the pad because it may not have the extra byte.
: chdir ( a u -- )
  cstring cchdir ?err drop ;

\c #include <stdlib.h>
c-function cgetenv getenv a -- a
c-function csetenv setenv a a n -- n
c-function cunsetenv unsetenv a -- n
c-function cclearenv clearenv -- n

0 constant overwrite
: getenv ( a1 u -- a2 ) cstring cgetenv ?err ;
: setenv ( a1 u1 a2 u2 -- )
  dup -rot cstring
  dup >r + 1+ dup >r
  swap count>term
  r> r> swap overwrite csetenv ?err drop ;
: unsetenv ( a u -- ) cstring cunsetenv ?err drop ;
: clearenv ( -- ) cclearenv ?err drop ;
