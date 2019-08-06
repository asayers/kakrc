declare-user-mode git

map global git 's' ': git status<ret>'      -docstring 'git status'
map global git 'a' ': git add<ret>'         -docstring 'Add this file to the stage'
map global git 'i' ': git-staged<ret>'      -docstring 'View this file in the stage'
map global git 'c' ': git-commit-mode<ret>' -docstring 'View staged changes'
map global git 'd' ': git diff<ret>'        -docstring 'View unstaged changes'
map global git 'l' ': git log<ret>'         -docstring 'git log'

define-command git-commit-mode %{
    git diff --cached
    # Just for this window, we override some of the git-mode keybinds
    map window git 'c' ':git commit<ret>'         -docstring 'Commit staged changes'
    map window git 'a' ':git commit --amend<ret>' -docstring 'Amend HEAD'
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
