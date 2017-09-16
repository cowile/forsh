variable stage
variable sep
bl sep !

: 3dup dup 2over rot ;

: new ( u "name" -- ) create 0 , allot does> stage ! ;
: >len ;
: +len ( a u -- ) swap >len +! ;
: >buf cell+ ;
: clear ( a -- ) >len 0 swap ! ;

: start ( a -- a+u ) dup >len @ + >buf ;
: hyphen ( a -- ) [char] - swap c! ;
: ndash ( a -- a+1 ) dup hyphen 1+ ;
: mdash ( a -- a+1 ) ndash ndash ;
: null ( a -- ) 0 swap c! ;
: fin ( a -- ) null ;

: lopt ( a1 u a2 -- )
  3dup swap cmove + fin drop ;
: sopt ( c a -- )
  2dup c! 1+ fin drop ;

: sflag ( c a -- )
  dup -rot
  start ndash sopt
  3 +len ;

: lflag ( a1 u a2 -- )
  3dup
  start mdash lopt
  swap 3 + +len drop ;

: parg ( a1 u a2 -- )
  3dup
  start lopt
  swap 1+ +len drop ;

: cmd parg ;

: get sep @ word count ;

: sf ( a "string" -- ) char swap sflag ;
: lf ( a "string" -- ) get rot lflag ;
: pa ( a "string" -- ) get rot parg ;
: co pa ;

: s stage @ sf ;
: l stage @ lf ;
: p stage @ pa ;
: c p ;

128 new testbuf
testbuf
c program
char a stage @ sflag
s b
s" long" stage @ lflag
l longer
s" file" stage @ parg
p /usr/share/longfile
stage @ >len ?
stage @ >buf 64 type cr

: iter ( a -- a+u a )
  dup >buf swap >len @ bounds ;
: >null ( a -- a+u ) begin dup c@ 0<> while 1+ repeat ;
: >field >null 1+ ;
: #fields ( a -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;

: prep ( a1 a2 -- )
  over >buf rot #fields 0 do
    swap 2dup !
    cell+
    swap >field
  loop 2drop ;

: ready ( a1 a2 -- a1+u a2 )
  2dup prep swap >buf swap ;

stage @ #fields . cr
stage @ pad ready
pad 8 cells dump cr

variable status
2variable line

\c #include <unistd.h>
c-function exec execvp a a -- n
c-function fork fork -- n
c-function cpipe pipe a -- n
\c #include <sys/wait.h>
c-function cwait wait a -- n
\c #include <string.h>
c-function explain strerror n -- a

: print ( a -- )
  dup >null over - type ;

: report ( n -- ) cr explain print ;

: wait ( -- n ) status cwait ;

: pipe ( -- a ) line cpipe ;
: read@ line 2@ nip ;
: write@ line 2@ drop ;
