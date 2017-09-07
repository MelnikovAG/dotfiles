set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" set the runtime path to include NeoBundle and initialize
set rtp+=/Users/henrebotha/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('/Users/henrebotha/.vim/bundle'))
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'slim-template/vim-slim.git'
Plugin 'kchmck/vim-coffee-script'
Plugin 'vim-airline/vim-airline'
Plugin 'chrisbra/NrrwRgn'
Plugin 'tpope/vim-surround'
" Plugin 'vim-syntastic/syntastic'
Plugin 'w0rp/ale'
Plugin 'haya14busa/incsearch.vim'
Plugin 'junegunn/vim-easy-align'
Plugin 'ervandew/supertab'
" Plugin 'wincent/command-t'
Plugin 'elmcast/elm-vim'
Plugin 'gregsexton/MatchTag'
" Plugin 'othree/javascript-libraries-syntax.vim'
Bundle 'vim-ruby/vim-ruby'

" All of your Vundle plugins must be added before the following line
call vundle#end()            " required

" let NeoBundle manage NeoBundle, required
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'joker1007/vim-ruby-heredoc-syntax'

" All of your NeoBundle plugins must be added before the following line
call neobundle#end()         " required

NeoBundleCheck " prompt to install uninstalled bundles

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

syntax enable

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Shortcuts for ale to navigate between errors
" ^k - go to previous error
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" ^j - go to next error
nmap <silent> <C-j> <Plug>(ale_next_wrap)
" Keep gutter open at all times
let g:ale_sign_column_always = 1
" Slow it down a little
let g:ale_lint_delay = 500
" Only enable one JS linter... TODO: find a per-file solution
let g:ale_linters = {
\   'javascript': ['jshint'],
\   'html': [],
\}

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:>\ ,eol:¬,space:-

" " Highlight search results when using `/`
" set hls

" incsearch.vim settings
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" Use C-l to highlight the current cursor position
nnoremap <C-l> :call HighlightNearCursor()<CR>
function HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    unlet s:highlightcursor
  endif
endfunction

" Use 2 spaces per tab
set tabstop=2
set shiftwidth=2

" Use soft tabs
set expandtab

" Make airline actually show up
set laststatus=2

" Enable powerline fonts
let g:airline_powerline_fonts = 1

" Line numbers
set number
set relativenumber

" Show as much as possible of a wrapped last line
set display=lastline

" Wrap at word boundaries, not in the middle of words
set linebreak

" Linter settings
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive' }
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_scss_checkers = ['scss_lint']
let g:syntastic_slim_checkers = []
" Disable Syntastic by default; do :call ActivateSyntastic() to enable. This is
" a startup time optimisation. See
" https://github.com/vim-syntastic/syntastic/issues/91#issuecomment-2888737
" let g:pathogen_disabled = ['syntastic']
" function! ActivateSyntastic() abort
"   set rtp+=~/.vim/bundle/syntastic
"   runtime plugin/syntastic.vim
" endfunction

" Trim trailing whitespace on write
autocmd BufWritePre * %s/\s\+$//e

" Persist undo state across sessions
set undofile
set undodir=$HOME/.vim/undo
set undolevels=1000
set undoreload=10000

" Keybinds for vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Markdown
" Enable syntax highlighting in fenced code blocks
let g:markdown_fenced_languages = ['slim', 'html', 'ruby', 'javascript', 'java', 'clojure', 'erb=eruby', 'coffee', 'xml', 'json', 'sql']

" Enable mouse scrolling inside tmux
set mouse=a

" JS lib syntax
" let g:used_javascript_libs = 'angularjs'

" Enable modelines for tweaking config per file
set modeline
set modelines=5

" Show partially-typed commands in the bottom right
set showcmd
