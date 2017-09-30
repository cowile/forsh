\ This code defines some generic unility functions for dealing
\ with null terminated strings (C strings).

: c!+ ( c a -- a+1 ) swap over c! 1+ ;
: ndash ( a -- a+1 ) [char] - swap c!+ ;
: mdash ( a -- a+1 ) ndash ndash ;
: null ( a -- ) 0 swap c! ;
: fin ( a -- ) null ;
: >null ( a -- a+u ) begin 1+ dup c@ 0= until ;
: <null ( a -- a-u ) begin 1- dup c@ 0= until ;

: 3dup dup 2over rot ;

\ This function converts a counted string into a null
\ terminated one for consumption by C libraries.
: move+term ( a1 a2 u -- )
  2dup + 0 swap c! move ;
: cstring ( a1 a2 u -- a2 u+1 )
  3dup move+term 1+ rot drop ;
