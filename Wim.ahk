#if  ; Global context
#SingleInstance force

wim_init( "." )

return  ; End of auto-execution section


; ----------------------------------------------------------------
; List of global variables
; ----------------------------------------------------------------

; wim_dir:      Directory where Wim.ahk is located
; wim_mode:     Currently active mode ("INSERT"/"NORMAL"/"VISUAL")
; wim_count:    Number that can be used before a command


; ----------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------

wim_switchTo_Insert:
    global wim_mode
    wim_useCount()  ; Reset count
    Menu, Tray, Icon, %wim_dir%/icons/I.ico
    wim_mode := "INSERT"
return

wim_switchTo_Normal:
    global wim_mode
    wim_useCount()  ; Reset count
    Send, {Left}
    Menu, Tray, Icon, %wim_dir%/icons/N.ico
    wim_mode := "NORMAL"
return

wim_switchTo_Visual:
    global wim_mode
    wim_useCount()  ; Reset count
    Menu, Tray, Icon, %wim_dir%/icons/V.ico
    wim_mode := "VISUAL"
return


; ----------------------------------------------------------------
; Functions
; ----------------------------------------------------------------

; Init Wim
wim_init( dir ) {
    global wim_dir
    if(wim_dir != "") {
        ; Init already executed, don't do it again
        return
    }
    if(dir == "") {
        dir := "."
    }
    wim_dir := dir
    Gosub, wim_switchTo_Insert
}

; Add/remove count digit and display the count as tray tool tip
wim_handleCount( x ) {
    global wim_count
    if(x >= 0) {
        ; Add digit
        wim_count *= 10
        wim_count += %x%
        
        if(wim_count >= 100) {
            wim_useCount()  ; Reset count
            MsgBox, 0x30, % "Wim: Warning", % "A count of > 99 is discouraged because sending key presses is much slower than native vi(m) features. Count reset.`n`nSee available INI settings to change/disable this limit."
            ; TODO INI setting
        }
    }
    else {
        ; Remove Digit
        if(wim_count < 10) {
            wim_useCount()  ; Reset count
        }
        else {
            ; Delete last digit
            wim_count := Floor( wim_count/10 )
        }
    }
    ; TODO: INI setting for disabling
    if(wim_count > 0) {
        TrayTip,, %wim_count%, 120
    }
}

; Return and reset count, remove tray tool tip
wim_useCount() {
    global wim_count
    if(wim_count == 0) {
        wim_count := 1
    }
    count := wim_count
    wim_count := 0
    TrayTip
    return count
}


; ----------------------------------------------------------------
; Global hotkeys
; ----------------------------------------------------------------

#Esc::Gosub, wim_switchTo_Normal


; ----------------------------------------------------------------
; Modes
; ----------------------------------------------------------------

#include Normal.ahk
#include Insert.ahk
#include Visual.ahk
#include NormalOrVisual.ahk
; Change include dir back to the main script dir (if the user included Wim.ahk from another script)
#include %A_ScriptDir%


#if  ; Global context