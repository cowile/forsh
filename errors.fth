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
\ This code defines error reporting for C system calls.

\c #include <errno.h>
c-function errno __errno_location -- a

: explain ( n -- ) strerror ;
: report ( n -- ) cr explain type ;
: ?err ( -- )
  errno @ 0<> if
    errno @ report
  then
  0 errno ! ;
