#if  ; Global context
#SingleInstance force


; ----------------------------------------------------------------
; Init / auto-execute section
; ----------------------------------------------------------------

SetWorkingDir %A_ScriptDir%

; Create empty array
wim_insertIDs := Object()

Gosub, wim_getConfig

; Register the hotkey for switching to Normal mode using the variable from the config
Hotkey, %wim_config_EscModifier%Esc, wim_switchTo_Normal

; Start in Insert mode
Gosub, wim_switchTo_Insert

; Start timer for handling ignored windows
SetTimer, wim_handleWindows, 250

return  ; End of auto-execute section


; ----------------------------------------------------------------
; List of global variables
; ----------------------------------------------------------------

; wim_mode:         String of currently active mode ("INSERT"/"NORMAL"/"VISUAL")
; wim_count:        Number that can be used before a command
; wim_ignore:       Boolean indicator if currently active window is ignored
; wim_insertIDs:    Array with key (HWND) and value (true) of windows that have the insert key mode active


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

wim_handleWindows:
    global wim_ignore
    ; Handle ignored windows
    {
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
    }
    ; Handle text cursor (using insert-key mode which has do be changed in each application separately)
    if(wim_changeTextCursor && wim_isText()) {
        WinGet, active_window, ID, A
        insert_enabled := wim_isInsertKeyModeActive(active_window)
        if((wim_mode == "NORMAL") || (wim_mode == "VISUAL")) {
            ; Enable insert-key mode
            if(!insert_enabled) {
                Send, {Insert}
                wim_setInsertKeyModeActive(active_window, !insert_enabled)
            }
        }
        else {  ; wim_mode == "INSERT"
            ; Disable insert-key mode
            if(insert_enabled) {
                Send, {Insert}
                wim_setInsertKeyModeActive(active_window, !insert_enabled)
            }
        }
    }
return

; Read ini file and save each config value to the corresponding global variable
wim_getConfig:
    global wim_config_EscModifier
    IniRead, wim_config_EscModifier, config.ini, default, EscModifier, +
    
    global wim_config_IgnoredWindows
    IniRead, iniVal, config.ini, default, IgnoredWindows, %A_Space%
    if(iniVal != "") {
        wim_config_IgnoredWindows := StrSplit( iniVal, ",", "`r`n`t ""'``" )
    }
    
    global wim_changeTextCursor
    IniRead, iniVal, config.ini, default, ChangeTextCursor, false
    StringLower, iniVal, iniVal
    wim_changeTextCursor := (iniVal == "true")
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

; Check if the current window has insert key mode active
wim_isInsertKeyModeActive(active_window) {
    global wim_insertIDs
    isInsertKeyModeActive := wim_insertIDs[active_window]
    if(isInsertKeyModeActive != true) {
        isInsertKeyModeActive := false
    }
    return isInsertKeyModeActive
}

; Set/reset insert key mode for active window active
wim_setInsertKeyModeActive(active_window, set) {
    global wim_insertIDs
    if(!wim_isText()) {
        return
    }
    if(set) {
        ; Mode enabled
        wim_insertIDs[active_window] := true
    }
    else {  ; reset
        ; Mode disabled
        wim_insertIDs.Delete(active_window)
    }
}

; Check if current focus is on a text field
wim_isText() {
    ; If current focus is on text, then the caret variable is set, else empty
    return (A_CaretX != "")
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
