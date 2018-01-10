Read_Keywords_File() {
	global PROGRAM

	if !FileExist(PROGRAM.KEYWORDS_FILE) {
		FileAppend,,% PROGRAM.KEYWORDS_FILE
	}

	FileRead, keywords,% PROGRAM.KEYWORDS_FILE
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
	global PROGRAM

	keywords := Get_Keywords_List()

	if !(str)
		Return

	if str not in %keywords%
	{
		FileAppend,% "`n" str,% PROGRAM.KEYWORDS_FILE
	}
}

Remove_Keyword(str) {
	global PROGRAM

	keywords := Get_Keywords_List()

	Loop, Parse,% keywords,% ","
	{
		if (A_LoopField != str)
			newList .= A_LoopField ","
	}
	
	newList := StrReplace(newList, ",", "`r`n")
	fileObj := FileOpen(PROGRAM.KEYWORDS_FILE, "w")
	fileObj.Write(newList)
}

Run_Keywords_File() {
	global PROGRAM

	Run,% PROGRAM.KEYWORDS_FILE
}
