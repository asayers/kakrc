# Based on https://github.com/alexherbo2/search-highlighter.kak
set-face global Search white,rgb:555500
hook global -group search-highlighter NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
    add-highlighter window/search dynregex '%reg{/}' 0:Search
    search-highlighter-selection-enable
}}
hook global -group search-highlighter NormalKey <esc> %{ try %{
    remove-highlighter window/search
    search-highlighter-selection-disable
}}
