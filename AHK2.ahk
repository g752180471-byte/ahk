#Requires AutoHotkey v2.0
#Include OCR.ahk

; ==============================
; 参数检查
; ==============================
if (A_Args.Length < 4) {
    A_Clipboard := "ERROR: NO_ARGS"
    ExitApp()
}

; 第5个参数：mode = "number"(默认) 或 "text"
mode := (A_Args.Length >= 5) ? A_Args[5] : "number"

try {
    x := Integer(A_Args[1])
    y := Integer(A_Args[2])
    w := Integer(A_Args[3])
    h := Integer(A_Args[4])
} catch {
    A_Clipboard := "ERROR: INVALID_ARG_TYPE"
    ExitApp()
}

; ==============================
; 显示截图区域（可视化）
; ==============================
ShowDimOverlay(x, y, w, h, 700)

; ==============================
; OCR 识别
; ==============================
try {
    result := OCR.FromRect(x, y, w, h)

    if IsObject(result)
        text := result.Text
    else
        text := result

    ; 根据模式处理结果
    if (mode = "text") {
        ; 提取所有文字（可选：去除多余空白）
        processedText := Trim(text)
        
        if (processedText != "")
            A_Clipboard := processedText
        else
            A_Clipboard := "NOT_FOUND"
    }
    else {  ; 默认 mode = "number"
        ; 提取数字
        digits := RegExReplace(text, "\D", "")
        
        if (digits != "")
            A_Clipboard := digits
        else
            A_Clipboard := "NOT_FOUND"
    }

} catch Any as e {
    A_Clipboard := "ERROR: " . e.Message
}

ExitApp()

; ==============================
; 函数区
; ==============================
ShowDimOverlay(x, y, w, h, duration := 600) {
    dim := Gui("+AlwaysOnTop -Caption +ToolWindow")
    dim.BackColor := "Black"
    dim.Show("x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight)
    WinSetTransparent(140, dim)

    highlight := Gui("+AlwaysOnTop -Caption +ToolWindow")
    highlight.BackColor := "Yellow"
    highlight.Show(Format("x{} y{} w{} h{}", x, y, w, h))
    WinSetTransparent(200, highlight)

    Sleep(duration)

    highlight.Destroy()
    dim.Destroy()
}