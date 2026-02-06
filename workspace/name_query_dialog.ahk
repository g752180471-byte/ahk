; AutoHotkey v1
; 1) Show all items using multiple list boxes (no single scrolling list mode)
; 2) Search by numeric sequence only
; 3) Remove large info panel
; 4) Confirm uses selected name -> json id, then run command with id

#NoEnv
#Warn
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8

global App := {}
global NS_SeqInput := ""
global NS_List1 := "", NS_List2 := "", NS_List3 := "", NS_List4 := ""
global NS_List5 := "", NS_List6 := "", NS_List7 := "", NS_List8 := ""
global NS_List9 := "", NS_List10 := "", NS_List11 := "", NS_List12 := ""
global NS_Idx1 := "", NS_Idx2 := "", NS_Idx3 := "", NS_Idx4 := ""
global NS_Idx5 := "", NS_Idx6 := "", NS_Idx7 := "", NS_Idx8 := ""
global NS_Idx9 := "", NS_Idx10 := "", NS_Idx11 := "", NS_Idx12 := ""

if (A_LineFile = A_ScriptFullPath)
{
    NameSel_RunDialog()
    ExitApp
}
return

NameSel_RunDialog()
{
    global App

    NameSel_Init()
    if (!App.Ready)
        return { confirmed: false, canceled: true, error: "init_failed", seq: "", name: "", id: "", cmd: "" }

    App.RunModeStandalone := (A_LineFile = A_ScriptFullPath)
    App.Done := false
    App.Result := { confirmed: false, canceled: true, error: "", seq: "", name: "", id: "", cmd: "" }

    NameSel_ShowGui()
    while (!App.Done)
        Sleep, 30

    return App.Result
}

; ----------------------------
; GUI events
; ----------------------------
NS_SeqChanged:
    global NS_SeqInput, App
    if (App.InputUpdating)
        return
    Gui, NS:Submit, NoHide
    App.ListNavMode := false
    App.HistoryCursor := 0
    App.HistoryBaseInput := NS_SeqInput
    NameSel_SelectByInputText(NS_SeqInput, false)
return

NS_QueryNow:
    global NS_SeqInput
    Gui, NS:Submit, NoHide
    NameSel_SelectByInputText(NS_SeqInput, true)
return

NS_ListPick:
    global App

    if (App.Selecting)
        return
    App.ListNavMode := true
                
    ctrlName := A_GuiControl
    GuiControlGet, pickedPos, NS:, %ctrlName%
    if (pickedPos <= 0)
        return

    if !RegExMatch(ctrlName, "^NS_(?:List|Idx)(\d+)$", m)
        return

    pickedBoxIndex := m1 + 0
    if !App.ListBoxes.HasKey(pickedBoxIndex)
        return

    uiTargetSeq := App.ListBoxes[pickedBoxIndex].start + pickedPos - 1
    NameSel_SelectBySeq(uiTargetSeq, false)
    App.ListNavMode := true

    if (A_GuiEvent = "DoubleClick")
        Gosub, NS_Confirm
return

NS_Confirm:
    global App, NS_SeqInput

    selectedSeq := App.SelectedSeq
    if (selectedSeq < 1 || selectedSeq > App.Total)
    {
        MsgBox, 48, Notice, No valid item selected.
        return
    }

    Gui, NS:Submit, NoHide
    selectedItem := App.Items[selectedSeq]
    selectedName := selectedItem.name
    selectedId := selectedItem.id
    historyText := Trim(NS_SeqInput)
    if (historyText = "")
        historyText := selectedSeq . ""
    NameSel_PushSeqHistory(historyText)
    App.LastInput := historyText

    runCmd := NameSel_WriteAndRunCmd(selectedId)
    NameSel_SaveRuntime(selectedSeq, selectedName, selectedId, runCmd)
    NameSel_SaveConfig()

    Clipboard := selectedId
    App.Result := { confirmed: true, canceled: false, error: "", seq: selectedSeq, name: selectedName, id: selectedId, cmd: runCmd }
    App.Done := true
    Gui, NS:Destroy
    if (App.RunModeStandalone)
        ExitApp
return

NS_Cancel:
NSGuiClose:
NSGuiEscape:
    global App
    NameSel_SaveConfig()
    App.Result := { confirmed: false, canceled: true, error: "", seq: "", name: "", id: "", cmd: "" }
    App.Done := true
    Gui, NS:Destroy
    if (App.RunModeStandalone)
        ExitApp
return

#If NameSel_IsActive()
Enter::
NumpadEnter::
    Gosub, NS_Confirm
return

Tab::
    NameSel_HandleTabKey()
return

Up::
    NameSel_HandleUpKey()
return

Down::
    NameSel_HandleDownKey()
return
#If

; ----------------------------
; Init / GUI
; ----------------------------
NameSel_Init()
{
    global App

    App := {}
    SplitPath, A_LineFile, , fn_libDir
    App.IniPath := fn_libDir . "\NameSelector.ini"
    App.Ready := false
    App.Items := []
    App.ListBoxes := {}
    App.Selecting := false
    App.InputUpdating := false
    App.RunModeStandalone := false
    App.Done := false
    App.Result := {}
    App.ListNavMode := false
    App.HistoryCursor := 0
    App.HistoryBaseInput := ""
    App.SelectedSeq := 0
    App.LastSeq := 1
    App.LastInput := ""
    App.SeqHistory := []

    App.MaxBoxes := 12
    App.BaseRowsPerBox := 30
    App.ListNameVarNames := ["NS_List1","NS_List2","NS_List3","NS_List4","NS_List5","NS_List6","NS_List7","NS_List8","NS_List9","NS_List10","NS_List11","NS_List12"]
    App.ListIdxVarNames := ["NS_Idx1","NS_Idx2","NS_Idx3","NS_Idx4","NS_Idx5","NS_Idx6","NS_Idx7","NS_Idx8","NS_Idx9","NS_Idx10","NS_Idx11","NS_Idx12"]

    ; Fixed json path (edit here)
    hardcodedJsonPath := "C:\Users\75218\AppData\Local\Microsoft\Edge\User Data\Default\Workspaces\WorkspacesCache"
    ; Command template (edit here). {id} will be replaced.
    defaultCmdTemplate := """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"" --launch-workspace={id}"

    IniRead, confTpl, % App.IniPath, Config, CmdTemplate, %defaultCmdTemplate%
    if (confTpl = "" || confTpl = "ERROR")
        confTpl := defaultCmdTemplate

    IniRead, confLastSeq, % App.IniPath, Runtime, LastSeq, 1
    if RegExMatch(confLastSeq, "^\d+$")
        App.LastSeq := confLastSeq + 0

    IniRead, confLastInput, % App.IniPath, Runtime, LastInput,
    if (confLastInput != "ERROR")
        confLastInput := Trim(confLastInput)
    else
        confLastInput := ""

    App.JsonPath := hardcodedJsonPath
    App.CmdTemplate := confTpl
    App.SeqHistory := NameSel_LoadSeqHistory(App.IniPath, 10)

    if !NameSel_LoadItems(App.JsonPath)
        return

    App.Total := App.Items.MaxIndex()
    if (App.Total = "")
        return

    neededBoxes := Ceil(App.Total / App.BaseRowsPerBox)
    if (neededBoxes <= App.MaxBoxes)
    {
        App.BoxCount := neededBoxes
        App.RowsPerBox := App.BaseRowsPerBox
    }
    else
    {
        App.BoxCount := App.MaxBoxes
        App.RowsPerBox := Ceil(App.Total / App.BoxCount)
    }

    if (App.LastSeq < 1 || App.LastSeq > App.Total)
        App.LastSeq := 1
    if (confLastInput != "")
    {
        if RegExMatch(confLastInput, "^\d+$")
        {
            App.LastInput := (confLastInput + 0) . ""
            if ((App.LastInput + 0) < 1 || (App.LastInput + 0) > App.Total)
                App.LastInput := App.LastSeq . ""
        }
        else
        {
            App.LastInput := confLastInput
        }
    }
    else if (App.SeqHistory.MaxIndex() >= 1)
    {
        App.LastInput := App.SeqHistory[1]
    }
    else
    {
        App.LastInput := App.LastSeq . ""
    }
    App.SelectedSeq := App.LastSeq
    App.Ready := true
}

NameSel_ShowGui()
{
    global App, NS_SeqInput
    global NS_List1, NS_List2, NS_List3, NS_List4, NS_List5, NS_List6
    global NS_List7, NS_List8, NS_List9, NS_List10, NS_List11, NS_List12
    global NS_Idx1, NS_Idx2, NS_Idx3, NS_Idx4, NS_Idx5, NS_Idx6
    global NS_Idx7, NS_Idx8, NS_Idx9, NS_Idx10, NS_Idx11, NS_Idx12

    if (App.GuiHwnd && WinExist("ahk_id " . App.GuiHwnd))
    {
        hwnd := App.GuiHwnd
        Gui, NS:Show
        WinShow, ahk_id %hwnd%
        WinActivate, ahk_id %hwnd%
        NameSel_SetSeqInputText(App.LastInput, true)
        return
    }

    leftX := 20
    leftW := 320
    listStartX := leftX + leftW + 24
    listLabelY := 20
    listY := 52
    nameW := 220
    idxW := 44
    colGap := 1
    panelW := nameW + colGap + idxW
    listGap := 40
    btnGap := 12
    btnW := Floor((leftW - btnGap) / 2)
    btn2X := leftX + btnW + btnGap
    rowPx := 18
    listH := (App.RowsPerBox * rowPx) + 8
    buttonY := listY + listH + 20
    winW := listStartX + (App.BoxCount * panelW) + ((App.BoxCount - 1) * listGap) + 20
    winH := buttonY + 90

    Gui, NS:New, +AlwaysOnTop +Resize -MinimizeBox +LabelNSGui +HwndhGui, Name Selector
    App.GuiHwnd := hGui
    Gui, NS:Font, s10, Microsoft YaHei

    histList := NameSel_HistoryForList(App.SeqHistory, App.LastInput, 10)
    histPipe := NameSel_ArrayToPipe(histList)
    Gui, NS:Add, Text, x%leftX% y20, Search:
    Gui, NS:Add, ComboBox, vNS_SeqInput gNS_SeqChanged x%leftX% y52 w%leftW% r10 Simple, %histPipe%

    Gui, NS:Add, Button, x%leftX% y%buttonY% w%btnW% h44 Default gNS_Confirm, Confirm
    Gui, NS:Add, Button, x%btn2X% y%buttonY% w%btnW% h44 gNS_Cancel, Cancel

    App.ListBoxes := {}
    Loop, % App.BoxCount
    {
        buildBoxIndex := A_Index
        startSeq := ((buildBoxIndex - 1) * App.RowsPerBox) + 1
        endSeq := buildBoxIndex * App.RowsPerBox
        if (endSeq > App.Total)
            endSeq := App.Total

        nameVar := App.ListNameVarNames[buildBoxIndex]
        idxVar := App.ListIdxVarNames[buildBoxIndex]
        panelX := listStartX + ((buildBoxIndex - 1) * (panelW + listGap))
        nameX := panelX
        idxX := panelX + nameW + colGap

        Gui, NS:Add, Text, x%panelX% y%listLabelY%, % "List " . buildBoxIndex
        Gui, NS:Add, ListBox, % "v" . nameVar . " gNS_ListPick x" . nameX . " y" . listY . " w" . nameW . " r" . App.RowsPerBox . " AltSubmit"
        Gui, NS:Add, ListBox, % "v" . idxVar . " gNS_ListPick x" . idxX . " y" . listY . " w" . idxW . " r" . App.RowsPerBox . " AltSubmit"

        namePipe := ""
        idxPipe := ""
        currentSeq := startSeq
        while (currentSeq <= endSeq)
        {
            rowItem := App.Items[currentSeq]
            namePipe .= rowItem.name . "|"
            idxPipe .= "[" . rowItem.seq . "]|"
            currentSeq++
        }
        GuiControl, NS:, %nameVar%, |%namePipe%
        GuiControl, NS:, %idxVar%, |%idxPipe%

        App.ListBoxes[buildBoxIndex] := { nameVar: nameVar, idxVar: idxVar, start: startSeq, end: endSeq }
    }

    Gui, NS:Show, Center w%winW% h%winH%, Name Selector
    NameSel_SelectByInputText(App.LastInput, false)
    NameSel_SetSeqInputText(App.LastInput, true)
}

NameSel_SelectBySeq(seq, writeInput := false)
{
    global App

    if (seq < 1 || seq > App.Total)
        return false

    App.Selecting := true
    for loopBoxIndex, meta in App.ListBoxes
    {
        nameVar := meta.nameVar
        idxVar := meta.idxVar
        if (seq >= meta.start && seq <= meta.end)
        {
            pos := seq - meta.start + 1
            GuiControl, NS:Choose, %nameVar%, %pos%
            GuiControl, NS:Choose, %idxVar%, %pos%
        }
        else
        {
            GuiControl, NS:Choose, %nameVar%, 0
            GuiControl, NS:Choose, %idxVar%, 0
        }
    }
    App.Selecting := false

    App.SelectedSeq := seq
    App.LastSeq := seq
    if (writeInput)
    {
        App.LastInput := seq . ""
        NameSel_SetSeqInputText(seq, true)
    }
    return true
}

NameSel_SelectByInputText(inputText, showNotice)
{
    global App

    fn_text := Trim(inputText)
    if (fn_text = "")
        return false

    if RegExMatch(fn_text, "^\d+$")
    {
        fnTargetSeq := fn_text + 0
        if (fnTargetSeq < 1 || fnTargetSeq > App.Total)
        {
            if (showNotice)
                MsgBox, 48, Notice, % "Sequence out of range. 1 - " . App.Total
            return false
        }
        fn_ok := NameSel_SelectBySeq(fnTargetSeq, false)
        if (fn_ok)
            App.LastInput := fn_text
        return fn_ok
    }

    fnTargetSeq := NameSel_FindSeqByName(fn_text)
    if (fnTargetSeq < 1)
    {
        if (showNotice)
            MsgBox, 48, Notice, No matching name found.
        return false
    }

    fn_ok := NameSel_SelectBySeq(fnTargetSeq, false)
    if (fn_ok)
        App.LastInput := fn_text
    return fn_ok
}

NameSel_FindSeqByName(nameText)
{
    global App

    fn_nameText := Trim(nameText)
    if (fn_nameText = "")
        return 0

    for fn_seq, fn_item in App.Items
    {
        if (fn_item.name = fn_nameText)
            return fn_seq
    }

    for fn_seq, fn_item in App.Items
    {
        if InStr(fn_item.name, fn_nameText, false)
            return fn_seq
    }

    return 0
}

; ----------------------------
; Data loading
; ----------------------------
NameSel_LoadItems(jsonPath)
{
    global App

    if !FileExist(jsonPath)
    {
        MsgBox, 16, Error, JSON not found:`n%jsonPath%
        return false
    }

    FileRead, jsonText, %jsonPath%
    if (ErrorLevel)
    {
        MsgBox, 16, Error, Failed to read JSON:`n%jsonPath%
        return false
    }

    parsedItems := []
    seq := 1
    pos := 1
    objPattern := "\{[^{}]*\}"

    while (pos := RegExMatch(jsonText, objPattern, objMatch, pos))
    {
        objText := objMatch
        hasId := RegExMatch(objText, """id""\s*:\s*""((?:\\.|[^""\\])*)""", mId)
        hasName := RegExMatch(objText, """name""\s*:\s*""((?:\\.|[^""\\])*)""", mName)

        if (hasId && hasName)
        {
            objId := NameSel_JsonUnescape(mId1)
            objName := NameSel_JsonUnescape(mName1)
            parsedItems.Push({ seq: seq, name: objName, id: objId })
            seq++
        }

        pos += StrLen(objMatch)
    }

    if (parsedItems.MaxIndex() = "")
    {
        MsgBox, 16, Error, No {id,name} object found in JSON.
        return false
    }

    App.Items := parsedItems
    return true
}

; ----------------------------
; Runtime/config
; ----------------------------
NameSel_SaveRuntime(seq, name, id, cmdLine)
{
    global App

    IniWrite, %seq%, % App.IniPath, Runtime, LastSeq
    IniWrite, % App.LastInput, % App.IniPath, Runtime, LastInput
    IniWrite, %name%, % App.IniPath, Runtime, LastName
    IniWrite, %id%, % App.IniPath, Runtime, LastId
    IniWrite, %A_Now%, % App.IniPath, Runtime, LastTime
    IniWrite, %cmdLine%, % App.IniPath, Runtime, LastCmd
}

NameSel_SaveConfig()
{
    global App
    IniWrite, % App.CmdTemplate, % App.IniPath, Config, CmdTemplate
    IniWrite, % App.LastSeq, % App.IniPath, Runtime, LastSeq
    IniWrite, % App.LastInput, % App.IniPath, Runtime, LastInput
    NameSel_SaveSeqHistory(App.IniPath, App.SeqHistory, 10)
}

; ----------------------------
; Command run
; ----------------------------
NameSel_WriteAndRunCmd(id)
{
    global App

    cmdBody := StrReplace(App.CmdTemplate, "{id}", id)
    runTarget := ComSpec . " /c " . Chr(34) . cmdBody . Chr(34)
    Run, %runTarget%,, Hide UseErrorLevel
    if (ErrorLevel)
        MsgBox, 48, Notice, Failed to run command:`n%cmdBody%
    return cmdBody
}

NameSel_IsActive()
{
    global App
    return (App.GuiHwnd && WinActive("ahk_id " . App.GuiHwnd))
}

NameSel_SelectAllSeqInput()
{
    global App
    hwnd := App.GuiHwnd

    ; ComboBox has an inner Edit control. Select all text there.
    ControlGet, hComboEdit, Hwnd,, Edit1, ahk_id %hwnd%
    if (hComboEdit)
    {
        SendMessage, 0x00B1, 0, -1,, ahk_id %hComboEdit%
        return
    }

    ; Fallback for non-standard class names.
    GuiControlGet, hSeqCtrl, NS:Hwnd, NS_SeqInput
    if (hSeqCtrl)
        SendMessage, 0x00B1, 0, -1,, ahk_id %hSeqCtrl%
}

NameSel_SetSeqInputText(value, selectAll := false)
{
    global App
    fn_text := Trim(value . "")
    hwnd := App.GuiHwnd

    App.InputUpdating := true
    App.ListNavMode := false
    ControlGet, hComboEdit, Hwnd,, Edit1, ahk_id %hwnd%
    if (hComboEdit)
        ControlSetText,, %fn_text%, ahk_id %hComboEdit%
    else
        GuiControl, NS:, NS_SeqInput, %fn_text%

    GuiControl, NS:Focus, NS_SeqInput
    if (selectAll)
        NameSel_SelectAllSeqInput()
    App.InputUpdating := false
}

NameSel_ArrayToPipe(ByRef arr)
{
    fn_out := ""
    for _, fn_item in arr
        fn_out .= fn_item . "|"
    return fn_out
}

NameSel_PushSeqHistory(seqText)
{
    global App

    fn_text := Trim(seqText . "")
    if (fn_text = "")
        return

    fn_new := []
    fn_new.Push(fn_text)

    for _, fn_old in App.SeqHistory
    {
        if (fn_old = fn_text)
            continue
        if (fn_new.MaxIndex() >= 10)
            break
        fn_new.Push(fn_old)
    }

    App.SeqHistory := fn_new
}

NameSel_LoadSeqHistory(iniPath, keepN)
{
    fn_hist := []
    fn_seen := {}
    Loop, %keepN%
    {
        fn_key := "item_" . A_Index
        IniRead, fn_val, %iniPath%, SeqHistory, %fn_key%,
        if (fn_val = "" || fn_val = "ERROR")
            continue
        fn_norm := Trim(fn_val . "")
        if (fn_norm = "")
            continue

        if (fn_seen.HasKey(fn_norm))
            continue
        fn_seen[fn_norm] := true
        fn_hist.Push(fn_norm)
    }
    return fn_hist
}

NameSel_SaveSeqHistory(iniPath, ByRef historyArr, keepN)
{
    IniDelete, %iniPath%, SeqHistory
    fn_i := 0
    for _, fn_val in historyArr
    {
        fn_i++
        if (fn_i > keepN)
            break
        IniWrite, %fn_val%, %iniPath%, SeqHistory, % "item_" . fn_i
    }
}

NameSel_HistoryForList(ByRef historyArr, lastInput, keepN)
{
    fn_out := []
    fn_seen := {}

    fn_last := Trim(lastInput . "")

    for _, fn_val in historyArr
    {
        fn_norm := Trim(fn_val . "")
        if (fn_norm = "")
            continue

        ; LastInput goes to edit box, not duplicated in list panel.
        if (fn_last != "" && fn_norm = fn_last)
            continue
        if (fn_seen.HasKey(fn_norm))
            continue

        fn_seen[fn_norm] := true
        fn_out.Push(fn_norm)
        if (fn_out.MaxIndex() >= keepN)
            break
    }
    return fn_out
}

NameSel_BrowseHistory(step)
{
    global App, NS_SeqInput

    fn_total := App.SeqHistory.MaxIndex()
    if (!fn_total)
        return
    App.ListNavMode := false

    Gui, NS:Submit, NoHide
    fn_current := Trim(NS_SeqInput . "")
    if (App.HistoryCursor = 0)
        App.HistoryBaseInput := fn_current

    fn_newCursor := App.HistoryCursor + step
    if (fn_newCursor < 0)
        fn_newCursor := 0
    if (fn_newCursor > fn_total)
        fn_newCursor := fn_total
    if (fn_newCursor = App.HistoryCursor)
        return

    App.HistoryCursor := fn_newCursor
    if (fn_newCursor = 0)
        fn_target := App.HistoryBaseInput
    else
        fn_target := App.SeqHistory[fn_newCursor]

    NameSel_SetSeqInputText(fn_target, true)
    if !NameSel_SelectByInputText(fn_target, false)
        App.LastInput := fn_target
}

NameSel_IsSearchFocused()
{
    global App
    fn_hwnd := App.GuiHwnd

    if !(fn_hwnd && WinActive("ahk_id " . fn_hwnd))
        return false

    ControlGetFocus, fn_focusCtrl, ahk_id %fn_hwnd%
    if (fn_focusCtrl = "")
        return false

    if RegExMatch(fn_focusCtrl, "^Edit\d+$")
        return true

    GuiControlGet, fn_hSeq, NS:Hwnd, NS_SeqInput
    if (!fn_hSeq)
        return false

    ControlGet, fn_hFocus, Hwnd,, %fn_focusCtrl%, ahk_id %fn_hwnd%
    return (fn_hFocus = fn_hSeq)
}

NameSel_FocusCurrentList()
{
    global App

    fn_seq := App.SelectedSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        fn_seq := App.LastSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        return

    for _, fn_meta in App.ListBoxes
    {
        if (fn_seq >= fn_meta.start && fn_seq <= fn_meta.end)
        {
            fn_pos := fn_seq - fn_meta.start + 1
            App.Selecting := true
            GuiControl, NS:Choose, % fn_meta.nameVar, %fn_pos%
            GuiControl, NS:Choose, % fn_meta.idxVar, %fn_pos%
            App.Selecting := false
            GuiControl, NS:Focus, % fn_meta.nameVar
            App.ListNavMode := true
            return
        }
    }
}

NameSel_HandleTabKey()
{
    global App

    if NameSel_IsSearchFocused()
    {
        NameSel_FocusCurrentList()
        return
    }

    if NameSel_IsListFocused()
    {
        App.ListNavMode := false
        GuiControl, NS:Focus, NS_SeqInput
        NameSel_SelectAllSeqInput()
        return
    }

    NameSel_FocusCurrentList()
}

NameSel_HandleUpKey()
{
    global App

    if NameSel_IsSearchFocused()
    {
        App.ListNavMode := false
        NameSel_BrowseHistory(-1)
        return
    }

    if (App.ListNavMode || NameSel_IsListFocused())
        NameSel_ListStep(-1)
    else
        NameSel_BrowseHistory(-1)
}

NameSel_HandleDownKey()
{
    global App

    if NameSel_IsSearchFocused()
    {
        App.ListNavMode := false
        NameSel_BrowseHistory(1)
        return
    }

    if (App.ListNavMode || NameSel_IsListFocused())
        NameSel_ListStep(1)
    else
        NameSel_BrowseHistory(1)
}

NameSel_ListStep(step)
{
    global App

    fn_seq := App.SelectedSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        fn_seq := App.LastSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        fn_seq := 1

    fn_target := fn_seq + step
    if (fn_target < 1)
        fn_target := 1
    if (fn_target > App.Total)
        fn_target := App.Total

    if (fn_target != fn_seq)
        NameSel_SelectBySeq(fn_target, false)

    NameSel_FocusCurrentList()
}

NameSel_IsListFocused()
{
    global App
    fn_hwnd := App.GuiHwnd

    if !(fn_hwnd && WinActive("ahk_id " . fn_hwnd))
        return false

    ControlGetFocus, fn_focusCtrl, ahk_id %fn_hwnd%
    if (fn_focusCtrl = "")
        return false

    return RegExMatch(fn_focusCtrl, "^ListBox\d+$")
}

; ----------------------------
; Helpers
; ----------------------------
NameSel_JsonUnescape(str)
{
    placeholder := Chr(1)
    str := StrReplace(str, "\\", placeholder)
    str := StrReplace(str, "\/", "/")
    str := StrReplace(str, "\" . Chr(34), Chr(34))
    str := StrReplace(str, "\r", "`r")
    str := StrReplace(str, "\n", "`n")
    str := StrReplace(str, "\t", "`t")

    loopGuard := 0
    while RegExMatch(str, "\\u([0-9A-Fa-f]{4})", mu)
    {
        loopGuard++
        if (loopGuard > 3000)
            break
        code := "0x" . mu1
        str := StrReplace(str, mu, Chr(code))
    }

    str := StrReplace(str, placeholder, Chr(92))
    return str
}
