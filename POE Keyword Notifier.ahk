/*
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*					POE Keyword Notifier																														*
*					Receive a notification based on keywords 																									*
*					Quickly message the player using buttons																									*
*																																								*
*					https://github.com/lemasato/POE-Keyword-Notifier/																							*
*					https://www.pathofexile.com/forum/view-thread/1755148/page/30#p15037215																		*
*																																								*	
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*/

#Warn LocalSameAsGlobal, StdOut
OnExit("Exit_Func")
#SingleInstance, Force
#Persistent
#NoEnv
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8
#KeyHistory 0
SetWinDelay, 0
DetectHiddenWindows, Off
ListLines, Off

if ( !A_IsCompiled && FileExist(A_ScriptDir "\resources\icon.ico") )
	Menu, Tray, Icon,% A_ScriptDir "\resources\icon.ico"

GroupAdd, POEGame, ahk_exe PathOfExile.exe
GroupAdd, POEGame, ahk_exe PathOfExile_x64.exe
GroupAdd, POEGame, ahk_exe PathOfExileSteam.exe
GroupAdd, POEGame, ahk_exe PathOfExile_x64Steam.exe

Menu,Tray,Tip,POE Keyword Notifier
Menu,Tray,NoStandard
Menu,Tray,Add,Open Settings,GUI_Settings.Create
Menu,Tray,Add
Menu,Tray,Add,Check for updates,Tray_Update
Menu,Tray,Add
Menu,Tray,Add,Reload,Reload_Func
Menu,Tray,Add,Close,Exit_Func
Menu,Tray,Icon

GroupAdd, ScriptPID,% "ahk_pid " DllCall("GetCurrentProcessId")

Start_Script()
Return

Tray_Update:
	UpdateCheck(True, True)
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#IfWinActive, ahk_group ScriptPID

; Esc:: ; Close the script if its the active window
; 	ExitApp
; Return

~Space:: ; Close the SplashTextOn() window
	global SPACEBAR_WAIT

	if (SPACEBAR_WAIT) {
		SplashTextOff()
	}
Return

; #IfWinActive

; F2::Reload_Func()

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Start_Script() {
	global sKEYWORDS, sLOGS_FILE
	global sLOGS_TIMER, sKEYWORDS_TIMER
	global PROGRAM 							:= {} ; Specific to the program's informations
	global GAME								:= {} ; Specific to the game config files

	; Name and ver
	PROGRAM.NAME 							:= "POE Keyword Notifier"
	PROGRAM.VERSION 						:= "0.3.2"
	; Github repo infos
	PROGRAM.GITHUB_USER 					:= "lemasato"
	PROGRAM.GITHUB_REPO 					:= "POE-Keyword-Notifier"
	PROGRAM.BRANCH 							:= "master"
	; Folders
	PROGRAM.MAIN_FOLDER 					:= A_MyDocuments "\AutoHotkey\" PROGRAM.NAME
	PROGRAM.LOGS_FOLDER						:= PROGRAM.MAIN_FOLDER "\Logs"
	; Files
	PROGRAM.INI_FILE 						:= PROGRAM.MAIN_FOLDER "\Preferences.ini"
	PROGRAM.KEYWORDS_FILE 					:= PROGRAM.MAIN_FOLDER "\keywords.txt"
	PROGRAM.LOGS_FILE 						:= PROGRAM.LOGS_FOLDER "\" A_YYYY "-" A_MM "-" A_DD " " A_Hour "h" A_Min "m" A_Sec "s.txt"
	; Links
	PROGRAM.LINK_GITHUB 					:= "https://github.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO
	; Updater file and links
	PROGRAM.UPDATER_FILENAME 				:= PROGRAM.MAIN_FOLDER "/POE-KN-Updater.exe"
	PROGRAM.NEW_FILENAME					:= PROGRAM.MAIN_FOLDER "/POE-KN-NewVersion.exe"
	PROGRAM.LINK_UPDATER 					:= "https://raw.githubusercontent.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO "/master/Updater_v2.exe"
	; PID
	PROGRAM.PID 							:= DllCall("GetCurrentProcessId")

	; Game folder and files
	GAME.MAIN_FOLDER 						:= A_MyDocuments "\my games\Path of Exile"
	GAME.INI_FILE 							:= GAME.MAIN_FOLDER "\production_Config.ini"
	GAME.INI_FILE_COPY 		 				:= PROGRAM.MAIN_FOLDER "\production_Config.ini"
	GAME.EXECUTABLES 						:= "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	SetWorkingDir,% PROGRAM.MAIN_FOLDER

	; Directories Creation - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	directories := PROGRAM.MAIN_FOLDER "`n" PROGRAM.LOGS_FOLDER

	Loop, Parse, directories, `n, `r
	{
		if (!InStr(FileExist(A_LoopField), "D")) {
			FileCreateDir, % A_LoopField
			AppendtoLogs("Local directory non-existent. Creating: """ A_LoopField """")
			if (ErrorLevel && A_LastError) {
				AppendtoLogs("Failed to create local directory. System Error Code: " A_LastError ". Path: """ A_LoopField """")
			}
		}
	}

	; Game executables groups - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe"]
	global POEGameList := "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	for nothing, executable in POEGameArr {
		GroupAdd, POEGameGroup, ahk_exe %executable%
	}

	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	FileDelete,% PROGRAM.UPDATER_FILENAME

	Tray_Refresh()

	; Local settings
	Update_Local_Config()
	Create_Local_File()
	; Local settings
	localSettings := Get_LocalSettings()
	Declare_LocalSettings(localSettings)
	; Game settings
	gameSettings := Get_GameSettings()
	Declare_GameSettings(gameSettings)
	; Logs files
	Create_LogsFile()
	Delete_OldLogsFile()

	UpdateCheck()

	Declare_Keywords_List()
	GUI_Notif.Create()

	; GUI_Notif.Add("iSellStuff","rota,zana","LF2M Zana 6 Rota")
	; GUI_Settings.Create()

	ShellMessage_Enable()

	while !(sLOGS_FILE) {
		sLOGS_FILE := Get_Logs_File()
		if (sLOGS_FILE)
			Break

		Sleep 30000
	}

	sLOGS_TIMER := Get_Local_Config("SETTINGS", "Timer_Logs")
	sKEYWORDS_TIMER := Get_Local_Config("SETTINGS", "Timer_Keywords")
	SetTimer, Read_Logs, -%sLOGS_TIMER%
	SetTimer, Declare_Keywords_List, -%sKEYWORDS_TIMER%
}

GitHub_Link:
	Run,% PROGRAM.LINK_GITHUB
Return

Reload_Func() {
	Sleep 10
	Reload
	Sleep 10000
}

Exit_Func(ExitReason, ExitCode) {
	if ExitReason not in Reload
		ExitApp
}

DoNothing:
Return

#Include %A_ScriptDir%/lib/
#Include Class_Ini.ahk
#Include EasyFuncs.ahk
#Include GameLogs.ahk
#Include GitHubReleasesAPI.ahk
#Include GUI_Notif.ahk
#Include GUI_Settings.ahk
#Include Keywords_File.ahk
#Include POE_Game.ahk
#Include POE_Game_File.ahk
#Include Local_File.ahk
#Include Logs.ahk
#Include ShellMessage.ahk
#Include ShowToolTip.ahk
#Include SplashText.ahk
#Include TrayRefresh.ahk
#Include UpdateCheck.ahk
#Include WM_Messages.ahk

#Include %A_ScriptDir%/lib/third-party
#Include AddToolTip.ahk
#Include Clip.ahk
#Include Download.ahk
#Include JSON.ahk
#Include StringToHex.ahk