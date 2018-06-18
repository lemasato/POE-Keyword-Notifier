WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global GUI_Notif_Handles
	static content

	PlayerSlot := GUI_Notif_Handles.TEXT_PlayerSlot
	KeywordSlot := GUI_Notif_Handles.TEXT_KeywordSlot
	MessageSlot := GUI_Notif_Handles.TEXT_MessageSlot
	TimeSlot := GUI_Notif_Handles.TEXT_TimeSlot

	if (hwnd = PlayerSlot || hwnd = KeywordSlot || hwnd = MessageSlot || hwnd = TimeSlot) {
		GuiControlGet, tabNum, Notif:,% GUI_Notif_Handles.TabCtrl
		coords := Get_ControlCoords("Notif", hwnd)

		if (hwnd = PlayerSlot)
			content := GUI_Notif.GetSlot("Player")
		else if (hwnd = KeywordSlot)
			content := GUI_Notif.GetSlot("Keyword")
		else if (hwnd = MessageSlot)
			content := GUI_Notif.GetSlot("Message")
		else if (hwnd = TimeSlot) {
			timeContentFull := GUI_Notif.GetSlot("TimeFull")
			timeDif := A_Now
			timeDif -= timeContentFull, Minutes
			timeDif := timeDif=0?"< 1":timeDif
			content := timeDif " mins ago"
		}

		WinGetPos, thisWinX, thisWinY
		MouseGetPos, MouseX
		radiusW := (coords.X+coords.W)-MouseX
		coordModeSettings := {ToolTip:"Screen"}
		ShowToolTip(content, coords.X+thisWinX, coords.Y+(coords.H*2)+thisWinY, radiusW, 12, coordModeSettings)
	}
}
