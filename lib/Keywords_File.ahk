Read_Keywords_File() {
	global ProgramValues

	if !FileExist(ProgramValues.Keywords_File) {
		FileAppend,,% ProgramValues.Keywords_File
	}

	FileRead, keywords,% ProgramValues.Keywords_File
	Return keywords
}

Declare_Keywords_List() {
	global sKEYWORDS

	sKEYWORDS := ""
	sKEYWORDS := Get_Keywords_List()
}

Get_Keywords_List() {
	global sKEYWORDS

	keywords := Read_Keywords_File()
	keywords := StrReplace(keywords, "`r`n", ",")

	; Remove blank lines from the list
	Loop, Parse,% keywords,% ","
	{
		if (A_LoopField)
			filtered_keywords .= A_LoopField ","
	}

	lastChar := SubStr(filtered_keywords, 0)
	if (lastChar = ",")
		StringTrimRight, filtered_keywords, filtered_keywords, 1

	return filtered_keywords
}

Add_Keyword(str) {
	global ProgramValues

	keywords := Get_Keywords_List()

	if !(str)
		Return

	if str not in %keywords%
	{
		FileAppend,% "`n" str,% ProgramValues.Keywords_File
	}
}

Remove_Keyword(str) {
	global ProgramValues

	keywords := Get_Keywords_List()

	Loop, Parse,% keywords,% ","
	{
		if (A_LoopField != str)
			newList .= A_LoopField ","
	}
	
	newList := StrReplace(newList, ",", "`r`n")
	fileObj := FileOpen(ProgramValues.Keywords_File, "w")
	fileObj.Write(newList)
}

Run_Keywords_File() {
	global ProgramValues

	Run,% ProgramValues.Keywords_File
}
