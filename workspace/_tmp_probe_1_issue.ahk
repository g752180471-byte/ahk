#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

FileDelete, %A_ScriptDir%\_tmp_probe_1_issue.txt

NameSel_Init()
if (!App.Ready) {
    FileAppend, init_failed, %A_ScriptDir%\_tmp_probe_1_issue.txt, UTF-8
    ExitApp
}

NameSel_ShowGui()
Sleep, 200

; test input 1
NS_SeqInput := "1"
Gosub, NS_SeqChanged
Sleep, 100
GuiControlGet, nowText1, NS:, NS_SeqInput
GuiControlGet, posName1, NS:, NS_List1
GuiControlGet, posIdx1, NS:, NS_Idx1
line1 := "input=1|SelectedSeq=" . App.SelectedSeq . "|Text=" . nowText1 . "|posName=" . posName1 . "|posIdx=" . posIdx1 . "`n"

; test input 2
NS_SeqInput := "2"
Gosub, NS_SeqChanged
Sleep, 100
GuiControlGet, nowText2, NS:, NS_SeqInput
GuiControlGet, posName2, NS:, NS_List1
GuiControlGet, posIdx2, NS:, NS_Idx1
line2 := "input=2|SelectedSeq=" . App.SelectedSeq . "|Text=" . nowText2 . "|posName=" . posName2 . "|posIdx=" . posIdx2 . "`n"

FileAppend, %line1%%line2%, %A_ScriptDir%\_tmp_probe_1_issue.txt, UTF-8
Gui, NS:Destroy
ExitApp
return

#Include %A_ScriptDir%\name_query_dialog.ahk
