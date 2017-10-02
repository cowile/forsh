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
