" NOTE: You must, of course, install the ack script
"       in your path.
" On Debian / Ubuntu:
"   sudo apt-get install ack-grep
" On your vimrc:
"   let g:ackprg="ack-grep -H --nocolor --nogroup --column"
"
" With MacPorts:
"   sudo port install p5-app-ack

" Location of the ack utility
if !exists("g:ackprg")
    let g:ackprg="ack -H --nocolor --nogroup --column"
endif

function! s:Ack(cmd, args, count)
    redraw
    echo "Searching ..."

    if a:count > 0
        " then we've selected something in visual mode
        let l:grepargs = shellescape(s:LastSelectedText())
    elseif empty(a:args)
        " If no pattern is provided, search for the word under the cursor
        let l:grepargs = expand("<cword>")
    else
        let l:grepargs = a:args
    end

    " Format, used to manage column jump
    if a:cmd =~# '-g$'
        let g:ackformat="%f"
    else
        let g:ackformat="%f:%l:%c:%m"
    end

    let grepprg_bak=&grepprg
    let grepformat_bak=&grepformat
    try
        let &grepprg=g:ackprg
        let &grepformat=g:ackformat
        silent execute a:cmd . " " . l:grepargs
    finally
        let &grepprg=grepprg_bak
        let &grepformat=grepformat_bak
    endtry

    if a:cmd =~# '^l'
        botright lopen
    else
        botright copen
    endif

    " TODO: Document this!
    exec "nnoremap <silent> <buffer> q :ccl<CR>"
    exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
    exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
    exec "nnoremap <silent> <buffer> o <CR>"
    exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"

    " If highlighting is on, highlight the search keyword.
    if exists("g:ackhighlight")
        let @/=a:args
        set hlsearch
    end

    redraw!
endfunction

function! s:AckFromSearch(cmd, args)
    let search =  getreg('/')
    " translate vim regular expression to perl regular expression.
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    call s:Ack(a:cmd, '"' .  search .'" '. a:args)
endfunction

function! s:AckOption(bang, ...)
    for option in a:000
        let remove      = (a:bang == '!')
        let base_option = substitute(option, '^no', '', '')
        let pattern     = '\v\s+--(no)?\V'.base_option

        if remove
            let replacement = ''
        else
            let replacement = ' --'.option
        endif

        if g:ackprg =~ pattern
            let g:ackprg = substitute(g:ackprg, pattern, replacement, '')
        else
            let g:ackprg .= ' --'.option
        endif
    endfor

    echo 'Ack called as: '.g:ackprg
endfunction

function! s:AckIgnore(bang, ...)
    for directory in a:000
        silent call s:AckOption(a:bang, 'ignore-dir="' . directory . '"')
    endfor

    echo 'Ack called as: '.g:ackprg
endfunction

function! s:LastSelectedText()
    let saved_cursor = getpos('.')

    let original_reg      = getreg('z')
    let original_reg_type = getregtype('z')

    normal! gv"zy
    let text = @z

    call setreg('z', original_reg, original_reg_type)
    call setpos('.', saved_cursor)

    return text
endfunction

command! -bang -nargs=* -complete=file -range=0 Ack call s:Ack('grep<bang>',<q-args>, <count>)
command! -bang -nargs=* -complete=file AckAdd call s:Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFromSearch call s:AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAck call s:Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAckAdd call s:Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFile call s:Ack('grep<bang> -g', <q-args>)

command! -bang -nargs=*                AckOption call s:AckOption('<bang>', <f-args>)
command! -bang -nargs=* -complete=file AckIgnore call s:AckIgnore('<bang>', <f-args>)

" vim: sw=4
