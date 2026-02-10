#NoEnv
#SingleInstance Force
SetBatchLines, -1
ListLines Off

global g_LastDate := ""
global g_LastHour := -1
global g_CellNames := {}

BuildUi()
Gosub, RefreshDisplay
SetTimer, RefreshDisplay, 1000
return

RefreshDisplay:
    now := A_Now
    datePart := SubStr(now, 1, 8)
    hourPart := SubStr(now, 9, 2) + 0
    timeText := FormatDateTime(now)

    GuiControl,, TitleText, Local Computer Time: %timeText%
    GuiControl,, StatusText, Status: local time from this computer

    if (datePart != g_LastDate || hourPart != g_LastHour) {
        UpdateGrid(datePart, hourPart)
        g_LastDate := datePart
        g_LastHour := hourPart
    }
return

BuildUi() {
    global g_CellNames

    marginX := 16
    marginY := 14
    leftWidth := 130
    cellW := 21
    cellH := 14
    colGap := 2
    rowGap := 4

    headerY := marginY + 52
    gridStartY := headerY + 24
    windowW := marginX * 2 + leftWidth + 24 * (cellW + colGap) - colGap
    windowH := gridStartY + 15 * (cellH + rowGap) + 56

    Gui, +Resize +MinSize780x420
    Gui, Margin, %marginX%, %marginY%
    Gui, Color, F7F9FC
    Gui, Font, s11 c203040, Segoe UI
    Gui, Add, Text, x%marginX% y%marginY% w760 h24 vTitleText, Local Computer Time: loading...

    Gui, Font, s9 c465A74, Segoe UI
    statusY := marginY + 26
    Gui, Add, Text, x%marginX% y%statusY% w780 h18 vStatusText, Status: local time from this computer

    Gui, Font, s9 c4A5563, Segoe UI
    tipY := marginY + 43
    Gui, Add, Text, x%marginX% y%tipY% w800 h18, Range: -7 days + today + +7 days, each block = 1 hour (24 total)

    Gui, Font, s9 c3A4656, Segoe UI
    Gui, Add, Text, x%marginX% y%headerY% w%leftWidth% h20 Center Border, Date

    Loop, 24 {
        idx := A_Index - 1
        x := marginX + leftWidth + (cellW + colGap) * (A_Index - 1)
        txt := Pad2(idx)
        Gui, Add, Text, x%x% y%headerY% w%cellW% h20 Center Border, %txt%
    }

    Loop, 15 {
        row := A_Index
        y := gridStartY + (cellH + rowGap) * (row - 1)
        rowName := "DateRow" . row
        Gui, Font, s9 c334155, Segoe UI
        Gui, Add, Text, x%marginX% y%y% w%leftWidth% h%cellH% Center Border v%rowName%,

        Loop, 24 {
            col := A_Index
            x := marginX + leftWidth + (cellW + colGap) * (col - 1)
            cellName := "Cell_" . row . "_" . col
            g_CellNames[row . ":" . col] := cellName
            Gui, Add, Progress, x%x% y%y% w%cellW% h%cellH% v%cellName% cD8DEE7 BackgroundF1F4F8, 100
        }
    }

    Gui, Show, w%windowW% h%windowH%, Local Time 24h View
}

UpdateGrid(currentDate, currentHour) {
    global g_CellNames

    Loop, 15 {
        row := A_Index
        offset := row - 8
        day := currentDate
        EnvAdd, day, %offset%, Days
        label := BuildDayLabel(day, offset)
        rowName := "DateRow" . row
        GuiControl,, %rowName%, %label%

        if (offset = 0) {
            GuiControl, +c0B63B8, %rowName%
        } else {
            GuiControl, +c334155, %rowName%
        }

        Loop, 24 {
            col := A_Index
            cellName := g_CellNames[row . ":" . col]
            if (offset = 0 && (col - 1) = currentHour) {
                GuiControl, +cF16E2F +BackgroundFFE5D6, %cellName%
            } else if (offset = 0) {
                GuiControl, +c99BFE5 +BackgroundEAF3FF, %cellName%
            } else {
                GuiControl, +cD8DEE7 +BackgroundF1F4F8, %cellName%
            }
        }
    }
}

BuildDayLabel(ymd, offset) {
    names := ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    FormatTime, weekdayIndex, %ymd%, WDay
    weekName := names[weekdayIndex]
    label := SubStr(ymd, 1, 4) "-" SubStr(ymd, 5, 2) "-" SubStr(ymd, 7, 2) " " . weekName
    if (offset = 0) {
        label .= "  Today"
    }
    return label
}

Pad2(n) {
    return SubStr("0" . n, -1)
}

FormatDateTime(ts) {
    return SubStr(ts, 1, 4) "-" SubStr(ts, 5, 2) "-" SubStr(ts, 7, 2) " "
        . SubStr(ts, 9, 2) ":" SubStr(ts, 11, 2) ":" SubStr(ts, 13, 2)
}

GuiClose:
GuiEscape:
    ExitApp
