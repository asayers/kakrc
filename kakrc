colorscheme gruvbox-dark
add-highlighter global/ show-matching
add-highlighter global/ number-lines -hlcursor

# Highlight trailing whitespace
add-highlighter global/ regex '[ \t]+$' 0:red,red

# No clippy
set -add global ui_options ncurses_assistant=none

# Use ripgrep, and exclude json/csv files.  These tend to be very large and
# uninteresting, but are non-binary, so rg searches them by default.
set global grepcmd 'rg --column -Tjson -Tjsonl -Tcsv'

set global toolsclient "tools"

# Colour make output
hook global BufCreate '\*make\*' %{
    hook buffer BufReadFifo '.*' 'ansi-render'
    hook buffer BufCloseFifo '.*' 'ansi-render'
}

# Browse directory on backspace
map global goto 'd' '<esc>: edit-or-dir %sh{git rev-parse --show-cdup}<ret>'

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
map global goto ']' '<esc>: lsp-definition<ret>' -docstring 'jump to tag'
# map global goto ']' '<esc><a-a>w: ctags-search<ret>' -docstring 'jump to tag'
map global goto '<left>' '<esc>: buffer-previous<ret>' -docstring 'prev buffer'
map global goto '<right>' '<esc>: buffer-next<ret>' -docstring 'next buffer'
map global goto '<' '<esc>: grep-previous-match<ret>' -docstring 'prev grep match'
map global goto '>' '<esc>: grep-next-match<ret>' -docstring 'next grep match'
map global goto '{' '<esc>: lint-previous-error<ret>' -docstring 'prev lint error'
map global goto '}' '<esc>: lint-next-error<ret>' -docstring 'next lint error'
map global goto -docstring 'edit kakrc' r '<esc>: e ~/.config/kak/kakrc<ret>'

# Show hover info (docs)
map global normal K ': lsp-hover<ret>'

# Case insensitive search by default
map global normal / '/(?i)'
map global normal ? '?(?i)'

# Key mappings to enter user modes
# map global normal '<c-w>' ': enter-user-mode i3<ret>'
map global user -docstring 'Git' g ': enter-user-mode git<ret>'
map global user -docstring 'LSP' l ': enter-user-mode lsp<ret>'

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

map global user y -docstring 'yank to clipboard' '<a-|>wl-copy<ret>'
map global user p -docstring 'paste from clipboard' '<a-!>wl-paste<ret>'
map global user P -docstring 'paste from clipboard' '!wl-paste<ret>'

map global user m ': mark-word<ret>' -docstring 'Mark the word under the cursor'
map global user M ': mark-clear<ret>' -docstring 'Clear all marks'

# Enable LSP
eval %sh{kak-lsp --kakoune -s $kak_session}
lsp-enable

declare-option -hidden str modeline_progress ""
define-command -hidden -params 6 -override lsp-handle-progress %{
    set global modeline_progress %sh{
        if ! "$6"; then
            echo "$2${5:+" ($5%)"}${4:+": $4"}"
        fi
    }
}
set global modelinefmt "%%opt{modeline_progress} %opt{modelinefmt}"

def find -params 1 -shell-script-candidates %{ git ls-files } %{ edit %arg{1} }

declare-user-mode select
map global normal "'" ': enter-user-mode select<ret>'
map global select "'" ':find '         -docstring 'select file'
map global select ';' ':buffer '       -docstring 'select buffer'
map global select 'l' ':ctags-search ' -docstring 'select tag'

declare-user-mode konflict
map global user k ': enter-user-mode konflict<ret>'
map global konflict s ': konflict-start<ret>'
map global konflict j ': konflict-use-mine<ret>'
map global konflict k ': konflict-use-yours<ret>'
map global konflict J ': konflict-use-mine-then-yours<ret>'
map global konflict K ': konflict-use-yours-then-mine<ret>'
map global konflict d ': konflict-use-none<ret>'
