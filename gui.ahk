; ----------------------------
; History input GUI (function library)
; 返回值：输入框的文本（未输入/取消则返回空字符串）
; 可选：ByRef outNumber 输出绑定数字
; ----------------------------

HistoryInput_State := ""

HistoryInput_Get(ByRef outNumber := "", bindNumber := "", iniPath := "") {
    global HistoryInput_State, HistoryInput_userText, BindNumInput

    if (IsObject(HistoryInput_State) && HistoryInput_State.Active)
        return ""

    HistoryInput_State := {}
    HistoryInput_State.Active := true
    HistoryInput_State.Done := false
    HistoryInput_State.SelectedText := ""
    HistoryInput_State.BoundNumber := 0
    HistoryInput_State.Cancelled := true

    if (iniPath = "") {
        SplitPath, A_LineFile,, scriptDir
        iniPath := scriptDir . "\HistoryConfig.ini"
    }
    Section := "FrequencyHistory"

    HistoryInput_State.IniFile := iniPath
    HistoryInput_State.Section := Section
    HistoryInput_State.items := {}
    HistoryInput_State.textToId := {}
    HistoryInput_State.maxId := 0
    HistoryInput_State.maxKeep := 1000
    HistoryInput_State.BindInputProvided := false
    HistoryInput_State.BindInputNumber := 0

    ; ----------------------------
    ; 读取历史（新格式：item_ID=count|last|num<TAB>escapedText）
    ; ----------------------------
    IniRead, AllItems, %iniPath%, %Section%
    if (AllItems != "ERROR" && AllItems != "") {
        Loop, Parse, AllItems, `n, `r
        {
            line := A_LoopField
            if (line = "")
                continue

            if RegExMatch(line, "^item_(\d+)=([0-9]+)\|([0-9]{14})\|(-?\d+)`t(.*)$", m) {
                id := m1 + 0
                cnt := m2 + 0
                last := m3
                num := m4 + 0
                txt := UnescapeText(m5)

                HistoryInput_State.items[id] := { text: txt, count: cnt, last: last, num: num }
                HistoryInput_State.textToId[txt] := id
                if (id > HistoryInput_State.maxId)
                    HistoryInput_State.maxId := id
            } else if RegExMatch(line, "^item_(\d+)=([0-9]+)`t(.*)$", m) {
                ; 兼容旧格式：count<TAB>text（无 last/num 字段）
                id := m1 + 0
                cnt := m2 + 0
                txt := UnescapeText(m3)
                last := A_Now
                num := 0

                HistoryInput_State.items[id] := { text: txt, count: cnt, last: last, num: num }
                HistoryInput_State.textToId[txt] := id
                if (id > HistoryInput_State.maxId)
                    HistoryInput_State.maxId := id
            } else if RegExMatch(line, "^item_(\d+)=([0-9]+)\|([0-9]{14})`t(.*)$", m) {
                ; 兼容中间格式：count|last<TAB>text（无 num 字段）
                id := m1 + 0
                cnt := m2 + 0
                last := m3
                txt := UnescapeText(m4)
                num := 0

                HistoryInput_State.items[id] := { text: txt, count: cnt, last: last, num: num }
                HistoryInput_State.textToId[txt] := id
                if (id > HistoryInput_State.maxId)
                    HistoryInput_State.maxId := id
            }
        }
    }

    ; ----------------------------
    ; 绑定数字输入来源（外部）
    ; 优先级：函数参数 bindNumber > 全局变量 BindNumInput
    ; ----------------------------
    if (bindNumber != "" && RegExMatch(Trim(bindNumber), "^-?\d+$")) {
        HistoryInput_State.BindInputNumber := bindNumber + 0
        HistoryInput_State.BindInputProvided := true
    } else {
        extNum := Trim(BindNumInput)
        if RegExMatch(extNum, "^-?\d+$") {
            HistoryInput_State.BindInputNumber := extNum + 0
            HistoryInput_State.BindInputProvided := true
        }
    }

    ; 组装下拉列表（按频率倒序）
    TempSort := ""
    for id, data in HistoryInput_State.items
        TempSort .= data.count . "|" . id . "`n"

    Sort, TempSort, N R
    HistoryList := ""
    Loop, Parse, TempSort, `n, `r
    {
        if (A_LoopField = "")
            continue
        StringSplit, p, A_LoopField, |
        id := p2 + 0
        HistoryList .= HistoryInput_State.items[id].text . "|"
    }

    ; ----------------------------
    ; GUI
    ; ----------------------------
    Gui, HistoryInput:New, +AlwaysOnTop -MinimizeBox +LabelHistoryInput +HwndhGui, 输入记录
    HistoryInput_State.GuiHwnd := hGui
    Gui, HistoryInput:Font, s10, Microsoft YaHei
    Gui, HistoryInput:Add, Text, x20 y16, 输入或选择内容：
    Gui, HistoryInput:Add, Button, x110 y44 w80 h30 Default gHistoryInput_Submit, 保 存
    Gui, HistoryInput:Add, Button, x210 y44 w80 h30 gHistoryInput_Close, 关 闭
    Gui, HistoryInput:Add, ComboBox, vHistoryInput_userText x20 y84 w360 r10, %HistoryList%
    Gui, HistoryInput:Show, Center w400 h170, 输入记录
    WinActivate, ahk_id %hGui%
    WinWait, ahk_id %hGui%,, 2
    if (ErrorLevel) {
        HistoryInput_State.Active := false
        ErrorLevel := 1
        return ""
    }

    ; 预选最高频的第一项，并自动展开下拉
    firstItem := GetFirstItem(HistoryList)
    if (firstItem != "")
        GuiControl, HistoryInput:ChooseString, HistoryInput_userText, %firstItem%
    GuiControl, HistoryInput:Focus, HistoryInput_userText
    Sleep, 50
    GuiControlGet, hCombo, HistoryInput:Hwnd, HistoryInput_userText
    if (hCombo)
        SendMessage, 0x14F, 1, 0,, ahk_id %hCombo% ; CB_SHOWDROPDOWN

    ; 等待用户提交或关闭
    WinWaitClose, ahk_id %hGui%

    outNumber := HistoryInput_State.BoundNumber
    result := HistoryInput_State.SelectedText
    HistoryInput_State.Active := false
    ErrorLevel := HistoryInput_State.Cancelled ? 1 : 0
    return result
}

HistoryInput_Submit() {
    global HistoryInput_State, HistoryInput_userText

    Gui, HistoryInput:Submit
    userText := NormalizeText(HistoryInput_userText)
    if (userText = "") {
        HistoryInput_State.SelectedText := ""
        HistoryInput_State.BoundNumber := 0
        HistoryInput_State.Cancelled := true
        HistoryInput_State.Done := true
        Gui, HistoryInput:Destroy
        return
    }

    if (HistoryInput_State.textToId.HasKey(userText)) {
        id := HistoryInput_State.textToId[userText]
        HistoryInput_State.items[id].count := HistoryInput_State.items[id].count + 1
        HistoryInput_State.items[id].last := A_Now
        ; 有外部数字就覆盖绑定；没有就保持原绑定
        if (HistoryInput_State.BindInputProvided)
            HistoryInput_State.items[id].num := HistoryInput_State.BindInputNumber
        HistoryInput_State.BoundNumber := HistoryInput_State.items[id].num
    } else {
        id := HistoryInput_State.maxId + 1
        HistoryInput_State.maxId := id
        ; 新文字：有数字就绑定该数字；没数字默认 0
        numVal := HistoryInput_State.BindInputProvided ? HistoryInput_State.BindInputNumber : 0
        HistoryInput_State.items[id] := { text: userText, count: 1, last: A_Now, num: numVal }
        HistoryInput_State.textToId[userText] := id
        HistoryInput_State.BoundNumber := numVal
    }
    HistoryInput_State.SelectedText := userText
    HistoryInput_State.Cancelled := false

    TrimToRecent(HistoryInput_State.items, HistoryInput_State.textToId, HistoryInput_State.maxKeep)

    ; 全量回写，避免旧数据残留
    IniDelete, % HistoryInput_State.IniFile, % HistoryInput_State.Section
    for id, data in HistoryInput_State.items
    {
        safeText := EscapeText(data.text)
        value := data.count . "|" . data.last . "|" . data.num . "`t" . safeText
        IniWrite, %value%, % HistoryInput_State.IniFile, % HistoryInput_State.Section, % "item_" id
    }

    ; 对外输出：供其他脚本读取
    IniWrite, % HistoryInput_State.SelectedText, % HistoryInput_State.IniFile, Runtime, LastText
    IniWrite, % HistoryInput_State.BoundNumber, % HistoryInput_State.IniFile, Runtime, LastNumber

    HistoryInput_State.Done := true
    Gui, HistoryInput:Destroy
}

HistoryInput_Close() {
    global HistoryInput_State
    HistoryInput_State.SelectedText := ""
    HistoryInput_State.BoundNumber := 0
    HistoryInput_State.Cancelled := true
    HistoryInput_State.Done := true
    Gui, HistoryInput:Destroy
}

HistoryInputGuiClose:
HistoryInputGuiEscape:
    HistoryInput_Close()
return

HistoryInput_IsActive() {
    global HistoryInput_State
    if !(IsObject(HistoryInput_State)
        && HistoryInput_State.Active
        && HistoryInput_State.GuiHwnd)
        return false
    if (WinActive("ahk_id " . HistoryInput_State.GuiHwnd))
        return true
    WinGetClass, cls, A
    return (cls = "ComboLBox")
}

HistoryInput_IsImeComposingOnFocus() {
    ControlGetFocus, focusedCtrl, A
    if (focusedCtrl = "")
        return false

    ControlGet, hFocus, Hwnd,, %focusedCtrl%, A
    if (!hFocus)
        return false

    return HistoryInput_IsImeComposing(hFocus)
}

HistoryInput_IsImeComposing(hWnd) {
    hIMC := DllCall("imm32\ImmGetContext", "Ptr", hWnd, "Ptr")
    if (!hIMC)
        return false

    ; GCS_COMPSTR=0x0008：有组合串表示正在组词，Enter 应先用于上屏。
    compLen := DllCall("imm32\ImmGetCompositionStringW", "Ptr", hIMC, "UInt", 0x0008, "Ptr", 0, "UInt", 0, "Int")
    DllCall("imm32\ImmReleaseContext", "Ptr", hWnd, "Ptr", hIMC)
    return (compLen > 0)
}

HistoryInput_ForwardEnterToFocus() {
    ControlGetFocus, focusedCtrl, A
    if (focusedCtrl = "")
        return
    ControlSend, %focusedCtrl%, {Enter}, A
}


#If HistoryInput_IsActive()
Enter::
NumpadEnter::
    if (HistoryInput_IsImeComposingOnFocus()) {
        HistoryInput_ForwardEnterToFocus()
        return
    }
    HistoryInput_Submit()
return
Esc::
    HistoryInput_Close()
return
#If

NormalizeText(str) {
    str := Trim(str)
    str := StrReplace(str, "`r`n", " ")
    str := StrReplace(str, "`n", " ")
    str := StrReplace(str, "`r", " ")
    str := StrReplace(str, "`t", " ")
    return Trim(str)
}

EscapeText(str) {
    ; 先转义反斜杠，再转义控制字符
    str := StrReplace(str, Chr(92), "\\")
    str := StrReplace(str, "`t", "\t")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`n", "\n")
    return str
}

UnescapeText(str) {
    ; 逆序还原，避免二次替换冲突
    str := StrReplace(str, "\n", "`n")
    str := StrReplace(str, "\r", "`r")
    str := StrReplace(str, "\t", "`t")
    str := StrReplace(str, "\\", Chr(92))
    return str
}

TrimToRecent(ByRef items, ByRef textToId, keepN) {
    count := 0
    for _, _ in items
        count++

    if (count <= keepN)
        return

    ; last|id，按数字升序后，从最旧开始删除
    timeList := ""
    for id, data in items
        timeList .= data.last . "|" . id . "`n"

    Sort, timeList, N
    needRemove := count - keepN
    removed := 0

    Loop, Parse, timeList, `n, `r
    {
        if (A_LoopField = "")
            continue
        if (removed >= needRemove)
            break

        StringSplit, p, A_LoopField, |
        id := p2 + 0
        if !items.HasKey(id)
            continue

        txt := items[id].text
        items.Delete(id)
        if (textToId.HasKey(txt))
            textToId.Delete(txt)
        removed++
    }
}

GetFirstItem(list) {
    if (list = "")
        return ""
    pos := InStr(list, "|")
    if (pos = 0)
        return list
    return SubStr(list, 1, pos - 1)
}
