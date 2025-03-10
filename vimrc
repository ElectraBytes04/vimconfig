set nocompatible

let MyStatusLine='- %f %m %=Line:%l/%L Col:%c -'
set laststatus=2
set statusline=%!MyStatusLine

set termguicolors
colorscheme iceberg

set showtabline=0
set number
set relativenumber
set colorcolumn=80,100,120
set nofoldenable

syntax enable
filetype plugin on
set tabstop=4 shiftwidth=4

set mouse=

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

highlight ALEError   guifg=#E27878 guibg=NONE    gui=underline cterm=underline
highlight ALEWarning guifg=#ECCC96 guibg=NONE    gui=underline cterm=underline
highlight ALEInfo    guifg=#84A0C6 guibg=NONE    gui=underline cterm=underline
highlight ALEHint    guifg=#A1EFD3 guibg=NONE    gui=underline cterm=underline

" Spell

hi! link SpellBad   ALEError
hi! link SpellCaps  ALEWarning
hi! link SpellRare  ALEInfo
hi! link SpellLocal ALEHint

" augroups

 augroup WikiMarkdown
 	autocmd Filetype mediawiki,markdown set wrap
	autocmd Filetype mediawiki,markdown set linebreak
 	autocmd Filetype mediawiki,markdown set textwidth=100
 	autocmd Filetype mediawiki,markdown set formatoptions+=t
 	autocmd Filetype mediawiki,markdown set conceallevel=2
 	autocmd Filetype mediawiki,markdown highlight conceal guibg=NONE
 	autocmd Filetype mediawiki,markdown let g:vim_markdown_folding_disabled = 1
 	autocmd Filetype mediawiki,markdown let g:vim_markdown_math = 1
 	autocmd Filetype mediawiki,markdown let g:vim_markdown_conceal=1            
 
 	autocmd Filetype markdown setlocal spell spelllang=en_us
 augroup END

" Custom functions

" Create 3 40 column margins on either side
function! SetupCenterLayout()
	vsp
	vertical resize 27
	enew
	setlocal statusline=-%=-
	wincmd l
	vsp
	wincmd l
	vertical resize 27
	enew
	setlocal statusline=-%=-
	wincmd h
	setlocal colorcolumn=100
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
