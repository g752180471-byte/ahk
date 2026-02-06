; AutoHotkey v1
; New variant:
; 1) Keep core behavior (select -> run command by id, save last selection)
; 2) Input box searches by name
; 3) Use single scrolling list

#NoEnv
#Warn
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8

global App := {}
global NS_NameInput := ""
global NS_List := ""

NameSel_Init()
if (!App.Ready)
    ExitApp

NameSel_ShowGui()
return

; ----------------------------
; GUI events
; ----------------------------
NS_NameChanged:
    global NS_NameInput
    Gui, NS:Submit, NoHide
    NameSel_SelectByNameInput(NS_NameInput, false)
return

NS_SearchNow:
    global NS_NameInput
    Gui, NS:Submit, NoHide
    NameSel_SelectByNameInput(NS_NameInput, true)
return

NS_ListPick:
    global App

    if (App.Selecting)
        return

    if (A_GuiEvent = "Normal" || A_GuiEvent = "DoubleClick")
    {
        ui_row := A_EventInfo + 0
        if (ui_row > 0)
            NameSel_SelectBySeq(ui_row, true)
    }

    if (A_GuiEvent = "DoubleClick")
        Gosub, NS_Confirm
return

NS_Confirm:
    global App, NS_NameInput

    if (App.SelectedSeq < 1 || App.SelectedSeq > App.Total)
    {
        Gui, NS:Submit, NoHide
        if !NameSel_SelectByNameInput(NS_NameInput, true)
            return
    }

    ui_selectedSeq := App.SelectedSeq
    ui_item := App.Items[ui_selectedSeq]
    ui_name := ui_item.name
    ui_id := ui_item.id

    ui_runCmd := NameSel_WriteAndRunCmd(ui_id)
    NameSel_SaveRuntime(ui_selectedSeq, ui_name, ui_id, ui_runCmd)
    NameSel_SaveConfig()

    Clipboard := ui_id
    MsgBox, 64, Done, Selected name:`t%ui_name%`nSelected id:`t%ui_id%`nCopied id to clipboard.
    Gui, NS:Destroy
    ExitApp
return

NS_Cancel:
NSGuiClose:
NSGuiEscape:
    NameSel_SaveConfig()
    Gui, NS:Destroy
    ExitApp
return

#If NameSel_IsActive()
Enter::
NumpadEnter::
    Gosub, NS_Confirm
return
#If

^!q::
    NameSel_ShowGui()
return

; ----------------------------
; Init / GUI
; ----------------------------
NameSel_Init()
{
    global App

    App := {}
    App.IniPath := A_ScriptDir . "\NameSelector_name_scroll.ini"
    App.Ready := false
    App.Items := []
    App.Selecting := false
    App.SelectedSeq := 0
    App.LastSeq := 1
    App.GuiHwnd := 0

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

    App.JsonPath := hardcodedJsonPath
    App.CmdTemplate := confTpl

    if !NameSel_LoadItems(App.JsonPath)
        return

    App.Total := App.Items.MaxIndex()
    if (App.Total = "")
        return

    if (App.LastSeq < 1 || App.LastSeq > App.Total)
        App.LastSeq := 1
    App.SelectedSeq := App.LastSeq
    App.Ready := true
}

NameSel_ShowGui()
{
    global App, NS_NameInput, NS_List

    if (App.GuiHwnd && WinExist("ahk_id " . App.GuiHwnd))
    {
        ui_hwnd := App.GuiHwnd
        Gui, NS:Show
        WinShow, ahk_id %ui_hwnd%
        WinActivate, ahk_id %ui_hwnd%
        return
    }

    winW := 1300
    winH := 760

    Gui, NS:New, +AlwaysOnTop +Resize -MinimizeBox +LabelNSGui +HwndhGui, Name Selector (Name Search + Scroll List)
    App.GuiHwnd := hGui
    Gui, NS:Font, s10, Microsoft YaHei

    Gui, NS:Add, Text, x20 y20, Search name:
    Gui, NS:Add, Edit, vNS_NameInput gNS_NameChanged x20 y50 w820 h28
    Gui, NS:Add, Button, x860 y49 w120 h30 gNS_SearchNow, Search

    Gui, NS:Add, Button, x20 y690 w240 h44 Default gNS_Confirm, Confirm
    Gui, NS:Add, Button, x280 y690 w240 h44 gNS_Cancel, Cancel

    Gui, NS:Add, ListView, vNS_List gNS_ListPick x20 y100 w1260 h570 Grid AltSubmit, No.|Name|Id

    Gui, NS:Show, Center w%winW% h%winH%, Name Selector

    NameSel_RefreshListView()
    NameSel_SelectBySeq(App.LastSeq, false)
    GuiControl, NS:Focus, NS_NameInput
}

NameSel_RefreshListView()
{
    global App

    Gui, NS:ListView, NS_List
    LV_Delete()

    for fn_idx, fn_item in App.Items
        LV_Add("", fn_item.seq, fn_item.name, fn_item.id)

    LV_ModifyCol(1, 70)
    LV_ModifyCol(2, 1050)
    LV_ModifyCol(3, 0)
}

NameSel_SelectBySeq(seq, updateInput)
{
    global App

    if (seq < 1 || seq > App.Total)
        return false

    App.Selecting := true
    Gui, NS:ListView, NS_List
    LV_Modify(0, "-Select -Focus")
    LV_Modify(seq, "Select Focus Vis")
    App.Selecting := false

    App.SelectedSeq := seq
    App.LastSeq := seq

    if (updateInput)
    {
        fn_name := App.Items[seq].name
        GuiControl, NS:, NS_NameInput, %fn_name%
    }
    return true
}

NameSel_SelectByNameInput(nameInput, showNotice)
{
    global App

    fn_query := NameSel_NormalizeText(nameInput)
    if (fn_query = "")
        return false

    fn_foundSeq := NameSel_FindSeqByName(fn_query)
    if (fn_foundSeq <= 0)
    {
        if (showNotice)
            MsgBox, 48, Notice, Name not found.
        return false
    }

    return NameSel_SelectBySeq(fn_foundSeq, false)
}

NameSel_FindSeqByName(query)
{
    global App

    ; exact match first
    for fn_idx, fn_item in App.Items
    {
        if (fn_item.name = query)
            return fn_idx
    }

    ; then fuzzy contains (case-insensitive)
    for fn_idx2, fn_item2 in App.Items
    {
        if InStr(fn_item2.name, query, false)
            return fn_idx2
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

    FileRead, fn_jsonText, %jsonPath%
    if (ErrorLevel)
    {
        MsgBox, 16, Error, Failed to read JSON:`n%jsonPath%
        return false
    }

    fn_items := []
    fn_seq := 1
    fn_pos := 1
    fn_objPattern := "\{[^{}]*\}"

    while (fn_pos := RegExMatch(fn_jsonText, fn_objPattern, fn_objMatch, fn_pos))
    {
        fn_objText := fn_objMatch
        fn_hasId := RegExMatch(fn_objText, """id""\s*:\s*""((?:\\.|[^""\\])*)""", fn_mId)
        fn_hasName := RegExMatch(fn_objText, """name""\s*:\s*""((?:\\.|[^""\\])*)""", fn_mName)

        if (fn_hasId && fn_hasName)
        {
            fn_id := NameSel_JsonUnescape(fn_mId1)
            fn_name := NameSel_JsonUnescape(fn_mName1)
            fn_items.Push({ seq: fn_seq, name: fn_name, id: fn_id })
            fn_seq++
        }

        fn_pos += StrLen(fn_objMatch)
    }

    if (fn_items.MaxIndex() = "")
    {
        MsgBox, 16, Error, No {id,name} object found in JSON.
        return false
    }

    App.Items := fn_items
    return true
}

; ----------------------------
; Runtime/config
; ----------------------------
NameSel_SaveRuntime(seq, name, id, cmdLine)
{
    global App

    IniWrite, %seq%, % App.IniPath, Runtime, LastSeq
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
}

; ----------------------------
; Command run
; ----------------------------
NameSel_WriteAndRunCmd(id)
{
    global App

    fn_cmdBody := StrReplace(App.CmdTemplate, "{id}", id)
    fn_runTarget := ComSpec . " /c " . Chr(34) . fn_cmdBody . Chr(34)
    Run, %fn_runTarget%,, Hide UseErrorLevel
    if (ErrorLevel)
        MsgBox, 48, Notice, Failed to run command:`n%fn_cmdBody%
    return fn_cmdBody
}

NameSel_IsActive()
{
    global App
    return (App.GuiHwnd && WinActive("ahk_id " . App.GuiHwnd))
}

NameSel_NormalizeText(str)
{
    str := Trim(str)
    str := StrReplace(str, "`r`n", " ")
    str := StrReplace(str, "`n", " ")
    str := StrReplace(str, "`r", " ")
    str := StrReplace(str, "`t", " ")
    return Trim(str)
}

; ----------------------------
; Helper
; ----------------------------
NameSel_JsonUnescape(str)
{
    fn_placeholder := Chr(1)
    str := StrReplace(str, "\\", fn_placeholder)
    str := StrReplace(str, "\/", "/")
    str := StrReplace(str, "\" . Chr(34), Chr(34))
    str := StrReplace(str, "\r", "`r")
    str := StrReplace(str, "\n", "`n")
    str := StrReplace(str, "\t", "`t")

    fn_loopGuard := 0
    while RegExMatch(str, "\\u([0-9A-Fa-f]{4})", fn_mu)
    {
        fn_loopGuard++
        if (fn_loopGuard > 3000)
            break
        fn_code := "0x" . fn_mu1
        str := StrReplace(str, fn_mu, Chr(fn_code))
    }

    str := StrReplace(str, fn_placeholder, Chr(92))
    return str
}
