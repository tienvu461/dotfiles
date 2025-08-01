call plug#begin('~/.vim/plugged')

" leave some space in between
" source explorer
Plug 'preservim/nerdtree'
" tmux
Plug 'christoomey/vim-tmux-navigator'

" extra text objects
Plug 'wellle/targets.vim'
Plug 'easymotion/vim-easymotion'
"Not working Plug 'tsony-tsonev/nerdtree-git-plugin'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" code auto complete linting suggestion
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': 'yarn install --frozen-lockfile'}
" conflicting with coc
" Plug 'jiangmiao/auto-pairs'

let g:coc_global_extensions = ['coc-tslint-plugin', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier']  " list of CoC extensions needed

" GIthub Copilot
" Plug 'github/copilot.vim'
" these two plugins will add highlighting and indenting to JSX and TSX files.
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" hightlighting *.tpl
Plug 'mustache/vim-mustache-handlebars'

Plug 'hashivim/vim-terraform'
" post install (yarn install | npm install) then load plugin only for editing supported files
" Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
Plug 'numToStr/Comment.nvim'

" fuzzy search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'rhysd/git-messenger.vim'

" for theme and color and appearance
Plug 'shaunsingh/nord.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
call plug#end()
lua require('Comment').setup()

autocmd!

set nocompatible
" absolute line number ON
"set number
" hybrid line number ON
set nu rnu
set clipboard=unnamedplus
" highlight current lint
set cursorline
:highlight Cursorline cterm=bold ctermbg=black
syntax enable
set fileencoding=utf-8
set title
" enable mouse support
set mouse=a
set splitbelow splitright
set background=dark
set nobackup
" hightlight search result
set hlsearch
set ignorecase
set smartcase

" Indentation using spaces "
" tabstop:	width of tab character
" softtabstop:	fine tunes the amount of whitespace to be added
" shiftwidth:	determines the amount of whitespace to add in normal mode
" expandtab:	when on use space instead of tab
" textwidth:	text wrap width
" autoindent:	autoindent in new line
set tabstop     =4
set softtabstop	=4
set shiftwidth  =4
set expandtab
set textwidth	=79
set laststatus  =2
set scrolloff   =10

" show the matching part of pairs [] {} and () "
set showmatch
set showcmd
" Give more space for displaying messages.
set cmdheight=2
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8
set ai
set ls=2
set autoindent

let mapleader = "\<Space>"

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
let g:gitgutter_max_signs = 2000

" beautify gitMessager popup window
let g:git_messenger_floating_win_opts = { 'border': 'single' }
let g:git_messenger_popup_content_margins = v:false
let g:git_messenger_include_diff = "current"
let g:git_messenger_always_into_popup = v:true

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

"setting color and theme:
colorscheme kanagawa
let g:nord_contrast = v:true
let g:nord_borders = v:true
let g:nord_disable_background = v:false
let g:nord_italic = v:false

"enables Airline for the tab bar and set powerline font
let g:airline_theme='molokai'
let g:airline_powerline_fonts = 1
let g:airline_section_b=''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

set guifont=Hack\ Nerd\ Font:h10

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

"Changing default NERDTree arrows
nnoremap <C-t> :NERDTreeToggle<CR>

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeShowHidden=1

let g:NERDTreeGitStatusWithFlags = 1         
let g:NERDTreeIgnore = ['^node_modules$']
" sync open file with NERDTree
" " Check if NERDTree is open or active
function! IsNERDTreeOpen()        
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufRead * call SyncTree()
" find current open file in nerdtree
map <leader>r :NERDTreeFind<cr>

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-A> :ZoomToggle<CR>

" FZF and Repgrip
nnoremap <silent> <C-f> :Rg<Cr>
nnoremap <silent> <C-p> :Files<Cr>
" command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
let g:fzf_layout = { 'down':  '40%'}

" Use <c-space> to trigger completion.
let g:coc_node_path = '$HOME/.nvm/versions/node/v22.14.0/bin/node'
if has('nvim')
  inoremap <silent><expr> <space-space> coc#refresh()
else
  inoremap <silent><expr> <o-@> coc#refresh()
endif

" https://github.com/neoclide/coc.nvim/issues/3167
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nmap <leader>do <Plug>(coc-codeaction)
nmap <leader>rn <Plug>(coc-rename)

" Brackets autoclose vanilla
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" add language for autocompletion here
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-css',
  \  'coc-eslint',
  \  'coc-prettier',
  \  'coc-go',
  \  'coc-phpls',
  \ ]
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
" command! ZoomToggle call s:ZoomToggle()
nnoremap <leader>ff :call CocAction('runCommand', 'prettier.formatFile')<CR>
"nmap <leader>f  <Plug>(coc-format-selected)

" my custom remap
nnoremap <silent> <S-t> :tabnew<CR>
nmap <leader>b :b#<cr>
nmap <leader>B :Buffers<cr>
" re-source nvim config
nnoremap <leader>sv :source $MYVIMRC<cr>
inoremap jk <ESC>
" split vert
nnoremap <silent> vv <C-w>v 

function! GoFmt()
  let saved_view = winsaveview()
  silent %!gofmt
  if v:shell_error > 0
    cexpr getline(1, '$')->map({ idx, val -> val->substitute('<standard input>', expand('%'), '') })
    silent undo
    cwindow
  endif
  call winrestview(saved_view)
endfunction

command! GoFmt call GoFmt()

" Auto Commands
" augroup auto_commands
" 	autocmd BufWrite *.py call CocAction('format')
"     autocmd BufWritePre *.go GoFmt
" 	autocmd FileType scss setlocal iskeyword+=@-@
" 	" autocmd BufWritePost *.php silent! call PhpCsFixerFixFile()
"     " autocmd BufEnter *.tf* colorscheme kanagawa
" augroup END


" For Terraform
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" for easymotion
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" tmux

" nnoremap <silent> <C-f> :silent !tmux neww tmux-sessionizer<CR>
