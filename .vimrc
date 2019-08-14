colorscheme	koehler
syntax		on
set nu
set selection=inclusive

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set foldmethod=marker

set nocompatible
filetype indent on
"set autoindent

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
"Plugin 'scrooloose/syntastic'
"Plugin 'scrooloose/nerdtree'
"Plugin 'terryma/vim-mulitple-cursors'

call vundle#end()
filetype plugin indent on

" Syntastic
"_set statusline+=%#warningmsg#
"_set statusline+=%{SyntasticStatuslineFlag()}
"_set statusline+=%*
"_
"_let g:syntastic_always_populate_loc_list = 1
"_let g:syntastic_auto_loc_list = 1
"_let g:syntastic_check_on_open = 1
"_let g:syntastic_check_on_wq = 0

" vim-multiple-cursor
"_let g:multi_cursor_use_default_mapping=0
"_
"_let g:multi_cursor_next_key='<C-n>'
"_let g:multi_cursor_prev_key='<C-p>'
"_let g:multi_cursor_skip_key='<C-x>'
"_let g:multi_cursor_quit_key='<Esc>'

" insert file header on new file creation: verilog type
autocmd bufnewfile *.v,*.vh,*.sv,*.svh so ~/.vim/custom_header/verilog_header.txt
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 6 ."g/File name      :.*/s//File name      : " .expand("%")
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 6 ."g/Description    :.*/s//Description    : " 
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 6 ."g/Created by     :.*/s//Created by     : " ."mingyu0.kim@lge.com"
autocmd Bufwritepre,filewritepre *.v,*.vh,*.sv,*.svh execute "normal ma"
autocmd Bufwritepre,filewritepre *.v,*.vh,*.sv,*.svh exe "1," . 6 ."g/Last modified  :.*/s//Last modified  : " .strftime("%c")
autocmd Bufwritepre,filewritepre *.v,*.vh,*.sv,*.svh execute "normal `a"

" insert 1st line to new c-shell file
autocmd bufnewfile *.ch so ~/.vim/custom_header/cshell.txt

" Move to the instantiation
map <F12> ? u_?
^<CR>

" Set module name finder
map <F11> ma?^\s*\<module\><CR>Wyiw'a:echo "module ->" @0<CR>

" Set NerdTree
map <F9> :NERDTreeToggle<CR>
let g:NERDTreeDirArrows=0
"let NERDTreeIgnore=['.o$']

" Set TagList
map <F10> :Tlist<CR>

"set tags+=/user/mgkim0/project/1_y-lens/CHIP/rtl/tags
