Create_Local_File() {
	global ProgramValues

	sect := "PROGRAM"
	keysAndValues := {	Last_Update_Check:"1994042612310000"
						,FileName:A_ScriptName
						,PID:ProgramValues.PID}

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
						,Button_1_Message:"Hi. Invite, please?"
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
				keyAndValuesArr.Insert(found1, found2)
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