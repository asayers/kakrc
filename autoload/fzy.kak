declare-user-mode fzy

map global fzy '<c-p>' ': fzy-file<ret>' -docstring 'fzy file'
map global fzy '<c-l>' ': fzy-tag<ret>'  -docstring 'fzy tag'

define-command fzy-thing -params 2 \
        -docstring 'fzy-thing <candidates cmd> <action> - allow the user to pick from a list populated by <candidates cmd>, then pass the selection to <action>' \
        %{
    evaluate-commands %sh{
        if [ -z "$kak_opt_termcmd" ]; then
            echo "echo -markup '{Error}termcmd option is not set'"
            exit
        fi
        out=$(mktemp)
        i3-msg split toggle >/dev/null # This ensures that we create a new container
        $kak_opt_termcmd "i3-msg layout tabbed >/dev/null; ($1) | fzy > $out || rm $out"
        if [ -f $out ]; then
            printf '%s %s' "$2" "$(cat $out)"
        else
            printf 'echo Nothing to do'
        fi
    }
}

define-command fzy-file %{
    fzy-thing "fd -tf" "edit"
}

define-command fzy-tag %{
    fzy-thing "readtags -l | cut -f1" "ctags-search"
}
