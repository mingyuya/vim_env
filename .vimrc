set swapfile
set dir=/users/mingyu.kim/swapfiles
" Important!!
if has('termguicolors')
  set termguicolors
endif
" The configuration options should be placed before `colorscheme sonokai`.
"let g:sonokai_style = 'andromeda'
"let g:sonokai_style = 'shusia'
let g:sonokai_better_performance = 1
colorscheme sonokai
"colorscheme	gruvbox
set background=dark
syntax on
set nu
set selection=inclusive
set lines=60 columns=120
set textwidth=0
set nowrap

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set foldmethod=marker

vnoremap <C-r> "hy:%s/<C-r>h//g

set nocompatible
filetype indent on

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2 
let g:netrw_winsize = 25
let g:netrw_altv = 1
""augroup ProjecDrawer
""  autocmd!
""  autocmd VimEnter * :Vexplore
""augroup END

set diffopt+=iwhite

autocmd BufRead *.txt set tw=0
""autocmd VimEnter * NERDTree | wincmd p
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
"let g:NERDTreeDirArrows = 1
"let g:NERDTreeGlyphReadOnly = "RO"
" Insert file header on new verilog file creation
autocmd bufnewfile *.v,*.vh,*.sv,*.svh so ~/.vim/custom_header/verilog_header.txt
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 8 ."g/File    :.*/s//File    : " .expand("%")
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 8 ."g/Author  :.*/s//Author  : " ."mingyu.kim@ovt.com"
autocmd bufnewfile *.v,*.vh,*.sv,*.svh exe "1," . 8 ."g/Created :.*/s//Created : " .strftime("%c")
autocmd bufnewfile *.csh so ~/.vim/custom_header/csh_header.txt
"autocmd Bufwritepre,filewritepre *.v,*.vh,*.sv,*.svh execute "normal ma"
"autocmd Bufwritepre,filewritepre *.v,*.vh,*.sv,*.svh execute "normal `a"

"map <F9> :Vexplore<CR>
nnoremap <F9> :NERDTreeToggle<CR>

set tags+=$FRONTEND/tags


""-------- Functions ---------
"" HexToDecVisualBlock : \d
"" DecToHexVisualBlock : \h

function! HexToDecVisualBlock()
  " This function is intended for Visual BLOCK mode (Ctrl-v).
  " It converts the selected block *per line*.

  let l:vm = visualmode()
  if l:vm !=# "\<C-v>"
    echoerr "Use Visual BLOCK mode (Ctrl-v) for this mapping."
    return
  endif

  " Save registers we might touch
  let l:save_unnamed = getreg('"')
  let l:save_unnamed_type = getregtype('"')

  " Get visual selection marks
  let l:p1 = getpos("'<")
  let l:p2 = getpos("'>")

  let l:start_l = min([l:p1[1], l:p2[1]])
  let l:end_l   = max([l:p1[1], l:p2[1]])
  let l:start_c = min([l:p1[2], l:p2[2]])
  let l:end_c   = max([l:p1[2], l:p2[2]])
  let l:width   = l:end_c - l:start_c + 1

  " Replace block region line by line
  for lnum in range(l:start_l, l:end_l)
    let l:line = getline(lnum)

    " If the line is shorter than the block start column, skip
    if strlen(l:line) < l:start_c - 1
      continue
    endif

    " Extract the exact block slice (byte-based columns)
    let l:slice = strpart(l:line, l:start_c - 1, l:width)

    " Trim whitespace inside the slice (in case you included spaces)
    let l:hex = substitute(l:slice, '\s\+', '', 'g')
    let l:hex = substitute(l:hex, '^0x', '', 'i')

    " If not a hex token, skip
    if l:hex !~# '^\x\+$'
      continue
    endif

    " Convert hex -> decimal
    let l:dec = string(str2nr(l:hex, 16))

    " Build the new line: prefix + dec + suffix
    let l:prefix = strpart(l:line, 0, l:start_c - 1)
    let l:suffix = strpart(l:line, l:end_c)

    call setline(lnum, l:prefix . l:dec . l:suffix)
  endfor

  " Restore unnamed register
  call setreg('"', l:save_unnamed, l:save_unnamed_type)
endfunction

" Visual-mode mapping: convert selected hex to decimal
vnoremap <leader>d :<C-u>call HexToDecVisualBlock()<CR>


function! DecToHexVisualBlock()
  " Intended for Visual BLOCK mode (Ctrl-v): converts the selected block per line.

  let l:vm = visualmode()
  if l:vm !=# "\<C-v>"
    echoerr "Use Visual BLOCK mode (Ctrl-v) for this mapping."
    return
  endif

  " Options
  "let l:prefix = "0x"   " set to "" if you don't want 0x
  let l:prefix = ""   " set to "" if you don't want 0x
  let l:upper  = 1      " 1 => ABCD, 0 => abcd

  " Save unnamed register
  let l:save_unnamed = getreg('"')
  let l:save_unnamed_type = getregtype('"')

  " Get visual selection marks
  let l:p1 = getpos("'<")
  let l:p2 = getpos("'>")

  let l:start_l = min([l:p1[1], l:p2[1]])
  let l:end_l   = max([l:p1[1], l:p2[1]])
  let l:start_c = min([l:p1[2], l:p2[2]])
  let l:end_c   = max([l:p1[2], l:p2[2]])
  let l:width   = l:end_c - l:start_c + 1

  for lnum in range(l:start_l, l:end_l)
    let l:line = getline(lnum)

    if strlen(l:line) < l:start_c - 1
      continue
    endif

    " Exact block slice
    let l:slice = strpart(l:line, l:start_c - 1, l:width)

    " Clean up the slice
    let l:dec_str = substitute(l:slice, '^\s\+|\s\+$', '', 'g')

    " Accept optional +/-, and digits only
    if l:dec_str !~# '^[+-]\=\d\+$'
      continue
    endif

    let l:dec = str2nr(l:dec_str, 10)

    " Convert to hex string
    let l:hex = l:upper ? printf("%X", l:dec) : printf("%x", l:dec)
    let l:rep = l:prefix . l:hex

    " Replace only the selected columns (block region) on this line
    let l:prefix_part = strpart(l:line, 0, l:start_c - 1)
    let l:suffix_part = strpart(l:line, l:end_c)

    call setline(lnum, l:prefix_part . l:rep . l:suffix_part)
  endfor

  " Restore unnamed register
  call setreg('"', l:save_unnamed, l:save_unnamed_type)
endfunction

" Mapping: Visual Block selection -> decimal to hex
vnoremap <leader>h :<C-u>call DecToHexVisualBlock()<CR>

" ----------------------------
" Custom keymap help (F7)
" ----------------------------
function! s:BuildMyKeyHelp()
  let l:leader = s:GetLeaderString()

  return [
  \ '=== My Custom Keymaps ===',
  \ '',
  \ ' Current Leader key: ' . l:leader,
  \ '',
  \ ' Visual mode:',
  \ '  ' . l:leader . 'd   : Hex -> Dec (Visual BLOCK per-line)',
  \ '  ' . l:leader . 'h   : Dec -> Hex (Visual BLOCK per-line)',
  \ '',
  \ ' Tips:',
  \ '  - Use Ctrl-v (Visual Block) to select only the hex/dec token columns.',
  \ '  - Leader key shown above reflects your current vimrc setting.',
  \ '',
  \ 'Press q to close this window..',
  \ ]
endfunction

function! ShowMyKeyHelp()
  let l:bufname = '[My Key Help]'

  " If the buffer already exists, reuse it
  for b in range(1, bufnr('$'))
    if bufexists(b) && bufname(b) ==# l:bufname
      execute 'botright sbuffer ' . b
      return
    endif
  endfor

  botright new
  execute 'file ' . l:bufname
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setlocal nobuflisted nowrap nonumber norelativenumber
  setlocal foldcolumn=0

  " Fill contents (example)
  call setline(1, s:BuildMyKeyHelp())

  " Make it read-only
  setlocal nomodifiable readonly

  " Set a dedicated filetype so we can attach syntax rules
  setlocal filetype=mykeyhelp

  " Close with q
  nnoremap <silent><buffer> q :close<CR>
endfunction

nnoremap <silent> <F12> :call ShowMyKeyHelp()<CR>

augroup MyKeyHelpSyntax
  autocmd!
  autocmd FileType mykeyhelp call s:MyKeyHelpHighlight()
augroup END

function! s:MyKeyHelpHighlight() abort
  " Enable syntax in this buffer
  syntax clear

  " Headline lines like: === Something ===
  syntax match MyKeyHelpTitle /^===.\+===$/

  " Section headers like: Visual mode:
  syntax match MyKeyHelpSection /^[A-Za-z][A-Za-z0-9 ]\+:\s*$/

  " Key tokens like: <leader>d, <F7>, Ctrl-v, \d
  syntax match MyKeyHelpKey /\v(<[^>]+>|\\\w|Ctrl-\w|C-v|F\d{1,2})/

  " Hex numbers like: 0x1A, deadBEEF
  syntax match MyKeyHelpHex /\v(0x)?[0-9A-Fa-f]{2,}/

  " Inline note lines starting with: -  (tips)
  syntax match MyKeyHelpBullet /^\s*-\s\+.*$/

  " Link syntax groups to standard highlight groups (theme-friendly)
  highlight default link MyKeyHelpTitle   Title
  highlight default link MyKeyHelpSection Statement
  highlight default link MyKeyHelpKey     Special
  highlight default link MyKeyHelpHex     Number
  highlight default link MyKeyHelpBullet  Comment
endfunction

function! s:GetLeaderString()
  if exists('g:mapleader') && g:mapleader !=# ''
    let l:leader = g:mapleader
  else
    let l:leader = '\'
  endif

  " Make special keys readable
  if l:leader ==# ' '
    return '<Space>'
  endif

  return l:leader
endfunction

