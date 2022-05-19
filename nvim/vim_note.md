# NERDTree
#### Windows

- `Ctrl ww` - Cycle through all windows
- `Ctrl wh` - Window left
- `Ctrl wj` - Window below
- `Ctrl wk` - Window up
- `Ctrl wl` - Window right 
#### Tabs
- `gt` - Next tab
- `gT` - Previous tab 
#### Dirs
- `C` - change current root dir
- 
- `cd` - Show CWD
#### Split Panes
- `Ctrl-W -` - Decrease current window height by N (default 1).
- `Ctrl-W +` - Increase current window height by N (default 1).
- `Ctrl-W <` - Decrease current window width by N (default 1).
- `Ctrl-W >` - Increase current window width by N (default 1).
- `:res +/-N` - Like: :res +10
- `:vertical res +/-N` - Like: :vertical res +10
# coc
- `gd` - Go to definication
- 

# nvim-comment
#### NORMAL mode
- `gcc` - Toggles the current line using linewise comment
- `gbc` - Toggles the current line using blockwise comment
- `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
- `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
- `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
- `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment 
#### VISUAL mode
- `gc` - Toggles the region using linewise comment
- `gb` - Toggles the region using blockwise comment

# search & replace
- `:%s/https:\/\/www.google.com/new/gc`
  - `%` - first line to last line
  - `g` - all occurences
  - `c` - confirm
- `:%s/"\(\d*\)"/\1/gc`
  - `%` - first line to last line
  - `\(\)` - capture group
  - `\1` - return group 1
  - eg: 1,test,"100" -> 1,test,100
# add multiple line at the same time
- `qq` - start recording
- `f"ai<text><esc>0j` - go to first occurence doublequote, insert text, go to the beginning of the line and go down
- `@q` - play 1 time
- `<n>@q` - play n time
