#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

result := NameSel_RunDialog()

if (!IsObject(result) || !result.confirmed)
{
    MsgBox, 48, Notice, Canceled or failed.
    return
}

MsgBox, 64, Result, % "seq: " . result.seq . "`nname: " . result.name . "`nid: " . result.id
return

#Include %A_ScriptDir%\name_query_dialog.ahk
