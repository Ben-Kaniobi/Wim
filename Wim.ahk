#if  ; Global context
#SingleInstance force


; ----------------------------------------------------------------
; Init / auto-execute section
; ----------------------------------------------------------------

SetWorkingDir %A_ScriptDir%

Gosub, wim_getConfig

; Register the hotkey for switching to Normal mode using the variable from the config
Hotkey, %wim_config_EscModifier%Esc, wim_switchTo_Normal

; Start in Insert mode
Gosub, wim_switchTo_Insert

return  ; End of auto-execute section


; ----------------------------------------------------------------
; List of global variables
; ----------------------------------------------------------------

; wim_mode:     Currently active mode ("INSERT"/"NORMAL"/"VISUAL")
; wim_count:    Number that can be used before a command


; ----------------------------------------------------------------
; List of global config variables read from INI file
; ----------------------------------------------------------------

; wim_config_EscModifier:       Modifier for switching to Normal mode with {Esc}


; ----------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------

wim_switchTo_Insert:
    global wim_mode
    wim_useCount()  ; Reset count
    Menu, Tray, Icon, icons/I.ico
    wim_mode := "INSERT"
return

wim_switchTo_Normal:
    global wim_mode
    wim_useCount()  ; Reset count
    Send, {Left}
    Menu, Tray, Icon, icons/N.ico
    wim_mode := "NORMAL"
return

wim_switchTo_Visual:
    global wim_mode
    wim_useCount()  ; Reset count
    Menu, Tray, Icon, icons/V.ico
    wim_mode := "VISUAL"
return

; Read ini file and save each config value to the corresponding global variable
wim_getConfig:
    global wim_config_EscModifier
    IniRead, wim_config_EscModifier, config.ini, default, EscModifier
return


; ----------------------------------------------------------------
; Functions
; ----------------------------------------------------------------

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
; Modes
; ----------------------------------------------------------------

; Set include dir to script dir
#include %A_ScriptDir%

#include Normal.ahk
#include Insert.ahk
#include Visual.ahk
#include NormalOrVisual.ahk


#if  ; Global context