set nocompatible              " be iMproved, required
filetype off                  " required
set shell=/bin/bash           " required

" ---------------------------------------------------------------------------
" --------------------------------- vim-plug --------------------------------
" ---------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mhinz/vim-sayonara'
Plug 'mhinz/vim-signify'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'AndrewRadev/linediff.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'SirVer/ultisnips'
Plug 'ervandew/supertab'
Plug 'scrooloose/nerdtree'
Plug 'mhinz/vim-startify'
Plug 'lervag/vimtex'
Plug 'majutsushi/tagbar'
Plug 'Yggdroot/indentLine'
Plug 'scrooloose/nerdcommenter'
Plug 'rhysd/vim-clang-format'
Plug 'ludovicchabant/vim-gutentags'
Plug 'Valloric/YouCompleteMe', {'do': './install.py --clang-completer --system-libclang'}
Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'idanarye/vim-vebugger', {'branch': 'develop'}

call plug#end()
" ---------------------------------------------------------------------------
" -------------------------------- Main VIMRC -------------------------------
" ---------------------------------------------------------------------------
" Set leader for all custom commands (all of them should start with <leader>)
let mapleader = " "
let maplocalleader = " "

map ; f<space>

" Quickly edit/reload this configuration file
nnoremap <leader>rce :e $MYVIMRC<cr>
nnoremap <leader>rcl :so $MYVIMRC<cr>

" Basic must haves
set nocompatible
set hidden                      " hide buffers instead of closing them
set number                      " line numbers
set wildmode=longest,list       " bash like completion in cmndln
set wildmenu
set noerrorbells visualbell t_vb=           " no bells and other noises
autocmd GUIEnter * set visualbell t_vb=     " also disable in GUI

" Indentation
set smarttab                    " Better tabs
set smartindent                 " Inserts new level of indentation
set autoindent                  " Copy indentation from previous line
set tabstop=2                   " Columns a tab counts for
set softtabstop=2               " Columns a tab inserts in insert mode
set shiftwidth=2                " Columns inserted with the reindent operations
set shiftround                  " Always indent by multiple of shiftwidth
set expandtab                   " Always use spaces instead of tabs

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Buffers and Windows
nnoremap <silent> <leader>q :Sayonara!<cr>         " close buffer
nnoremap <silent> gb :bnext<cr>                    " next buffer
nnoremap <silent> gj :bnext<cr>                    " next buffer
nnoremap <silent> gB :bprev<cr>                    " prev buffer
nnoremap <silent> gk :bprev<cr>                    " prev buffer
nnoremap <silent> <leader>V :vertical sb#<cr>      " open buffer in split
nnoremap <tab> <c-w>w           " easier split navigation
nnoremap <bs> <c-w>W
set diffopt+=vertical           " split vertical in diff scenarios
set splitbelow
set completeopt-=preview
nnoremap <silent> <leader>E :lopen<cr>             " open jump list

" ------------- NeoVim specifics -----------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

" ------------- MacVim specifics -----------------
if has("gui_macvim")
  set guifont=SFMono\ Nerd\ Font:h13
  set macmeta
endif

" ------------- Visual Stuff (make it pretty) --------------
syntax enable
set bg=dark
colorscheme solarized8_flat
set guioptions-=r       " remove right scrollbar
set guioptions-=L       " remove left scrollbar
let g:indentLine_color_gui = '#586e75'
set linespace=3
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Invisible characters
nmap <leader>v :set list!<cr>   " Toggle hidden characters
set nolist                      " Hide by default
set listchars=tab:▸\ ,trail:-,extends:>,precedes:<,nbsp:⎵,eol:¬,space:·

" Gutter
highlight clear SignColumn
set signcolumn=yes

if has("gui_running")
  set lines=75 columns=150
endif

" -------------------- Search Commands ---------------------
"  Search and replace
nnoremap <leader>sr :%s/\<<C-r><C-w>\>//g<Left><Left>
" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" --------------- Coding Stuff (mostly C++) ---------------
" Set shortcut for make
nnoremap <leader>B :make!<cr>

" Set Column limit indicator
augroup collumnLimit
  autocmd!
  autocmd BufEnter,WinEnter,FileType cpp
        \ set tw=100
  autocmd BufEnter,WinEnter,FileType cpp
        \ highlight CollumnLimit ctermbg=DarkGrey guibg=#586e75
  let collumnLimit = 101 " feel free to customize
  let pattern =
        \ '\%<' . (collumnLimit+1) . 'v.\%>' . collumnLimit . 'v'
  autocmd BufEnter,WinEnter,FileType cpp
        \ let w:m1=matchadd('CollumnLimit', pattern, -1)
augroup END

" -------------------- Latex Stuff  -----------------------
let g:tex_flavor = "latex"
let g:vimtex_quickfix_mode = 0
let g:vimtex_index_split_width = 40
augroup latexCommands
  autocmd!
  autocmd BufRead,BufNewFile *.tex
        \ let g:indentLine_setConceal=0
  autocmd BufRead,BufNewFile *.tex
        \ imap <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u
  autocmd BufRead,BufNewFile *.tex
        \ nmap <c-f> [s1z=<c-o>
  autocmd BufRead,BufNewFile *.tex
        \ set spell
  autocmd BufRead,BufNewFile *.tex
        \ set spelllang=en_us
  autocmd BufRead,BufNewFile *.tex
        \ set spellfile=~/.vim/myspell.utf-8.add
  autocmd BufRead,BufNewFile *.tex
        \ set tw=110
  " Change this in a project specific file if needed
  autocmd BufReadPre *.tex
        \ let b:vimtex_main = 'main.tex'
augroup END

" --------------------------------------------------------------------
" -------------------------- Package Configs -------------------------
" Version Control
vmap <leader>hgb :<c-u>!hg blame -fundq <c-r>=expand("%:p") <cr> \| sed -n <c-r>=line("'<") <cr>,<c-r>=line("'>") <cr>p <cr>

" Nerdtree
map <C-n> :NERDTreeToggle<cr>
map <C-m> :NERDTreeFind<cr>
let g:NERDTreeWinSize=80
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeShowBookmarks=1

" Tagbar
nnoremap <leader>t :TagbarOpenAutoClose<cr>
let g:tagbar_width = 60
let g:tagbar_sort = 0

" YCM
let g:ycm_confirm_extra_conf = 0
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_always_populate_location_list = 1
let g:ycm_filetype_blacklist = {
      \ 'vim' : 1,
      \ 'gitcommit' : 1,
      \ 'tagbar' : 1,
      \ 'qf' : 1,
      \ 'notes' : 1,
      \ 'markdown' : 1,
      \ 'unite' : 1,
      \ 'text' : 1,
      \ 'vimwiki' : 1,
      \ 'pandoc' : 1,
      \ 'infolog' : 1,
      \ 'mail' : 1
      \}
nnoremap <leader>Y :YcmRestartServer<cr>
nnoremap <leader>yg :YcmCompleter GoTo<cr>
nnoremap <leader>yh :YcmCompleter GoToInclude<cr>
nnoremap <leader>yd :YcmCompleter GoToDeclaration<cr>
nnoremap <leader>yi :YcmCompleter GoToDefinition<cr>
nnoremap <leader>yf :YcmCompleter FixIt<cr>

let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
let g:ycm_key_list_stop_completion = ['<cr>', '<c-y>']

" make YCM compatible with UltiSnips (using supertab)
let g:SuperTabDefaultCompletionType = '<C-j>'

" Ycm + vimtex
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme

" Ultisnips
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
let g:UltiSnipsSnippetsDir="~/.vim/ultisnips"

" Airline
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let g:airline#extensions#tabline#enabled = 1

" NERD Commenter
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
let g:NERDCreateDefaultMappings = 0
nnoremap <silent> <leader>/ :call NERDComment(0, "toggle")<cr>
vnoremap <silent> <leader>/ :call NERDComment(0, "toggle")<cr>
nnoremap <silent> <leader>x :call NERDComment(0, "toggle")<cr>
vnoremap <silent> <leader>x :call NERDComment(0, "toggle")<cr>

" Clangformat
let g:clang_format#detect_style_file = 1
" Use clangformat only on the current scope
autocmd FileType c,cpp,objc vnoremap <buffer>ff :ClangFormat<cr>
function! MyClangFormat()
    let s:pos = getpos( '. ')
    let s:view = winsaveview()
    normal va}ff
    call setpos( '.', s:pos )
    call winrestview( s:view )
endfunc
" map to <Leader>f in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><leader>f :call MyClangFormat()<cr>
autocmd FileType c,cpp,objc nnoremap <buffer><leader>cf :ClangFormat<cr>
" Toggle auto formatting:
nmap <leader>C :ClangFormatAutoToggle<cr>

" Signify
let g:signify_vcs_list = [ 'git', 'hg' ]
let g:signify_disable_by_default = 1
"nnoremap <silent> <leader>si :SignifyToggle<cr>

" Incsearch and Asterisk
let g:incsearch#auto_nohlsearch = 0
nnoremap <Esc><Esc> :<C-u>nohlsearch<CR>
map /  <plug>(incsearch-forward)
map ?  <plug>(incsearch-backward)
map g/  <plug>(incsearch-stay)
map *  <plug>(asterisk-z*)
map #  <plug>(asterisk-z#)
map g* <plug>(asterisk-gz*)
map g# <plug>(asterisk-gz#)
let g:asterisk#keeppos = 1

" Better Whitespace
nmap <leader>sw :StripWhitespace<cr>
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1

" Startify on new buffers
nmap <leader>S :Startify<cr>
let g:startify_change_to_dir = 0
autocmd BufEnter *
  \ if !exists('t:startify_new_tab') && empty(expand('%')) |
  \   let t:startify_new_tab = 1 |
  \   Startify |
  \ endif

" FZF commands
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -g !tags '.shellescape(<q-args>), 1,
  \           fzf#vim#with_preview('right:50%'),
  \   <bang>0)
command! -bang -nargs=* Tags
  \ call fzf#vim#tags(<q-args>,
  \      {'options': '--preview "echo {} | cut -f1 -f3 -f4 -f5 | tr ''\t'' ''\n''  "'})
command! -bang -nargs=* Files
  \ call fzf#run(fzf#wrap({
  \ 'source': 'rg --files',
  \ 'down': '30%',
  \ }))

nnoremap <c-p> :Files<cr>
nnoremap <c-l> :Buffers <cr>
nnoremap <c-k> :BTags <cr>
nnoremap <leader>C :Commands<cr>
nnoremap <leader>H :History: <cr>
nnoremap <leader>P :Tags<cr>
nnoremap <leader>L :Lines <cr>
nnoremap <leader>B :BLines <cr>
nnoremap <leader>rg :Rg<space>
nnoremap <leader>sp :Tags <c-r><c-w><cr>
nnoremap <leader>sl :Lines <c-r><c-w><cr>
nnoremap <leader>sg :Rg <c-r><c-w><cr>
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Gutentags
let g:gutentags_project_root=['.gutctags']
let g:gutentags_cache_dir = $HOME .'/.cache/guten_tags'

" Projectionist
let g:projectionist_heuristics = {
      \ "*": {
      \   "*.cpp": {"alternate": "{}.h"},
      \   "*.h": {"alternate": "{}.cpp"}
      \ }
      \ }
nnoremap <silent> <leader>a :A<cr>
nnoremap <silent> <leader>sa *:A<cr>

" Linediff
vnoremap <silent> <leader>ld :Linediff<cr>
nnoremap <silent> <leader>ldr :LinediffReset<cr>

" Unmap
unmap <cr>

" --------------------------------------------------------------------
" Load project specific .vimrc if required
" --------------------------------------------------------------------
set secure
set exrc

