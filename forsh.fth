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
\ Add the shell words to the search order as a word list,
\ but keep the default list as the compilation list and
\ first place to search.
get-current
vocabulary shell
shell definitions
require interface.fth
also forth
set-current

\ Clear any junk memory errors.
0 errno !
0 status !

\ This is the separator that delimits inline arguments.
\ It is a space character by default. To include spaces in an
\ argument, set to something else. The word 'q' is defined
\ to do this conveniently for one field.
bl sep !

\ This is the default stage size. Anyone that needs a larger
\ command can make one with 'actor' or change the variable.
1024 #stage !

\ This is the size for the io buffer when copying between files.
\ Set it to 4 KiB by default.
4096 #io !

\ Remove the default boot message
' noop is bootmessage

\ Set up a cue to be printed before every command.
act cueact
: strip >| [c] tr [s] d [p] \n |> ;
: bar [char] | emit ;
: at [char] @ emit ;
: arrow [char] > emit ;
: acue
  cueact
  cr bar space [c] whoami strip
  at [c] hostname strip
  space [c] date [p] +%H:%M strip
  space [c] pwd strip
  cr bar arrow space ;
' acue is 'cue

\ Add a default act so user commands may happen immediately.
act default
quit
