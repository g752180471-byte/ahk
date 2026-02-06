; AutoHotkey v1
; Press F9 to read 1.json and overwrite name_values.json + name_values.txt.

#NoEnv
#Warn
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8

global inputFile := "C:\Users\75218\AppData\Local\Microsoft\Edge\User Data\Default\Workspaces\WorkspacesCache"
global outputJsonFile := A_ScriptDir . "\name_values.json"
global outputTxtFile := A_ScriptDir . "\name_values.txt"

TrayTip, AHK Exporter, Ready. Press F9 to overwrite JSON+TXT, 3, 1
return

F9::
count := ExtractAndWrite(inputFile, outputJsonFile, outputTxtFile)
if (count = -1)
{
    MsgBox, 16, Error, File not found:`n%inputFile%
    return
}
if (count = -2)
{
    MsgBox, 16, Error, Read failed:`n%inputFile%
    return
}
MsgBox, 64, Done-覆写成功, Wrote-写入 %count% lines to:`n%outputJsonFile%`n%outputTxtFile%
return

ExtractAndWrite(inPath, outJsonPath, outTxtPath)
{
    if !FileExist(inPath)
        return -1

    FileRead, json, %inPath%
    if (ErrorLevel)
        return -2

    pattern := """name""\s*:\s*""((?:\\.|[^""\\])*)"""
    pos := 1
    idx := 0
    jsonOut := "[`r`n"
    txtOut := ""
    first := true

    while (pos := RegExMatch(json, pattern, m, pos))
    {
        if (!first)
            jsonOut .= ",`r`n"

        jsonOut .= "  {""index"":" . idx . ",""name"":""" . JsonEscape(m1) . """}"
        txtOut .= idx . ": " . m1 . "`r`n"
        first := false
        idx++
        pos += StrLen(m)
    }

    if (idx = 0)
        jsonOut .= "]`r`n"
    else
        jsonOut .= "`r`n]`r`n"

    FileDelete, %outJsonPath%
    FileAppend, %jsonOut%, %outJsonPath%, UTF-8

    FileDelete, %outTxtPath%
    FileAppend, %txtOut%, %outTxtPath%, UTF-8

    return idx
}

JsonEscape(str)
{
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, Chr(34), "\" . Chr(34))
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`t", "\t")
    return str
}
