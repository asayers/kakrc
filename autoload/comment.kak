map global normal '#'     ': comment-line<ret>'  -docstring 'comment line'
map global normal '<a-#>' ': comment-block<ret>' -docstring 'comment block'
map global normal '='     ': format<ret>'        -docstring 'format buffer'
map global normal '+'     ': reflow<ret>'        -docstring 'reflow selection'

# Formatting comments
declare-option -docstring 'Prefix indicating that a line is part of a docstring' str docstring_line
define-command select-comment %{ execute-keys %sh{
    # This doesn't quite work right - it will select all comment blocks in
    # the current paragraph, not just the one the cursor is in.
    printf '<a-a>p<a-s><a-k>^\\h*%s<ret><a-_>\n' "$kak_opt_comment_line"
    # <a-a>c^($|\s*[^\s/]),^($|\s*[^\s/])<ret>H<a-;>L<a-;>
}}
map global object '#' '<esc>: select-comment<ret>'
map global user 'f' '<a-a>/<a-=>'

define-command reflow %{ execute-keys %sh{
    comment="$(echo $kak_selection | sed -n '1s/^\s*\([#/*()-]*\).*/\1/p')"
    if [ -z $comment ]; then
        printf '|fmt --width=%s --uniform-spacing<ret>\n' "${kak_opt_autowrap_column}"
    else
        printf '|fmt --prefix="%s" --width=%s --uniform-spacing<ret>\n' "${comment}" "${kak_opt_autowrap_column}"
    fi
}}
