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
	global sKEYWORDS

	Loop, Parse,% str,`n
	{
		if ( RegExMatch( A_LoopField, "S)^(?:[^ ]+ ){6}(\d+)\] (#|$)(.*?): (.*)", subPat ) ) { ; 1:? - 2:Chat - 3:Name - 4:Msg
			channel := subPat2, player := subPat3, message := subPat4
			player := RemoveGuildPrefix(player)
			AutoTrimStr(player)

			Loop, Parse,% sKEYWORDS,% ","
			{
				if subPat4 contains %A_LoopField%
					keyWords .= A_LoopField ","
			}
			if (keyWords) {
				SoundPlay, *16
				StringTrimRight, keyWords, keyWords, 1
				GUI_Notif.Add(player, keyWords, message)
			}
		}
	}
}
