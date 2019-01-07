# http://i3wm.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# depends on: x11.kak
# see also: tmux.kak

## Temporarily override the default client creation command
define-command -hidden -params 2 i3-new-impl %{
  evaluate-commands %sh{
    echo "echo $2"
    if [ -z "$kak_opt_termcmd" ]; then
      echo "echo -markup '{Error}termcmd option is not set'"
      exit
    fi
    {
      # https://github.com/i3/i3/issues/1767
      i3-msg "split $1"
      # clone (same buffer, same line)
      exec $kak_opt_termcmd "$2"
    } < /dev/null > /dev/null 2>&1 &
  }
}

define-command i3-new-down -docstring "Create a new kak client below" %{
    i3-new-impl v "kak -c %val{session} -e 'execute-keys :buffer <space> %val{buffile} <ret> %val{cursor_line} g'"
}

define-command i3-new-right -docstring "Create a new kak client on the right" %{
    i3-new-impl h "kak -c %val{session} -e 'execute-keys :buffer <space> %val{buffile} <ret> %val{cursor_line} g'"
}

define-command i3-new-term-down -docstring "Create a new terminal below" %{
    i3-new-impl v "zsh"
}

define-command i3-new-term-right -docstring "Create a new terminal on the right" %{
    i3-new-impl h "zsh"
}


# Suggested aliases

# alias global new i3-new-right

# declare-user-mode i3
# map global i3 h :i3-new-left<ret> -docstring '← new window on the left'
# map global i3 l :i3-new-right<ret> -docstring '→ new window on the right'
# map global i3 k :i3-new-up<ret> -docstring '↑ new window above'
# map global i3 j :i3-new-down<ret> -docstring '↓ new window below'

# define-command i3-focus-left  -docstring "Move focus left"  %{ nop %sh{ i3-msg focus left  } }
# define-command i3-focus-right -docstring "Move focus right" %{ nop %sh{ i3-msg focus right } }
# define-command i3-focus-up    -docstring "Move focus up"    %{ nop %sh{ i3-msg focus up    } }
# define-command i3-focus-down  -docstring "Move focus down"  %{ nop %sh{ i3-msg focus down  } }
# map global i3 <left> :i3-focus-left<ret> -docstring '← focus window left'
# map global i3 <right> :i3-focus-right<ret> -docstring '→ focus window right'
# map global i3 <up> :i3-focus-up<ret> -docstring '↑ focus window up'
# map global i3 <down> :i3-focus-down<ret> -docstring '↓ focus window down'

# Suggested mapping

#map global user 3 ': enter-user-mode i3<ret>' -docstring 'i3…'
