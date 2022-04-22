if exists('g:loaded_cirque') || &cp
    finish
endif
let g:loaded_cirque = 1
let g:cirque_locked = 0

if !get(g:, 'cirque_disable_at_vimenter') && (!has('nvim') || has('nvim-0.3.5'))
    " Only for Nvim v0.3.5+: https://github.com/neovim/neovim/issues/9885
    set shortmess+=I
endif

augroup cirque
    autocmd VimEnter    * nested call s:on_vimenter()
    autocmd VimLeavePre * nested call s:on_vimleavepre()
    autocmd QuickFixCmdPre  *vimgrep* let g:cirque_locked = 1
    autocmd QuickFixCmdPost *vimgrep* let g:cirque_locked = 0
augroup END

function! s:update_oldfiles(file)
    if g:cirque_locked || !exists('v:oldfiles')
        return
    endif
    let idx = index(v:oldfiles, a:file)
    if idx != -1
        call remove(v:oldfiles, idx)
    endif
    call insert(v:oldfiles, a:file, 0)
endfunction

function! s:on_vimenter()
    if !argc() && line2byte('$') == -1
        if get(g:, 'cirque_session_autoload') && filereadable('Session.vim')
            source Session.vim
        elseif !get(g:, 'cirque_disable_at_vimenter')
            call cirque#insane_in_the_membrane(1)
        endif
    endif
    if get(g:, 'cirque_update_oldfiles')
        call map(v:oldfiles, 'fnamemodify(v:val, ":p")')
        autocmd cirque BufNewFile,BufRead,BufFilePre *
                    \ call s:update_oldfiles(expand('<afile>:p'))
    endif
    autocmd! cirque VimEnter
endfunction

function! s:on_vimleavepre()
    if get(g:, 'cirque_session_persistence')
                \ && exists('v:this_session')
                \ && filewritable(v:this_session)
        call cirque#session_write(fnameescape(v:this_session))
    endif
endfunction

command! -nargs=? -bar -bang -complete=customlist,cirque#session_list CLoad   call cirque#session_load(<bang>0, <f-args>)
command! -nargs=? -bar -bang -complete=customlist,cirque#session_list CSave   call cirque#session_save(<bang>0, <f-args>)
command! -nargs=? -bar -bang -complete=customlist,cirque#session_list CDelete call cirque#session_delete(<bang>0, <f-args>)
command! -nargs=0 -bar CClose call cirque#session_close()
command! -nargs=0 -bar Cirque call cirque#insane_in_the_membrane(0)
command! -nargs=0 -bar CirqueDebug call cirque#debug()

nnoremap <silent><plug>(cirque-open-buffers) :<c-u>call cirque#open_buffers()<cr>
