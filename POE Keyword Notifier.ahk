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

Space:: ; Close the SplashTextOn() window
	global SPACEBAR_WAIT

	if (SPACEBAR_WAIT) {
		SplashTextOff()
	}
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Start_Script() {
	global sKEYWORDS, sLOGS_FILE
	global sLOGS_TIMER, sKEYWORDS_TIMER
	global ProgramValues := {}

	ProgramValues.Name 					:= "POE Keyword Notifier"
	ProgramValues.Version 				:= "0.1.1"
	ProgramValues.Branch 				:= "master"
	ProgramValues.Github_User 			:= "lemasato"
	ProgramValues.GitHub_Repo 			:= "POE-Keyword-Notifier"

	ProgramValues.GitHub 				:= "https://github.com/" ProgramValues.Github_User "/" ProgramValues.GitHub_Repo

	ProgramValues.Local_Folder 			:= A_MyDocuments "\AutoHotkey\" ProgramValues.Name
	; ProgramValues.Resources_Folder 		:= ProgramValues.Local_Folder "\resources"

	ProgramValues.Ini_File 				:= ProgramValues.Local_Folder "\Preferences.ini"
	ProgramValues.Keywords_File 		:= ProgramValues.Local_Folder "\keywords.txt"

	ProgramValues.Updater_File 			:= ProgramValues.Local_Folder "/POE-KN-Updater.exe"
	ProgramValues.Temporary_Name		:= ProgramValues.Local_Folder "/BNet-KN-NewVersion.exe"
	ProgramValues.Updater_Link 			:= "https://raw.githubusercontent.com/" ProgramValues.Github_User "/" ProgramValues.GitHub_Repo "/master/Updater_v2.exe"

	ProgramValues.PID 					:= DllCall("GetCurrentProcessId")

	SetWorkingDir,% ProgramValues.Local_Folder
;	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Directories Creation
	localDirs := ProgramValues.Local_Folder
			; . "`n" ProgramValues.Resources_Folder
	Loop, Parse, localDirs,% "`n"
	{
		if (!InStr(FileExist(A_LoopField), "D")) {
			FileCreateDir, % A_LoopField
		}
	}
;	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	FileDelete,% ProgramValues.Updater_File
;	Startup
	Tray_Refresh()
	Create_Local_File()
	UpdateCheck(1, 1)
	Declare_Keywords_List()

	GUI_Notif.Create()

	; GUI_Notif.Add("iSellStuff","rota,zana","LF2M Zana 6 Rota")
	; GUI_Settings.Create()

	while !(sLOGS_FILE) {
		sLOGS_FILE := Get_Logs_File()
		if (sLOGS_FILE)
			Break
		if (A_Index = 1)
			SplashTextOn(ProgramValues.Name, "Path of Exile's logs file could not be found."
			.								 "`nThe app will now wait until the game is started."
			.								 "",0,1)
			SetTimer, SplashTextOff, -3000
		Sleep 30000
	}

	sLOGS_TIMER := Get_Local_Config("SETTINGS", "Timer_Logs")
	sKEYWORDS_TIMER := Get_Local_Config("SETTINGS", "Timer_Keywords")
	SetTimer, Read_Logs, -%sLOGS_TIMER%
	SetTimer, Declare_Keywords_List, -%sKEYWORDS_TIMER%

	SplashTextOn(ProgramValues.Name, "Right click on the tray icon to access the settings"
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
	Run,% ProgramValues.GitHub
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