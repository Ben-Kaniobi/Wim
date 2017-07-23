#if !wim_ignore && (wim_mode == "VISUAL")


; ----------------------------------------------------------------
; Mode change
; ----------------------------------------------------------------

v::Gosub, wim_switchTo_Normal

~LButton::Gosub, wim_switchTo_Normal

~MButton::Gosub, wim_switchTo_Normal

~RButton::Gosub, wim_switchTo_Normal


; ----------------------------------------------------------------
; Movement
; ----------------------------------------------------------------

h::
    count := wim_useCount()
    Send, +{Left %count%}
return

j::
    count := wim_useCount()
    Send, +{Down %count%}
return

k::
    count := wim_useCount()
    Send, +{Up %count%}
return

l::
    count := wim_useCount()
    Send, +{Right %count%}
return

; TODO: ^^

$::
    Send, +{End}
    Send, +{Left}
    wim_useCount()  ; Reset count
return

; TODO: gg

+G::
    Send, +^{End}
    Send, +{Home}
    wim_useCount()  ; Reset count
return


; TODO others


#if  ; Global context
