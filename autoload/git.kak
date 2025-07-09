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

map global normal '<a-=>' '|shrink-conflicts<ret>' -docstring "Shrink conflicts in the current buffer"

## From git.kak by lenormf

# Faces that highlight text that overflows the following limits:
#   - title: 50 characters
#   - body: 72 characters
# http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
set-face global GitOverflowTitle yellow
set-face global GitOverflowBody yellow

hook -group git-commit-highlight global WinSetOption filetype=git-(commit|rebase) %{
    add-highlighter window/git-commit-highlight/ regex "^\h*[^#\s][^\n]{71}([^\n]+)" 1:GitOverflowBody
    add-highlighter window/git-commit-highlight/ regex "\A[\s\n]*[^#\s][^\n]{49}([^\n]+)" 1:GitOverflowTitle
}


## From git-konflict.kak by eko234
# https://github.com/eko234/git-konflict.kak

map global object m       %{c^[<lt>=|]{4\,}[^\n]*\n,^[<gt>=|]{4\,}[^\n]*\n<ret>} -docstring 'conflict markers'
map global object <a-m>   %{c^[<lt>]{4\,},^[<gt>]{4\,}[^\n]*<ret>}               -docstring 'conflict'
# map global object <a-m> %{c^[<lt>]{4\,},^[<gt>]{4\,}[^\n]*<ret>}           -docstring 'conflict section'

define-command konflict-use-mine %{
  evaluate-commands -draft %{
    execute-keys ghh/^<lt>{4}<ret>xd
    execute-keys h/^={4}<ret>j
    execute-keys -with-maps <a-a>m
    execute-keys d
  }
} -docstring "resolve a conflict by using the first version"

define-command konflict-use-yours %{
  evaluate-commands -draft %{
    execute-keys ghj
    execute-keys -with-maps <a-a>m
    execute-keys dh/^>{4}<ret>xd
  }
} -docstring "resolve a conflict by using the second version"

define-command konflict-use-mine-then-yours %{
  evaluate-commands -draft %{
    execute-keys -with-maps <a-l><a-a><a-m>s[=]{4,}<ret>c<esc>[m<a-h><a-l>dd]m<a-h><a-l>dd
  }
} -docstring "resolve a conflict by using the first and then the second version"

define-command konflict-use-yours-then-mine %{
  evaluate-commands -draft -save-regs ^ %{
    execute-keys -with-maps <a-l><a-a><a-m>s[=]{4,}<ret>ghh[mJZ<a-l><a-a><a-m>s[=]{4,}<ret>ghj]mKL<a-z>a<a-(>
    execute-keys -with-maps <a-l><a-a><a-m>s[=]{4,}<ret>c<esc>[m<a-h><a-l>dd]m<a-h><a-l>dd
  }
} -docstring "resolve a conflict by using the second and then the first version"

define-command konflict-use-none %{
  evaluate-commands -draft %{
    execute-keys <a-l>
    execute-keys -with-maps <a-a><a-m>
    execute-keys <a-d>
  }
} -docstring "resolve a conflict by using none"

define-command konflicts-grep %{
  grep <<<<
}

define-command konflict-highlight-conflicts -override %{
  add-highlighter -override global/ regex %{^[<lt>=]{4,}[^\n]*\n.+^[<gt>=]{4,}[^\n]*\n} 0:default+rb
}

define-command konflict-start %{
  konflict-highlight-conflicts
  konflicts-grep
}
