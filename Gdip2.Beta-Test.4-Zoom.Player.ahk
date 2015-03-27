#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()

iconsZip := new gdip.Zip("Icons\IcoMoon\icomoon.zip")
fishZip := new gdip.Zip("Capture.zip")
fishCount := fishZip.Files.MaxIndex()
icons := { Bitmap: [] }

loop % iconsZip.Files.MaxIndex()
{
	fileName := iconsZip.Files[A_Index].FileName
	RegExMatch(fileName, "\d+\-([\w\-]+)\.png", m)
	bitmap1 := gdip.BitmapFromZip(iconsZip, fileName).ApplyColorMatrix([[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,1,0],[1,1,1,0,1]])
	icons.Bitmap[m1] := bitmap1
}

array := []
loop % fishCount
{
	index := fishZip.GetIndex("Capture\" A_Index ".jpg")
	array.Insert(fishZip.Files[index])
}
fishZip.Files := array

bitmap1 := gdip.BitmapFromZip(fishZip, 1)
UnScaledSize := bitmap1.Size
bitmap1.Dispose()

point1 := new gdip.Point(0, 0)
brush1 := new gdip.Brush(119, 0, 0, 0)

iconCross := icons.Bitmap["cross"].Resize(0.2)
iconArrowDown := icons.Bitmap["arrow-down"].Resize(0.4)
iconArrowUp := icons.Bitmap["arrow-up"].Resize(0.4)
iconZoomIn := icons.Bitmap["zoom-in"].Resize(0.7)
iconZoomOut := icons.Bitmap["zoom-out"].Resize(0.7)

size1 := new gdip.Size(UnScaledSize.Width + 20, UnScaledSize.Height + 40 + iconCross.Height + iconArrowDown.Height)

win1 := new gdip.Window(size1)

crossPoint := new gdip.Point(win1.Width - iconCross.Width - 10, 10)
arrowDownPoint := new gdip.Point((win1.Width - iconArrowDown.Width) // 2, win1.Height - iconArrowDown.Height - 10)
arrowUpPoint := new gdip.Point((win1.Width - iconArrowUp.Width) // 2, win1.Height - iconArrowUp.Height - 10 + 100)

expand := true
if (!expand)
	size1.Height += 100
obj1 := new gdip.Object(size1)
arrowPoint := (!expand) ? arrowUpPoint : arrowDownPoint

iconZoomOutPoint := new gdip.Point((win1.Width // 3) - (iconZoomOut.Width // 2), arrowUpPoint.Y - iconZoomOut.Height - 20)
iconZoomInPoint := new gdip.Point((2 * win1.Width // 3) - (iconZoomIn.Width // 2), arrowUpPoint.Y - iconZoomIn.Height - 20)

win1.Update(obj1, new gdip.Point((A_ScreenWidth - win1.Width) // 2, (A_ScreenHeight - win1.Height) // 2))

z := 1
i := 0
SetTimer, Update, 70
return

;#####################################################################################

Update:
i := (i > fishCount) ? 1 : i + 1
bitmap1 := gdip.BitmapFromZip(fishZip, i)
obj1.Clear()
obj1.FillRoundedRectangle(brush1, point1, size1, 10)

iconArrow := (expand) ? iconArrowDown : iconArrowUp

bitmap2 := bitmap1.CloneBitmapArea(new gdip.Point(0, 0), new gdip.Size(UnScaledSize, 1 / z)).Resize(z)
obj1.DrawImage(bitmap2, new gdip.Point(10, 30))

obj1.DrawImage(iconCross, crossPoint, (win1.IsHover(crossPoint, iconCross)) ? 1 : 0.5)
obj1.DrawImage(iconArrow, arrowPoint, (win1.IsHover(arrowPoint, expand ? iconArrowDown : iconArrowUp)) ? 1 : 0.5)

if (!expand)
{
	obj1.DrawImage(iconZoomIn, iconZoomInPoint, (win1.IsHover(iconZoomInPoint, iconZoomIn)) ? 1 : 0.5)
	obj1.DrawImage(iconZoomOut, iconZoomOutPoint, (win1.IsHover(iconZoomOutPoint, iconZoomOut)) ? 1 : 0.5)
}

win1.Update(obj1)
;Will be garbage collected when out of scope
;bitmap1.Dispose()

lButton := GetKeyState("LButton")
if (lButton)
{
	if (win1.IsHover(crossPoint, iconCross))
	{
		ExitApp
	}
	else if (win1.IsHover(iconZoomInPoint, iconZoomIn))
	{
		z := (z >= 4) ? 4 : z + 0.2
	}
	else if (win1.IsHover(iconZoomOutPoint, iconZoomOut))
	{
		z := (z <= 1) ? 1 : z - 0.2
	}
	else if (win1.IsHover(arrowPoint, iconArrow))
	{
		expand := !expand
		arrowPoint := (expand) ? arrowDownPoint : arrowUpPoint
		size1.Height := (expand) ? size1.Height - 100 : size1.Height + 100
		obj1 := new gdip.Object(size1)
	}
	else
		win1.Drag()
}
return

;#####################################################################################

Esc::
ExitApp
return