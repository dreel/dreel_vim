

set nocompatible
set background=dark
colorscheme koehler

if has('win32') || has('win64')
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

runtime! autoload/pathogen.vim
silent! call pathogen#helptags()
silent! call pathogen#runtime_append_all_bundles()

if !has('win32') && !has('win64')
  set term=$TERM
endif

filetype plugin indent on
syntax on
set mouse=a
scriptencoding utf-8

set cursorline
hi cursorline guibg=#333333
hi CursorColumn guibg=#333333

if has('statusline')
  set laststatus=2

  set statusline=%<%f\    " Filename
  set statusline+=%w%h%m%r " Options
  set statusline+=%{fugitive#statusline()} "  Git Hotness
  set statusline+=\ [%{&ff}/%Y]            " filetype
  set statusline+=\ [%{getcwd()}]          " current dir
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

set nu
set showmatch
set incsearch
set hlsearch
set winminheight=0

set list
set listchars=tab:>.,trail:.,extends:#,nbsp:. " Highlight problematic whitespace

set autoindent
set shiftwidth=2
set expandtab
set tabstop=2
set softtabstop=2

set switchbuf=split,usetab

" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,php,js,python,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))

" Making it so ; works like : for commands. Saves typing and eliminates :W style typos due to lazy holding shift.
nnoremap ; :

" Easier moving in tabs and windows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_
map <C-K> <C-W>k<C-W>_

function! InitializeDirectories()
  let separator = "."
  let parent = $HOME 
  let prefix = '.vim'
  let dir_list = { 
        \ 'backup': 'backupdir', 
        \ 'views': 'viewdir', 
        \ 'swap': 'directory' }

  for [dirname, settingname] in items(dir_list)
    let directory = parent . '/' . prefix . dirname . "/"
    if exists("*mkdir")
      if !isdirectory(directory)
        call mkdir(directory)
      endif
    endif
    if !isdirectory(directory)
      echo "Warning: Unable to create backup directory: " . directory
      echo "Try: mkdir -p " . directory
    else  
      let directory = substitute(directory, " ", "\\\\ ", "")
      exec "set " . settingname . "=" . directory
    endif
  endfor
endfunction
call InitializeDirectories() 

map <C-e> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
map <leader>e :NERDTreeFind<CR>
nmap <leader>nt :NERDTreeFind<CR>

let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

set directory=$HOME/.vimswap/

if has('gui_running')
  set guioptions-=T             " remove the toolbar
  set lines=40                  " 40 lines of text instead of 24,
  set transparency=5            " Make the window slightly transparent
  set autochdir
else
  set term=builtin_ansi         " Make arrow and other keys work
endif


function! NERDTreeInitAsNeeded()
    redir => bufoutput
    buffers!
    redir END
    let idx = stridx(bufoutput, "NERD_tree")
    if idx > -1
        NERDTreeMirror
        NERDTreeFind
        wincmd l
    endif
endfunction

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
