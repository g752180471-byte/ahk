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

;;  
;;大纲1
;;  
;;  
;;1. 全局变量与状态
;;  
global App := {}
global NS_SeqInput := ""
global NS_List1 := "", NS_List2 := "", NS_List3 := "", NS_List4 := ""
global NS_List5 := "", NS_List6 := "", NS_List7 := "", NS_List8 := ""
global NS_List9 := "", NS_List10 := "", NS_List11 := "", NS_List12 := ""
global NS_Idx1 := "", NS_Idx2 := "", NS_Idx3 := "", NS_Idx4 := ""
global NS_Idx5 := "", NS_Idx6 := "", NS_Idx7 := "", NS_Idx8 := ""
global NS_Idx9 := "", NS_Idx10 := "", NS_Idx11 := "", NS_Idx12 := ""

;;  
;;2. 程序入口
;;  
if (A_LineFile = A_ScriptFullPath)
{
    NameSel_RunDialog()
    ExitApp
}
return

;;  
;;2.1 对话框主流程
;;  
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
;;  
;;5. 交互事件
;;  
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

    uiRow := App.ListBoxes[pickedBoxIndex].rowStart + pickedPos - 1
    if (uiRow < 1 || uiRow > App.DisplayTotal)
        return

    rowData := App.DisplayRows[uiRow]
    if !(IsObject(rowData) && rowData.kind = "item")
    {
        if (App.SelectedSeq >= 1 && App.SelectedSeq <= App.Total)
            NameSel_SelectBySeq(App.SelectedSeq, false)
        return
    }

    NameSel_SelectBySeq(rowData.seq, false)
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

    runCmd := NameSel_WriteAndRunCmd(selectedItem)
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

;;  
;;7.0 Ctrl 热键入口（高亮行）
;;  
~LControl Up::
~RControl Up::
    NameSel_HandleCtrlTap()
return
#If

; ----------------------------
; Init / GUI
; ----------------------------
;;  
;;3. 初始化
;;  
NameSel_Init()
{
    global App

    App := {}
    SplitPath, A_LineFile, , fn_libDir
    App.IniPath := fn_libDir . "\NameSelector.ini"
    App.Ready := false
    App.Items := []
    App.DisplayRows := []
    App.SeqToRow := {}
    App.Groups := []
    App.DisplayTotal := 0
    App.GroupGapRows := 3
    App.LoadWarnings := []
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
    App.PinnedFilePath := "C:\Users\75218\Nutstore\1\我的坚果云\我-使用说明书.pptx"
    App.PinnedFileName := "我-使用说明书.pptx"
    App.PinnedFileCmdTemplate := "start " . Chr(34) . Chr(34) . " " . Chr(34) . "{id}" . Chr(34)

    App.MaxBoxes := 12
    App.BaseRowsPerBox := 50
    App.ListNameVarNames := ["NS_List1","NS_List2","NS_List3","NS_List4","NS_List5","NS_List6","NS_List7","NS_List8","NS_List9","NS_List10","NS_List11","NS_List12"]
    App.ListIdxVarNames := ["NS_Idx1","NS_Idx2","NS_Idx3","NS_Idx4","NS_Idx5","NS_Idx6","NS_Idx7","NS_Idx8","NS_Idx9","NS_Idx10","NS_Idx11","NS_Idx12"]

    stableJsonPath := "C:\Users\75218\AppData\Local\Microsoft\Edge\User Data\Default\Workspaces\WorkspacesCache"
    betaJsonPath := "C:\Users\75218\AppData\Local\Microsoft\Edge Beta\User Data\Profile 1\Workspaces\WorkspacesCache"
    sxsJsonPath := "C:\Users\75218\AppData\Local\Microsoft\Edge SxS\User Data\Default\Workspaces\WorkspacesCache"

    ; Command template. {id} will be replaced.
    defaultCmdTemplate := """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"" --launch-workspace={id}"
    betaCmdTemplate := """C:\Program Files (x86)\Microsoft\Edge Beta\Application\msedge.exe"" --launch-workspace={id}"
    sxsCmdTemplate := """C:\Users\75218\AppData\Local\Microsoft\Edge SxS\Application\msedge.exe"" --launch-workspace={id}"

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

    App.CmdTemplate := confTpl
    App.Sources := []
    App.Sources.Push({ label: "Edge", jsonPath: stableJsonPath, cmdTemplate: confTpl })
    App.Sources.Push({ label: "Edge Beta", jsonPath: betaJsonPath, cmdTemplate: betaCmdTemplate })
    App.Sources.Push({ label: "Edge Can", jsonPath: sxsJsonPath, cmdTemplate: sxsCmdTemplate })
    App.SeqHistory := NameSel_LoadSeqHistory(App.IniPath, 10)

    if !NameSel_LoadItemsFromSources()
        return

    NameSel_BuildDisplayRows()
    App.Total := App.Items.MaxIndex()
    if (App.Total = "" || App.Total <= 0 || App.DisplayTotal <= 0)
        return

    neededBoxes := Ceil(App.DisplayTotal / App.BaseRowsPerBox)
    if (neededBoxes <= App.MaxBoxes)
    {
        App.BoxCount := neededBoxes
        App.RowsPerBox := App.BaseRowsPerBox
    }
    else
    {
        App.BoxCount := App.MaxBoxes
        App.RowsPerBox := Ceil(App.DisplayTotal / App.BoxCount)
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

;;  
;;4. GUI 构建与展示
;;  
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
        WinSet, AlwaysOnTop, Off, ahk_id %hwnd%
        Gui, NS:Show
        WinShow, ahk_id %hwnd%
        WinActivate, ahk_id %hwnd%
        NameSel_SetSeqInputText(App.LastInput, true)
        return
    }

    leftX := 20
    leftW := 280
    listStartX := leftX + leftW + 24
    listLabelY := 20
    listY := 52
    nameW := 190
    idxW := 42
    colGap := 1
    panelW := nameW + colGap + idxW
    listGap := 18
    btnGap := 12
    btnW := Floor((leftW - btnGap) / 2)
    btn2X := leftX + btnW + btnGap
    rowPx := 16
    listH := (App.RowsPerBox * rowPx) + 8
    buttonY := listY + listH + 20
    winW := listStartX + (App.BoxCount * panelW) + ((App.BoxCount - 1) * listGap) + 20
    winH := buttonY + 90

    Gui, NS:New, +Resize -MinimizeBox +LabelNSGui +HwndhGui, Name Selector
    App.GuiHwnd := hGui
    WinSet, AlwaysOnTop, Off, ahk_id %hGui%
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
        startRow := ((buildBoxIndex - 1) * App.RowsPerBox) + 1
        endRow := buildBoxIndex * App.RowsPerBox
        if (endRow > App.DisplayTotal)
            endRow := App.DisplayTotal

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
        currentRow := startRow
        while (currentRow <= endRow)
        {
            rowItem := App.DisplayRows[currentRow]
            namePipe .= rowItem.name . "|"
            idxPipe .= rowItem.idx . "|"
            currentRow++
        }
        GuiControl, NS:, %nameVar%, |%namePipe%
        GuiControl, NS:, %idxVar%, |%idxPipe%

        App.ListBoxes[buildBoxIndex] := { nameVar: nameVar, idxVar: idxVar, rowStart: startRow, rowEnd: endRow }
    }

    Gui, NS:Show, Center w%winW% h%winH%, Name Selector
    NameSel_SelectByInputText(App.LastInput, false)
    NameSel_SetSeqInputText(App.LastInput, true)
}

;;  
;;6. 查询与选择逻辑
;;  
;;  
;;6.1 高亮显示：按序号选中列表项
;;  
NameSel_SelectBySeq(seq, writeInput := false)
{
    global App

    if (seq < 1 || seq > App.Total)
        return false
    rowTarget := App.SeqToRow[seq]
    if (!rowTarget)
        return false

    App.Selecting := true
    for loopBoxIndex, meta in App.ListBoxes
    {
        nameVar := meta.nameVar
        idxVar := meta.idxVar
        if (rowTarget >= meta.rowStart && rowTarget <= meta.rowEnd)
        {
            pos := rowTarget - meta.rowStart + 1
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

    fn_matches := NameSel_FindSeqMatches(fn_text)
    if (fn_matches.MaxIndex() = "")
    {
        if (showNotice)
            MsgBox, 48, Notice, No matching name found.
        return false
    }

    fnTargetSeq := fn_matches[1]
    fn_ok := NameSel_SelectBySeq(fnTargetSeq, false)
    if (fn_ok)
        App.LastInput := fn_text
    return fn_ok
}

NameSel_FindSeqMatches(nameText)
{
    global App

    fn_nameText := Trim(nameText)
    fn_matches := []
    if (fn_nameText = "")
        return fn_matches

    ; Exact matches first.
    for fn_seq, fn_item in App.Items
    {
        if (fn_item.name = fn_nameText)
            fn_matches.Push(fn_seq)
    }

    ; Then fuzzy matches.
    for fn_seq, fn_item in App.Items
    {
        if (fn_item.name = fn_nameText)
            continue
        if InStr(fn_item.name, fn_nameText, false)
            fn_matches.Push(fn_seq)
    }

    return fn_matches
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
;;  
;;8. 数据加载与解析
;;  
NameSel_LoadItemsFromSources()
{
    global App

    allItems := []
    groups := []
    loadWarnings := []
    nextSeq := 1
    pinnedAdded := false
    pinnedPath := App.PinnedFilePath

    for _, source in App.Sources
    {
        groupStart := nextSeq

        if (!pinnedAdded && pinnedPath != "")
        {
            pinnedName := App.PinnedFileName
            if (pinnedName = "")
            {
                SplitPath, pinnedPath, pinnedName
                if (pinnedName = "")
                    pinnedName := pinnedPath
            }
            pinnedItem := { seq: nextSeq, name: pinnedName, id: pinnedPath, source: source.label, cmdTemplate: App.PinnedFileCmdTemplate }
            allItems.Push(pinnedItem)
            nextSeq++
            pinnedAdded := true
        }

        loadResult := NameSel_AppendItemsFromJson(allItems, source, nextSeq)
        groupEnd := nextSeq - 1
        groupCount := groupEnd - groupStart + 1
        if (groupCount < 0)
            groupCount := 0

        groups.Push({ label: source.label, startSeq: groupStart, endSeq: groupEnd, count: groupCount })
        if (!loadResult.ok)
            loadWarnings.Push(source.label . ": " . loadResult.error . "`n" . source.jsonPath)
    }

    if (allItems.MaxIndex() = "")
    {
        details := ""
        for _, warnText in loadWarnings
            details .= warnText . "`n`n"
        MsgBox, 16, Error, % "No workspace data loaded.`n`n" . RTrim(details, "`n")
        return false
    }

    App.Items := allItems
    App.Groups := groups
    App.LoadWarnings := loadWarnings
    return true
}

NameSel_AppendItemsFromJson(ByRef outItems, ByRef source, ByRef nextSeq)
{
    result := { ok: false, error: "", count: 0 }
    jsonPath := source.jsonPath

    if !FileExist(jsonPath)
    {
        result.error := "JSON not found"
        return result
    }

    FileRead, jsonText, %jsonPath%
    if (ErrorLevel)
    {
        result.error := "Failed to read JSON"
        return result
    }

    count := NameSel_ParseJsonItems(jsonText, source.label, source.cmdTemplate, outItems, nextSeq)
    if (count <= 0)
    {
        result.error := "No {id,name} object found in JSON"
        return result
    }

    result.ok := true
    result.count := count
    return result
}

NameSel_ParseJsonItems(jsonText, sourceLabel, cmdTemplate, ByRef outItems, ByRef nextSeq)
{
    parsedCount := 0
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
            ; Skip items marked as deprecated/invalid in name.
            if InStr(objName, "作废", false)
            {
                pos += StrLen(objMatch)
                continue
            }
            outItems.Push({ seq: nextSeq, name: objName, id: objId, source: sourceLabel, cmdTemplate: cmdTemplate })
            nextSeq++
            parsedCount++
        }

        pos += StrLen(objMatch)
    }
    return parsedCount
}

NameSel_BuildDisplayRows()
{
    global App

    displayRows := []
    seqToRow := {}
    sepPad := Chr(160)

    for _, group in App.Groups
    {
        if (group.count <= 0)
            continue

        if (displayRows.MaxIndex() >= 1)
        {
            Loop, % App.GroupGapRows
                displayRows.Push({ kind: "sep", name: sepPad, idx: sepPad })
            displayRows.Push({ kind: "sep", name: "----- " . group.label . " -----", idx: sepPad })
            Loop, % App.GroupGapRows
                displayRows.Push({ kind: "sep", name: sepPad, idx: sepPad })
        }

        seq := group.startSeq
        while (seq <= group.endSeq)
        {
            item := App.Items[seq]
            displayRows.Push({ kind: "item", seq: seq, name: item.name, idx: "[" . item.seq . "]" })
            rowIndex := displayRows.MaxIndex()
            seqToRow[seq] := rowIndex
            seq++
        }
    }

    App.DisplayRows := displayRows
    App.SeqToRow := seqToRow
    App.DisplayTotal := displayRows.MaxIndex()
    if (App.DisplayTotal = "")
        App.DisplayTotal := 0
}

; ----------------------------
; Runtime/config
; ----------------------------
;;  
;;9. 运行与持久化
;;  
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
NameSel_WriteAndRunCmd(item)
{
    global App

    if !IsObject(item)
        return ""

    cmdTemplate := item.cmdTemplate
    if (cmdTemplate = "")
        cmdTemplate := App.CmdTemplate
    cmdBody := StrReplace(cmdTemplate, "{id}", item.id)
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

;;  
;;10.1 高亮显示：聚焦当前选中项
;;  
NameSel_FocusCurrentList()
{
    global App

    fn_seq := App.SelectedSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        fn_seq := App.LastSeq
    if (fn_seq < 1 || fn_seq > App.Total)
        return
    fn_row := App.SeqToRow[fn_seq]
    if (!fn_row)
        return

    for _, fn_meta in App.ListBoxes
    {
        if (fn_row >= fn_meta.rowStart && fn_row <= fn_meta.rowEnd)
        {
            fn_pos := fn_row - fn_meta.rowStart + 1
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

;;  
;;10. 键盘导航与辅助函数
;;  
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

;;  
;;7. 多结果切换（Ctrl 单击切换下一个模糊匹配）
;;  
NameSel_HandleCtrlTap()
{
    global App, NS_SeqInput

    ; Ignore Ctrl combinations such as Ctrl+C, Ctrl+V.
    if (A_PriorKey != "LControl" && A_PriorKey != "RControl")
        return false

    Gui, NS:Submit, NoHide
    fn_text := Trim(NS_SeqInput . "")
    if (fn_text = "")
        return false
    if RegExMatch(fn_text, "^\d+$")
        return false

    fn_matches := NameSel_FindSeqMatches(fn_text)
    fn_count := fn_matches.MaxIndex()
    if (fn_count = "" || fn_count <= 1)
        return false

    fn_currPos := 0
    for fn_i, fn_seq in fn_matches
    {
        if (fn_seq = App.SelectedSeq)
        {
            fn_currPos := fn_i
            break
        }
    }

    if (fn_currPos <= 0 || fn_currPos >= fn_count)
        fn_nextPos := 1
    else
        fn_nextPos := fn_currPos + 1

    fn_target := fn_matches[fn_nextPos]
    if !NameSel_SelectBySeq(fn_target, false)
        return false

    App.ListNavMode := true
    App.LastInput := fn_text
    return true
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
