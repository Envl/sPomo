#SingleInstance
#NoTrayIcon

;; Variables
AppRunning:=True
PomoRunning:=False
tomatoTime:=1500 ;;25min*60s
relaxTime:=300000 ;;5min*60s*1000ms
yPos:=A_ScreenHeight*0.85

;; GUI
Gui ,sPomo:+LastFound +AlwaysOnTop 
Gui, sPomo:-Caption +Owner -SysMenu
gui, sPomo:font,s16 w700 q5,Tahoma
Gui, sPomo:Color,000000
; Gui, sPomo:Add, Text, xp-15 yp+7 cWhite vPomoStatus,(╯°Д°）╯ 
Gui, sPomo:Add, Text, xp-15 yp+7 cWhite vPomoStatus,任何时候连续按下  `;;pom  以切换工作/休闲模式
WinSet, Transparent, 210
; WinSet, Region,0-0 w100 h40 R2-2
Gui, sPomo:Show,NoActivate Center,sPomodoro

;; Righ Click Menu
Menu, rMenu, Add, 退出, CloseApp
Menu, rMenu, Add  ; Add a separator line.
Menu, rMenu, Add, sPomo by @GnimOay, rMenuHandler
;; Tray Menu
Menu,Tray,Add
Menu,Tray,Add,Heyyyy,ClosePomo

;; Register Windows Events
OnMessage(0x200,"WM_MOUSEMOVE")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")
OnMessage(0x204, "WM_RBUTTONDOWN")

:*:;;pom::
Gui sPomo:+LastFound 
if(PomoRunning){
    PomoRunning:=False
    GuiControl,sPomo:,PomoStatus,(╯°Д° ) ╯ ┻━┻
    WinSet, Region,0-0 w150 h40 R2-2
    GuiControl,sPomo:Move,PomoStatus,x5
    Goto, ClosePomo
}
PomoRunning:=True
GuiControl,sPomo:,PomoStatus,(╯°Д° ) ╯
WinSet, Region,0-0 w100 h40 R2-2
; Gui, sPomo:Show,NoActivate
WinMove, sPomodoro,,0,%yPos%
Goto, StartPomo
Return




StartPomo:
SoundPlay, start.mp3
SetTimer, StartPomo, Off
SetTimer, TickTick, 1000
timeElapsed:=0
energy:=1
min:=1
Return

TickTick:
timeElapsed+=1.0  ;; +1s
totalTime:=tomatoTime
timeLeft:=totalTime-timeElapsed
min:=Format("{:02i}",Floor(timeLeft/60))
sec:=Format("{:02i}",Floor(timeLeft-min*60))
; energy:=1-timeElapsed/()
if(energy<=0 or min<0){
    SetTimer, TickTick, Off
    SoundPlay, end.mp3
    Goto, Relax
}
; display:=energy*10
display=%min%`:%sec%
GuiControl,sPomo:Text,PomoStatus,%display%
GuiControl,sPomo:Move,PomoStatus,x18
Return

Relax:
; GuiControl,,PomoStatus,(╯°Д°）╯
GuiControl,sPomo:,PomoStatus,(╯°Д° ) ╯
GuiControl,sPomo:Move,PomoStatus,x5
SetTimer, StartPomo, %relaxTime%
Return

ClosePomo:
SetTimer, TickTick, Off
SetTimer, StartPomo, Off
; Gui,sPomo:Destroy
Return

CloseApp:
ExitApp

rMenuHandler:
; Tooltip, You selected %A_ThisMenuItem% from the menu %A_ThisMenu%.
return


WM_MOUSEMOVE( wparam, lparam, msg, hwnd ){
    if wparam = 1 ; LButton
        PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
}

WM_RBUTTONDOWN(){
    Menu,rMenu,Show
}
; WM_LBUTTONUP(wparam,lparam,msg,hwnd){
;     WinMove, sPomodoro, , 0,0
; }

; WM_LBUTTONDOWN(wparam,lparam,msg,hwnd){
; }