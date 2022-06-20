" Only do this when not done yet for this buffer
if exists('b:did_ftplugin')
    finish
endif

" Behaves mostly like Python
runtime! ftplugin/python.vim ftplugin/python_*.vim ftplugin/python/*.vim


"
" Folding
"
setlocal foldmethod=expr
setlocal foldexpr=GetSnakemakeFold(v:lnum)

function! GetSnakemakeFold(lnum)
    " fold preamble
    if a:lnum == 1
        return '>1'
    endif

    let thisline = getline(a:lnum)

    " blank lines end folds
    if thisline =~? '\v^\s*$'
        return '-1'
    " start fold on top level rules or python objects
    elseif thisline =~? '\v^(rule|def|checkpoint|class)'
        return '>1'
    elseif thisline =~? '\v^\S'
        if PreviousLineIndented(a:lnum) && NextRuleIndented(a:lnum)
            return '>1'
        endif
    endif

    return '='

endfunction

function! NextRuleIndented(lnum)
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        let thisline = getline(current)
        if thisline =~? '\v^(rule|def|checkpoint|class)'
            return 0
        elseif thisline =~? '\v^\s+(rule|checkpoint)'
            return 1
        endif

        let current += 1
    endwhile

    return 0
endfunction

function! PreviousLineIndented(lnum)
    let current = a:lnum - 1

    while current >= 1
        let thisline = getline(current)
        if thisline =~? '\v^\S'
            return 0
        elseif thisline =~? '\v^\s+\S'
            return 1
        endif

        let current -= 1
    endwhile

    return 0
endfunction


"
" Sections
"
function! s:NextSection(type, backwards, visual)
    if a:visual
        normal! gv
    endif

    if a:type == 1
        let pattern = '\v(^rule|^checkpoint|^def|%^)'
    elseif a:type == 2
        let pattern = '\v\n\zs\n^(rule|checkpoint|def)'
    endif

    if a:backwards
        let dir = '?'
    else
        let dir = '/'
    endif

    execute 'silent normal! ' . dir . pattern . dir . "\r"
endfunction

noremap <script> <buffer> <silent> ]]
        \ :call <SID>NextSection(1, 0, 0)<cr>

noremap <script> <buffer> <silent> [[
        \ :call <SID>NextSection(1, 1, 0)<cr>

noremap <script> <buffer> <silent> ][
        \ :call <SID>NextSection(2, 0, 0)<cr>

noremap <script> <buffer> <silent> []
        \ :call <SID>NextSection(2, 1, 0)<cr>

vnoremap <script> <buffer> <silent> ]]
        \ :<c-u>call <SID>NextSection(1, 0, 1)<cr>

vnoremap <script> <buffer> <silent> [[
        \ :<c-u>call <SID>NextSection(1, 1, 1)<cr>

vnoremap <script> <buffer> <silent> ][
        \ :<c-u>call <SID>NextSection(2, 0, 1)<cr>

vnoremap <script> <buffer> <silent> []
        \ :<c-u>call <SID>NextSection(2, 1, 1)<cr>
