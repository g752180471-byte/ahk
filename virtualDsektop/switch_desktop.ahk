#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance Force
SetBatchLines, -1

; This file provides functions to be called by another AHK script.

global InputDigit
global DesktopList_State := { cacheRows: "", cacheTick: 0, cacheTtlMs: 10000, refreshInProgress: false }
SetTimer, __DesktopListPrimeCache, -50

ShowDesktopList() {
    global DesktopList_State

    ; Fast path: show cached data first, refresh in background if stale.
    if (IsObject(DesktopList_State.cacheRows) && DesktopList_State.cacheRows.MaxIndex() > 0) {
        ShowDesktopListGui(DesktopList_State.cacheRows)
        if ((A_TickCount - DesktopList_State.cacheTick) > DesktopList_State.cacheTtlMs)
            SetTimer, __DesktopListPrimeCache, -10
        return
    }

    rows := DesktopList_RefreshCache()
    if (!IsObject(rows) || rows.MaxIndex() = 0) {
        MsgBox, 48, Desktop List, No desktops found.
        return
    }

    ShowDesktopListGui(rows)
}

DesktopList_RefreshCache() {
    global DesktopList_State

    if (DesktopList_State.refreshInProgress)
        return DesktopList_State.cacheRows

    DesktopList_State.refreshInProgress := true
    rows := DesktopList_FetchRows()
    if (IsObject(rows) && rows.MaxIndex() > 0) {
        DesktopList_State.cacheRows := rows
        DesktopList_State.cacheTick := A_TickCount
    }
    DesktopList_State.refreshInProgress := false
    return rows
}

DesktopList_FetchRows() {
    tmpFile := A_Temp "\desktop_list.txt"

    cmd := "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ""$i=0; Get-DesktopList | ForEach-Object { '{0}`t{1}`t{2}' -f $i, $_.Name, $_.Visible; $i++ } | Set-Content -Path '" tmpFile "' -Encoding UTF8"""
    RunWait, %cmd%, , Hide
    FileRead, output, %tmpFile%

    if (Trim(output) = "") {
        cmd := "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ""Get-DesktopList *>&1 | Out-String | Set-Content -Path '" tmpFile "' -Encoding UTF8"""
        RunWait, %cmd%, , Hide
        FileRead, output, %tmpFile%
    }
    return ParseDesktopRows(output)
}

ParseDesktopRows(output) {
    rows := []
    lines := StrSplit(output, "`n", "`r")
    Loop % lines.MaxIndex()
    {
        line := Trim(lines[A_Index])
        if (A_Index = 1)
            line := StrReplace(line, Chr(65279))
        if (line = "")
            continue
        if (RegExMatch(line, "i)^number\\s+name\\b"))
            continue
        if (RegExMatch(line, "^-+$"))
            continue

        if (InStr(line, "`t")) {
            parts := StrSplit(line, "`t")
            num := Trim(parts[1])
            name := Trim(parts[2])
            visible := Trim(parts[3])
            StringLower, visibleLower, visible
            rows.Push({ num: num, name: name, visible: (visibleLower = "true") })
            continue
        }

        if (RegExMatch(line, "i)^\\s*\\d+\\s+(.+?)\\s{2,}.*\\s+(true|false)\\s*$", m)) {
            name := m1
            visible := m2
            StringLower, visibleLower, visible
            rows.Push({ num: "?", name: name, visible: (visibleLower = "true") })
        }
    }
    return rows
}

ShowDesktopListGui(rows) {
    Gui, DesktopList:Destroy
    Gui, DesktopList:New, +AlwaysOnTop +ToolWindow +LabelDesktopList
    Gui, DesktopList:Margin, 10, 10
    Gui, DesktopList:Font, s10, Consolas
    Gui, DesktopList:Add, ListView, w560 r12 Grid +Multi, 序号|名称|对勾
    Gui, DesktopList:Default

    firstVisible := 0
    for index, row in rows {
        check := row.visible ? "✓" : ""
        displayNum := FormatDisplayDesktopNumber(row.num)
        rowIndex := LV_Add("", displayNum, row.name, check)
        if (row.visible) {
            LV_Modify(rowIndex, "Select Vis")
            if (!firstVisible)
                firstVisible := rowIndex
        }
    }

    if (firstVisible)
        LV_Modify(firstVisible, "Select Vis Focus")

    LV_ModifyCol(1, "AutoHdr")
    LV_ModifyCol(2, 360)
    LV_ModifyCol(3, "AutoHdr")

    Gui, DesktopList:Font, s9, Consolas
    Gui, DesktopList:Add, Text, , 输入 1-9:
    Gui, DesktopList:Add, Edit, vInputDigit gInputDigitChanged w60
    Gui, DesktopList:Add, Button, gDesktopListSubmit Default w80, 确定
    Gui, DesktopList:Show, , Desktop List
    GuiControl, DesktopList:Focus, InputDigit
}

DesktopListSubmit:
    GuiControlGet, input, DesktopList:, InputDigit
    input := Trim(input)
    if (!RegExMatch(input, "^[1-9]$")) {
        Gui, DesktopList:Destroy
        return
    }
    targetDesktop := input - 1
    SwitchDesktopByNumber(targetDesktop)
    Gui, DesktopList:Destroy
return

InputDigitChanged:
    GuiControlGet, input, DesktopList:, InputDigit
    input := Trim(input)
    if (RegExMatch(input, "^[1-9]$")) {
        targetDesktop := input - 1
        SwitchDesktopByNumber(targetDesktop)
        Gui, DesktopList:Destroy
    }
return

DesktopListClose:
DesktopListEscape:
    Gui, DesktopList:Destroy
return

SwitchDesktopByNumber(num) {
    cmd := "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ""Switch-Desktop -Desktop " num """"
    Run, %cmd%, , Hide
}

FormatDisplayDesktopNumber(rawNum) {
    if RegExMatch(Trim(rawNum), "^\d+$")
        return (rawNum + 1)
    return rawNum
}

__DesktopListPrimeCache:
    DesktopList_RefreshCache()
return
