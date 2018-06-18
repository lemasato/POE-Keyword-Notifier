UpdateCheck(prompt=false, forceCheck=false, preRelease=false) {
	global PROGRAM, SPACEBAR_WAIT

	autoupdate := Get_Local_Config("SETTINGS", "Auto_Update")
	lastUpdateCheck := Get_Local_Config("PROGRAM", "Last_Update_Check")
	if (forceCheck) ; Fake the last update check, so it's higher than 35mins
		lastUpdateCheck := 1994042612310000

	timeDif := A_Now
	timeDif -= lastUpdateCheck, Minutes

	if !(timeDif > 35) ; Hasn't been longer than 35mins since last check, cancel to avoid spamming GitHub API
		Return

	if FileExist(PROGRAM.UPDATER_FILENAME)
		FileDelete,% PROGRAM.UPDATER_FILENAME

	Set_Local_Config("PROGRAM", "Last_Update_Check", A_Now)

	if (preRelease)
		releaseInfos := GetLatestPreRelease_Infos(PROGRAM.GITHUB_USER, PROGRAM.GITHUB_REPO)
	else
		releaseInfos := GetLatestRelease_Infos(PROGRAM.GITHUB_USER, PROGRAM.GITHUB_REPO)
	onlineVer := releaseInfos.name
	onlineDownload := releaseInfos.assets.1.browser_download_url

	if (!onlineVer || !onlineDownload) {
		SplashTextOn(PROGRAM.NAME " - Updating Error", "There was an issue when retrieving the latest release from GitHub API"
		.											"`nIf this keeps on happening, please try updating manually."
		.											"`nYou can find the GitHub repository link in the Settings menu.", 1, 1)
	}
	else if (onlineVer && onlineDownload) && (onlineVer != PROGRAM.VERSION){
		if (prompt)
			ShowUpdatePrompt(onlineVer, onlineDownload)
		else if (autoupdate) {
			Download(PROGRAM.LINK_UPDATER, PROGRAM.UPDATER_FILENAME)
			Run_Updater(onlineDownload)
		}
		Return
	}
	else if (onlineVer = PROGRAM.VERSION && prompt) {
		MsgBox, ,% PROGRAM.NAME,% "You are up to date!`n`nCurrent version: " A_Tab PROGRAM.VERSION "`nOnline version: " A_Tab onlineVer
	}

	Return {Version:onlineVer, Download:onlineDownload}
}

ShowUpdatePrompt(ver, dl) {
	global PROGRAM

	MsgBox, 4100,% PROGRAM.NAME " - Update detected (v" ver ")",% "Current version:" A_Tab PROGRAM.VERSION
	.										 "`nOnline version: " A_Tab ver
	.										 "`n"
	.										 "`nWould you like to update now?"
	.										 "`nThe entire updating process is automated."
	IfMsgBox, Yes
	{
		success := Download(PROGRAM.LINK_UPDATER, PROGRAM.UPDATER_FILENAME)
		if (success)
			Run_Updater(dl)
	}
}

Run_Updater(downloadLink) {
	global PROGRAM

	updaterLink 		:= PROGRAM.LINK_UPDATER

	Set_Local_Config("PROGRAM", "LastUpdate", A_Now)
	Run,% PROGRAM.UPDATER_FILENAME 
	. " /Name=""" PROGRAM.NAME  """"
	. " /File_Name=""" A_ScriptDir "\" PROGRAM.NAME ".exe" """"
	. " /Local_Folder=""" PROGRAM.MAIN_FOLDER """"
	. " /Ini_File=""" PROGRAM.INI_FILE """"
	. " /NewVersion_Link=""" downloadLink """"
	ExitApp
}