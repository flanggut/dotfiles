" ------------------------------ VUNDLE Packages ------------------------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-ctrlspace/vim-ctrlspace'
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'
Plugin 'scrooloose/nerdcommenter'

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

" Basic must haves
set nocompatible
set number
set hidden
set wildmode=longest,list
set wildmenu

" Indentation
set smarttab                    " Better tabs
set smartindent                 " Inserts new level of indentation
set autoindent                  " Copy indentation from previous line
set tabstop=4                   " Columns a tab counts for
set softtabstop=4               " Columns a tab inserts in insert mode
set shiftwidth=4                " Columns inserted with the reindent operations
set shiftround                  " Always indent by multiple of shiftwidth
set expandtab                   " Always use spaces instead of tabs

" Search
set hlsearch
set incsearch
set ignorecase

" Buffers and Windows
nnoremap <silent> <leader>q :bdelete<CR>
set diffopt+=vertical           " split vertical in diff scenarios

" ------------- Visual Stuff (make it pretty) --------------
syntax enable
set bg=dark

" GUI
if has("gui_running")
    colorscheme solarized
    set guifont=Meslo\ LG\ S\ for\ Powerline
endif

" Invisible characters
nmap <leader>v :set list!<CR>   " Toggle hidden characters
set nolist                      " Hide by default
set listchars=tab:▸\ ,trail:-,extends:>,precedes:<,nbsp:⎵,eol:¬

" --------------- Coding Stuff (mostly C++) ---------------
" Set shortcut for make
nnoremap <leader>b :make!<CR>

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

" --------------------------------------------------------------------
" -------------------------- Package Configs -------------------------
" YCM
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
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
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']
nnoremap <leader>yd :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>yi :YcmCompleter GoToDefinition<CR>

" CtrlSpace
if executable("ag")
    let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
endif

" Airline
set laststatus=2
if has("gui_running")
    let g:airline_powerline_fonts = 1
    let g:airline_theme='solarized'
    let g:airline#extensions#tabline#enabled = 1
endif

" NERD Commenter
noremap <silent> <leader>/ :call NERDComment(0, "toggle")<CR>
noremap <silent> <leader>c :call NERDComment(0, "toggle")<CR>


