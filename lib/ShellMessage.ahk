ShellMessage_Enable() {
	ShellMessage_State(True)
}

ShellMessage_Disable() {
	ShellMessage_State(False)
}

ShellMessage_State(state) {
	Gui, ShellMsg:Destroy
	Gui, ShellMsg:New, +LastFound 

	Hwnd := WinExist()
	DllCall( "RegisterShellHookWindow", UInt,Hwnd )
	MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
	OnMessage( MsgNum, "ShellMessage", state)
}

ShellMessage(wParam,lParam) {
/*			Triggered upon activating a window
 *			Is used to correctly position the Trades GUI while in Overlay mode
*/
	global PROGRAM, hGUI_Notif, POEGameList

	if ( wParam=4 or wParam=32772 ) { ; 4=HSHELL_WINDOWACTIVATED | 32772=HSHELL_RUDEAPPACTIVATED
		if WinActive("ahk_id" hGUI_Notif) {
;		Prevent these keyboard presses from interacting with the Trades GUI
			Hotkey, IfWinActive,% "ahk_id " hGUI_Notif
			Hotkey, NumpadEnter, DoNothing, On
			Hotkey, Escape, DoNothing, On
			Hotkey, Space, DoNothing, On
			Hotkey, Tab, DoNothing, On
			Hotkey, Enter, DoNothing, On
			Hotkey, Left, DoNothing, On
			Hotkey, Right, DoNothing, On
			Hotkey, Up, DoNothing, On
			Hotkey, Down, DoNothing, On
			Hotkey, IfWinActive, ahk_group ScriptPID
			Hotkey, ~Space, Off
			Hotkey, IfWinActive
			Return ; returning prevents from triggering Gui_Trades_Set_Position while the GUI is active
		}
		else {
			Hotkey, IfWinActive, ahk_group ScriptPID
			Hotkey, ~Space, On
			Hotkey, IfWinActive
		}
	}
}
