Create_LogsFile() {
	global PROGRAM, GAME

	quote := """"

	FileAppend,% "",% PROGRAM.LOGS_FILE
	os3264bits := A_Is64bitOS?"x64":"x86"
	appendToFile := "OS Informations: " quote A_OSType A_Space . A_OSVersion A_Space . os3264bits quote
	. "`n"			"OS Res-DPI: " quote PROGRAM.OS.RESOLUTION_DPI quote
	. "`n"
	. "`n"			"Program version: " quote PROGRAM.VERSION quote
	. "`n"			"Main folder: " quote PROGRAM.MAIN_FOLDER quote
	. "`n"			"Chat key: " quote GAME.SETTINGS.ChatKey_Name quote . "     " "VK: " quote GAME.SETTINGS.ChatKey_VK quote . "     " "SC: " quote GAME.SETTINGS.ChatKey_SC quote
	. "`n`n"
	. "`n"

	FileAppend,% appendToFile,% PROGRAM.LOGS_FILE
}

Delete_OldLogsFile(_daysLimit=10) {
/*		Keep only recent logs file
*/
	global PROGRAM
	logsPath := PROGRAM.LOGS_FOLDER
	daysLimit := _daysLimit*1000000 ; Convert to YYYYMMDDHH24MISS

	Loop, %logsPath%\*.txt
	{
		FileGetTime, lastMod,% A_LoopFileFullPath, M
		fileDaysOld := A_Now-lastMod
		if ( fileDaysOld >= daysLimit) {
			FileDelete,% A_LoopFileFullPath
			AppendToLogs("Deleted file from logs folder due to being over " _daysLimit " days old: """ A_LoopFileName """")
		}
	}
}


AppendToLogs(string) {
	global PROGRAM

	timeStamp := "[" A_YYYY "/" A_MM "/" A_DD " " A_Hour ":" A_Min ":" A_Sec "]"
	appendtoFile := timeStamp . A_Space . string . "`n"

	FileAppend,% appendtoFile,% PROGRAM.LOGS_FILE
}