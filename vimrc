set nocompatible
set shell=/bin/bash

" Detect OS
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" ------------- NeoVim specifics -----------------
if has("nvim")
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath=&runtimepath
endif
" ---------------------------------------------------------------------------
" --------------------------------- vim-plug --------------------------------
" ---------------------------------------------------------------------------
" https://github.com/junegunn/vim-plug
" ---------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')
" Some simple defaults
Plug 'tpope/vim-sensible'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'kassio/neoterm'
Plug 'voldikss/vim-floaterm'

" Visual
Plug 'arcticicestudio/nord-vim'
Plug 'ayu-theme/ayu-vim'
Plug 'arzg/vim-colors-xcode'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Buffers and Windows
Plug 'mhinz/vim-startify'
Plug 'majutsushi/tagbar'
Plug 'mhinz/vim-sayonara'
Plug 'vim-scripts/BufOnly.vim'
Plug 'mcchrish/nnn.vim'

" Moving around
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'justinmk/vim-sneak'

" General Editing
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
Plug 'AndrewRadev/linediff.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Yggdroot/indentLine'
Plug 'scrooloose/nerdcommenter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Swift
" Plug 'keith/swift.vim'
Plug 'arzg/vim-swift'

call plug#end()
" ---------------------------------------------------------------------------
" -------------------------------- Main VIMRC -------------------------------
" ---------------------------------------------------------------------------
" Set leader for all custom commands (all of them should start with <leader>)
let mapleader = " "
let maplocalleader = " "

" Quickly reload this configuration file
nnoremap <leader>rcl :so $MYVIMRC<cr>

" Basic must haves
set nocompatible
set hidden                      " hide buffers instead of closing them
set number                      " line numbers
set wildmode=longest,list       " bash like completion in cmndln
set wildmenu
set noerrorbells visualbell t_vb=           " no bells and other noises
autocmd GUIEnter * set visualbell t_vb=     " also disable in GUI
set noshowmode                  " no mode in cmdln
set cmdheight=2
set shortmess+=c
set updatetime=300
set timeoutlen=500
set ttimeoutlen=5

" Indentation
set smarttab                    " Better tabs
set smartindent                 " Inserts new level of indentation
set autoindent                  " Copy indentation from previous line
set tabstop=2                   " Columns a tab counts for
set softtabstop=2               " Columns a tab inserts in insert mode
set shiftwidth=2                " Columns inserted with the reindent operations
set shiftround                  " Always indent by multiple of shiftwidth
set expandtab                   " Always use spaces instead of tabs
autocmd FileType swift setlocal shiftwidth=4 softtabstop=4 expandtab

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Buffers and Windows
nnoremap <silent> <leader>q :Sayonara<cr>
nnoremap <silent> <leader>Q :Sayonara!<cr>
nnoremap <silent> gb :bnext<cr>
nnoremap <silent> gj :bnext<cr>
nnoremap <silent> gB :bprev<cr>
nnoremap <silent> gk :bprev<cr>
nnoremap <silent> <leader>V :vertical sb#<cr>
nnoremap <silent> <leader>bo :BufOnly<cr>
nnoremap <tab> <c-w>w
nnoremap <c-m> <c-i>
nnoremap <bs> <c-w>W
inoremap <c-l> <c-o>$
set diffopt+=vertical           " split vertical in diff scenarios
set splitbelow
set completeopt-=preview
nnoremap <silent> <leader>E :lopen<cr>             " open jump list

" ------------- Visual Stuff (make it pretty) --------------
syntax enable
set bg=dark
set guioptions-=r       " remove right scrollbar
set guioptions-=L       " remove left scrollbar
set linespace=3

" IndentLine {{
let g:indentLine_char = '│'
let g:indentLine_first_char = '│'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_color_gui = '#586e75'
" }}
"

" Colors
" colorscheme nord
" let ayucolor="mirage"
" colorscheme ayu
colorscheme xcodedark
hi Normal ctermfg=white ctermbg=black
hi EndOfBuffer ctermbg=black

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
vnoremap <leader>sr "hy:%s/<C-r>h//gc<left><left><left>

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
        \ setlocal spell
  autocmd BufRead,BufNewFile *.tex
        \ setlocal spelllang=en_us
  autocmd BufRead,BufNewFile *.tex
        \ set spellfile=~/.vim/myspell.utf-8.add
  autocmd BufRead,BufNewFile *.tex
        \ set tw=110
  " Change this in a project specific file if needed
  autocmd BufReadPre *.tex
        \ let b:vimtex_main = 'main.tex'
augroup END

" -------------------- Markdown Stuff  -----------------------
augroup markdownCommands
  autocmd!
  autocmd BufRead,BufNewFile *.md
        \ nmap <c-f> [s1z=<c-o>
  autocmd BufRead,BufNewFile *.md
        \ setlocal spell
  autocmd BufRead,BufNewFile *.md
        \ setlocal spelllang=en_us
augroup END

" Markdown Plugin
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_folding_level = 2
let g:vim_markdown_conceal = 0


" ------------------------------------------------------------------------------
" ------------------------------- Package Configs ------------------------------
" ------------------------------------------------------------------------------

" Floaterm
if g:os == "Darwin"
  let g:floaterm_shell='/usr/local/bin/fish'
elseif g:os == "Linux"
  let g:floaterm_shell='/bin/fish'
endif
let g:floaterm_height=0.7
let g:floaterm_position='bottomright'
nnoremap <silent> <leader>fm :FloatermNew! make<cr>
nnoremap <silent> <c-s> :FloatermToggle<cr>
tnoremap <silent> <c-s> <c-\><c-n>:FloatermToggle<cr>

"  nnn
let g:nnn#layout = { 'window': { 'width': 0.6, 'height': 0.7, 'xoffset': 0.95, 'highlight': 'Debug'} }

" Airline
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='minimalist'

" Neoterm
let g:neoterm_default_mod = 'botright'
let g:neoterm_autoscroll = 1
nnoremap <silent><leader>ter :T fish<cr>

"  vim-sneak
let g:sneak#s_next = 0
let g:sneak#f_reset = 1
let g:sneak#t_reset = 1
let g:sneak#prompt = '> '
let g:sneak#absolute_dir = 0
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T

nmap <expr> N sneak#is_sneaking() ? '<Plug>Sneak_,' : 'N'
nmap <expr> n sneak#is_sneaking() ? '<Plug>Sneak_;' : 'n'
highlight Sneak cterm=bold ctermbg=yellow ctermfg=black

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
autocmd FileType c,cpp,objc nnoremap <buffer><leader>cf :call MyClangFormat()<cr>
autocmd FileType c,cpp,objc nnoremap <buffer><leader>f :ClangFormat<cr>
" Toggle auto formatting:
nmap <leader>C :ClangFormatAutoToggle<cr>

" Signify
let g:signify_vcs_list = [ 'git', 'hg' ]
let g:signify_disable_by_default = 1
nnoremap <silent> <leader>si :SignifyToggle<cr>

" Incsearch and Asterisk
let g:incsearch#auto_nohlsearch = 0
nnoremap <esc><esc> :<C-u>nohlsearch<CR>
" map /  <plug>(incsearch-forward)
" map ?  <plug>(incsearch-backward)
" map g/ <plug>(incsearch-stay)
map *  <plug>(asterisk-z*)
map #  <plug>(asterisk-z#)
map g* <plug>(asterisk-gz*)
map g# <plug>(asterisk-gz#)

" Better Whitespace
nmap <leader>sw :StripWhitespace<cr>
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=0
let g:strip_max_file_size = 10000
let g:strip_whitelines_at_eof=1

" Startify
nmap <leader>S :Startify<cr>
let g:startify_change_to_dir = 0
let g:startify_files_number = 20
let g:startify_lists = [
  \ { 'type': 'files',     'header': ['   MRU']            },
  \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
  \ ]
let g:startify_bookmarks = [ {'c': '~/.vimrc'} ]
let g:startify_enable_special = 0

" FZF
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --no-ignore-messages --column --line-number --no-heading --color=always --smart-case -g !tags '.shellescape(<q-args>), 1,
  \           fzf#vim#with_preview('right:50%'),
  \   <bang>0)
command! -bang -nargs=* Tags
  \ call fzf#vim#tags(<q-args>,
  \      {'options': '--preview "echo {} | cut -f1 -f3 -f4 -f5 | tr ''\t'' ''\n''  "'})
command! -bang -nargs=* FilesRg
  \ call fzf#run(fzf#wrap({
  \ 'source': 'rg --no-ignore-messages --files',
  \ 'down': '30%',
  \ }))

let g:fzf_action = {
  \ 'ctrl-d': 'bdelete',
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let Cmd = get(get(g:, 'fzf_action', default), a:key, default)
  return type(Cmd) == type('') ? Cmd : default
endfunction

function! s:bufopen(lines)
  if len(a:lines) < 2
    return
  endif
  let b = matchstr(a:lines[1], '\[\zs[0-9]*\ze\]')
  let cmd = s:action_for(a:lines[0])
  if !empty(cmd)
    if cmd == 'bdelete'
      execute 'silent' cmd b
      return
    endif
    execute 'silent' cmd
  endif
  execute 'buffer' b
endfunction

function! s:fzf_buffers()
  call fzf#vim#buffers({
  \ 'sink*':   function('s:bufopen'),
  \ 'options': ['+m', '-x', '--tiebreak=index', '--header-lines=1', '--ansi', '-d', '\t', '-n', '2,1..2', '--prompt', 'Buf> ']
  \})
endfunction

function! CreateCenteredFloatingWindow()
    let width = min([&columns - 4, max([80, &columns - 20])])
    let height = min([&lines - 4, max([20, &lines - 10])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    au BufWipeout <buffer> exe 'bw '.s:buf
endfunction

let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }

nnoremap <c-p> :FilesRg<cr>
nnoremap <silent><c-l> :call <sid>fzf_buffers()<cr>
nnoremap <c-k> :BTags <cr>
nnoremap <leader>ll :BLines <cr>
nnoremap <leader>L :Lines <cr>
nnoremap <leader>C :Commands<cr>
nnoremap <leader>H :History: <cr>
nnoremap <leader>P :Tags<cr>
nnoremap <leader>rg :Rg<space>
nnoremap <leader>sp :Tags <c-r><c-w><cr>
nnoremap <leader>sl :Lines <c-r><c-w><cr>
nnoremap <leader>sg :Rg <c-r><c-w><cr>
nnoremap <leader>M :FZFMru<cr>

nmap <leader>lq <Plug>(fzf-quickfix)

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

" Linediff
vnoremap <silent> <leader>ld :Linediff<cr>
nnoremap <silent> <leader>ldr :LinediffReset<cr>

" CoC
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-j>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><c-k> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
au CursorHoldI * sil call CocActionAsync('showSignatureHelp')

command! -nargs=0 Format :call CocAction('format')

nmap <silent> <leader>f :Format<cr>
nmap <silent> <leader>e  <Plug>(coc-diagnostic-next)
nmap <silent> <leader>E  <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>yd <Plug>(coc-declaration)
nmap <silent>      <c-j> <Plug>(coc-definition)
nmap <silent> <leader>yi <Plug>(coc-implementation)
nmap <silent> <leader>yr <Plug>(coc-references)
nmap <silent> <leader>yt <Plug>(coc-type-definition)
nmap <silent> <leader>ya <Plug>(coc-codeaction)
nmap <silent> <leader>yf <Plug>(coc-fix-current)
nmap <silent> <leader>dd :<C-u>CocList diagnostics<cr>

" Other remapping and instant snippets (using F keys in insert mode)
nnoremap <expr> <cr> foldclosed(line('.')) == -1 ? "\<cr>" : "zO"
inoremap <F12> <c-r>=strftime("%Y-%m-%d")<cr>

" --------------------------------------------------------------------
" Load project specific .vimrc if required
" --------------------------------------------------------------------
set secure
set exrc
