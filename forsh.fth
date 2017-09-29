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

\ Set up a cue to be printed before every command.
act cueact
: strip >| [c] tr [s] d [p] \n |> ;
: bar [char] | emit ;
: at [char] @ emit ;
: arrow [char] > emit ;
: acue
  stage @ cueact
  cr bar space [c] whoami strip
  at [c] hostname strip
  space [c] date [p] +%H:%M strip
  space [c] pwd strip
  cr bar arrow space
  stage ! ;
' acue is cue

\ Add a default act so user commands may happen immediately.
act default
