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


; ----------------------------------------------------------------
; Movement
; ----------------------------------------------------------------

h::
    count := wim_useCount()
    Send, {Left %count%}
return

j::
    count := wim_useCount()
    Send, {Down %count%}
return

k::
    count := wim_useCount()
    Send, {Up %count%}
return

l::
    count := wim_useCount()
    Send, {Right %count%}
return

; TODO: ^^

$::
    Send, {End}
    Send, {Left}
    wim_useCount()  ; Reset count
return

; TODO: gg

+G::
    Send, ^{End}
    Send, {Home}
    wim_useCount()  ; Reset count
return


; TODO others


#if  ; Global context