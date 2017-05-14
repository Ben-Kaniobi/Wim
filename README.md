Wim
===

Vim-like keyboard shortcuts for Windows, using [AutoHotkey](https://www.autohotkey.com/).


How to use
==========

1. [Get AutoHotkey](https://www.autohotkey.com/download/)
2. Run it with the script as argument, e.g.: `AutoHotkeyU64.exe "path\to\Wim.ahk"`
3. The script starts in *insert* mode. To switch to *normal* mode, press `[Win]`+`[Esc]` (that way `[Esc]` can still be used where needed instead of accidentally switching mode).


Including *Wim.ahk* in an other script
====================================

If you want to include *Wim.ahk* in an other script (e.g. your main script that loads others), then you can do that like this:

1. Include the directory where *Wim.ahk* is located (relative or absolute)
2. Include *Wim.ahk*

example:

    #include Wim
    #include Wim.ahk

Also you'll have to call the function `wim_init` in your auto-execute section, with the directory where *Wim.ahk* is located as argument, e.g.:

    wim_init( "Wim" )

But please keep in mind that Wim changes the system tray icon and might have other unwanted side effects, therefore **I recommend running it separately**.