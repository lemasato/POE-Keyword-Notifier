Create_Local_File() {
	global ProgramValues

	sect := "PROGRAM"
	keysAndValues := {	Last_Update_Check:"1994042612310000"
						,FileName:A_ScriptName
						,PID:ProgramValues.PID
						,Version:ProgramValues.Version}

	for iniKey, iniValue in keysAndValues {
		currentValue := Get_Local_Config(sect, iniKey)

		if (iniKey = "Last_Update_Check") { ; Make sure value is time format
			EnvAdd, currentValue, 1, Seconds
			if !(currentValue) || (currentValue = 1)
				currentValue := "ERROR"
		}
		if iniKey in FileName,PID ; These values are instance specific
		{
			currentValue := "ERROR"
		}
		if (currentValue = "ERROR") {
			Set_Local_Config(sect, iniKey, iniValue)
		}
	}

	sect := "BUTTONS"
	keysAndValues := { 	Button_1_Name:"[ Ask for Invite ]"
						,Button_2_Name:"Button Two"
						,Button_3_Name:"Button Three"
						,Button_1_Message:"@%player% Hi. Invite, please?"
						,Button_2_Message:"Message example Two"
						,Button_3_Message:"Message example Three"}

	for iniKey, iniValue in keysAndValues {
		currentValue := Get_Local_Config(sect, iniKey)
		if (currentValue = "ERROR") {
			Set_Local_Config(sect, iniKey, iniValue)
		}
	}

	sect := "SETTINGS"
	keysAndValues := {	Auto_Update:1
						,Transparency:200
						,Timer_Logs:600
						,Timer_Keywords:30000}

	for iniKey, iniValue in keysAndValues {
		currentValue := Get_Local_Config(sect, iniKey)
		if (currentValue = "ERROR") {
			Set_Local_Config(sect, iniKey, iniValue)
		}
	}

}

Get_Local_Config(sect, key="") {
	global ProgramValues

	if (key) {
		IniRead, val,% ProgramValues.Ini_File,% sect,% key
		if (val && val != "ERROR") || (val = 0)
			Return val
		else Return "ERROR"
	}
	else {
		IniRead, allKeys,% ProgramValues.Ini_File,% sect
		
		keyAndValuesArr := {}
		Loop, Parse, allKeys,% "`n`r"
		{
			keyAndValue := A_LoopField
			if RegExMatch(keyAndValue, "(.*)=(.*)", found) {
				keyName := found1, value := found2
				valueFirstChar := SubStr(value, 1, 1)
				valueLastChar := SubStr(value, 0, 1)

				; Remove quotes
				if (valueFirstChar = """" && valueLastChar = """") {
					StringTrimLeft, value, value, 1
					StringTrimRight, value, value, 1
				}

				keyAndValuesArr.Insert(keyName, value)
				found1 := "", found2 := ""
			}
		}
		return keyAndValuesArr
	}
}

Set_Local_Config(sect, key, val) {
	global ProgramValues

	IniWrite,% val,% ProgramValues.Ini_File,% sect,% key
}

Update_Local_Config() {
	global ProgramValues

	if !FileExist(ProgramValues.Ini_File)
		Return

	;	This setting is unreliable in cases where the user updates to 1.12 (or higher) then reverts back to pre-1.12 since the setting was only added as of 1.12
	IniRead, priorVer,% ProgramValues.Ini_File,% "PROGRAM",% "Version",% "UNKNOWN"

	subVersions := StrSplit(priorVersionNum, ".")
	mainVer := subVersions[1], releaseVer := subVersions[2], patchVer := subVersions[3]

;	Example. This will handle changes that happened before 0.3.
	if (mainVer = 0 && releaseVer < 3) {

	}

	; Previous versions were directly sending message as whisper.
	if (priorVer = "UNKNOWN") {
		Loop 3 {
			msg := Get_Local_Config("BUTTONS", "Button_" A_Index "_Message")
			msg := "@%player% " msg
			Set_Local_Config("BUTTONS", "Button_" A_Index "_Message", msg)
		}
	}

}