define-command replace-pane -params 1 -docstring 'Replace the current tmux pane with the specified program' %{
    evaluate-commands %sh{
        # $RANDOM doesn't seem to be working here... let's jury-rig it.
        name=$(date | md5sum | awk '{ print $1 }')
        mkfifo "/tmp/$name"
        tmux new-window -n "$name" -d "sh -c '$1 > /tmp/$name'"
        tmux swap-pane -s "$name." -t "$TMUX_PANE"
        out=$(cat "/tmp/$name")
        tmux swap-pane -t "$name." -s "$TMUX_PANE"
        echo "$out"
    }
}
