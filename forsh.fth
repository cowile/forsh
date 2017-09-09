3 constant etx
variable stage
variable sep
bl sep !

: new ( u "name" -- ) create 0 , allot ;
: >len ;
: >buf cell+ ;
: jump ( addr -- addr+u ) dup >len @ + >buf ;
: clear ( addr -- ) >len 0 swap ! ;

: hyphen ( addr -- ) [char] - swap c! ;
: dash ( addr -- addr+1 ) dup hyphen 1+ ;
: mdash ( addr -- addr+1 ) dash dash ;
: null ( addr -- ) 0 swap c! ;
: end ( addr -- ) etx swap c! ;
: fin ( addr -- ) dup null 1+ end ;

: sflag ( addr c -- )
  >r dup
  dup jump
  dash
  dup r> swap c! 1+
  fin
  >len 3 ( length of -?\0 ) swap +! ;

: lflag ( addr1 addr2 u -- )
  >r >r dup
  dup jump
  mdash
  dup r> swap r@ cmove r@ +
  fin
  >len r@ 3 + ( length of --*\0 ) swap +! r> ;

: sf ( addr "char" -- ) char sflag ;
: lf ( addr "string" -- ) sep @ word count lflag ;

\c #include <unistd.h>
c-function exec execvp n n -- n
