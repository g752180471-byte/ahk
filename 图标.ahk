#Persistent ; 让脚本持续运行，不退出
myVare := false ; 初始化 myVar 变量为 false
myVare1 := false ; 初始化 myVar 变量为 false
y := " "
;循环的初始值
x := 1
;循环次数差值的初始值
Start := 1
;循环次数差值的结束值
End := 20

;;F1---控制开关
;; 
!F1::
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return
#If (myVare=true) ; 只有当 myVar 为 true 时才激活以下的热键

;;1---任意更改
;; 
1::

       Send, m
       Sleep, 100 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
       Send, {Tab} ; 
       Sleep, 100 ;
       Send, {Space} 
       Sleep, 100 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 50 ; 

return

;;2---excel删除工作表--键盘--d、回车
;; 
2::

       Send, d
       Sleep, 100 ; 

       Send, {Enter} ; 
       Sleep, 50 ; 

return

;;3---鼠标--循环点击2
3::

       Loop,100
       {

              Sleep, 40 ; 
              Click 900, 1300
       }
return

;;4---鼠标--循环点击1
4::

       Loop,100
       {
              Loop,11
              {
                     Click 1600, 700
                     Sleep, 100 
                     Click 928, 757
                     Sleep, 3000
              }

              Click 1244, 1329
              Sleep, 3000

       }
return

;;5---鼠标--循环点击
5::

       Loop,1000
       {

              Click
              Sleep, 100
       }
return

;;q---ico桌面图标1
q::
       ;Send, {AppsKey}
       ; Sleep, 100 ; 
       Send, r ; 
       Sleep, 1000 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 1000 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 1000 ; 
       Send, +{Tab} ; 
return

;;w---ico桌面图标2
w::
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 1000 ; 
       Send, {Tab} ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 1000 ; 
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return

;;点击任务栏
e::
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
       Sleep, 100 ; 
       Send, #b ; 
       Sleep, 100 ; 
       Send, {Enter} ; 
       Sleep, 300 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
       Send, {Down} ; 
       Sleep, 100 ; 
return

;;x---键盘--头右底
x::
       Send, {Home}
       Sleep, 100 ; 
       Send, ^{Right}; 
       Sleep, 100 ; 
       Send, {Enter}
return

;; 
;;s---幕布---循环操作
;; 
s::
       ;IniRead, Start, D:\2\config.ini, Settings, Start
       ;IniRead, End, D:\2\config.ini, Settings, End
       Loop, % End - Start + 1
       {
              Send, {Home} ; 
              Sleep, 100 ; 
              ClipSaved := ClipboardAll ; 保存剪贴板的原始内容
              Clipboard := "" ; 清空剪贴板
              Send, {Home} 
              Sleep, 50 ; 
              Send, +{End} 
              Sleep, 50 ;
              SetKeyDelay, 10,10
              Send,^c
              SetKeyDelay, -1
              ; 模拟 Ctrl + C 复制选中的文字
              ClipWait, 2 ; 等待剪贴板内容更新，超时为 2 秒
              if Clipboard
              {
                     selectedText := Clipboard ; 将选中的文字赋值到变量 selectedText
              }
              else
              {
              }
              Clipboard := "" ; 清空剪贴板
              Clipboard := ClipSaved ; 恢复剪贴板原始内容
              Send, {Home} ; 
              Sleep, 100 ; 
              position := InStr(selectedText, ".") ; 检测 . 的位置并赋值给变量 position
              if (position > 0)
              {
                     Start1 := 1
                     Loop, % position - Start1
                     {
                            Send, {Right} ; 
                            Sleep, 50 ;  
                            Send, {Backspace} ; 
                            Sleep, 50 ; 
                     }
              }
              else
              {
                     Send, {ASC 46} ; ASCII 46 是英文点号 .
                     Sleep, 50 ;  
                     Send, {Home} ; 
                     Sleep, 50 ; 
              }
              Send, %x% ; 
              Sleep, 200 ; 
              Send, {Down} ; 
              Sleep, 200 ; 
              Send, {Down} ; 
              Sleep, 200 ; 
              x := x + 1 ;
       }
return

;;d---幕布---问题解决3
d::
       Send, {Up} ; 
       Sleep, 50 ;
       Send, {End} ; 
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Down} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 目的-结论
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 目的-行动
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 收集信息
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 产品{ASC 40}印记{ASC 43}{ASC 46}{ASC 46}{ASC 46}{ASC 46}{ASC 41}
       Send,!4
       Sleep, 50 ; 
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return

;;z---鼠标--打勾
z::
       MouseGetPos, x, y ; 获取当前鼠标位置
       Click down ; 按住左键
       ; 按“√”的路径移动鼠标
       Sleep 100
       MouseMove, x+30, y+50, 4 ; 向右下移动
       Sleep 100
       MouseMove, x+60+30, y-50, 4 ; 向右上移动
       Click up ; 松开左键
return

;;f---幕布---问题解决2
f::
       Send, 目标-结论
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 目的-行动步Ⓜ️
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 叙述-锚点-信息多-完整-发生的事件
       Send, {ASC 40}
       Send,历史积累
       Send, {ASC 41}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 1.收集信息
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 问题相关的结构的定义叙述
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 2.搜索
       Send, {ASC 40}
       Send,外部雇佣
       Send, {ASC 41}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 关键词
       Sleep, 50 ; 
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 途径选择
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 谷歌
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 百度
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 细分领域
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 官网
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {ASC 46}{ASC 46}{ASC 46}{ASC 46}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, +{Tab} ; 
       Sleep, 50 ;
       Send, {ASC 100}{ASC 101}{ASC 101}{ASC 112}{ASC 115}{ASC 101}{ASC 101}{ASC 107}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 问人、其他产品
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 问历史记录
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, +{Tab} ; 
       Sleep, 50 ;
       Send, 搜索结果
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 3.测试&行动{ASC 96}例如工作{ASC 96}
       Send,!4
       Sleep, 50 ; 
       Send, +{Tab} ;
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 2.分析
       Sleep, 50 ; 
       Send, +{Tab} ;
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;  
       period := 17
       Loop, % period
       {
              Send, {Up} ; 
              Sleep, 50 ; 
       }
       Send, {End} ; 
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ; 
       Send, {Tab} ; 
       Sleep, 50 ; 
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return

;;g---幕布---问题解决
g::
       Send, 目标-结论
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 目的-行动步骤Ⓜ️
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;  
       Send, 待办⬇
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;  
       Send, 叙述-锚点-信息多-完整-发生的事件
       Send, {ASC 40}
       Send,历史积累
       Send, {ASC 41}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 1.收集信息1️⃣
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 问题相关的结构的定义叙述
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 2.搜索
       Send, {ASC 40}
       Send,外部雇佣
       Send, {ASC 41}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 途径选择
       Sleep, 50 ; 
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 谷歌
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 关键词
       Sleep, 50 ; 
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, +{Tab} ; 
       Sleep, 50 ;
       Send, 百度
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 细分领域
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {Tab} ; 
       Sleep, 50 ;
       Send, 官网
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, {ASC 46}{ASC 46}{ASC 46}{ASC 46}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, +{Tab} ; 
       Sleep, 50 ;
       Send, {ASC 100}{ASC 101}{ASC 101}{ASC 112}{ASC 115}{ASC 101}{ASC 101}{ASC 107}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 问人、其他产品
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 问历史记录
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, +{Tab} ; 
       Sleep, 50 ;
       Send, 搜索结果
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 3.测试&行动{ASC 96}例如工作{ASC 96}
       Send,!4
       Sleep, 50 ; 
       Send, +{Tab} ;
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;
       Send, 2.分析
       Sleep, 50 ; 
       Send, +{Tab} ;
       Sleep, 50 ;
       Send, {Enter} ; 
       Sleep, 50 ;  
       Send, 产品{ASC 40}根据需要的功能、制造产品{ASC 41}
       Send,!4
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ;  
       Send, 归档{ASC 61}提醒{ASC 40}分领域-具体、具体-总{ASC 41}
       Send,!4
       Sleep, 50 ; 
       period := 19
       Loop, % period
       {
              Send, {Up} ; 
              Sleep, 50 ; 
       }
       Send, {End} ; 
       Sleep, 50 ; 
       Send, {Enter} ; 
       Sleep, 50 ; 
       Send, {Tab} ; 
       Sleep, 50 ; 
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return

;;a---??
a::
       Send, {Home} ; 
       Sleep, 50 ; 
       ClipSaved := ClipboardAll ; 保存剪贴板的原始内容
       Clipboard := "" ; 清空剪贴板
       Send, ^a 
       Sleep, 100 ; 
       Send, ^c ; 模拟 Ctrl + C 复制选中的文字
       ClipWait, 2 ; 等待剪贴板内容更新，超时为 2 秒
       if Clipboard
       {
              selectedText := Clipboard ; 将选中的文字赋值到变量 selectedText
       }
       else
       {
       }
       Clipboard := "" ; 清空剪贴板
       Clipboard := ClipSaved ; 恢复剪贴板原始内容
       Send, {Home} ; 
       Sleep, 50 ; 
       position := InStr(selectedText, ".") ; 检测 . 的位置并赋值给变量 position
       if (position > 0)
       {
              Start1 := 1
              Loop, % position - Start1+1
              {
                     Send, {Right} ; 
                     Sleep, 50 ;  
              }
       }
       else
       {
       }
       Send, +{End}
       Sleep, 50 
       Send, {Backspace}
       Sleep, 50 
       Send,^v
return

;;c---GPT翻译，分析代码
c::
       SendInput, {ASC 60}翻译成中文{ASC 62}
       Sleep, 10 ; 
       SendInput,{ASC 60}{ASC 47}翻译成中文{ASC 62}
       Sleep, 10 ; 
       SendInput,{ASC 60}翻译成英文{ASC 62}
       Sleep, 10 ; 
       SendInput,{ASC 60}{ASC 47}翻译成英文{ASC 62}
       Sleep, 50 ; 
       SendInput,{ASC 60}分析代码中的所有语法{ASC 62}
       Sleep, 50 ; 
       SendInput,{ASC 60}{ASC 47}分析代码中的所有语法{ASC 62}
       Sleep, 100 ; 
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
return

;;r---修改变量x
r::
       ; 显示一个输入框，让用户修改变量
       InputBox, UserInput, 修改变量, 请输入新的变量值（当前值为：%x%）, , 300, 150
       if (ErrorLevel = 0) ; 如果用户点击确定
       {
              x := UserInput
              MsgBox 新变量的值已更改为：%x%
       }
       else ; 如果用户取消
       {
              MsgBox 操作已取消
       }
return

;;t---修改变量End
t::
       ; 显示一个输入框，让用户修改变量
       InputBox, UserInput, 修改变量, 请输入新的变量值（当前值为：%End%）, , 300, 150
       if (ErrorLevel = 0) ; 如果用户点击确定
       {
              End := UserInput
              MsgBox 新变量的值已更改为：%End%
       }
       else ; 如果用户取消
       {
              MsgBox 操作已取消
       }
return
;v::
;获取当前时间
;currentTime := A_Now
;格式化时间（YYYY-MM-DD HH:MM:SS）
;formattedTime := SubStr(currentTime, 1, 4) . "-" . SubStr(currentTime, 5, 2) . "-" . SubStr(currentTime, 7, 2) . " " . SubStr(currentTime, 9, 2) . ":" . SubStr(currentTime, 11, 2) . ":" . SubStr(currentTime, 13, 2)
; 显示时间
;MsgBox, 当前时间是：%formattedTime%
;return

;;v---当前日期
v::
       ; 获取当前日期和时间
       FormatTime, formattedTime, %A_Now%, yyyy-MM-dd
       ; 发送格式化后的日期和时间
       SendInput, % "@" . formattedTime . " "
       Send,{#}
       sleep,50
       Send,🌕
       sleep,50
       Send,{Right}
       Send,{Backspace}
       Send, % " "
       ;Send,{#}
       ;sleep,50
       ;Send,提醒
       ;Send, % " "
       ;sleep,50
       ;Send,{Right}
       ;Send,{Backspace}
return
;;b---修改变量y
b::
       myVare := !myVare
       if myVare
       {
              MsgBox 0,图标.ahk,开启了功能！,0.3
       }
       else
       {
              MsgBox 0,图标.ahk,关闭了功能！,0.3
       }
       ; 显示一个输入框，让用户修改变量
       InputBox, UserInput, 修改变量, 请输入新的变量值（当前值为：%y%）, , 300, 150
       if (ErrorLevel = 0) ; 如果用户点击确定
       {
              y := UserInput
              MsgBox 新变量的值已更改为：%y%
       }
       else ; 如果用户取消
       {
              MsgBox 操作已取消
       }
return

;;n-??
n::
       Send,{Home}
       sleep,50
       Send,{Up}
       sleep,50
       Send,!l
       Send, % " "
       ;Send,{#}
       ;sleep,50
       ;Send,提醒
       ;Send, % " "
       ;sleep,50
       ;Send,{Right}
       ;Send,{Backspace}
return

;#IfWinActive ahk_class AcrobatSDIWindow
#If (myVare=true)
;+Enter::+F3
;取消限定
p::
       ;;p-加载

       MsgBox, 0, 提示, 🔄 脚本重新加载中..., 0.5

       Reload

return

;#IfWinActive ahk_exe idea64.exe
;F7::
;MsgBox 操作已取消
;send,{F7}
;return                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
