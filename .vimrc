let mapleader = " "

set number relativenumber hidden
set shiftwidth=4 softtabstop=4
set path+=** wildmenu
silent! set wildoptions+=fuzzy
set shellpipe=>%s\ 2>&1

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case grepformat=%f:%l:%c:%m
else
    set grepprg=grep\ -rnI\ $*\ .
endif

filetype plugin on
syntax on

if has('termguicolors') && $COLORTERM =~# 'truecolor\|24bit'
    set termguicolors
endif
colorscheme desert
for g in ['Normal', 'LineNr', 'SignColumn', 'EndOfBuffer']
    execute 'hi' g 'ctermbg=NONE guibg=NONE'
endfor

function! s:Ctags() abort
    if has('nvim')
        call jobstart(['ctags', '-R', '.'])
    elseif has('job')
        call job_start(['ctags', '-R', '.'])
    endif
endfunction

function! s:Find(pat) abort
    let glob = a:pat =~ '[*?[]' ? a:pat : '*' . a:pat . '*'
    let cmd = executable('rg') ? 'rg --files -g ' : 'find . -type f -name '
    call setqflist([], ' ', {'title': 'find', 'efm': '%f',
        \ 'lines': systemlist(cmd . shellescape(glob))})
    copen
endfunction
command! -nargs=1 Find call s:Find(<q-args>)

" In a :Find list, <CR> also ticks the entry off.
function! s:QfEnter() abort
    let idx = line('.')
    execute 'cc' idx
    if getqflist({'title': 1}).title ==# 'find'
        let items = getqflist()
        call remove(items, idx - 1)
        call setqflist([], 'r', {'items': items})
    endif
    cclose
endfunction

augroup vimrc
    autocmd!
    if executable('ctags')
        autocmd BufWritePost *.c,*.h,*.cpp,*.hpp,*.go,*.py call s:Ctags()
    endif
    autocmd BufEnter * if isdirectory(expand('<amatch>')) | setlocal nobuflisted | endif
    autocmd QuickFixCmdPost grep cwindow
    autocmd FileType qf nnoremap <buffer> <silent> <CR> :call <SID>QfEnter()<CR>
augroup END

nnoremap <Leader>b :buffers<CR>:buffer<Space>
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>d :bd<CR>
nnoremap <Leader>w :wa<CR>
nnoremap <silent> <Leader>q :qa!<CR>
nnoremap <silent> <Esc> :<C-u>noh<CR>
nnoremap <Leader>g :silent grep!<Space>
nnoremap <Leader>f :Find<Space>
nnoremap <Leader>e :e <C-r>=expand('%:h') =~ '^\.\?$' ? '' : expand('%:h') . '/'<CR>

vnoremap (  <Esc>`>a)<Esc>`<i(<Esc>
vnoremap [  <Esc>`>a]<Esc>`<i[<Esc>
vnoremap {  <Esc>`>a}<Esc>`<i{<Esc>
vnoremap `` <Esc>`>a`<Esc>`<i`<Esc>
vnoremap '' <Esc>`>a'<Esc>`<i'<Esc>
vnoremap "" <Esc>`>a"<Esc>`<i"<Esc>

inoremap <C-Space> <C-x><C-o>
inoremap <C-@>     <C-x><C-o>
