#if wim_mode == "NORMAL"


; ----------------------------------------------------------------
; Mode change
; ----------------------------------------------------------------

v::GoSub, wim_switchTo_Visual

a::
    Send, {Right}
    GoSub, wim_switchTo_Insert
return

+A::
    Send, {End}
    GoSub, wim_switchTo_Insert
return

i::
    GoSub, wim_switchTo_Insert
return

+I::
    Send, {Home}
    GoSub, wim_switchTo_Insert
return


; TODO others


#if  ; Global context