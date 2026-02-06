#NoEnv
#SingleInstance Force
SendMode Input
SetTitleMatchMode, 3

targetTitle := "总索引+十年总目标+RAM"

; 触发热键（可改）：Ctrl+Alt+T
^!t::
    ; 第一步：先打开任务视图（Win+Tab）
    Send, #{Tab}
    Sleep, 2000

    WinGet, hwnd, ID, %targetTitle%

    if (!hwnd) {
        Send, {Esc}
        MsgBox, 48, 提示, 没找到窗口：%targetTitle%
        return
    }

    WinGet, minmax, MinMax, ahk_id %hwnd%
    if (minmax = -1)
        WinRestore, ahk_id %hwnd%

    WinActivate, ahk_id %hwnd%
return
