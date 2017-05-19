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

; Start timer for handling ignored windows
SetTimer, wim_handleIgnoredWindows, 250

return  ; End of auto-execute section


; ----------------------------------------------------------------
; List of global variables
; ----------------------------------------------------------------

; wim_mode:     String of currently active mode ("INSERT"/"NORMAL"/"VISUAL")
; wim_count:    Number that can be used before a command
; wim_ignore:   Boolean indicator if currently active window is ignored


; ----------------------------------------------------------------
; List of global config variables read from INI file
; ----------------------------------------------------------------

; wim_config_EscModifier:       Modifier for switching to Normal mode with {Esc}
; wim_config_IgnoredWindows:    Array of windows where hotkeys are disabled


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
    wim_moveOnSameLine("Left")
    Menu, Tray, Icon, icons/N.ico
    wim_mode := "NORMAL"
return

wim_switchTo_Visual:
    global wim_mode
    wim_useCount()  ; Reset count
    Menu, Tray, Icon, icons/V.ico
    wim_mode := "VISUAL"
return

wim_handleIgnoredWindows:
    global wim_ignore
    wim_ignore_old := wim_ignore
    wim_ignore := wim_isExeFromListActive()
    if(!wim_ignore_old && wim_ignore) {
        Menu, Tray, Icon, icons/X.ico
    }
    else if(wim_ignore_old && !wim_ignore) {
        ; Restore icon
        if(wim_mode == "INSERT") {
            Menu, Tray, Icon, icons/I.ico
        }
        if(wim_mode == "NORMAL") {
            Menu, Tray, Icon, icons/N.ico
        }
        if(wim_mode == "VISUAL") {
            Menu, Tray, Icon, icons/V.ico
        }
    }
return

; Read ini file and save each config value to the corresponding global variable
wim_getConfig:
    global wim_config_EscModifier
    IniRead, wim_config_EscModifier, config.ini, default, EscModifier
    
    global wim_config_IgnoredWindows
    IniRead, iniVal, config.ini, default, IgnoredWindows
    if(iniVal == "") {
        ; No ignore windows specified in config, timer not needed
        SetTimer, wim_handleIgnoredWindows, Off
    }
    else {
        wim_config_IgnoredWindows := StrSplit( iniVal, ",", "`r`n`t ""'``" )
    }
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

; Check if the executable of the currently active window is on the ignore list
wim_isExeFromListActive() {
    global wim_config_IgnoredWindows
    isExeActive := false
    Loop % wim_config_IgnoredWindows.Length() {
        isExeActive |= WinActive("ahk_exe " . wim_config_IgnoredWindows[A_Index])
    }
    return isExeActive
}

; Move text cursor left/right while avoiding wrapping to previous/next line
wim_moveOnSameLine(direction) {
    if((direction != "Left") && (direction != "Right")) {
        return
    }
    caretY := A_CaretY
    if(caretY == "") {
        ; No text cursor present, don't move
        return
    }
    else {
        Send, {%direction%}
    }
    if(A_CaretY != caretY) {
        ; Text cursor wrapped to another line, reverse
        if(direction == "Left") {
            Send, {Right}
        }
        else {  ; direction == "Right"
            Send, {Left}
        }
    }
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