define-command highlight-cursor-line %{
    remove-highlighter window/cursorline
    add-highlighter window/cursorline line %val{cursor_line} default,rgb:3c3733
}
hook global WinCreate '.*' highlight-cursor-line
hook global RawKey '.*' highlight-cursor-line
# add-highlighter global/100col column 100 default,rgb:3c3733
