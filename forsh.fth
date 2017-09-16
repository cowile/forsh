variable stage
variable sep
bl sep !

: 3dup dup 2over rot ;

: new ( u "name" -- ) create 0 , allot does> stage ! ;
: >len ;
: +len ( addr u -- ) swap >len +! ;
: >buf cell+ ;
: clear ( addr -- ) >len 0 swap ! ;

: start ( addr -- addr+u ) dup >len @ + >buf ;
: hyphen ( addr -- ) [char] - swap c! ;
: ndash ( addr -- addr+1 ) dup hyphen 1+ ;
: mdash ( addr -- addr+1 ) ndash ndash ;
: null ( addr -- ) 0 swap c! ;
: fin ( addr -- ) null ;

: lopt ( addr1 u addr2 -- )
  3dup swap cmove + fin drop ;
: sopt ( c addr -- )
  2dup c! 1+ fin drop ;

: sflag ( c addr -- )
  dup -rot
  start ndash sopt
  3 +len ;

: lflag ( addr1 u addr2 -- )
  3dup
  start mdash lopt
  swap 3 + +len drop ;

: parg ( addr1 u addr2 -- )
  3dup
  start lopt
  swap 1+ +len drop ;

: cmd parg ;

: get sep @ word count ;

: sf ( addr "string" -- ) char swap sflag ;
: lf ( addr "string" -- ) get rot lflag ;
: pa ( addr "string" -- ) get rot parg ;
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

: iter ( addr -- addr+u addr )
  dup >buf swap >len @ bounds ;
: >null ( addr -- addr+u ) begin dup c@ 0<> while 1+ repeat ;
: >field >null 1+ ;
: #fields ( addr -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;

: prep ( addr1 addr2 -- )
  over >buf rot #fields 0 do
    swap 2dup !
    cell+
    swap >field
  loop 2drop ;

: ready ( addr1 addr2 -- addr1+u addr2 )
  2dup prep swap >buf swap ;

stage @ #fields . cr
stage @ pad ready
pad 8 cells dump cr

\c #include <unistd.h>
c-function exec execvp a a -- n

: run stage @ pad ready exec ;

64 new t
t
c touch p newfile run
