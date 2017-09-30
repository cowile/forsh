\ This code defines shell functionality relating to the working
\ environment. It allows changing the working directory and
\ manipulating environment variables.

require strings.fth
require errors.fth

\c #include <unistd.h>
c-function cchdir chdir a -- n

\ The function must convert to a null terminated string first.
\ Move it to the pad because it may not have the extra byte.
: chdir ( a u -- )
  pad swap cstring drop
  cchdir ?err drop ;

\c #include <stdlib.h>
c-function csetenv setenv a a n -- n
c-function cunsetenv unsetenv a -- n
c-function cclearenv clearenv -- n

\ gforth provides getenv already
0 constant nooverwrite
1 constant overwrite
: setenv ( a1 u1 a2 u2 -- )
  pad swap cstring
  + swap cstring drop
  pad swap overwrite csetenv ?err drop ;
: unsetenv ( a u -- )
  pad swap cstring drop
  cunsetenv ?err drop ;
: clearenv ( -- ) cclearenv ?err drop ;
