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

#Warn LocalSameAsGlobal
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

Menu,Tray,Tip,PoE Keyword Notifier
Menu,Tray,NoStandard
Menu,Tray,Add,Open Settings,GUI_Settings.Create
Menu,Tray,Add
Menu,Tray,Add,Reload,Reload_Func
Menu,Tray,Add,Close,Exit_Func
Menu,Tray,Icon

GroupAdd, ScriptPID,% "ahk_pid " DllCall("GetCurrentProcessId")

Start_Script()
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Start_Script() {
	global sKEYWORDS, sLOGS_FILE
	global sLOGS_TIMER, sKEYWORDS_TIMER
	global PROGRAM 							:= {} ; Specific to the program's informations
	global GAME								:= {} ; Specific to the game config files

	; Name and ver
	PROGRAM.NAME 							:= "POE Keyword Notifier"
	PROGRAM.VERSION 						:= "0.2.1"
	; Github repo infos
	PROGRAM.GITHUB_USER 					:= "lemasato"
	PROGRAM.GITHUB_REPO 					:= "POE-Keyword-Notifier"
	PROGRAM.BRANCH 							:= "master"
	; Folders
	PROGRAM.MAIN_FOLDER 					:= A_MyDocuments "\AutoHotkey\" PROGRAM.NAME
	; Files
	PROGRAM.INI_FILE 						:= PROGRAM.MAIN_FOLDER "\Preferences.ini"
	PROGRAM.KEYWORDS_FILE 					:= PROGRAM.MAIN_FOLDER "\keywords.txt"
	; Links
	PROGRAM.LINK_GITHUB 					:= "https://github.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO
	; Updater file and links
	PROGRAM.UPDATER_FILENAME 				:= PROGRAM.MAIN_FOLDER "/POE-KN-Updater.exe"
	PROGRAM.NEW_FILENAME					:= PROGRAM.MAIN_FOLDER "/POE-KN-NewVersion.exe"
	PROGRAM.LINK_UPDATER 					:= "https://raw.githubusercontent.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO "/master/Updater_v2.exe"
	; PID
	PROGRAM.PID 							:= DllCall("GetCurrentProcessId")

	; Game folder and files
	GAME.MAIN_FOLDER 				:= MyDocuments "\my games\Path of Exile"
	GAME.INI_FILE 					:= GAME.MAIN_FOLDER "\production_Config.ini"
	GAME.INI_FILE_COPY 		 		:= PROGRAM.MAIN_FOLDER "\production_Config.ini"
	GAME.EXECUTABLES 				:= "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	SetWorkingDir,% PROGRAM.MAIN_FOLDER

;	Directories Creation - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	localDirs := PROGRAM.MAIN_FOLDER

	Loop, Parse, localDirs, `n, `r
	{
		if (!InStr(FileExist(A_LoopField), "D")) {
			FileCreateDir, % A_LoopField
		}
	}

;	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	FileDelete,% PROGRAM.UPDATER_FILENAME

	Tray_Refresh()

	; Local settings
	Update_Local_Config()
	Create_Local_File()
	; Game settings
	; gameSettings := Get_GameSettings()
	; Declare_GameSettings(gameSettings)
	
	UpdateCheck(0, 1)

	Declare_Keywords_List()

	GUI_Notif.Create()
	; GUI_Notif.Add("iSellStuff","rota,zana","LF2M Zana 6 Rota")
	; GUI_Settings.Create()

	while !(sLOGS_FILE) {
		sLOGS_FILE := Get_Logs_File()
		if (sLOGS_FILE)
			Break
		if (A_Index = 1)
			SplashTextOn(PROGRAM.NAME, "Path of Exile's logs file could not be found."
			.								 "`nThe app will now wait until the game is started."
			.								 "",0,1)
			SetTimer, SplashTextOff, -3000
		Sleep 30000
	}

	sLOGS_TIMER := Get_Local_Config("SETTINGS", "Timer_Logs")
	sKEYWORDS_TIMER := Get_Local_Config("SETTINGS", "Timer_Keywords")
	SetTimer, Read_Logs, -%sLOGS_TIMER%
	SetTimer, Declare_Keywords_List, -%sKEYWORDS_TIMER%

	SplashTextOn(PROGRAM.NAME, "Right click on the tray icon to access the settings"
	.								 "`n"
	.								 "`nNow monitoring the logs file located at:"
	.								 "`n" """" sLOGS_FILE """"
	.								 "",0,1)
	SetTimer, SplashTextOff, -3000
}

; ================================================

RemoveGuildPrefix(str) {
	if RegExMatch(str, "<.*>(.*)", strPat) {
		name := strPat1
		name = %name%
		Return name
	}
	else
		Return str	
}

Get_Control_Coords(guiName, ctrlHandler) {
/*		Retrieve a control's position and return them in an array.
		The reason of this function is because the variable content would be blank
			unless its sub-variables (coordsX, coordsY, ...) were set to global.
			(Weird AHK bug)
*/
	GuiControlGet, coords, %guiName%:Pos,% ctrlHandler
	return {X:coordsX,Y:coordsY,W:coordsW,H:coordsH}
}

; ================================================

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

#Include %A_ScriptDir%/lib/
#Include CoordMode.ahk
#Include FileDownload.ahk
#Include GameLogs.ahk
#Include GitHubReleasesAPI.ahk
#Include GUI_Notif.ahk
#Include GUI_Settings.ahk
#Include Keywords_File.ahk
#Include Local_File.ahk
#Include ShowToolTip.ahk
#Include SplashText.ahk
#Include TrayRefresh.ahk
#Include UpdateCheck.ahk
#Include WM_Messages.ahk

#Include %A_ScriptDir%/lib/third-party
#Include JSON.ahk