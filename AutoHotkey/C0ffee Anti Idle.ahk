#InstallKeybdHook
#Persistent
#MaxThreadsPerHotkey 2

; Todo: 
; * make Close Tab check if the current window still exist if it does try ^m or taskkill ?
;;;;;;;;;;;;;;;;;;;;
;Initialize profiles
;;;;;;;;;;;;;;;;;;;;

LoadProfile()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;KEY BINDS !!! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Close Tab Alt+w

Numpad7::^w


; Copy
Numpad4::send ^c

; Paste
Numpad5::^v

; Fancy pants paste
NumpadAdd::#v

; Alt Tab sort of 
Numpad0:: Send !{Tab}	; brings up the Alt-Tab menu
Numpad1:: Send {Alt Down}{Shift Down}{Tab}{Alt Up}{Shift Up}	; brings up the Alt-Tab menu backaward

; Chrome Tabs
NumpadDiv::^+tab
NumpadMult::^tab

!F11::HighContrastOn()
!F12::HighContrastOff()

; Alt F4!
NumpadSub::CloseWindow()


; Reload
^!r::ReloadScript()

;;;;;;;;;;;;;;;;;;;;
;Anti idle binding enter key to prevent sending of clipboard or sensitive data
;;;;;;;;;;;;;;;;;;;;

AntiIdleNoEnter:
{


	if (A_TimeIdle > 900000)
	{
		SendF22()
		Hotkey, Enter, On
		Hotkey, NumpadEnter, On
	}	
}
return

;;;;;;;;;;;;;;;;;;;;
;Anti idle Normal 
;;;;;;;;;;;;;;;;;;;;

AntiIdle()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
}
return

;;;;;;;;;;;;;;;;;;;;
;Anti idle Unknown Computer (not mine)
;;;;;;;;;;;;;;;;;;;;

AntiIdleUnknown()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
;this will never trigger ..
;	if (A_TimeIdle > 900000)
;	{
;		SetNormal()
;	}

}
return

;;;;;;;;;;;;;;;;;;;;;
;Sends F22 to anti idle
;;;;;;;;;;;;;;;;;;;;

SendF22()
{
Send,{F22}
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
;Setup profile based on IP address
;;;;;;;;;;;;;;;;;;;;

LoadProfile()
{
objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
	{
		IPAddress := % objItem.IPAddress[0]
		If InStr(IPAddress, "10.76.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			SetTimer, AntiIdleNoEnter, 900000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOn()
			break
			}

		else If InStr(IPAddress, "192.168.20.12")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOn()			
			break
			}

		else If InStr(IPAddress, "10.206.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Office Profile")
			SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(1)
			HighContrastOn()
			break
			}
		else If InStr(IPAddress, "192.168.3.17")
			{
			Message("IPAddress: " . IPAddress . " Loading Game Home Profile")
			SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOn()			
			break
			}	
	}

;;;;;;;;;;;;;;;;;;;;
;Fallback setting for NOT MY COMPUTER to idle and revert back any settings
;;;;;;;;;;;;;;;;;;;;

	if ProfileSet != 1
	{
	Message("Setting profile for unknown system?")
	SetTimer, AntiIdleUnknown, 58000, 0
	SwapMouseButton(1)
	}
}

;;;;;;;;;;;;;;;;;;;;
;Get IP address functions use to load 'profiles' based on IP address
;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
;Display the networks public IP
;;;;;;;;;;;;;;;;;;;;

GetPublicIP() {
    HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HttpObj.Open("GET","https://www.google.com/search?q=what+is+my+ip&num=1")
    HttpObj.Send()
    RegexMatch(HttpObj.ResponseText,"Client IP address: ([\d\.]+)",match)
    Return match1
}
return

;;;;;;;;;;;;;;;;;;;;
;Unbinds Enter key
;;;;;;;;;;;;;;;;;;;;

Enter::Message("Press F1 Key to Stop")
NumpadEnter::Message("Press F1 Key to Stop")
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off

F1::
{
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off
return
}

;;;;;;;;;;;;;;;;;;;;
;Refresh all windows (F5)
;;;;;;;;;;;;;;;;;;;;

ClickyClick()
{
WinGet windows, List
	Loop %windows%
	{
	id := windows%A_Index%
	WinGetTitle wt, ahk_id %id%
	r .= wt . "`n"
	settitlematchmode,2
	if (wt != "")
	{
	WinActivate,%wt%
	sleep,500
	Send,^{F5}
	;tooltip,%wt%
	}
	CoordMode, Mouse, window
	}
return
}


;;;;;;;;;;;;;;;;;;;;
; SwapMouseButton(0) or 1
;;;;;;;;;;;;;;;;;;;;

SwapMouseButton(Swap)
{
	; SwapMouseButton(0)   ; Right-Hand
	; SwapMouseButton(1)   ; Left-Hand
	DllCall("user32.dll\SwapMouseButton", "UInt", Swap)
}

;;;;;;;;;;;;;;;;;;;;
; Turn on High contrast
;;;;;;;;;;;;;;;;;;;;

HighContrastOn()
{
	vFlags := 0x1 ;on
	vSize := A_PtrSize=8?16:12
	VarSetCapacity(HIGHCONTRAST, vSize, 0)
	NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
	;HCF_HIGHCONTRASTON := 0x1
	NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
	;SPI_SETHIGHCONTRAST := 0x43
	DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
}
return


;;;;;;;;;;;;;;;;;;;;
; Turn off high contrast ( some colors are off in windows ) maybe apply theme on / off to fix
;;;;;;;;;;;;;;;;;;;;

HighContrastOff()
{
	vFlags := 0x0 ;off
	vSize := A_PtrSize=8?16:12
	VarSetCapacity(HIGHCONTRAST, vSize, 0)
	NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
	;HCF_HIGHCONTRASTON := 0x1
	NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
	;SPI_SETHIGHCONTRAST := 0x43
	DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
}
return

;;;;;;;;;;;;;;;;;;;;
; Sets everything back to normal
;;;;;;;;;;;;;;;;;;;;

SetNormal()
{

HighContrastOff()
SwapMouseButton(0)

}
return

;;;;;;;;;;;;;;;;;;;;
; Easy way to Send message
;;;;;;;;;;;;;;;;;;;;

Message(Message)
{
TrayTip, "%Message%" ," ",10, 1
tooltip, "%Message%",300,300
;msgbox,0,, 	"%Message%",3 ; Do not use because of it changes focus ..
sleep, 5000
tooltip,
}

;;;;;;;;;;;;;;;;;;;;
; Close window Alt+F4 but says no to save notepad prompt
;;;;;;;;;;;;;;;;;;;;

CloseWindow()
{
send,!{f4}
;#IfWinActive, ahk_class Notepad
;ifWinActive Notepad ahk_class #32770
WinActivate, Notepad ahk_class #32770

	{
		sleep,20
		send,n
	}
}
return

;;;;;;;;;;;;;;;;;;;;
; Reloads the script so you don't have to rightclick reload etc
;;;;;;;;;;;;;;;;;;;;

ReloadScript()
{
Reload
Message("Reloading")
}
return
