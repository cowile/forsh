\ This code defines the ability to change directories.

require errors.fth

\c #include <unistd.h>
c-function cchdir chdir a -- n

\ The function must convert to a null terminated string first.
\ Move it to the pad because it may not have the extra byte.
: chdir ( a u -- )
  dup pad + 0 swap c!
  pad swap move
  pad cchdir ?err drop ;
