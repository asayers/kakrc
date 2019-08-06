##
## Based on search-highlighter.kak by alexherbo2, but stripped down to a
## bare minimum
##

# Set the 'Search' face to a dark yellow background
set-face global Search white,rgb:555500

# Enable highlighting by pressing a search-related key
hook global NormalKey [/?*nN]|<a-[/?*nN]> \
    %{ try %{ add-highlighter window/search dynregex '%reg{/}' 0:Search }}

# Disable highlighting by pressing escape
hook global NormalKey <esc> \
    %{ remove-highlighter window/search }
