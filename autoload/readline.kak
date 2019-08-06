##
## readline.kak by lenormf
## Readline shortcuts implemented in insert mode
##

map global insert <c-b> <esc>hi   -docstring "move the cursor one character to the left"
map global insert <c-f> <esc>li   -docstring "move the cursor one character to the right"
map global insert <a-b> <esc>b\;i -docstring "move the cursor one word to the left"
map global insert <a-f> <esc>e\;i -docstring "move the cursor one word to the right"
map global insert <c-a> <esc>I    -docstring "move the cursor to the start of the line"
map global insert <c-e> <esc>gli  -docstring "move the cursor to the end of the line"

map global insert <c-d> <esc>c   -docstring "delete the character under the anchor"
map global insert <c-u> <esc>Ghc -docstring "delete from the anchor to the start of the line"
map global insert <c-k> <esc>Glc -docstring "delete from the anchor to the end of the line"
map global insert <a-d> <esc>ec  -docstring "delete until the next word boundary"
map global insert <c-w> <esc>bc  -docstring "delete until the previous word boundary"

map global insert <c-t> %{<esc>:try 'exec H<lt>a-k>[^\n][^\n]<lt>ret>\;dp'<ret>i} \
    -docstring "exchange the char before cursor with the character at cursor"
map global insert <a-t> %{<esc>:try 'exec <lt>a-k>\s<lt>ret>e' catch 'exec <lt>a-i>w'<ret><a-;>BS\s+<ret><a-">\;<space>i} \
    -docstring "exchange the word before cursor with the word at cursor"

map global insert <a-u> <esc>e<a-i>w~\;i -docstring "uppercase the current or following word"
map global insert <a-l> <esc>e<a-i>w`\;i -docstring "lowercase the current or following word"
map global insert <a-c> <esc>e<a-i>w\;~i -docstring "capitalize the current or following word"

map global insert <c-y> <esc>pi -docstring "paste after the anchor"
