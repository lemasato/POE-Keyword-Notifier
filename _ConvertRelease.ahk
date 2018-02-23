﻿#SingleInstance, Force

; Main file - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

FileRead, ver,%A_ScriptDir%/resources/version.txt
ver := StrReplace(ver, "`n", "")
ver = %ver% ; Auto trim

verFull := ver
StringReplace ver,ver,`.,`.,UseErrorLevel
Loop % 3-ErrorLevel {
	verFull .= ".0"
}
desc := "POE Keyword Notifier"
inputFile := "POE Keyword Notifier.ahk"
outputFile := "POE Keyword Notifier.exe"

Run_Ahk2Exe(inputFile, ,A_ScriptDir "/resources/icon.ico")
Set_FileInfos(outputFile, verFull, desc, "© lemasato.github.io " A_YYYY)
fileInfos := FileGetInfo(outputFile)
while (fileInfos.FileVersion != verFull) {
	ToolTip, #%A_Index%`nAttempting to set file infos for file:`n%outputFile%
	fileInfos := FileGetInfo(outputFile)
	Set_FileInfos(outputFile, verFull, desc, "© lemasato.github.io " A_YYYY)
	Sleep 500
}
ToolTip,
fileInfos := ""

; Updater file - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

ver := "2.1"
verFull := ver
StringReplace ver,ver,`.,`.,UseErrorLevel
Loop % 3-ErrorLevel {
	verFull .= ".0"
}
desc := "POE Keyword Notifier: Updater"
inputFile := "Updater_v2.ahk"
outputFile := "Updater_v2.exe"

Run_Ahk2Exe(inputFile, ,A_ScriptDir "/resources/icon.ico")
Set_FileInfos(outputFile, verFull, desc, "© lemasato.github.io " A_YYYY)
fileInfos := FileGetInfo(outputFile)
while (fileInfos.FileVersion != verFull) {
	ToolTip, #%A_Index%`nAttempting to set file infos for file:`n%outputFile%
	fileInfos := FileGetInfo(outputFile)
	Set_FileInfos(outputFile, verFull, desc, "© lemasato.github.io " A_YYYY)
	Sleep 500
}
ToolTip,
fileInfos := ""

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

SoundPlay, *32
ToolTip, Compile Success
Sleep 1500
ToolTip
ExitApp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


Run_Ahk2Exe(fileIn, fileOut="", fileIcon="", mpress=0, binFile="Unicode 32-bit.bin") {
	EnvGet, ProgramW6432, ProgramW6432
	_ProgramFiles := (ProgramW6432)?(ProgramW6432):(A_ProgramFiles)
	ahk2ExePath := _ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe"


	SplitPath, fileIn, , fileInDir, , fileInNoExt
	SplitPath, fileOut, , fileOutDir, , fileOutNoExt

	if (!fileInDir)
		fileInDir := A_ScriptDir
	if (!fileOutDir)
		fileOutDir := fileInDir

	fileInParam := " /in " """" fileIn """"
	fileOutParam := (fileOut)?(fileOutDir "\" fileOut):(fileOutDir "\" fileInNoExt ".exe")
	fileOutParam := " /out " """" fileOutParam """"

	fileIconParam := (fileIcon)?(" /icon " """" fileIcon """"):("")

	mpressParam := (mpress)?(" /mpress 1"):(" /mpress 0")

	SplitPath, binFile, binFileName, binFileDir
	if (!binFileDir) {
		binFileDir := _ProgramFiles "\AutoHotkey\Compiler"
		binFileFullPath := _ProgramFiles "\AutoHotkey\Compiler\" binFile
		binParam := " /bin """ binFileFullPath """"
	}
	else {
		binFileFullPath := binFile
		binParam := " /bin " """" binFile """"
	}

	if (binFile && !FileExist(binFileFullPath)) {
		MsgBox % binFile " not found in " _ProgramFiles "\AutoHotkey\Compiler\"
		. "`nOperation aborted."
		ExitApp
	}

	RunWait, %ahk2ExePath% %fileInParam% %fileOutParam% %fileIconParam% %mpressParam% %binParam% ,,Hide
}

Set_FileInfos(file, version="", desc="", copyright="", adds="") {
	if !FileExist("verpatch.exe") {
		MsgBox verpatch.exe not found! Operation aborted.
		ExitApp
	}

	if (version) {
		versionArr := StrSplit(version, ".")
	}
	Loop % 4- versionArr.MaxIndex() { ; File version requires four numbers
		version .= ".0"
	}

	args := "/high"
	args .= (version)?(" """ version """"):("")
	args .= (desc)?(" /s desc """ desc """"):("")
	args .= (product)?(" /s product """ product """"):("")
	args .= (copyright)?(" /s copyright """ copyright """"):("")

	RunWait, verpatch.exe "%file%" %args% %adds%,,Hide
}

FileGetInfo( lptstrFilename) {
/*	MsgBox % FileGetInfo( comspec ).CompanyName
	MsgBox % FileGetInfo( A_WinDir "\system32\calc.exe" ).FileDescription
*/
	List := "Comments InternalName ProductName CompanyName LegalCopyright ProductVersion"
		. " FileDescription LegalTrademarks PrivateBuild FileVersion OriginalFilename SpecialBuild"
	dwLen := DllCall("Version.dll\GetFileVersionInfoSize", "Str", lptstrFilename, "Ptr", 0)
	dwLen := VarSetCapacity( lpData, dwLen + A_PtrSize)
	DllCall("Version.dll\GetFileVersionInfo", "Str", lptstrFilename, "UInt", 0, "UInt", dwLen, "Ptr", &lpData) 
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\VarFileInfo\Translation", "PtrP", lplpBuffer, "PtrP", puLen )
	sLangCP := Format("{:04X}{:04X}", NumGet(lplpBuffer+0, "UShort"), NumGet(lplpBuffer+2, "UShort"))
	i := {}
	Loop, Parse, % List, %A_Space%
		DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\StringFileInfo\" sLangCp "\" A_LoopField, "PtrP", lplpBuffer, "PtrP", puLen )
		? i[A_LoopField] := StrGet(lplpBuffer, puLen) : ""
	return i
}