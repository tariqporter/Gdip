#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()

/*
zip1 := new gdip.Zip("Capture.zip")
fileCount := zip1.Files.MaxIndex()


array := []
loop %fileCount%
{
	index := zip1.GetIndex("Capture\" A_Index ".jpg")
	array.Insert(zip1.Files[index])
}
zip1.Files := array
*/

;bitmap1 := gdip.BitmapFromFile("Capture\1.jpg")
;bitmap1 := gdip.BitmapFromZip(zip1, "Capture\1.jpg")

/*
bitmap1 := gdip.BitmapFromZip(zip1, 1)
point1 := new gdip.Point(0, 0)
size1 := new gdip.Size(bitmap1.Width + (2 * 30), bitmap1.Height + (2 * 30))
bitmap1.Dispose()
*/

point1 := new gdip.Point(0, 0)
size1 := new gdip.Size(500, 500)
obj1 := new gdip.Object(size1)
win1 := new gdip.Window(point1, size1)

spriteSheet := { Source: gdip.BitmapFromFile("Icons\glyphicons-halflings.png") }
spriteSheet.Information := [{x:0,y:0,w:23,h:22},{x:24,y:0,w:23,h:22},{x:48,y:0,w:23,h:22},{x:72,y:0,w:23,h:22}]
spriteSheet.Bitmaps := []
x := 0
loop % spriteSheet.Information.MaxIndex()
{
	i := spriteSheet.Information[A_Index]
	;MsgBox, % i.x "`n" i.y "`n" i.w "`n" i.h
	bitmap1 := spriteSheet.Source.CloneBitmapArea(new gdip.Point(i.x, i.y), new gdip.Size(i.w, i.h))
	spriteSheet.Bitmaps.Insert(bitmap1)
	;MsgBox, % bitmap1.Pointer
	obj1.DrawImage(bitmap1, new gdip.Point(x, 0))
	x += bitmap1.Width
	bitmap1.Dispose()
}

;OnMessage(0x201, "WM_LBUTTONDOWN")
win1.Update(obj1, new gdip.Point((A_ScreenWidth - win1.Width) // 2, (A_ScreenHeight - win1.Height) // 2))

;brush1 := new gdip.Brush(119, 0, 0, 0)

i := 0
;SetTimer, Update, 70
return

;#####################################################################################

Update:
i := (i > fileCount) ? 1 : i + 1
;bitmap1 := gdip.BitmapFromFile("Capture\" i ".jpg")
;bitmap1 := gdip.BitmapFromZip(zip1, "Capture\" i ".jpg")
bitmap1 := gdip.BitmapFromZip(zip1, i)
obj1.Clear()
obj1.FillRoundedRectangle(brush1, point1, size1, 10)
obj1.DrawImage(bitmap1, new gdip.Point(30, 30))
win1.Update(obj1)
bitmap1.Dispose()
return

;#####################################################################################

WM_LBUTTONDOWN()
{
	PostMessage, 0xA1, 2
}

;#####################################################################################

Esc::
brush1.Dispose()
zip.Dispose()
gdip.Dispose()
ExitApp
return