#if !wim_ignore && ((wim_mode == "NORMAL") || (wim_mode == "VISUAL"))


; ----------------------------------------------------------------
; Block keys and combinations
; ----------------------------------------------------------------

#include KeyBlocking.ahk


; ----------------------------------------------------------------
; Mode change
; ----------------------------------------------------------------

; When we already are in normal or Visual mode, we can also use Esc without modifier
Esc::Gosub, wim_switchTo_Normal


; ----------------------------------------------------------------
; Count prefix
; ----------------------------------------------------------------

0::wim_handleCount(0)
1::wim_handleCount(1)
2::wim_handleCount(2)
3::wim_handleCount(3)
4::wim_handleCount(4)
5::wim_handleCount(5)
6::wim_handleCount(6)
7::wim_handleCount(7)
8::wim_handleCount(8)
9::wim_handleCount(9)
$Delete::
    if(wim_count == 0) {
        Send, {Delete}
    }
    else {
        wim_handleCount(-1)
    }
return


#if  ; Global context