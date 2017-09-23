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
\ argument, set to something else.
bl sep !

\ This is the size for the io buffer when copying between files.
\ Set it to a KiB by default.
1024 #io !

\ Add a default actor so commands may happen immediately.
1024 actor default
default
