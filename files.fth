\ Copyright 2017 Colton Lewis
\
\ Licensed under the Apache License, Version 2.0 (the "License");
\ you may not use this file except in compliance with the License.
\ You may obtain a copy of the License at
\
\     http://www.apache.org/licenses/LICENSE-2.0
\
\ Unless required by applicable law or agreed to in writing, software
\ distributed under the License is distributed on an "AS IS" BASIS,
\ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
\ See the License for the specific language governing permissions and
\ limitations under the License.
\
\ This code handles file based input and output. It includes
\ anonymous pipes and the ability to convert file descriptors
\ to file pointers for use with other file handling functions
\ provided by gforth.

require errors.fth

\c #include <stdio.h>
c-function cfdopen fdopen n a -- a
c-function cfileno fileno a -- n

\ Whenever convenient, add error checking to system calls.
: fdopen cfdopen ?err ;
: fileno cfileno ?err ;
: fd>fp ( fd c -- fp ) pad c! 0 pad 1+ c! pad fdopen ;
: fd>ro ( fd -- fp ) [char] r fd>fp ;
: fd>wo ( fd -- fp ) [char] w fd>fp ;

\ conv converts a pair of pipe file descriptors into two file
\ pointers. This function assumes 32 bit file descriptors and
\ a 64 bit cell size.
: conv ( n -- fp1 fp2 )
  dup 32 lshift 32 rshift fd>ro
  swap 32 rshift fd>wo ;

\c #include <unistd.h>
c-function cdup2 dup2 n n -- n
c-function cpipe pipe a -- n

: pipe ( -- fd1 fd2 )
  pad cpipe ?err drop pad @ conv ;

\ The results of pipe can be stored in a 2variable. Provide
\ functions to access the read and write ends.
: read@ 2@ drop ;
: write@ 2@ nip ;

: close ( fp -- ) close-file ?err drop ;

0 constant stin
1 constant stout
2 constant sterr
: clone ( fd1 fd2 -- ) cdup2 ?err drop ;

\ These words allow io between arbitrary files with user with a user
\ settable buffer and size.
variable io
variable #io
create iodef 4096 allot
iodef io !

: iobuf ( fp -- a u fp ) io #io @ rot ;
: rin ( fp -- ) iobuf read-file ?err drop ;
: wout ( fp -- ) iobuf write-file ?err drop ;
: copy ( fp1 fp2 -- )
  #io @ -rot
  begin
    over rin #io ! dup wout
  over file-eof? until
  2drop #io ! ;

\ Copying to standard output or standard error are common cases.
: tell ( fp -- ) dup stdout copy close ;
: wail ( fp -- ) dup stderr copy close ;
