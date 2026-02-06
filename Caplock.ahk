#Persistent ; 让脚本持续运行，不退出
myVare :=true ; 初始化 myVar 变量为 false
sleep,50
;MsgBox CapsLock 设置为 AlwaysOff
;这个表示关闭大小写功能
SetCapsLockState, AlwaysOff
;;基本规则
    ;1.名称
         ;3行空格
        ;   或者 选择---
    ;2.分隔符
        ;使用空格
    ; 3.二级标签
    ;     4个____


;;使用本文-修改点
;改1.txt名字
;改图片
;改本ahk的点
;; 

;; F12--控制value值，锁死caps键
!F12::
    myVare := !myVare
    if myVare
    {
        MsgBox 0,图标.ahk,开启了功能！,0.3
        SetCapsLockState, AlwaysOff
    }
    else
    {
        MsgBox 0,图标.ahk,关闭了功能！,0.3
        SetCapsLockState, AlwaysOn
    }
return

;;myValue=true，下列代码才能用

;; 
;; #---导入虚拟桌面ahk
#Include %A_ScriptDir%\virtualDsektop\switch_desktop.ahk
;; 
#If (myVare=true) 
    ;按键映射

;; Cap+a、s
Capslock & a::
Send ^#{Left}
; Sleep, 100
    ; ShowDesktopList()
    Return
Capslock & S::
    Send ^#{Right}
    ; Sleep, 100
    ; ShowDesktopList()

Return
;;Cap+d   点击索引
Capslock & d::Click 535, 40

;; 
;; Cap+e   幕布---节点复制+退出
Capslock & e::
    Send,{Home}
    Send, {ASC 35} 

    Sleep 200
    Send, ^d

    Sleep 200
    Send +{Tab}
    Send +{Tab}

    Send +{Tab}
    Send +{Tab}

    Send +{Tab}
    Send +{Tab}

    Send +{Tab}
    Send +{Tab}
return

;; Cap+q   点击工作区
Capslock & q::
dianwork: 
    WinGetTitle, title, A

    isEdge := (InStr(title, "Microsoft") and InStr(title, "Edge"))

    Click 50, 40
    Sleep 200
    Send {Tab}
    Send {Tab}
    Send {Tab}

    ;MsgBox, 获取到的标题是: %title%
    if (isEdge){

    } else {

        Send {Tab}

    }
    Input, key, L2, {Down}{PgDn}{Esc} ; 如果按下 Down 键就结束输入并返回

    ; 检查是否按了 Down 键
    if (ErrorLevel = "EndKey:Down")
    {
        Send, {Down}
        return ; 按了 Down 键，取消后续操作
    }

    if (ErrorLevel = "EndKey:PgDn")
    {
        Send, {PgDn}
        return ; 按了 Down 键，取消后续操作
    }

    period := key +0 ; 强制转换为数字（如果输入非数字会变成0）

    if (period > 0)
    {
        Loop, % period
        {
            Send, {Down}
        }

    }
    else
    {
        ; MsgBox, 请输入数字！
        return 
    }

return

;; Cap+w---一键打开--幕布信息

; #Include %A_ScriptDir%\workspace\name_query_dialog.ahk
Capslock & w::
    nsScript := A_ScriptDir . "\workspace\name_query_dialog.ahk"
    if !FileExist(nsScript)
    {
        MsgBox, 48, 提示, 未找到脚本：`n%nsScript%
        return
    }

    ahkExe := A_AhkPath
    if !FileExist(ahkExe)
        ahkExe := "C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe"

    Run, "%ahkExe%" "%nsScript%", , UseErrorLevel
    if (ErrorLevel)
        MsgBox, 48, 提示, 启动失败：`n%nsScript%

Return


;; 
;;Cap+x  
; 1.弹出输入框，输入文字，2.点击索引，搜索3.暂停4.cap+q的操作
Capslock & x::

Return
;;-Cap+x   win+tab(作废)()
WinGetClass, ActiveClass, A

;  检查是否是桌面或系统窗口
isDesktop := (ActiveClass = "Progman") 
or (ActiveClass = "WorkerW") 
or (ActiveClass = "Shell_TrayWnd")
or (ActiveClass = "")

if (isDesktop)
{
    ; 任务2：在桌面上
    Send #{Tab}
    Send {Space}
}
else
{
    ; 任务1：有活动窗口
    Send #{Tab}
    Sleep 500
    Send {Tab}
    Send {Space}
}
return
;; Cap+z   edge-索引、RAM
Capslock & z::
    ; 1. 定义 Edge 正式版的绝对路径 (通常是这个，如果你的不一样，请看下文如何查找)
    EdgePath := "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

    ; Run, "%EdgePath%" --new-window "https://mubu.com/app/edit/home/44zC-L_0v2d?ref="
    ;Sleep 100

    ; WorkspaceURL1 := "https://mubu.com/app/edit/home/1o4szniQWE0#Phqn6zv806"
    ; Run, "%EdgePath%"    "%WorkspaceURL1%"

    Run, "%EdgePath%" --new-window "https://mubu.com/app/edit/home/1o4szniQWE0#0l1xPn2yFL"

    Sleep 100

    ; 2. 你的工作区链接 (记得替换成你自己的)
    WorkspaceURL := "https://mubu.com/app/edit/home/2H_7EU-_mE0#AACT9ZBg7E"

    Run, "%EdgePath%" "%WorkspaceURL%"

    ; Sleep, 2000
    ; SendInput, g 
return
;; 

;; Cap+1   win----查看

Capslock & 1::

; 需要显示列表时调用
ShowDesktopList()

return
;; 
;; Cap+2   幕布---输入--问题解决⭐⭐⭐
;; 
Capslock & 2::
    SendInput, ^{Numpad2}

    Sleep,100
    Loop,6
    {
        Send, {Up}
        Sleep,10
    }

return

;; Cap+3   win---切到主界面
Capslock & 3::
    cmd := "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ""Switch-Desktop -Desktop 0.索引"""
    Run, %cmd%, , Hide

return


;; Cap+4   马丽琴-发金币

Capslock & 4::
       
;SetMouseDelay, 50-正常运行
SetMouseDelay, 50

; 设置发送速度（可选，如果发送太快导致漏字，可以调大数字）

; 读取 UTF-8 格式文件
FileRead, content, *P65001 E:\code_project\ahk\1.txt

if ErrorLevel
{
    ToolTip, 无法读取文件！ ; 用气泡提示代替弹窗，不干扰操作
    Sleep, 2000
    ToolTip
return
}

; 按换行符分割
lines := StrSplit(content, "`n", "`r")

; 逐行发送
for index, line in lines
{
    ; 过滤掉完全空白的行（如果需要保留空行，可以删掉这个 if）
    if (Trim(line) != "")
    {

        Click 2533, 439
        Sleep, 100
        Click 2410, 480
        Sleep, 100
        ; 发送这一行的内容
        ; 使用 {Text} 模式可以确保特殊字符（如 # ! ^ +）被原样发送而不被当做快捷键
        line := Trim(line)
        SendInput, {Text}%line%

        Sleep, 100
        Gosub, CheckText

        Click, 2396, 518, Right

        Sleep, 500
        Click	2383, 537
        Sleep, 500
        Click	824, 1400
        Sleep, 500

        ;;_____可选修改点
        SendInput, ^{Numpad5}
        Sleep, 500
        SendInput, ^{Numpad6}
        Sleep, 500
        ;;_____修改点1

        SendInput, {Text}今天第6讲啦～每天都在进步，每天都是优秀宝子，冲冲冲，金币奖励🥇

        Loop, 0
        {
            SendInput, ^r
            Sleep, 500
            Click 986, 934
            Sleep, 500
        }

        ; KeyWait, F8, D
        Sleep, 500
        Send, {Enter}

        ; 发金币
        Sleep, 1000
        Click 2357, 217	
        Sleep, 4000
        Click 2475, 1458
        Sleep, 500
        Click 2477, 1105

        Sleep, 1000

        Gosub, CheckNumber

        Click 2472, 668

        SendInput, {Text}1000
        Click 2497, 745
        Click 2220, 678

        Click 2297, 1443
        Sleep, 1000

        Click 2436, 1146
        Sleep, 500
        Click	824, 1400
        Sleep, 3000
        Send, {Enter}

        ; 转回群
        Sleep, 500
        Click 228, 51
        ;;_____修改点2
        SendInput, {Text}冬一期4B中
        Sleep, 1500
        Send, {Enter}

        ; 每一行之间稍微停顿一下，模拟人类输入，也给软件反应时间
        Sleep, 100
        ;FileAppend, %line%----`n, C:\Users\75218\Desktop\3.txt, UTF-8
    }
}

ToolTip, 内容发送完毕！
Sleep, 1000
ToolTip

return


Capslock & 5::
    Send, {F6} 
Return
;; 
CheckNumber: ; v1 脚本内容
    SetKeyDelay, 50

    ; 1. 准备阶段
    Clipboard := ""
    Sleep, 50

    ; 2. 定义参数
    ; 这里的路径一定要加引号，防止空格导致失效
    v2_interpreter := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
    v2_script := "E:\code_project\ahk\AHK2.ahk"

    posX := 2372
    posY := 564
    posW := 187 ; 2559 - 2372
    posH := 50 ; 614 - 564

    Sleep, 50

    ; 3. 调用 v2 进行 OCR 识别
    ; 注意：v2_interpreter 变量两侧加了引号
    Run, "%v2_interpreter%" "%v2_script%" %posX% %posY% %posW% %posH%

    Sleep, 50

    ; 4. 等待回传结果 (最多等 3 秒)
    ClipWait, 3
    if (ErrorLevel) {
        ToolTip, OCR 响应超时
        Sleep, 1000
        ToolTip
        return
    }

    Sleep, 50

    ; ... 前面 Run 和 ClipWait 代码保持不变 ...

    ; 5. 获取并清洗数据
    num := Trim(Clipboard)

    ; 尝试将结果转换为数字，如果不是数字（比如 ERROR），num_val 会变成空
    num_val := num + 0 

    ; --- 核心判断条件 ---
    ; 条件：结果为空 OR 是错误标识 OR 不是数字 OR 数字 < 1000
    if (num = "" || num = "NOT_FOUND" || num = "ERROR" || num_val = "" || num_val < 1000) 
    {

        ; 触发暂停条件
        MsgBox, 48, 提示, 识别结果 [%num%] 不符合要求（为空或小于100）。`n程序已暂停，按 F8 继续。
        KeyWait, F8, D
    } 
    else 
    {
    }

    ToolTip
return

;; Cap+p   重载
Capslock & p::
    MsgBox, 0, 提示, 🔄 脚本重新加载中..., 0.5

    Reload

return

CheckText: ; v1 子程序
    SetKeyDelay, 50

    ; ========= 1. 准备 =========
    Clipboard := ""
    Sleep, 50

    ; ========= 2. OCR 参数 =========
    v2_interpreter := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
    v2_script := "E:\code_project\ahk\AHK2.ahk"

    posX := 2272
    posY := 504
    posW := 400
    posH := 20

    Sleep, 50

    ; ========= 3. 调用 v2 OCR =========
    Run, "%v2_interpreter%" "%v2_script%" %posX% %posY% %posW% %posH% text

    ; ========= 4. 等待 OCR 结果 =========
    ClipWait, 3
    if (ErrorLevel)
    {
        ToolTip, OCR 响应超时
        Sleep, 1000
        ToolTip
        return
    }

    Sleep, 50

    ; ========= 5. OCR 文本清洗 =========
    x := Clipboard

    ; ========= 6. 仅判断是否为空 =========
    if (x = "" || x = "NOT_FOUND" || x = "ERROR")
    {
        MsgBox, 48, 提示,搜索--%line%--为空，F8-继续
        KeyWait, F8, D
        return
    }

    ; Else
    ; {
    ;      ; 去掉换行 / 制表符
    ; x := StrReplace(x, "`r")
    ; x := StrReplace(x, "`n")
    ; x := StrReplace(x, "`t")

    ; ; 只保留 中文 / 英文 / 数字
    ; x := RegExReplace(x, "[^0-9A-Za-z一-龥]", "")
    ; x := Trim(x)
    ;     MsgBox,%x%
    ; }

    ; 有内容 → 直接返回，继续主流程
return

;#IfWinActive ahk_exe idea64.exe
;F7::
;MsgBox 操作已取消
;send,{F7}
;return          

;翻转Capslock大小写锁定的状态
;$*Capslock::
;SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
;Return
