" ------------------------------ VUNDLE Packages ------------------------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-ctrlspace/vim-ctrlspace'
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'
Plugin 'scrooloose/nerdcommenter'
Plugin 'majutsushi/tagbar'
Plugin 'rhysd/vim-clang-format'
Plugin 'Yggdroot/indentLine'
Plugin 'mhinz/vim-signify'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/vim-asterisk'
Plugin 'lervag/vimtex'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'SirVer/ultisnips'
Plugin 'ervandew/supertab'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" ---------------------------------------------------------------------------
" -------------------------------- Main VIMRC -------------------------------
" ---------------------------------------------------------------------------
" Set leader for all custom commands (all of them should start with <leader>)
let mapleader = " "
let maplocalleader = " "

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

" Buffers and Windows
nnoremap <silent> <leader>q :bdelete<cr>    " close buffer
nnoremap <silent> gb :bnext<cr>             " next buffer
nnoremap <silent> gj :bnext<cr>             " next buffer
nnoremap <silent> gB :bprev<cr>             " prev buffer
nnoremap <silent> gk :bprev<cr>             " prev buffer
nnoremap <tab> <c-w>w           " easier split navigation
nnoremap <bs> <c-w>W
set diffopt+=vertical           " split vertical in diff scenarios
set splitbelow                  "  below
set completeopt-=preview

" ------------- Visual Stuff (make it pretty) --------------
syntax enable
set bg=dark
colorscheme solarized
set guioptions-=r       " remove right scrollbar
set guioptions-=L       " remove left scrollbar
set guifont=SFMono\ Nerd\ Font:h13
let g:indentLine_color_gui = '#586e75'
set linespace=3

" Invisible characters
nmap <leader>v :set list!<cr>   " Toggle hidden characters
set nolist                      " Hide by default
set listchars=tab:▸\ ,trail:-,extends:>,precedes:<,nbsp:⎵,eol:¬,space:·

" Gutter
highlight clear SignColumn
set signcolumn=yes

" --------------- Coding Stuff (mostly C++) ---------------
" Set shortcut for make
nnoremap <leader>b :make!<cr>

" Set Column limit indicator
augroup collumnLimit
  autocmd!
  autocmd BufEnter,WinEnter,FileType cpp
        \ highlight CollumnLimit ctermbg=DarkGrey guibg=#586e75
  let collumnLimit = 81 " feel free to customize
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
" Tagbar
nnoremap <leader>t :TagbarOpenAutoClose<cr>
let g:tagbar_width = 60

" YCM
let g:ycm_confirm_extra_conf = 0
let g:ycm_add_preview_to_completeopt = 1
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
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
let g:UltiSnipsSnippetsDir="~/.vim/ultisnips"

" CtrlSpace
if executable("ag")
    let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
endif
nnoremap <silent><c-p> :CtrlSpace O<cr>

" Airline
set laststatus=2
if has("gui_running")
    let g:airline_powerline_fonts = 1
    let g:airline_theme='solarized'
    let g:airline#extensions#tabline#enabled = 1
endif

" NERD Commenter
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
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
nnoremap <silent> <leader>si :SignifyToggle<cr>

" Incsearch and Asterisk
let g:incsearch#auto_nohlsearch = 1
map /  <plug>(incsearch-forward)
map ?  <plug>(incsearch-backward)
map g/ <plug>(incsearch-stay)
map n  <plug>(incsearch-nohl-n)
map N  <plug>(incsearch-nohl-N)
map *  <plug>(incsearch-nohl)<plug>(asterisk-*)
map #  <plug>(incsearch-nohl)<plug>(asterisk-#)
map g* <plug>(incsearch-nohl)<plug>(asterisk-g*)
map g# <plug>(incsearch-nohl)<plug>(asterisk-g#)
map z*  <plug>(incsearch-nohl0)<plug>(asterisk-z*)
map gz* <plug>(incsearch-nohl0)<plug>(asterisk-gz*)
map z#  <plug>(incsearch-nohl0)<plug>(asterisk-z#)
map gz# <plug>(incsearch-nohl0)<plug>(asterisk-gz#)
let g:asterisk#keeppos = 1

" Better Whitespace
nmap <leader>sw :StripWhitespace<cr>

" --------------------------------------------------------------------
" Load project specific .vimrc if required
" --------------------------------------------------------------------
set secure
set exrc

