"     |||||         |||||  |   |     |   | ||||| || || ||||  |||||
"    |             |   |  |   |      |   |   |   | | | |   | |
"   ||||   |||||  |   |  |||||       |   |   |   |   | ||||  |
"  |             |   |      |         | |    |   |   | |   | |
" |||||         |||||      |           |   ||||| |   | |   | |||||

" |-------------------------------============-------------------------------|
" |                               Vim Settings                               |
" |-------------------------------============-------------------------------|


set nocompatible

syntax enable
silent! set filetype plugin indent on

set termguicolors
colorscheme iceberg

" --- Editor Settings ---
set number
set relativenumber
set showcmd
set showtabline=0
set colorcolumn=80,100,120
set nofoldenable

set mouse=

" --- Text Settings ---
set wrap
set textwidth=80
set tabstop=6
set shiftwidth=6
set noexpandtab


" |---------------------------------=======----------------------------------|
" |                                 Plugins                                  |
" |---------------------------------=======----------------------------------|


" --- Plugin Installs ---
call plug#begin()

Plug 'tribela/vim-transparent'

Plug 'tpope/vim-fugitive'

Plug 'dense-analysis/ale'

Plug 'rust-lang/rust.vim'

Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'

Plug 'lervag/wiki.vim'
Plug 'm-pilia/vim-mediawiki'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

call plug#end()


" /-/-/ Plugin Configs \-\-\

" --- Wiki.vim ---
let g:wiki_root = "~/wiki"
let g:wiki_filetypes = ['wiki', 'wikt']

" --- ALE ---
let g:ale_linters = {'rust': ['analyzer'], 'python': ['flake8']}

let g:ale_set_signs = 0

highlight ALEError   guifg=#E27878 guibg=NONE gui=underline cterm=underline
highlight ALEWarning guifg=#ECCC96 guibg=NONE gui=underline cterm=underline
highlight ALEInfo    guifg=#84A0C6 guibg=NONE gui=underline cterm=underline
highlight ALEHint    guifg=#A1EFD3 guibg=NONE gui=underline cterm=underline

" --- Spell ---
hi! link SpellBad   ALEError
hi! link SpellCap   ALEWarning
hi! link SpellRare  ALEInfo
hi! link SpellLocal ALEHint


" |--------------------------------==========--------------------------------|
" |                                Statusline                                |
" |--------------------------------==========--------------------------------|


function! LinterStatus() abort
	let l:counts = ale#statusline#Count(bufnr(''))

	let l:all_error = l:counts.error + l:counts.style_error
	let l:all_warning = l:counts.warning + l:counts.style_warning
	let l:all_info = l:counts.info

	if l:all_error > l:all_warning && l:all_error > l:all_info
		hi SLLintColor guifg=#17171b guibg=#E27878
	elseif l:all_warning > l:all_info && l:all_warning > l:all_error
		hi SLLintColor guifg=#17171b guibg=#ECCC96
	elseif l:all_info > l:all_error && l:all_info > l:all_warning
		hi SLLintColor guifg=#17171b guibg=#84A0C6
	else
		hi! link SLLintColor StatusLine
	en

	return printf(
	\ '%dE : %dW : %dI',
	\ all_error,
	\ all_warning,
	\ all_info
	\)
endfunction

let MyStatusLine=' %f %#Folded# %y%m %#SpecialKey#
				\ %=%#Folded# L: %L c: %c %#SLLintColor# %{LinterStatus()} '

set laststatus=2
set statusline=%!MyStatusLine


" |-------------------------------============-------------------------------|
" |                               AutoCommands                               |
" |-------------------------------============-------------------------------|


" /-/-/ FileType Rules \-\-\

autocmd BufNew,BufNewFile,BufRead *.wikt setlocal filetype=mediawiki

augroup WikiMarkdown
   	autocmd Filetype mediawiki,markdown set wrap
	autocmd Filetype mediawiki,markdown set linebreak
 	autocmd Filetype mediawiki,markdown set textwidth=80
 	autocmd Filetype mediawiki,markdown set formatoptions+=t
 	autocmd Filetype mediawiki,markdown set conceallevel=2
 	autocmd Filetype mediawiki,markdown highlight conceal guibg=NONE
	autocmd Filetype mediawiki,markdown let g:vim_markdown_folding_disabled=1
 	autocmd Filetype mediawiki,markdown let g:vim_markdown_math=1
 	autocmd Filetype mediawiki,markdown let g:vim_markdown_conceal=1
augroup END


" |------------------------------===============-----------------------------|
" |                              CustomFunctions                             |
" |------------------------------===============-----------------------------|


function! SetupCenterLayout()
	" Center window content, creating two margins on either side. The center
	" width is locked to 85 columns (accounting for textoff) and the margins are
	" set to the size of the remaining space / 2.

	let l:win_info = getwininfo(win_getid())
	let l:win_width = l:win_info[0]['width']
	let l:total_margin = max([l:win_width - 85, 0])
	let l:margin_single = (l:total_margin / 2)

	let l:margin_single = float2nr(l:margin_single)

	execute "vsp"
	execute "vertical resize " . l:margin_single
	enew
	setlocal winfixwidth
	setlocal statusline=%#SpecialKey#-%=-

	wincmd l

	execute "vsp"
	wincmd l
	execute "vertical resize " . l:margin_single
	enew
	setlocal winfixwidth
	setlocal statusline=%#SpecialKey#-%=-

	wincmd h

	setlocal colorcolumn=80
	setlocal statusline=%!MyStatusLine
endfunction

function! CloseCenterLayout()
	" Close margins created by StartCenterLayout().
	only
	set statusline=%!MyStatusLine
	set colorcolumn=80,100,120
endfunction

function! BrowserView()
	" View files as HTML on browser.
	" Base code by subhadip, adapted by me.
	execute "silent !" . "pandoc " . "%:p" . " -o " . "%:p" . ".html"
	execute "silent !" . "python3 -m webbrowser -t " . "%:p" . ".html"
	call getchar()
	if has('win32')
		execute "silent !" . "del " . "%:p" . ".html"
	else
		execute "silent !" . "rm " . "%:p" . ".html"
	endif
	execute "redraw!"
endfunction

function! CopyFileContents(source_file_path)
	" Copy entire contents of the source_file_path to current open file.
	let l:source_file_path = expand(a:source_file_path)

	echo l:source_file_path
	execute "r! cat " . l:source_file_path
	execute "1delete"
endfunction


" |----------------------------------======----------------------------------|
" |                                  Remaps                                  |
" |----------------------------------======----------------------------------|


" --- Normal Vim ---
nnoremap <localleader>v :call BrowserView()<cr>


" /-/-/ Plugins \-\-\

" --- FZF ---
nnoremap <localleader>fz :FZF<cr> 

" --- Wiki.vim ---
nnoremap <localleader>wb :WikiLinkReturn<cr>


" /-/-/ Commands \-\-\

command! SCenterLayout :call SetupCenterLayout()
command! CCenterLayout :call CloseCenterLayout()

command! -nargs=+ CopyFileContents :silent! call CopyFileContents(<f-args>)
