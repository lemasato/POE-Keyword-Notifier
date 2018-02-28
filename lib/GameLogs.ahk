Get_Logs_File() {
	logsFullPath := ""
	processes := ["PathOfExile.exe","PathOfExile_x64.exe","PathOfExile_x64Steam.exe","PathOfExileSteam.exe"]

	for id, pName in processes {
		Process, Exist,% pName
		if (ErrorLevel) { ; Exists
			WinGet, pFullPath, ProcessPath,% "ahk_exe " pName
			SplitPath, pFullPath, , pFolder

			if FileExist(pFolder "\logs\Client.txt") {
				logsFullPath := pFolder "\logs\Client.txt"
				Break
			}
		}
	}

	Return logsFullPath
}

Read_Logs() {
	global sLOGS_FILE, sLOGS_TIMER
	static fileObj

	if (!fileObj && sLOGS_FILE) {
		fileObj := FileOpen(sLOGS_FILE, "r")
		fileObj.Read()
	}

	if ( fileObj.pos < fileObj.length ) {
		newLogs := fileObj.Read()
		Parse_Logs(newLogs)
	}

	SetTimer,% A_ThisFunc, -%sLOGS_TIMER%
}

Parse_Logs(str) {
	global PROGRAM, sKEYWORDS

	isGlobalChatAllowed := PROGRAM.SETTINGS.SETTINGS.Monitor_Global
	isPartyChatAllowed := PROGRAM.SETTINGS.SETTINGS.Monitor_Party
	isWhispersChatAllowed := PROGRAM.SETTINGS.SETTINGS.Monitor_Whispers
	isTradeChatAllowed := PROGRAM.SETTINGS.SETTINGS.Monitor_Trade
	isGuildChatAllowed := PROGRAM.SETTINGS.SETTINGS.Monitor_Guild

	Loop, Parse,% str,`n,`r
	{
		if ( RegExMatch( A_LoopField, "SO)^(?:[^ ]+ ){6}(\d+)\] (@From|#|\$|&|\%)(.*?): (.*)", subPat ) ) { ; 1:? - 2:Chat - 3:Name - 4:Msg
		; if ( RegExMatch( A_LoopField, "SO)^(?:[^ ]+ ){6}(\d+)\] (#+|&+)(.*?): (.*)", subPat ) ) { ; 1:? - 2:Chat - 3:Name - 4:Msg
			gamePID := subPat.1, channel := subPat.2, player := subPat.3, message := subPat.4
			player := RemoveGuildPrefix(player)
			AutoTrimStr(player, channel, gamePID)

			if ( (channel = "#" && isGlobalChatAllowed)
			|| (channel = "%" && isPartyChatAllowed)
			|| (channel = "@From" && isWhispersChatAllowed)
			|| (channel = "$" && isTradeChatAllowed)
			|| (channel = "&" && isGuildChatAllowed) )
				allowedChannel := True
			else allowedChannel := False

			if !(allowedChannel)
				Return

			Loop, Parse,% sKEYWORDS,% ","
			{
				if message contains %A_LoopField%
					keyWords .= A_LoopField ","
			}
			if (keyWords && allowedChannel) {
				SoundPlay, *16
				StringTrimRight, keyWords, keyWords, 1
				GUI_Notif.Add(player, keyWords, message)
			}
		}
	}
}
