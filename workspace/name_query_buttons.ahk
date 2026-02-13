; AutoHotkey v1
; Fixed-button launcher:
; 1) Keep xlsx/pptx behavior from name_query_dialog.ahk
; 2) Remove List 3/4 panels completely
; 3) Pin num=3, num=4, and num=125 commands as fixed buttons (independent from future dialog changes)

#Requires AutoHotkey v1.1.33+
#NoEnv
#Warn
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8

global App := {}

if (A_LineFile = A_ScriptFullPath)
{
    NQ_Run()    
}
return

NQ_Run()
{
    global App

    NQ_Init()
    if (!App.Ready)
        return

    NQ_ShowGui()
}

NQ_Init()
{
    global App

    App := {}
    SplitPath, A_LineFile, , scriptDir
    App.IniPath := scriptDir . "\NameSelector.ini"
    App.Ready := false

    ; Copied from name_query_dialog.ahk
    App.PinnedFilePath := "C:\Users\75218\Nutstore\1\我的坚果云\我-使用说明书.pptx"
    App.PinnedFileName := "我-使用说明书.pptx"
    App.PinnedFileCmdTemplate := "start " . Chr(34) . Chr(34) . " " . Chr(34) . "{id}" . Chr(34)
    App.DailyPlanDir := "C:\Users\75218\Desktop\时间计划\2026"
    App.DailyPlanName := "今日计划"
    App.DailyPlanTag := "__daily_plan__"

    ; Fixed command template (do not read from ini, so it will not drift).
    App.FixedEdgeCmdTemplate := """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"" --launch-workspace={id}"
    App.FixedEdgeCanCmdTemplate := """C:\Users\75218\AppData\Local\Microsoft\Edge SxS\Application\msedge.exe"" --launch-workspace={id}"

    ; Fixed num=3 / num=4 snapshot from current name_query_dialog data source.
    ; These ids are intentionally hardcoded.
    App.FixedNum3Item := { seq: 3
        , name: "时间"
        , id: "1e82a035-343e-4501-9344-5435ed5b6316"
        , cmdTemplate: App.FixedEdgeCmdTemplate
        , type: "fixed_workspace" }

    App.FixedNum4Item := { seq: 4
        , name: "我-使用说明+元架构所有信息"
        , id: "f3d4097b-e065-46fc-be91-7a70186151a0"
        , cmdTemplate: App.FixedEdgeCmdTemplate
        , type: "fixed_workspace" }

    ; Fixed num=125 snapshot from current name_query_dialog data source.
    App.FixedNum125Item := { seq: 125
        , name: "____②notion日历"
        , id: "6f785fef-827d-4340-b56a-1f171946271b"
        , cmdTemplate: App.FixedEdgeCanCmdTemplate
        , type: "fixed_workspace" }

    dailyName := App.DailyPlanName . " (" . NQ_GetDailyPlanY() . ")"
    App.DailyPlanItem := { seq: 1
        , name: dailyName
        , id: App.DailyPlanTag
        , cmdTemplate: App.PinnedFileCmdTemplate
        , type: "daily_plan" }

    App.PinnedItem := { seq: 2
        , name: App.PinnedFileName
        , id: App.PinnedFilePath
        , cmdTemplate: App.PinnedFileCmdTemplate
        , type: "file" }

    App.Ready := true
}

NQ_ShowGui()
{
    global App

    leftX := 20
    topY := 20
    btnW := 420
    btnH := 42
    gapY := 10
    y := topY

    Gui, NQ:New, -MinimizeBox +LabelNQGui +HwndhGui, Workspace Fixed Buttons
    App.GuiHwnd := hGui
    Gui, NQ:Font, s10, Microsoft YaHei

    Gui, NQ:Add, Text, x%leftX% y%y%, 聚焦界面
    y += 26

    
    Gui, NQ:Add, Button, Default hwndhBtnDaily x%leftX% y%y% w%btnW% h%btnH% gNQ_OpenPinned, 0.第三视角--看我(.pptx)
    y += btnH + gapY
    Gui, NQ:Add, Button,  x%leftX% y%y% w%btnW% h%btnH% gNQ_RunFixed4, 1.第一顺序-(幕布)-情绪、时间、空间(知识点所在位置查找方法)
    y += btnH + gapY
    Gui, NQ:Add, Button, x%leftX% y%y% w%btnW% h%btnH% gNQ_RunFixed3,  a.目标+任务列表（幕布）
    y += btnH + gapY
    Gui, NQ:Add, Button, x%leftX% y%y% w%btnW% h%btnH% gNQ_OpenDaily, b.每天---目标+行动 (.xlsx)
    y += btnH + gapY
    Gui, NQ:Add, Button, x%leftX% y%y% w%btnW% h%btnH% gNQ_RunFixed125, c.日历
    y += btnH + gapY+100
    Gui, NQ:Add, Button, x%leftX% y%y% w%btnW% h%btnH% gNQ_Close, 关闭
    
    Gui, NQ:Show, AutoSize Center, Workspace Fixed Buttons
    WinActivate, ahk_id %hGui%
    WinWaitActive, ahk_id %hGui%,, 1
    if (hBtnDaily)
        DllCall("SetFocus", "Ptr", hBtnDaily, "Ptr")
}

NQ_OpenDaily:
    global App
    if (NQ_ExecuteItem(App.DailyPlanItem))
        Gosub, NQ_Close
return

NQ_OpenPinned:
    global App
    if (NQ_ExecuteItem(App.PinnedItem))
        Gosub, NQ_Close
return

NQ_RunFixed3:
    global App
    if (NQ_ExecuteItem(App.FixedNum3Item))
        Gosub, NQ_Close
return

NQ_RunFixed4:
    global App
    if (NQ_ExecuteItem(App.FixedNum4Item))
        Gosub, NQ_Close
return

NQ_RunFixed125:
    global App
    if (NQ_ExecuteItem(App.FixedNum125Item))
        Gosub, NQ_Close
return

NQ_Close:
NQGuiClose:
NQGuiEscape:
    Gui, NQ:Destroy
    ExitApp
return

NQ_ExecuteItem(execItem)
{
    if !IsObject(execItem)
        return false

    runLine := NQ_WriteAndRunCmd(execItem)
    if (runLine = "")
        return false

    itemId := NQ_GetItemEffectiveId(execItem)
    NQ_SaveRuntime(execItem.seq, execItem.name, itemId, runLine)
    Clipboard := itemId
    return true
}

NQ_SaveRuntime(seq, name, id, cmdLine)
{
    global App

    IniWrite, %seq%, % App.IniPath, Runtime, LastSeq
    IniWrite, %name%, % App.IniPath, Runtime, LastName
    IniWrite, %id%, % App.IniPath, Runtime, LastId
    IniWrite, %A_Now%, % App.IniPath, Runtime, LastTime
    IniWrite, %cmdLine%, % App.IniPath, Runtime, LastCmd
}

NQ_WriteAndRunCmd(workItem)
{
    global App

    if !IsObject(workItem)
        return ""

    workTargetId := NQ_GetItemEffectiveId(workItem)
    if (workTargetId = "")
        return ""

    if (workItem.type = "daily_plan" && !FileExist(workTargetId))
    {
        MsgBox, 48, Notice, % "Daily plan file not found:`n" . workTargetId
        return ""
    }

    ; If target looks like local file path but missing, stop with notice.
    if (!NQ_IsExistingFile(workTargetId)
        && RegExMatch(workTargetId, "i)^[A-Z]:\\")
        && RegExMatch(workTargetId, "\.[^\\/:*?""<>|\r\n]+$"))
    {
        MsgBox, 48, Notice, % "File not found:`n" . workTargetId
        return ""
    }

    ; Real file: open directly so Office can reuse windows.
    if NQ_IsExistingFile(workTargetId)
    {
        Run, %workTargetId%,, UseErrorLevel
        if (ErrorLevel)
        {
            MsgBox, 48, Notice, Failed to open file:`n%workTargetId%
            return ""
        }
        NQ_TryActivateOfficeWindow(workTargetId)
        return workTargetId
    }

    cmdTemplate := workItem.cmdTemplate
    if (cmdTemplate = "")
        cmdTemplate := App.FixedEdgeCmdTemplate

    cmdBody := StrReplace(cmdTemplate, "{id}", workTargetId)
    Run, %cmdBody%,, UseErrorLevel
    if (ErrorLevel)
    {
        MsgBox, 48, Notice, Failed to run command:`n%cmdBody%
        return ""
    }
    return cmdBody
}

NQ_IsExistingFile(path)
{
    attrs := FileExist(path)
    if (attrs = "")
        return false
    return !InStr(attrs, "D")
}

NQ_TryActivateOfficeWindow(filePath)
{
    SplitPath, filePath, , , ext
    StringLower, ext, ext

    if (ext = "xlsx" || ext = "xls" || ext = "xlsm" || ext = "xlsb")
    {
        Sleep, 120
        WinActivate, ahk_exe EXCEL.EXE
        return
    }

    if (ext = "pptx" || ext = "ppt" || ext = "pptm")
    {
        Sleep, 120
        WinActivate, ahk_exe POWERPNT.EXE
        return
    }
}

NQ_GetItemEffectiveId(workItem)
{
    if !IsObject(workItem)
        return ""

    if (workItem.type = "daily_plan")
        return NQ_GetDailyPlanPath()

    return workItem.id
}

NQ_GetDailyPlanY()
{
    return A_MM . "." . A_DD
}

NQ_GetDailyPlanPath()
{
    global App
    return App.DailyPlanDir . "\" . NQ_GetDailyPlanY() . ".xlsx"
}
