"==============================================================================
" Identify platform
"------------------------------------------------------------------------------
silent function! FTKmacOS()
    return has('macunix')
endfunction
silent function! FTKLinux()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! FTKWindows()
    return  (has('win32') || has('win64'))
endfunction


"==============================================================================
" Basics
"------------------------------------------------------------------------------
set nocompatible        " Must be first line
if !FTKWindows()
    set shell=zsh
endif


"==============================================================================
" Windows Compatible
"------------------------------------------------------------------------------
" Use '.vim' instead of 'vimfiles' on Windows
if FTKWindows()
    set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif


"==============================================================================
" Arrow Key Fix
"------------------------------------------------------------------------------
" https://github.com/spf13/spf13-vim/issues/780
" TODO: Check if this issue still exists
if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
    inoremap <silent> <C-[>OC <RIGHT>
endif


"==============================================================================
" Use before config if available
"------------------------------------------------------------------------------
if filereadable(expand("~/.vimrc.pre"))
    source ~/.vimrc.pre
endif


"==============================================================================
" Use plugins config
"------------------------------------------------------------------------------
if filereadable(expand("~/.vimrc.plugins"))
    source ~/.vimrc.plugins
endif


"==============================================================================
" General
"------------------------------------------------------------------------------
set background=dark

" Allow to trigger background
function! FTKToggleBG()
    let s:tbg = &background
    if s:tbg == "dark"
        set background=light
    else
        set background=dark
    endif
endfunction
noremap <leader>bg :call FTKToggleBG()<CR>

filetype plugin indent on   " Automatically detect file types.
syntax on                   " Syntax highlighting
set mouse=a                 " Automatically enable mouse usage
set mousehide               " Hide the mouse cursor while typing
scriptencoding utf-8

if has('clipboard')
    if has('unnamedplus')  " When possible use + register for copy-paste
        set clipboard=unnamed,unnamedplus
    else         " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
    endif
endif

set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore             " Allow for cursor beyond last character
set history=1000                    " Store a ton of history (default is 20)
set hidden                          " Allow buffer switching without saving
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator

" Set the cursor to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Restore cursor to file position in previous editing session
" To disable this, add the following to your .vimrc.before.local file:
"   let g:spf13_no_restore_cursor = 1
function! FTKResCur()
    if line("'\"") <= line("$")
        silent! normal! g`"
        return 1
    endif
endfunction

augroup ftkResCur
    autocmd!
    autocmd BufWinEnter * call FTKResCur()
augroup END

" Setting up the directories
set backup
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

" Add exclusions to mkview and loadview
" eg: *.*, svn-commit.tmp
let g:skipview_files = [
    \ '\[example pattern\]'
    \ ]

" Complete
set complete-=i


"==============================================================================
" Vim UI
"------------------------------------------------------------------------------
if filereadable(expand(g:ftk_plugin_dir . "/vim-colors-solarized/colors/solarized.vim"))
    let g:solarized_termcolors=256
    let g:solarized_termtrans=1
    let g:solarized_contrast="normal"
    let g:solarized_visibility="normal"
    color solarized
endif

set tabpagemax=15               " Only show 15 tabs
set showmode                    " Display the current mode

set cursorline                  " Highlight current line

highlight clear SignColumn      " SignColumn should match background
highlight clear LineNr          " Current line number row will have same background color in relative mode
"highlight clear CursorLineNr    " Remove highlight color from current line number

if has('cmdline_info')
    set ruler                   " Show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    set showcmd                 " Show partial commands in status line and
                                " Selected characters/lines in visual mode
endif

if has('statusline')
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\                     " Filename
    set statusline+=%w%h%m%r                 " Options
    if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
        set statusline+=%{fugitive#statusline()} " Git Hotness
    endif
    set statusline+=\ [%{&ff}/%Y]            " Filetype
    set statusline+=\ [%{getcwd()}]          " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
set number                      " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set breakindent
set breakindentopt=shift:2,min:30,sbr
set showbreak=»
set foldmethod=syntax
set nofoldenable
set completeopt=menu,longest
set previewheight=3


"==============================================================================
" Formatting
"------------------------------------------------------------------------------
set autoindent                  " Indent at the same level of the previous line
set shiftwidth=4                " Use indents of 4 spaces
set expandtab                   " Tabs are spaces, not tabs
set tabstop=4                   " An indentation every four columns
set softtabstop=4               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
"set matchpairs+=<:>             " Match, to be used with %
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
"set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
"autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
" preceding line best in a plugin but here for now.

autocmd BufNewFile,BufRead *.coffee set filetype=coffee

autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4


"==============================================================================
" Key (re)Mappings
"------------------------------------------------------------------------------
let maplocalleader = '_'

" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Code folding options
nmap <leader>f0 :set foldlevel=0<CR>
nmap <leader>f1 :set foldlevel=1<CR>
nmap <leader>f2 :set foldlevel=2<CR>
nmap <leader>f3 :set foldlevel=3<CR>
nmap <leader>f4 :set foldlevel=4<CR>
nmap <leader>f5 :set foldlevel=5<CR>
nmap <leader>f6 :set foldlevel=6<CR>
nmap <leader>f7 :set foldlevel=7<CR>
nmap <leader>f8 :set foldlevel=8<CR>
nmap <leader>f9 :set foldlevel=9<CR>

" Toggle search highlighting rather than clear the current
" search results.
nmap <silent> <leader>/ :set invhlsearch<CR>

" Find merge conflict markers
map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

" Shortcuts
" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Some helpers to edit mode
" http://vimcasts.org/e/14
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Adjust viewports to the same size
map <Leader>= <C-w>=

" Map <Leader>ff to display all lines with keyword under cursor
" and ask which one to jump to
nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Easier horizontal scrolling
map zl zL
map zh zH

" Easier formatting
nnoremap <silent> <leader>q gwip

" Preview window
nnoremap <Leader>ta :set completeopt+=preview<CR>
nnoremap <Leader>at :set completeopt-=preview<CR>

" Colorcolumn
nnoremap <Leader>88 :set cc=80<CR>
nnoremap <Leader>89 :set cc=<CR>


"==============================================================================
" Plugins
"------------------------------------------------------------------------------
" nerdtree
if isdirectory(expand(g:ftk_plugin_dir . '/nerdtree'))
    let g:NERDShutUp=1

    if isdirectory(expand(g:ftk_plugin_dir . '/vim-nerdtree-tabs'))
        map <Leader>ee <plug>NERDTreeTabsToggle<CR>
    else
        map <Leader>ee :NERDTreeToggle<CR>
    endif

    let NERDTreeShowBookmarks=1
    let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
    let NERDTreeChDirMode=0
    let NERDTreeQuitOnOpen=1
    let NERDTreeMouseMode=2
    let NERDTreeShowHidden=1
    let NERDTreeKeepTreeInNewTab=1
    let g:nerdtree_tabs_open_on_gui_startup=0

    " Initialize NERDTree as needed {
    function! FTKNERDTreeInitAsNeeded()
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
endif

" vim-airline
if isdirectory(expand(g:ftk_plugin_dir . '/vim-airline-themes'))
    if !exists('g:airline_theme')
        let g:airline_theme = 'solarized'
    endif
endif

if isdirectory(expand(g:ftk_plugin_dir . '/vim-airline'))
    let g:airline_skip_empty_sections = 1
    nnoremap <Leader>ae :let w:airline_skip_empty_sections = 1<CR>
    nnoremap <Leader>ea :let w:airline_skip_empty_sections = 0<CR>
    nnoremap <Leader>aa :AirlineRefresh<CR>
endif

" Monota
if isdirectory(expand(g:ftk_plugin_dir . "/Monota"))
    let g:monotaDarkColorScheme = "Monota"
    let g:monotaLightColorScheme = "MonotaLight"

    nnoremap <Leader>scd :MonotaSetDarkColorScheme<CR>
    nnoremap <Leader>scl :MonotaSetLightColorScheme<CR>

    call monota#SetColorScheme('dark')
endif

" vim-signify
if isdirectory(expand(g:ftk_plugin_dir . "/vim-signify"))
    let g:signify_sign_add = '+'
    let g:signify_sign_delete = '-'
    let g:signify_sign_change = '*'
endif


"==============================================================================
" GUI Settings
"------------------------------------------------------------------------------
if has('gui_running')
    set guioptions-=T           " Remove the toolbar
    set guioptions-=l           " Remove left-hand scrollbar
    set guioptions-=L           " Remove left-hand scrollbar
    set guioptions-=r           " Remove right-hand scrollbar
    set guioptions-=R           " Remove right-hand scrollbar
    if FTKmacOS() && has("gui_running")
        set guifont=SF\ Mono:h12
        set linespace=1
    elseif FTKLinux() && has("gui_running")
        set guifont=Ubuntu\ Mono\ 13
    elseif FTKWindows() && has("gui_running")
        set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
    endif
else
    if &term == 'xterm' || &term == 'screen'
        set t_Co=256
    endif
endif


"==============================================================================
" Functions
"------------------------------------------------------------------------------
" Initialize directories
function! FTKInitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }

    if has('persistent_undo')
        let dir_list['undo'] = 'undodir'
    endif

    if exists('g:ftk_storage_directory')
        let common_dir = g:ftk_storage_directory . '/' . prefix
    else
        let common_dir = parent . '/.' . prefix
    endif

    for [dirname, settingname] in items(dir_list)
        let directory = common_dir . dirname . '/'
        if exists("*mkdir")
            if !isdirectory(directory)
                call mkdir(directory, 'p')
            endif
        endif
        if !isdirectory(directory)
            echo "Warning: Unable to create backup directory: " . directory
            echo "Try: mkdir -p " . directory
        else
            let directory = substitute(directory, " ", "\\\\ ", "g")
            exec "set " . settingname . "=" . directory
        endif
    endfor
endfunction

call FTKInitializeDirectories()

" Strip whitespace
function! FTKStripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction


"==============================================================================
" Use local vimrc if available
"------------------------------------------------------------------------------
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif


"==============================================================================
" Use local gvimrc if available and gui is running
"------------------------------------------------------------------------------
if has('gui_running')
    if filereadable(expand("~/.gvimrc.local"))
        source ~/.gvimrc.local
    endif
endif
