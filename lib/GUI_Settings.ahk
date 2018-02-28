Class GUI_Settings {
	Create() {
		static
		global PROGRAM, sKEYWORDS, hGUI_Settings
		global GUI_Settings_Handles := {}
		global GUI_Settings_Submit := {}

		config_Buttons := Get_Local_Config("BUTTONS")
		config_Settings := Get_Local_Config("SETTINGS")
		Declare_Keywords_List()

		Gui, Settings:Destroy
		Gui, Settings:New, +AlwaysOnTop +ToolWindow +LabelGUI_Settings_ +HwndhGUI_Settings
		Gui, Settings:Font,S8,Segoe UI

		Gui, Settings:Add, Text, x10 y10,Transparency (50-255): 
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

		Gui, Settings:Add, GroupBox, x10 y+10 w435 h50 c000000,Chats to monitor
		Gui, Settings:Add, CheckBox,% "x25 yp+25 vCB_MonitorGlobal hwndhCB_MonitorGlobal Checked" config_Settings.Monitor_Global,# (global)
		Gui, Settings:Add, CheckBox,% "x+5 yp vCB_MonitorParty hwndhCB_MonitorParty Checked" config_Settings.Monitor_Party,`% (party)
		Gui, Settings:Add, CheckBox,% "x+5 yp vCB_MonitorWhispers hwndhCB_MonitorWhispers Checked" config_Settings.Monitor_Whispers,@ (whispers)
		Gui, Settings:Add, CheckBox,% "x+5 yp vCB_MonitorTrade hwndhCB_MonitorTrade Checked" config_Settings.Monitor_Trade,$ (trade)
		Gui, Settings:Add, CheckBox,% "x+5 yp vCB_MonitorGuild hwndhCB_MonitorGuild Checked" config_Settings.Monitor_Guild,`& (guild)

		keywordsList := StrReplace(sKEYWORDS, ",", "|")
		Gui, Settings:Add, GroupBox, x10 y+15 w435 h50 c000000,Keywords
		Gui, Settings:Add, ComboBox, x25 yp+20 w200 R10 vCOMBO_Keywords hwndhCOMBO_Keywords,% keywordsList
		Gui, Settings:Add, Button, x+5 w100 gGUI_Settings.AddKeyword,Add
		Gui, Settings:Add, Button, x+5 w100 gGUI_Settings.RemoveKeyword,Remove

		Gui, Settings:Add, GroupBox, x10 y+10 w435 h55 c000000,Button 1
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN1_Name hwndhEDIT_BTN1_Name R1,% config_Buttons.Button_1_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN1_Message hwndhEDIT_BTN1_Message R1,% config_Buttons.Button_1_Message

		Gui, Settings:Add, GroupBox, x10 y+15 w435 h55 c000000,Button 2
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN2_Name hwndhEDIT_BTN2_Name R1,% config_Buttons.Button_2_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN2_Message hwndhEDIT_BTN2_Message R1,% config_Buttons.Button_2_Message

		Gui, Settings:Add, GroupBox, x10 y+15 w435 h55 c000000,Button 3
		Gui, Settings:Add, Text, x25 yp+25,Name:
		Gui, Settings:Add, Edit, x+5 yp-3 w95 vEDIT_BTN3_Name hwndhEDIT_BTN3_Name R1,% config_Buttons.Button_3_Name
		Gui, Settings:Add, Text, x+5 yp+3,Message:
		Gui, Settings:Add, Edit, x+5 yp-3 w220 vEDIT_BTN3_Message hwndhEDIT_BTN3_Message R1,% config_Buttons.Button_3_Message

		Gui, Settings:Add, Text, x10 y+20,% "v" PROGRAM.VERSION
		Gui, Settings:Add, Link, x10 y+0 hwndhLINK_GitHub gGitHub_Link,% "<a href="""">GitHub</a>"

		AddToolTip(hEDIT_Transparency, "Level of transparency of the interface.`n`nDefault value: 200.")
		AddToolTip(hUPDOWN_Transparency, "Level of transparency of the interface.`n`nDefault value: 200.")
		AddToolTip(hEDIT_Keywords_Timer, "Rate at which the file containing keywords should be read`nin case you add or remove keywords.`n`nDefault value: 30000ms (=30s).")
		AddToolTip(hUPDOWN_Keywords_Timer, "Rate at which the file containing keywords should be read`nin case you add or remove keywords.`n`nDefault value: 30000ms (=30s).")
		AddToolTip(hEDIT_Logs_Timer, "Rate at which POE logs file should be read.`n`nDefault value: 600ms (=0.6s)")
		AddToolTip(hUPDOWN_Logs_Timer, "Rate at which POE logs file should be read.`n`nDefault value: 600ms (=0.6s)")

		AddToolTip(hEDIT_BTN1_Name, "Name of the button as it will appear on the interface.")
		AddToolTip(hEDIT_BTN2_Name, "Name of the button as it will appear on the interface.")
		AddToolTip(hEDIT_BTN3_Name, "Name of the button as it will appear on the interface.")
		AddToolTip(hEDIT_BTN1_Message, "Message that should be sent upon pressing this button.`nUse @%player% to send it as whisper to the player.")
		AddToolTip(hEDIT_BTN2_Message, "Message that should be sent upon pressing this button.`nUse @%player% to send it as whisper to the player.")
		AddToolTip(hEDIT_BTN3_Message, "Message that should be sent upon pressing this button.`nUse @%player% to send it as whisper to the player.")

		GUI_Settings_Handles.EDIT_Transparency := hEDIT_Transparency
		GUI_Settings_Handles.UPDOWN_Transparency := hUPDOWN_Transparency
		GUI_Settings_Handles.EDIT_Keywords_Timer := hEDIT_Keywords_Timer
		GUI_Settings_Handles.UPDOWN_Keywords_Timer := hUPDOWN_Keywords_Timer
		GUI_Settings_Handles.EDIT_Logs_Timer := hEDIT_Logs_Timer
		GUI_Settings_Handles.UPDOWN_Logs_Timer := hUPDOWN_Logs_Timer

		GUI_Settings_Handles.CB_MonitorGlobal := hCB_MonitorGlobal
		GUI_Settings_Handles.CB_MonitorParty := hCB_MonitorParty
		GUI_Settings_Handles.CB_MonitorWhispers := hCB_MonitorWhispers
		GUI_Settings_Handles.CB_MonitorTrade := hCB_MonitorTrade
		GUI_Settings_Handles.CB_MonitorGuild := hCB_MonitorGuild

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
		global GUI_Settings_Submit, PROGRAM
		iniFile := PROGRAM.INI_FILE

		GUI_Settings.Submit()

		; Timers
		Set_Local_Config("SETTINGS", "Timer_Keywords", GUI_Settings_Submit.EDIT_Keywords_Timer)
		Set_Local_Config("SETTINGS", "Timer_Logs", GUI_Settings_Submit.EDIT_Logs_Timer)
		Set_Local_Config("SETTINGS", "Transparency", GUI_Settings_Submit.EDIT_Transparency)

		; Chat channels
		Set_Local_Config("SETTINGS", "Monitor_Global", GUI_Settings_Submit.CB_MonitorGlobal)
		Set_Local_Config("SETTINGS", "Monitor_Party", GUI_Settings_Submit.CB_MonitorParty)
		Set_Local_Config("SETTINGS", "Monitor_Whispers", GUI_Settings_Submit.CB_MonitorWhispers)
		Set_Local_Config("SETTINGS", "Monitor_Trade", GUI_Settings_Submit.CB_MonitorTrade)
		Set_Local_Config("SETTINGS", "Monitor_Guild", GUI_Settings_Submit.CB_MonitorGuild)

		; Buttons
		Set_Local_Config("BUTTONS", "Button_1_Name", GUI_Settings_Submit.EDIT_BTN1_Name)
		Set_Local_Config("BUTTONS", "Button_1_Message", """" GUI_Settings_Submit.EDIT_BTN1_Message """")
		Set_Local_Config("BUTTONS", "Button_2_Name", GUI_Settings_Submit.EDIT_BTN2_Name)
		Set_Local_Config("BUTTONS", "Button_2_Message", """" GUI_Settings_Submit.EDIT_BTN2_Message """")
		Set_Local_Config("BUTTONS", "Button_3_Name", GUI_Settings_Submit.EDIT_BTN3_Name)
		Set_Local_Config("BUTTONS", "Button_3_Message", """" GUI_Settings_Submit.EDIT_BTN3_Message """")

		localSettings := Get_LocalSettings()
		Declare_LocalSettings(localSettings)
	}
}
