# Based on https://github.com/Delapouite/kakoune-i3/blob/master/i3.kak

define-command i3-split-vertical -docstring "Create a new kak client below" %{
    # clone (same buffer, same line)
    i3-terminal-vertical "kak -c %val{session} -e 'execute-keys :buffer <space> %val{buffile} <ret> %val{cursor_line} g'"
}

define-command i3-split-horizontal -docstring "Create a new kak client on the right" %{
    # clone (same buffer, same line)
    i3-terminal-horizontal "kak -c %val{session} -e 'execute-keys :buffer <space> %val{buffile} <ret> %val{cursor_line} g'"
    echo "kak -c %val{session} -e 'execute-keys :buffer <space> %val{buffile} <ret> %val{cursor_line} g'"
}

define-command i3-terminal-vertical -params 1.. -shell-completion -docstring "i3-terminal-vertical <program> [arguments]: Create a new terminal below" %{
    evaluate-commands %sh{echo "i3-new-impl v %{$@}"}
}

define-command i3-terminal-horizontal -params 1.. -shell-completion -docstring "i3-terminal-vertical <program> [arguments]: Create a new terminal on the right" %{
    evaluate-commands %sh{echo "i3-new-impl h %{$@}"}
}

define-command -hidden -params 2.. i3-new-impl %{
    evaluate-commands %sh{
        if [ -z "$kak_opt_termcmd" ]; then
            echo "echo -markup '{Error}termcmd option is not set'"
            exit
        fi
        i3-msg "split $1" >&2
        shift
        # We have to disconnect stdout and stderr, or kakoune will wait
        # for the command to finish
        $kak_opt_termcmd "$@" >/dev/null 2>/dev/null &
    }
}

define-command i3-focus-left  -docstring "Move focus left"  %{ nop %sh{ i3-msg focus left  } }
define-command i3-focus-right -docstring "Move focus right" %{ nop %sh{ i3-msg focus right } }
define-command i3-focus-up    -docstring "Move focus up"    %{ nop %sh{ i3-msg focus up    } }
define-command i3-focus-down  -docstring "Move focus down"  %{ nop %sh{ i3-msg focus down  } }

# Suggested aliases

# alias global new i3-new-right

# declare-user-mode i3
# map global i3 h :i3-new-left<ret> -docstring '← new window on the left'
# map global i3 l :i3-new-right<ret> -docstring '→ new window on the right'
# map global i3 k :i3-new-up<ret> -docstring '↑ new window above'
# map global i3 j :i3-new-down<ret> -docstring '↓ new window below'

# map global i3 <left> :i3-focus-left<ret> -docstring '← focus window left'
# map global i3 <right> :i3-focus-right<ret> -docstring '→ focus window right'
# map global i3 <up> :i3-focus-up<ret> -docstring '↑ focus window up'
# map global i3 <down> :i3-focus-down<ret> -docstring '↓ focus window down'

# Suggested mapping

#map global user 3 ': enter-user-mode i3<ret>' -docstring 'i3…'
