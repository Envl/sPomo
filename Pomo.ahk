#SingleInstance
#NoTrayIcon

 ;; Variables
AppRunning:=True
PomoRunning:=False
isOnTop:=True
isHidden:=False
isPomo:=True  ;; Pomo or EyeCare
tomatoTime:=1500 ;;25min*60s
relaxTime:=300000 ;;5min*60s*1000ms
readingTime:=1200 ;;20min*60s
eyeCareTime:=20000 ;;20s*1000ms
yPos:=A_ScreenHeight*0.85
;; Register Windows Events
OnMessage(0x200,"WM_MOUSEMOVE")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")
OnMessage(0x204, "WM_RBUTTONDOWN")
;; Monitor tasks
SetTimer, CheckFullScrn, 3000    ; Periodically check Fullscreen application
;; GUI
Gui ,sPomo:+LastFound +AlwaysOnTop 
Gui, sPomo:-Caption +Owner -SysMenu
gui, sPomo:font,s16 w700 q5,Tahoma
Gui, sPomo:Color,000000
WinSet, Transparent, 210
Gui, sPomo:Add, Text, xp-15 yp+7 cWhite vPomoStatus,任何时候连续按下  `;;pom  开/关番茄钟      or      连续按下  `;;eye  开/关20-20-20护眼模式
Gui, sPomo:Show,NoActivate center,sPomodoro
;; for EyeCare relax only
Gui ,eyeCare:+LastFound +AlwaysOnTop 
Gui, eyeCare:-Caption +Owner -SysMenu
gui, eyeCare:font,s16 w700 q5,Tahoma
Gui, eyeCare:Color,000000
WinSet, Transparent, 180
xx:=A_ScreenWidth/3
Gui, eyeCare: Add,Text,cWhite w%A_ScreenWidth% x%xx%, 快眺望远方的山峰,别错过转弯的路口
Gui,eyeCare:Show,NoActivate center, eyeRelax
WinHide,eyeRelax
; WinHide,eyeRelax
;; Righ Click Menu
Menu, rMenu, Add, Exit, CloseApp
Menu, rMenu, Add  ; Add a separator line.
Menu, rMenu, Add, sPomo by @GnimOay, rMenuHandler
;; Tray Menu
Menu,Tray,Add
Menu,Tray,Add,Heyyyy,ClosePomo


:*:;;pom::
    isPomo:=True
    Goto, MainApp
Return

:*:;;eye::
    isPomo:=False
    Goto, MainApp
Return

MainApp:
    WinShow, sPomodoro
    Gui sPomo:+LastFound 
    face:=isPomo?"(╯°Д° ) ╯ ┻━┻":"(✪ω✪)"
    GuiControl,sPomo:,PomoStatus,%face%
    if(PomoRunning){
        PomoRunning:=False
        GuiControl,sPomo:Move,PomoStatus,x5
        width:=isPomo?150:90
        WinSet, Region,0-0 w%width% h40 R2-2
        Goto, ClosePomo
    }
    PomoRunning:=True
    width:=75
    WinSet, Region,0-0 w%width% h40 R2-2
    WinMove, sPomodoro,,0,%yPos%
    Goto, StartPomo
Return

StartPomo:
    WinShow, sPomodoro
    WinHide, eyeRelax
    face:=isPomo?"(╯°Д° ) ╯ ┻━┻":"(✪ω✪)"
    GuiControl,sPomo:,PomoStatus,%face%
    Gui sPomo:+LastFound
    WinSet, Region,0-0 w100 h40 R2-2
    WinMove, sPomodoro,,0,%yPos%
    SoundPlay, start.mp3
    SetTimer, StartPomo, Off
    SetTimer, TickTick, 1000
    timeElapsed:=0
    energy:=1
    min:=1
Return

TickTick:
    timeElapsed+=1.0  ;; +1s
    totalTime:=isPomo? tomatoTime:readingTime
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
    display= %min%`:%sec%
    GuiControl,sPomo:Text,PomoStatus,%display%
    GuiControl,sPomo:Move,PomoStatus,x18
Return

Relax:
    display:=isPomo?"(╯°Д° ) ╯":"快眺望远方的山峰,别错过转弯的路口"
    GuiControl,sPomo:,PomoStatus,%display%
    if(isPomo){
        GuiControl,sPomo:Move,PomoStatus,x5
    }
    else{
        WinHide,sPomodoro
        WinShow, eyeRelax
    }
    duration:=isPomo?relaxTime:eyeCareTime
    ToolTip, %duration%
    SetTimer, StartPomo, %duration%
Return

ClosePomo:
    SetTimer, TickTick, Off
    SetTimer, StartPomo, Off
    face:=isPomo?"(╯°Д° ) ╯ ┻━┻":"护眼:关"
    GuiControl,sPomo:,PomoStatus,%face%
    Goto, CloseBeep
    ; Gui,sPomo:Destroy
Return

CloseBeep:
    SoundBeep,800, 230 
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

CheckFullScrn:
    WinGetActiveTitle, title
    if isWindowFullScreen(title){
        if not isHidden{
            WinHide,sPomodoro
            isHidden:=True
        }
    }
    else if isHidden{
        WinShow, sPomodoro
        isHidden:=False
    }
Return

isWindowFullScreen( winTitle ) {
	;checks if the specified window is full screen
	winID := WinExist( winTitle )
	If ( !winID ){
		Return false
    }
	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}
