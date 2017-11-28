CoordMode(obj="") {
/*	Param1
 *	ToolTip: Affects ToolTip.
 *	Pixel: Affects PixelGetColor, PixelSearch, and ImageSearch.
 *	Mouse: Affects MouseGetPos, Click, and MouseMove/Click/Drag.
 *	Caret: Affects the built-in variables A_CaretX and A_CaretY.
 *	Menu: Affects the Menu Show command when coordinates are specified for it.

 *	Param2
 *	If Param2 is omitted, it defaults to Screen.
 *	Screen: Coordinates are relative to the desktop (entire screen).
 *	Relative: Coordinates are relative to the active window.
 *	Window [v1.1.05+]: Synonymous with Relative and recommended for clarity.
 *	Client [v1.1.05+]: Coordinates are relative to the active window's client area, which excludes the window's title bar, menu (if it has a standard one) and borders. Client coordinates are less dependent on OS version and theme.
*/
	if !(obj) { ; No param specified. Return current settings
		CoordMode_Settings := {}

		CoordMode_Settings.ToolTip 	:= A_CoordModeToolTip
		CoordMode_Settings.Pixel 	:= A_CoordModePixel
		CoordMode_Settings.Mouse 	:= A_CoordModeMouse
		CoordMode_Settings.Caret 	:= A_CoordModeCaret
		CoordMode_Settings.Menu 	:= A_CoordModeMenu

		return CoordMode_Settings
	}

	for param1, param2 in obj { ; Apply specified settings.
		if param1 not in ToolTip,Pixel,Mouse,Caret,Menu
			MsgBox, Wrong Param1 for CoordMode: %param1%
		else if param2 not in Screen,Relative,Window,Client
			Msgbox, Wrong Param2 for CoordMode: %param2%
		else
			CoordMode,%param1%,%param2%
	}
}
