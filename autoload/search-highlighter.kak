##
## Based on search-highlighter.kak by alexherbo2
##

# Set the 'Search' face to a dark yellow background
set-face global Search white,rgb:555500

# Enable highlighting by pressing a search-related key
hook global -group search-highlighter NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
    add-highlighter window/search dynregex '%reg{/}' 0:Search
    # search-highlighter-selection-enable
}}

# Disable highlighting by pressing escape
hook global -group search-highlighter NormalKey <esc> %{ try %{
    remove-highlighter window/search
    # search-highlighter-selection-disable
}}
