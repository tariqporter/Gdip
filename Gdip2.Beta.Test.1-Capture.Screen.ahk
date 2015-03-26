#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()
return

;#####################################################################################

F12::
started := !started
if (started)
{
	i := 1
	MsgBox, Starting capture...
	SetTimer, Capture, 70
}
else
{
	MsgBox, %i% images captured
	SetTimer, Capture, off
}
return

;#####################################################################################

Capture:
bitmap1 := gdip.BitmapFromScreen(-1200, 200, 450, 240)
E := bitmap1.SaveToFile("Capture\" i++ ".jpg", 60)
bitmap1.Dispose()
return

;#####################################################################################

Esc::
gdip.Dispose()
ExitApp
return