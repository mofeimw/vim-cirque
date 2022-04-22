if exists("b:current_syntax")
    finish
endif

let s:sep = cirque#get_separator()
let s:padding_left = repeat(' ', get(g:, 'cirque_padding_left', 3))

syntax sync fromstart

execute 'syntax match CirqueBracket /.*\%'. (len(s:padding_left) + 6) .'c/ contains=
            \ CirqueNumber,
            \ CirqueSelect'
syntax match CirqueSpecial /\V<empty buffer>\|<quit>/
syntax match CirqueNumber  /^\s*\[\zs[^BSVT]\{-}\ze\]/
syntax match CirqueSelect  /^\s*\[\zs[BSVT]\{-}\ze\]/
syntax match CirqueVar     /\$[^\/]\+/
syntax match CirqueFile    /.*/ contains=
            \ CirqueBracket,
            \ CirquePath,
            \ CirqueSpecial,

execute 'syntax match CirqueSlash /\'. s:sep .'/'
execute 'syntax match CirquePath /\%'. (len(s:padding_left) + 6) .'c.*\'. s:sep .'/ contains=CirqueSlash,CirqueVar'

execute 'syntax region CirqueHeader start=/\%1l/ end=/\%'. (len(g:cirque_header) + 2) .'l/'

if exists('g:cirque_custom_footer')
    execute 'syntax region CirqueFooter start=/\%'. cirque#get_lastline() .'l/ end=/\_.*/'
endif

if exists('b:cirque.section_header_lines')
    for line in b:cirque.section_header_lines
        execute 'syntax region CirqueSection start=/\%'. line .'l/ end=/$/'
    endfor
endif

highlight default link CirqueBracket Delimiter
highlight default link CirqueFile    Identifier
highlight default link CirqueFooter  Title
highlight default link CirqueHeader  Title
highlight default link CirqueNumber  Number
highlight default link CirquePath    Directory
highlight default link CirqueSection Statement
highlight default link CirqueSelect  Title
highlight default link CirqueSlash   Delimiter
highlight default link CirqueSpecial Comment
highlight default link CirqueVar     CirquePath

let b:current_syntax = 'cirque'
