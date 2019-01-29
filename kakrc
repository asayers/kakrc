colorscheme gruvbox

# Some UI niceties
add-highlighter global/ show-matching
add-highlighter global/ number-lines -hlcursor
add-highlighter global/ wrap -word -indent

# No clippy
set -add global ui_options ncurses_assistant=none

# Use ripgrep
set global grepcmd 'rg --column'

set global tabstop 4

set global toolsclient "tools"
hook global BufCreate '\*make\*' %{
    hook buffer BufReadFifo '.*' 'ansi-render'
    hook buffer BufCloseFifo '.*' 'ansi-render'
}

# Edit or dir
unalias global e edit
alias global e edit-or-dir
map global normal '<backspace>' ': edit-or-dir %sh{dirname <c-r>%}<ret>'

# Soft tabs
# map global insert <tab> '<a-;><gt>'
# map global insert <s-tab> '<a-;><lt>'

# set global ctagscmd %{sh -c 'fd | xargs ctags'}
map global normal '#'     ': comment-line<ret>'  -docstring 'comment line'
map global normal '<a-#>' ': comment-block<ret>' -docstring 'comment block'
map global normal '='     ': format<ret>'        -docstring 'format buffer'

# Formatting comments
declare-option -docstring 'Prefix indicating that a line is part of a docstring' str docstring_line
define-command select-comment %{ execute-keys %sh{
    # This doesn't quite work right - it will select all comment blocks in the current paragraph, not just the one the cursor is in.
    printf '<a-a>p<a-s><a-k>^\\h*%s<ret><a-_>\n' "$kak_opt_docstring_line"
    # <a-a>c^($|\s*[^\s/]),^($|\s*[^\s/])<ret>H<a-;>L<a-;>
}}
map global object '/' '<esc>: select-comment<ret>'
map global normal '<a-=>' '|fmt -p${kak_opt_docstring_line} -u -w${kak_opt_autowrap_column}<ret>'
map global user 'f' '<a-a>/<a-=>'

# Opening splits
alias global vsp i3-split-horizontal
alias global hsp i3-split-vertical
define-command vspt 'i3-terminal-horizontal zsh'
define-command hspt 'i3-terminal-vertical zsh'

map global goto ']' '<esc><a-a>w: ctags-search<ret>' -docstring 'jump to tag'
map global goto '>' '<esc>: grep-next-match<ret>'
map global goto '<' '<esc>: grep-previous-match<ret>'

# Key mappings to enter user modes
# map global normal '<c-w>' ': enter-user-mode i3<ret>'
map global normal "'"     ': enter-user-mode git<ret>'
map global normal "<c-p>" ': enter-user-mode fzy<ret>'

# Show git changes in gutter
hook global WinCreate    .* 'git show-diff'
hook global BufWritePost .* %{
    git update-diff
    ctags-update-tags
}

hook global WinSetOption filetype=rust %{
    set window formatcmd 'rustfmt'
    set window lintcmd %{
        cargo clippy 2>&1 | gawk 'match($0, /   --> (.*)/, arr) { print arr[1] " " prev } { prev=$0 }'
    }
    set window makecmd 'cargo'
    map window user 'c' ': make check --all --color always<ret>' -docstring 'cargo check'
    map window user 't' ': make test --all --color always<ret>' -docstring 'cargo test'
    map window user 'd' ': make doc --all --color always<ret>' -docstring 'cargo doc'
    set window docstring_line '///'
}
hook global WinSetOption filetype=sh %{
    set window lintcmd 'shellcheck -f gcc'
}

# define-command replace-pane -params 1 -docstring 'Replace the current tmux pane with the specified program' %{
#     evaluate-commands %sh{
#         # $RANDOM doesn't seem to be working here... let's jury-rig it.
#         name=$(date | md5sum | awk '{ print $1 }')
#         mkfifo "/tmp/$name"
#         tmux new-window -n "$name" -d "sh -c '$1 > /tmp/$name'"
#         tmux swap-pane -s "$name." -t "$TMUX_PANE"
#         out=$(cat "/tmp/$name")
#         tmux swap-pane -t "$name." -s "$TMUX_PANE"
#         echo "$out"
#     }
# }

# define-command fzf %{ replace-pane "sh -c kak" }
