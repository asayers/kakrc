colorscheme gruvbox
add-highlighter global/ show-matching
add-highlighter global/ number-lines -hlcursor

# Highlight trailing whitespace
add-highlighter global/ regex '[ \t]+$' 0:red,red

# No clippy
set -add global ui_options ncurses_assistant=none

# Use ripgrep
set global grepcmd 'rg --column --ignore'

set global toolsclient "tools"

# Colour make output
hook global BufCreate '\*make\*' %{
    hook buffer BufReadFifo '.*' 'ansi-render'
    hook buffer BufCloseFifo '.*' 'ansi-render'
}

# Edit or dir
unalias global e edit
alias global e edit-or-dir
map global normal '<backspace>' ': edit-or-dir %sh{dirname <c-r>%}<ret>'

# Soft tabs
hook global InsertChar \t %{ try %{
  execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
}}

# set global ctagscmd %{sh -c 'fd | xargs ctags'}
map global normal 'D' 'Gl<a-;>'
map global normal '<a-d>' ': select-surround<ret>'

# Opening splits
alias global vsp i3-split-horizontal
alias global hsp i3-split-vertical

# New goto targets
map global goto ']' '<esc><a-a>w: ctags-search<ret>' -docstring 'jump to tag'
map global goto '<left>' '<esc>: buffer-previous<ret>' -docstring 'prev buffer'
map global goto '<right>' '<esc>: buffer-next<ret>' -docstring 'next buffer'
map global goto '<' '<esc>: grep-previous-match<ret>' -docstring 'prev grep match'
map global goto '>' '<esc>: grep-next-match<ret>' -docstring 'next grep match'
map global goto '{' '<esc>: lint-previous-error<ret>' -docstring 'prev lint error'
map global goto '}' '<esc>: lint-next-error<ret>' -docstring 'next lint error'
map global goto -docstring 'edit kakrc' r '<esc>: e ~/.config/kak/kakrc<ret>'

# Case insensitive search by default
map global normal / '/(?i)'
map global normal ? '?(?i)'

# Key mappings to enter user modes
# map global normal '<c-w>' ': enter-user-mode i3<ret>'
map global user -docstring 'Git' "g" ': enter-user-mode git<ret>'
map global normal "<c-p>" ': enter-user-mode fzy<ret>'

# Show git changes in gutter
hook global WinCreate    .* 'git show-diff'
hook global BufWritePost .* %{ git update-diff }

# Rust settings
hook global WinSetOption filetype=rust %{
    set window formatcmd 'rustfmt'
    set window lintcmd %{
        cargo clippy 2>&1 | gawk 'match($0, /   --> (.*)/, arr) { print arr[1] " " prev } { prev=$0 }'
    }
    set window makecmd 'RUST_BACKTRACE=1 cargo'
    map window user 'c' ': make check --all --color always<ret>' -docstring 'cargo check'
    map window user 't' ': make test --all --color always -- --nocapture --test-threads=1<ret>' -docstring 'cargo test'
    map window user 'd' ': make doc --all --color always<ret>' -docstring 'cargo doc'
    set window docstring_line '///'
}

# Shell settings
hook global WinSetOption filetype=sh %{
    set window lintcmd 'shellcheck -f gcc'
}

map global user y -docstring 'yank to clipboard' '<a-|>xsel -ib<ret>'
map global user p -docstring 'paste from clipboard' '<a-!>xsel --output --clipboard<ret>'
map global user P -docstring 'paste from clipboard' '!xsel --output --clipboard<ret>'

# Enable LSP
eval %sh{kak-lsp --kakoune -s $kak_session}
lsp-enable
