3 constant etx
variable stage
variable sep
bl sep !

: new ( u "name" -- ) create 0 , allot does> stage ! ;
: >len ;
: >buf cell+ ;
: start ( addr -- addr+u ) dup >len @ + >buf ;
: clear ( addr -- ) >len 0 swap ! ;

: hyphen ( addr -- ) [char] - swap c! ;
: dash ( addr -- addr+1 ) dup hyphen 1+ ;
: mdash ( addr -- addr+1 ) dash dash ;
: null ( addr -- ) 0 swap c! ;
: end ( addr -- ) etx swap c! ;
: fin ( addr -- ) dup null 1+ end ;

: sflag ( addr c -- )
  >r dup
  dup start
  dash
  dup r> swap c! 1+
  fin
  >len 3 ( length of -?\0 ) swap +! ;

: lflag ( addr1 addr2 u -- )
  >r >r dup
  dup start
  mdash
  dup r> swap r@ cmove r@ +
  fin
  >len r> 3 + ( length of --*\0 ) swap +! ;

: parg ( addr1 addr2 u -- )
  >r >r dup
  dup start
  dup r> swap r@ cmove r@ +
  fin
  >len r> 1+ swap +! ;

: sf ( addr "char" -- ) char sflag ;
: lf ( addr "string" -- ) sep @ word count lflag ;
: pa ( addr "string" -- ) sep @ word count parg ;

: s stage @ sf ;
: l stage @ lf ;
: p stage @ pa ;

128 new testbuf
testbuf
stage @ char a sflag
s b
stage @ s" long" lflag
l longer
stage @ s" file" parg
p /usr/share/longfile
stage @ >len ?
stage @ >buf 50 type cr

\c #include <unistd.h>
c-function exec execvp n n -- n
