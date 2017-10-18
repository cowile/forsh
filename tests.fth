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
\ This code conducts tests to sanity check all the code.
\ Inspection of results is conducted manually.

require forsh.fth

\ Declare an actor and build its command line arguments.
act prog
c program
char a stage @ sflag
s b
s" long" stage @ lflag
l longer
s" file" stage @ parg
p /usr/share/longfile
stage @ >len ? cr
stage @ show cr
stage @ back
b
pr cr

\ Prepare an actor for execution and examine the array of
\ pointers to strings built on the pad.
pad 10 cells 255 fill
stage @ #fields . cr
stage @ pad ready
pad 10 cells dump cr
2drop

\ Make sure anonymous pipes return valid file pointers.
0 errno !
2variable line
pipe line 2!
line write@ close
line read@ close

\ See if commands and pipelines work.
1 8 lshift #io !
36 actor def
c echo p hi $
c echo p hello >| c cat |>
c echo p hello >| s" file" |>f
c rm p file $

cr
\ Define commands as forth words.
: ls.fth
  [c] ls >|
  [c] grep [p] \.fth$ |> ;
ls.fth

cr
ge PWD se old
\ Change directories in a forth word.
home
c pwd $
ge old chdir
$

\ Show environment variables work.
s" value" se var
cr s" var="
type ge var type cr
ce

cr
\ Duplicate the ls command above with matching.
s" *.fth" m 3 pc echo {} ; $

\ Observe terminal settings.
c stty s a $
