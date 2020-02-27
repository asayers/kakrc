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

# Browse directory on backspace
map global normal '<backspace>' ': edit-or-dir %sh{dirname <c-r>%}<ret>'
map global goto 'G' '<esc>: edit-or-dir %sh{git rev-parse --show-cdup}<ret>'

# Soft tabs
hook global InsertChar \t %{ try %{
  execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
}}

# set global ctagscmd %{sh -c 'fd | xargs ctags'}
map global normal 'D' 'Gl'
map global normal '<a-D>' 'Gh'
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
map global goto -docstring 'edit kakrc' R '<esc>: e ~/.config/kak/kakrc<ret>'

# Show hover info (docs)
# map global normal K ': lsp-hover<ret>'

# Auto-highlight references
# hook global NormalIdle '.*' %{ try %{ lsp-highlight-references }}

# Case insensitive search by default
map global normal / '/(?i)'
map global normal ? '?(?i)'

# Key mappings to enter user modes
# map global normal '<c-w>' ': enter-user-mode i3<ret>'
map global user -docstring 'Git' "g" ': enter-user-mode git<ret>'

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

map global user m ': mark-word<ret>' -docstring 'Mark the word under the cursor'
map global user M ': mark-clear<ret>' -docstring 'Clear all marks'

# Enable LSP
eval %sh{kak-lsp --kakoune -s $kak_session}
hook global WinSetOption filetype=(rust|python|go|javascript|typescript|c|cpp) %{
    lsp-enable-window
}

def find -params 1 -shell-script-candidates %{ git ls-files } %{ edit %arg{1} }

declare-user-mode select
map global normal "'" ': enter-user-mode select<ret>'
map global select "'" ':find '         -docstring 'select file'
map global select ';' ':buffer '       -docstring 'select buffer'
map global select 'l' ':ctags-search ' -docstring 'select tag'
