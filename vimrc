set nocompatible

set termguicolors
colorscheme iceberg

set showtabline=0
set number
set relativenumber
set colorcolumn=80,100,120
set nofoldenable

set wrap
set textwidth=80

syntax enable
filetype plugin on
set tabstop=4 shiftwidth=4

set mouse=

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

" Plugins

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

" Wiki.vim
let g:wiki_root = "~/wiki"
let g:wiki_filetypes = ['wiki']

" ALE

let g:ale_linters = {'rust': ['analyzer'], 'python': ['flake8']}

let g:ale_set_signs = 0

highlight ALEError   guifg=#E27878 guibg=NONE gui=underline cterm=underline
highlight ALEWarning guifg=#ECCC96 guibg=NONE gui=underline cterm=underline
highlight ALEInfo    guifg=#84A0C6 guibg=NONE gui=underline cterm=underline
highlight ALEHint    guifg=#A1EFD3 guibg=NONE gui=underline cterm=underline

" Spell

hi! link SpellBad   ALEError
hi! link SpellCap   ALEWarning
hi! link SpellRare  ALEInfo
hi! link SpellLocal ALEHint

" augroups

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

" Custom functions

" Create 3 40 column margins on either side
function! SetupCenterLayout()
	vsp
	vertical resize 44
	enew
	setlocal statusline=%#SpecialKey#-%=-
	wincmd l
	vsp
	wincmd l
	vertical resize 44
	enew
	setlocal statusline=%#SpecialKey#-%=-
	wincmd h
	setlocal colorcolumn=80
	setlocal statusline=%!MyStatusLine
endfunction

" Close margins
function! CloseCenterLayout()
	only
	set statusline=%!MyStatusLine
	set colorcolumn=80,100,120
endfunction

command! SCenterLayout :call SetupCenterLayout()
command! CCenterLayout :call CloseCenterLayout()

" View markdown files as HTML on browser
" Base code by subhadip, adapted by me
function! MarkdownView()
	execute "silent !" . "pandoc " . "%:p" . " -o " . "%:p" . ".html"
	execute "silent !" . "python -m webbrowser " . "%:p" . ".html"
	call getchar()
	if has('win32')
		execute "silent !" . "del " . "%:p" . ".html"
	else
		execute "silent !" . "rm " . "%:p" . ".html"
	endif
endfunction

nnoremap <localleader>v :call MarkdownView()<cr>
