#if !wim_ignore && (wim_mode == "NORMAL")


; ----------------------------------------------------------------
; Mode change
; ----------------------------------------------------------------

v::Gosub, wim_switchTo_Visual

a::
    wim_moveOnSameLine("Right")
    Gosub, wim_switchTo_Insert
return

+A::
    Send, {End}
    Gosub, wim_switchTo_Insert
return

i::
    Gosub, wim_switchTo_Insert
return

+I::
    Send, {Home}
    Gosub, wim_switchTo_Insert
return

o::
    Send, {End}
    Send, {Enter}
    Gosub, wim_switchTo_Insert
return

+O::
    Send, {Home}
    Send, {Enter}
    Send, {Up}
    Gosub, wim_switchTo_Insert
return


; ----------------------------------------------------------------
; Movement
; ----------------------------------------------------------------

h::
    count := wim_useCount()
    Send, {Left %count%}
return

-::
NumpadSub::
j::
    count := wim_useCount()
    Send, {Down %count%}
return

+::
NumpadAdd::
k::
    count := wim_useCount()
    Send, {Up %count%}
return

l::
    count := wim_useCount()
    Send, {Right %count%}
return

w::
    count := wim_useCount()
    Send, ^{Right %count%}
return

b::
    count := wim_useCount()
    Send, ^{Left %count%}
return

; TODO: ^^

$::
    Send, {End}
    wim_moveOnSameLine("Left")
    wim_useCount()  ; Reset count
return

; TODO: gg

+G::
    Send, ^{End}
    Send, {Home}
    wim_useCount()  ; Reset count
return

^Enter::
    count := wim_useCount()
    Send, {Down %count%}
return


; ----------------------------------------------------------------
; Others
; ----------------------------------------------------------------

u::Send, ^z

^r::Send, ^y

.::
NumpadDot::
    count := wim_useCount()
    Send, {Del %count%}
return

/::
NumpadDiv::
    Send, ^f
    ; We change to insert mode so the user can instantly input text
    Gosub, wim_switchTo_Insert
return

Enter::
NumpadEnter::
    caretY := A_CaretY
    if(caretY == "") {
        ; No text cursor present, in that special case still send enter key to be able to interract with windows
        Send, {Enter}
    }
    else {
        count := wim_useCount()
        Send, {Down %count%}
    }
return


#if  ; Global context
