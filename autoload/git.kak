declare-user-mode git

map global git 's' ': git status<ret>' -docstring 'git status'
map global git 'l' ': git log<ret>' -docstring 'git log'
map global git 'i' ': git-staged<ret>' -docstring 'git staged'
map global git 'c' -docstring 'View staged changes' ': git-commit-mode<ret>'
map global git 'd' -docstring 'View unstaged changes' ': git diff<ret>'

define-command git-commit-mode %{
    git diff --cached
    map window git 'c' -docstring 'Commit staged changes' ':git commit<ret>'
    map window git 'a' -docstring 'Amend HEAD' ':git commit --amend<ret>'
}

define-command git-stage-as -hidden -params 2 -docstring 'git-stage-as <file> <relpath>: Stage the contents of <file> at <relpath>' %{
    evaluate-commands %sh{
        obj=$(git hash-object -w ${1})
        printf '100644 blob %s	%s' "${obj}" "${2}" | git update-index --index-info
        printf 'echo Updated git index at %s\n' "${2}"
    }
}

define-command git-read-index -hidden -params 1 -file-completion -docstring 'Read the index at the specified path' %{
    evaluate-commands %sh{
        output="$(mktemp -d)/$(basename ${1})"
        # empty_tree=$(printf '' | git hash-object -t tree --stdin)
        empty_tree="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        obj=$(git diff-index --cached ${empty_tree} ${1} | cut -d' ' -f4) # There must be a better way!
        git cat-file blob ${obj} > ${output}
        printf 'edit %s\n' "${output}"
        printf 'hook buffer BufWritePost .* "git-stage-as %s %s"\n' "${output}" "${1}"
    }
}

define-command git-staged -docstring 'git-staged: Show the current file as it appears in the index' %{
    git-read-index %val{bufname}
}



##
## git.kak by lenormf
##

# http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Faces that highlight text that overflows the following limits:
#   - title: 50 characters
#   - body: 72 characters
set-face global GitOverflowTitle yellow
set-face global GitOverflowBody yellow

hook -group git-commit-highlight global WinSetOption filetype=git-(commit|rebase) %{
    add-highlighter window/git-commit-highlight/ regex "^\h*[^#\s][^\n]{71}([^\n]+)" 1:GitOverflowBody
    add-highlighter window/git-commit-highlight/ regex "\A[\s\n]*[^#\s][^\n]{49}([^\n]+)" 1:GitOverflowTitle
}
