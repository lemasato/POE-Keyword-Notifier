Class GUI_Notif
{
	Create() {
		static
		global PROGRAM, hGUI_Notif
		global GUI_Notif_Handles := {}, GUI_Notif_Values := {}
		global Tabs_Infos := {}
		global TABS_COUNT := 0

		config_Buttons := Get_Local_Config("BUTTONS")
		cTransparency := Get_Local_Config("SETTINGS", "Transparency")

		Gui, Notif:Destroy
		Gui, Notif:New, -SysMenu +AlwaysOnTop +ToolWindow +HwndhGUI_Notif
		Gui, Notif:Font,S8,Segoe UI

		Gui, Notif:Add, Tab2, x0 y0 w302 h132 vTabCtrl hwndhTabCtrl gGUI_Notif.OnTabSwitch +Theme -Wrap
		Gui, Notif:Tab
		Gui, Notif:Add, Text, x10 y30 hwndTEXT_Player BackgroundTrans,Player: 
		Gui, Notif:Add, Text, xp+55 yp 0x0100 w210 hwndhTEXT_PlayerSlot BackgroundTrans,
		Gui, Notif:Add, Text, x10 y+10 hwndhTEXT_Keyword BackgroundTrans,Keyword:
		Gui, Notif:Add, Text, xp+55 yp 0x0100 w230 hwndhTEXT_KeywordSlot BackgroundTrans,
		Gui, Notif:Add, Text, x10 y+10 hwndhTEXT_Message BackgroundTrans,Message:
		Gui, Notif:Add, Text, xp+55 yp 0x0100 w230 hwndhTEXT_MessageSlot BackgroundTrans,

		Gui, Notif:Add, Button, x8 y+10 w95 h25 hwndhBTN_Msg1,% config_Buttons.Button_1_Name
		__f := GUI_Notif.SendMsg.bind(GUI_Notif, "1")
		GuiControl, Notif:+g,% hBTN_Msg1,% __f

		Gui, Notif:Add, Button, x+0 yp wp hp hwndhBTN_Msg2,% config_Buttons.Button_2_Name
		__f := GUI_Notif.SendMsg.bind(GUI_Notif, "2")
		GuiControl, Notif:+g,% hBTN_Msg2,% __f

		Gui, Notif:Add, Button, x+0 yp wp hp hwndhBTN_Msg3,% config_Buttons.Button_3_Name
		__f := GUI_Notif.SendMsg.bind(GUI_Notif, "3")
		GuiControl, Notif:+g,% hBTN_Msg3,% __f

		Gui, Notif:Add, Button, hwndhBTN_Close x280 y21 w20 h20 gGUI_Notif.CloseTab,X

		GUI_Notif_Handles.TabCtrl := hTabCtrl
		GUI_Notif_Handles.TEXT_PlayerSlot := hTEXT_PlayerSlot
		GUI_Notif_Handles.TEXT_KeywordSlot := hTEXT_KeywordSlot
		GUI_Notif_Handles.TEXT_MessageSlot := hTEXT_MessageSlot

		GUI_Notif_Values.Button_1_Message := config_Buttons.Button_1_Message
		GUI_Notif_Values.Button_2_Message := config_Buttons.Button_2_Message
		GUI_Notif_Values.Button_3_Message := config_Buttons.Button_3_Message

		Gui, Notif:Show, x0 y0 w300 h130 Hide,% PROGRAM.NAME
		OnMessage(0x200, "WM_MOUSEMOVE")
		Gui, Notif:+LastFound
		WinSet, Transparent,% cTransparency
		Return
	}

	SendMsg(num, CtrlHwnd) {
		global GUI_Notif_Values

		player := GUI_Notif.GetSlot("Player")
		msg := StrReplace(GUI_Notif_Values["Button_" num "_Message"], "%player%", player)

		Send_IGMessage(msg)
	}

	CloseTab() {
		global GUI_Notif_Handles, TABS_COUNT, Tabs_Infos

		GuiControlGet, tabNum, Notif:,% GUI_Notif_Handles.TabCtrl

		Tabs_Infos[tabNum "_Player"] := ""
		Tabs_Infos[tabNum "_Keyword"] := ""
		Tabs_Infos[tabNum "_Message"] := ""
		
		tabNumToReplace := tabNum
		if (tabNum < TABS_COUNT) {
			while (tabNumToReplace < TABS_COUNT) {
				Tabs_Infos[tabNumToReplace "_Player"] := Tabs_Infos[tabNumToReplace+1 "_Player"]
				Tabs_Infos[tabNumToReplace "_Keyword"] := Tabs_Infos[tabNumToReplace+1 "_Keyword"]
				Tabs_Infos[tabNumToReplace "_Message"] := Tabs_Infos[tabNumToReplace+1 "_Message"]
				tabNumToReplace++
			}
		}
		Tabs_Infos[TABS_COUNT "_Player"] := ""
		Tabs_Infos[TABS_COUNT "_Keyword"] := ""
		Tabs_Infos[TABS_COUNT "_Message"] := ""

		TABS_COUNT--

		GuiControl, Notif:,% GUI_Notif_Handles.TabCtrl,|
		Loop % TABS_COUNT {
			GuiControl, Notif:,% GUI_Notif_Handles.TabCtrl,% A_Index
		}
		GUI_Notif.OnTabSwitch()
		GuiControl, Notif:ChooseString,% GUI_Notif_Handles.TabCtrl,% tabNum
		if (ErrorLevel)
			GuiControl, Notif:ChooseString,% GUI_Notif_Handles.TabCtrl,% tabNum-1

		if (TABS_COUNT = 0) {
			Gui, Notif:Hide
		}
	}

	GetSlot(which) {
		global GUI_Notif_Handles, TABS_COUNT

		if (which = "Player")
			GuiControlGet, content, Notif:,% GUI_Notif_Handles.TEXT_PlayerSlot
		else if (which = "Keyword")
			GuiControlGet, content, Notif:,% GUI_Notif_Handles.TEXT_KeywordSlot
		else if (which = "Message")
			GuiControlGet, content, Notif:,% GUI_Notif_Handles.TEXT_MessageSlot
		else if (which = "All") {
			allContent := {}
			Loop % TABS_COUNT {
				pContent := GUI_Notif.GetSlot("Player")
				kContent := GUI_Notif.GetSlot("Keyword")
				mContent := GUI_Notif.GetSlot("Message")

				allContent[A_Index "_Player"] := pContent
				allContent[A_Index "_Keyword"] := kContent
				allContent[A_Index "_Message"] := mContent
			}
			allContent["MAX_INDEX"] := TABS_COUNT
			return allContent
		}

		return content
	}

	Add(player, keyword, msg) {
		global GUI_Notif_Handles
		global Tabs_Infos
		global TABS_COUNT		
		TABS_COUNT++

		Tabs_Infos[TABS_COUNT "_Player"] := player
		Tabs_Infos[TABS_COUNT "_Keyword"] := keyword
		Tabs_Infos[TABS_COUNT "_Message"] := msg

		GuiControl, Notif:,% GUI_Notif_Handles.TabCtrl,%TABS_COUNT%
		GUI_Notif.OnTabSwitch()

		Gui, Notif:Show, NoActivate
	}

	OnTabSwitch() {
		global GUI_Notif_Handles, Tabs_Infos
		GuiControlGet, tabNum, Notif:,% GUI_Notif_Handles.TabCtrl
		
		GuiControl, Notif:,% GUI_Notif_Handles.TEXT_PlayerSlot,% Tabs_Infos[tabNum "_Player"]
		GuiControl, Notif:,% GUI_Notif_Handles.TEXT_KeywordSlot,% Tabs_Infos[tabNum "_Keyword"]
		GuiControl, Notif:,% GUI_Notif_Handles.TEXT_MessageSlot,% Tabs_Infos[tabNum "_Message"]
	}
}