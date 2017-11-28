Class GUI_Settings {
	Create() {
		static
		global ProgramValues, sKEYWORDS
		global GUI_Settings_Handles := {}
		global GUI_Settings_Submit := {}

		config_Buttons := Get_Local_Config("BUTTONS")
		config_Settings := Get_Local_Config("SETTINGS")
		Declare_Keywords_List()

		Gui, Settings:Destroy
		Gui, Settings:New, +AlwaysOnTop +ToolWindow +LabelGUI_Settings_
		Gui, Settings:Font,S8,Segoe UI

		Gui, Settings:Add, Text, x10 y10,Transparency: 
		Gui, Settings:Add, Edit, x+5 yp-3 w60 Number ReadOnly vEDIT_Transparency hwndhEDIT_Transparency,% config_Settings.Transparency
		Gui, Settings:Add, UpDown, x+0 hp -16 Range10-51 Wrap gGUI_Settings.OnUpDown_Change vUPDOWN_Transparency hwndhUPDOWN_Transparency,% config_Settings.Transparency / 5
		; The range above has to be adjusted based on the multiplier due to the way the -16 pameter works.
		; Range: 50-255. Multiplier: 5. Therefore, 50/5=10 and 255/5=51.
		; The default value has to be divided by the multiplier too.

		Gui, Settings:Add, Text, x10 y+10,Keywords file timer (ms):
		Gui, Settings:Add, Edit, x+5 yp-3 w100 Number ReadOnly vEDIT_Keywords_Timer hwndhEDIT_Keywords_Timer,% config_Settings.Timer_Keywords
		Gui, Settings:Add, UpDown, x+0 hp -16 Range1-30 Wrap gGUI_Settings.OnUpDown_Change vUPDOWN_Keywords_Timer hwndhUPDOWN_Keywords_Timer,% config_Settings.Timer_Keywords / 1000

		Gui, Settings:Add, Text, x10 y+10,Game logs file timer (ms):
		Gui, Settings:Add, Edit, x+5 yp-3 w100 Number ReadOnly vEDIT_Logs_Timer hwndhEDIT_Logs_Timer,% config_Settings.Timer_Logs
		Gui, Settings:Add, UpDown, x+0 hp -16 Range3-50 Wrap gGUI_Settings.OnUpDown_Change vUPDOWN_Logs_Timer hwndhUPDOWN_Logs_Timer,% config_Settings.Timer_Logs / 100

		keywordsList := StrReplace(sKEYWORDS, ",", "|")
		Gui, Settings:Add, GroupBox, x10 y+10 w435 h50 c000000,Keywords
		Gui, Settings:Add, ComboBox, x25 yp+20 w200 R10 vCOMBO_Keywords hwndhCOMBO_Keywords,% keywordsList
		Gui, Settings:Add, Button, x+5 w100 gGUI_Settings.AddKeyword,Add
		Gui, Settings:Add, Button, x+5 w100 gGUI_Settings.RemoveKeyword,Remove

		Gui, Settings:Add, GroupBox, x10 y+10 w435 h55 c000000,Button 1
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN1_Name hwndhEDIT_BTN1_Name,% config_Buttons.Button_1_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN1_Message hwndhEDIT_BTN1_Message,% config_Buttons.Button_1_Message

		Gui, Settings:Add, GroupBox, x10 y+15 w435 h55 c000000,Button 2
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN2_Name hwndhEDIT_BTN2_Name,% config_Buttons.Button_2_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN2_Message hwndhEDIT_BTN2_Message,% config_Buttons.Button_2_Message

		Gui, Settings:Add, GroupBox, x10 y+15 w435 h55 c000000,Button 3
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN3_Name hwndhEDIT_BTN3_Name,% config_Buttons.Button_3_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN3_Message hwndhEDIT_BTN3_Message,% config_Buttons.Button_3_Message

		Gui, Settings:Add, GroupBox, x10 y+15 w4

		GUI_Settings_Handles.EDIT_Transparency := hEDIT_Transparency
		GUI_Settings_Handles.UPDOWN_Transparency := hUPDOWN_Transparency
		GUI_Settings_Handles.EDIT_Keywords_Timer := hEDIT_Keywords_Timer
		GUI_Settings_Handles.UPDOWN_Keywords_Timer := hUPDOWN_Keywords_Timer
		GUI_Settings_Handles.EDIT_Logs_Timer := hEDIT_Logs_Timer
		GUI_Settings_Handles.UPDOWN_Logs_Timer := hUPDOWN_Logs_Timer

		GUI_Settings_Handles.COMBO_Keywords := hCOMBO_Keywords

		GUI_Settings_Handles.EDIT_BTN1_Name := hEDIT_BTN1_Name
		GUI_Settings_Handles.EDIT_BTN1_Message := hEDIT_BTN1_Message
		GUI_Settings_Handles.EDIT_BTN2_Name := hEDIT_BTN2_Name
		GUI_Settings_Handles.EDIT_BTN2_Message := hEDIT_BTN2_Message
		GUI_Settings_Handles.EDIT_BTN3_Name := hEDIT_BTN3_Name
		GUI_Settings_Handles.EDIT_BTN3_Message := hEDIT_BTN3_Message

		Gui, Settings:Show
		Gui, Settings:Submit, NoHide
		Return

		GUI_Settings_Close:
			GUI_Settings.OnClose()
		Return
	}

	AddKeyword() {
		global GUI_Settings_Handles, GUI_Settings_Submit, sKEYWORDS
		GUI_Settings.Submit()

		entry := GUI_Settings_Submit.COMBO_Keywords
		Add_Keyword(entry)

		Declare_Keywords_List()
		keywordsList := StrReplace(sKEYWORDS, ",", "|")
		GuiControl, Settings:,% GUI_Settings_Handles.COMBO_Keywords,% "|" keywordsList
	}

	RemoveKeyword() {
		global GUI_Settings_Handles, GUI_Settings_Submit, sKEYWORDS
		GUI_Settings.Submit()

		entry := GUI_Settings_Submit.COMBO_Keywords
		Remove_Keyword(entry)

		Declare_Keywords_List()
		keywordsList := StrReplace(sKEYWORDS, ",", "|")
		GuiControl, Settings:,% GUI_Settings_Handles.COMBO_Keywords,% "|" keywordsList
	}

	Submit() {
		global GUI_Settings_Submit := {}
		global GUI_Settings_Handles

		Sleep 10
		for ctrlName, handle in GUI_Settings_Handles
		{
			GuiControlGet, content, Settings:,% handle
			GUI_Settings_Submit[ctrlName] := content
		}
		Sleep 10
	}

	OnUpDown_Change() {
		global GUI_Settings_Handles
		StringTrimLeft, ctrlType, A_GuiControl, 7

		if (A_GuiControl = "UPDOWN_Transparency")
			inc := 5
		else if (A_GuiControl = "UPDOWN_Keywords_Timer")
			inc := 1000
		else if (A_GuiControl = "UPDOWN_Logs_Timer")
			inc := 100

		GuiControlGet, curVal, Settings:,% GUI_Settings_Handles["UPDOWN_" ctrlType]
		GuiControl,Settings:,% GUI_Settings_Handles["EDIT_" ctrlType],% curVal * inc
	}

	OnClose() {
		global GUI_Settings_Handles

		GUI_Settings.SaveSettings()
		Gui,Settings:Destroy

		allContent := GUI_Notif.GetSlot("All")
		GUI_Notif.Create()
		Loop % allContent["MAX_INDEX"] {
			GUI_Notif.Add(allContent[A_Index "_Player"], allContent[A_Index "_Keyword"], allContent[A_Index "_Message"])
		}
	}

	SaveSettings() {
		global GUI_Settings_Submit, ProgramValues
		iniFile := ProgramValues.Ini_File

		GUI_Settings.Submit()

		; Timers
		Set_Local_Config("SETTINGS", "Timer_Keywords", GUI_Settings_Submit.EDIT_Keywords_Timer)
		Set_Local_Config("SETTINGS", "Timer_Logs", GUI_Settings_Submit.EDIT_Logs_Timer)
		Set_Local_Config("SETTINGS", "Transparency", GUI_Settings_Submit.EDIT_Transparency)
		; Buttons
		Set_Local_Config("BUTTONS", "Button_1_Name", GUI_Settings_Submit.EDIT_BTN1_Name)
		Set_Local_Config("BUTTONS", "Button_1_Message", GUI_Settings_Submit.EDIT_BTN1_Message)
		Set_Local_Config("BUTTONS", "Button_2_Name", GUI_Settings_Submit.EDIT_BTN2_Name)
		Set_Local_Config("BUTTONS", "Button_2_Message", GUI_Settings_Submit.EDIT_BTN2_Message)
		Set_Local_Config("BUTTONS", "Button_3_Name", GUI_Settings_Submit.EDIT_BTN3_Name)
		Set_Local_Config("BUTTONS", "Button_3_Message", GUI_Settings_Submit.EDIT_BTN3_Message)
	}
}
