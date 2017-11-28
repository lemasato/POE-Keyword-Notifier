WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global GUI_Notif_Handles
	static content

	PlayerSlot := GUI_Notif_Handles.TEXT_PlayerSlot
	KeywordSlot := GUI_Notif_Handles.TEXT_KeywordSlot
	MessageSlot := GUI_Notif_Handles.TEXT_MessageSlot

	if (hwnd = PlayerSlot || hwnd = KeywordSlot || hwnd = MessageSlot) {
		GuiControlGet, tabNum, Notif:,% GUI_Notif_Handles.TabCtrl
		coords := Get_Control_Coords("Notif", hwnd)

		if (hwnd = PlayerSlot)
			content := GUI_Notif.GetSlot("Player")
		else if (hwnd = KeywordSlot)
			content := GUI_Notif.GetSlot("Keyword")
		else if (hwnd = MessageSlot)
			content := GUI_Notif.GetSlot("Message")

		WinGetPos, thisWinX, thisWinY
		MouseGetPos, MouseX
		radiusW := (coords.X+coords.W)-MouseX
		coordModeSettings := {ToolTip:"Client"}
		ShowToolTip(content, coords.X, coords.Y, radiusW, 12, coordModeSettings)
	}
}
