RemoveGuildPrefix(str) {
	if RegExMatch(str, "<.*>(.*)", strPat) {
		name := strPat1
		name = %name%
		Return name
	}
	else
		Return str
}

Send_IGMessage(message) {
/*
 *			Sends a message in game
 *			Replaces all the %variables% into their actual content
*/
	global PROGRAM, GAME

	programName := PROGRAM.NAME
	gameIniFile := PROGRAM.Game_Ini_File

	Thread, NoTimers

; ;	Retrieve the virtual key id for chat opening
	chatVK := GAME.SETTINGS.ChatKey_VK
	if (!chatVK) {
		MsgBox(4096, programName " - Operation Cancelled.", "Could not detect the chat key!"
		. "`nPlease send me an archive containing the Logs folder."
		. "`nYou can find links to GitHub / GGG / Reddit in the [About?] tray menu."
		. "`n`n(The local folder containing the Logs folder will open upon closing this box).")
		Run, % PROGRAM.MAIN_FOLDER
		Return 1
	}

	; if PID is not POE, need to replace it
	if !WinExist("ahk_group POEGameGroup")
		Return

	; Activate game window
	GroupActivate, POEGame
	WinWaitActive, ahk_group POEGame, ,5
	if (!ErrorLevel) {
		firstChar := SubStr(message, 1, 1) ; Get first char, to compare if its a special chat command
		; Opening the chat window
		if chatVK in 0x1,0x2,0x4,0x5,0x6,0x9C,0x9D,0x9E,0x9F ; Mouse buttons
		{
			keyDelay := A_KeyDelay, keyDuration := A_KeyDuration
			SetKeyDelay, 10, 10
			ControlSend, ,{VK%keyVK%}, ahk_group POEGame ; Mouse buttons tend to activate the window under the cursor.
																	  ; Therefore, we need to send the key to the actual game window.
			SetKeyDelay,% keyDelay,% keyDuration
		}
		else
			SendEvent,{VK%chatVK%}

		; Clearing chat
		if firstChar not in /,`%,&,#,@ ; Not a command. We send / then remove it to make sure chat is empty
			SendEvent,{sc035}{BackSpace} ; Slash

		Clip(message)
		SendEvent,{Enter}
	}
	Set_TitleMatchMode("RegEx")
}