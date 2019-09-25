map global normal '*'     ': star-auto-select *<ret>'
map global normal '<a-*>' ': star-auto-select <lt>a-*><ret>'

define-command star-auto-select -hidden -params 1 \
    -docstring 'auto-select a word under cursor when star is pressed with no selection' %{
    try %{ evaluate-commands %sh{
        if echo "$kak_selections_desc" | grep -Eq '^(([0-9]+)\.([0-9]+),\2\.\3:?)+$'; then
          echo execute-keys '<a-i>w<ret>'
        fi
    } }
    execute-keys -save-regs '' -with-hooks %arg{1}
}
