##
## kak-ansi by eraserhd
##

# This is copied from version 1.  Version 2 is a rewrite in C, which is
# surplus to my requirements.

declare-option -hidden range-specs ansi_color_ranges

define-command \
    -docstring %{ansi-render-selection: colorize ANSI codes contained inside selection

After highlighters are added to colorize the buffer, the ANSI codes
are removed.} \
    -params 0 \
    ansi-render-selection %{
    evaluate-commands -draft %{
        try %{
            add-highlighter buffer/ansi ranges ansi_color_ranges
            set-option buffer ansi_color_ranges %val{timestamp}
        }
        update-option buffer ansi_color_ranges
        evaluate-commands %sh{ exec awk '
            BEGIN{
                COLORS[0] = "black";
                COLORS[1] = "red";
                COLORS[2] = "green";
                COLORS[3] = "yellow";
                COLORS[4] = "blue";
                COLORS[5] = "magenta";
                COLORS[6] = "cyan";
                COLORS[7] = "white";
                COLORS[9] = "default";

                split(ENVIRON["kak_selection_desc"], selection_desc, /[.,]/);

                # line, column             - position of this character.
                # prev_line, prev_column   - position of previous character.
                # start_line, start_column - starting position of current highlight.
                prev_line = start_line = line = selection_desc[1];
                start_column = column = selection_desc[2];
                prev_column = column - 1;
            }
            function advance(ch) {
                prev_line = line;
                prev_column = column;
                if (ch == "\n") {
                    ++line;
                    column = 1;
                } else {
                    ++column;
                }
            }
            BEGIN{
                text = ENVIRON["kak_selection"];
                printf "set-option -add buffer ansi_color_ranges";
                foreground = "default";
                background = "default";
                attributes = "";
                for (i = 0; i < length(text); i++) {
                    ch = substr(text, i, 1);
                    if (ch == "\x1B") {
                        face = foreground "," background attributes;
                        if (face != "default,default" &&
                            (start_line != prev_line || prev_column >= start_column)) {
                            printf " %d.%d,%d.%d|%s", start_line, start_column, prev_line, prev_column, face;
                        }
                        if (1 == match(substr(text, i, 35), /\x1B\[[0-9;]*m/)) {
                            start_line = line;
                            start_column = column + RLENGTH;
                            split(substr(text, i+2, RLENGTH-3), codes, /;/);
                            if (length(codes) == 0) {
                                foreground = background = "default";
                                attributes = "";
                            }
                            for (j = 1; j <= length(codes); j++) {
                                code = 0 + codes[j];
                                if (code == 0) {
                                    foreground = background = "default";
                                    attributes = "";
                                } else if (code == 1) {
                                    attributes = "+b";
                                } else if (code >= 30 && code <= 39) {
                                    foreground = COLORS[code % 10];
                                } else if (code >= 40 && code <= 49) {
                                    background = COLORS[code % 10];
                                }
                            }
                        }
                    }
                    advance(ch);
                }
                printf "\n";
            }
        ' }
        try %{ execute-keys 's\x1B\[[\d;]*m<ret><a-d>' }
        update-option buffer ansi_color_ranges
    }
}

define-command \
    -docstring %{ansi-render: colorize buffer by using ANSI codes

After highlighters are added to colorize the buffer, the ANSI codes
are removed.} \
    -params 0 \
    ansi-render %{
    evaluate-commands -draft %{
        execute-keys '%'
        ansi-render-selection
    }
}

define-command \
    -docstring %{ansi-clear: clear highlighting for current buffer.} \
    -params 0 \
    ansi-clear %{
        set buffer ansi_color_ranges
}

hook -group ansi global BufCreate '\*stdin\*' %{
    hook -once buffer NormalIdle '' ansi-render
}
