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
	bitmap1 := gdip.BitmapFromZip(iconsZip, fileName)
	
	;bitmap1.ImageAttributes := [[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,1,0],[1,1,1,0,1]]
	
	bitmap1.ImageAttr := [[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,0.5,0],[1,1,1,0,1]]
	;bitmap1.ImageAttributes := 0.1
	;MsgBox, % bitmap1.Pointer
	;ApplyColorMatrix([[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,1,0],[1,1,1,0,1]])
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


/*
iconCross := icons.Bitmap["cross"]
iconArrowDown := icons.Bitmap["arrow-down"]
iconArrowUp := icons.Bitmap["arrow-up"]
iconZoomIn := icons.Bitmap["zoom-in"]
iconZoomOut := icons.Bitmap["zoom-out"]
*/

size1 := new gdip.Size(UnScaledSize.Width + 20, UnScaledSize.Height + 40 + iconCross.Height + iconArrowDown.Height)

win1 := new gdip.Window(size1)

crossPoint := new gdip.Point(win1.Width - iconCross.Width - 10, 10)
arrowDownPoint := new gdip.Point((win1.Width - iconArrowDown.Width) // 2, win1.Height - iconArrowDown.Height - 10)
arrowUpPoint := new gdip.Point((win1.Width - iconArrowUp.Width) // 2, win1.Height - iconArrowUp.Height - 10 + 100)

;expand := true
;if (!expand)
;	size1.Height += 100
obj1 := new gdip.Object(size1)
;arrowPoint := (!expand) ? arrowUpPoint : arrowDownPoint

;iconZoomOutPoint := new gdip.Point((win1.Width // 3) - (iconZoomOut.Width // 2), arrowUpPoint.Y - iconZoomOut.Height - 20)
;iconZoomInPoint := new gdip.Point((2 * win1.Width // 3) - (iconZoomIn.Width // 2), arrowUpPoint.Y - iconZoomIn.Height - 20)

shapeBackground := new gdip.Shape("Rectangle", point1, size1, 20, 0, brush1, 0)
shapeBackground.click := "Drag"

win1.Update(obj1, new gdip.Point((A_ScreenWidth - win1.Width) // 2 - 1700, (A_ScreenHeight - win1.Height) // 2))

shapeFish := new gdip.Shape("Image", 0, new gdip.Point(10, 30))
shapeFish.hoverIn := { function: "FishHover", parameters: {}}

;shapeBackground.FullHeight := shapeBackground.Height
shapeCross := new gdip.Shape("Image", iconCross, new gdip.Point(win1.Width - iconCross.Width - 10, 10))
;shapeCross.hoverIn := { function: "HoverIn", parameters: { iconArrowDown: iconArrowDown, test: 69 }}
;shapeCross.hoverOut := { function: "HoverOut", parameters: { iconCross: iconCross}}
shapeCross.click := { function: "Close", parameters: { shapeFish: shapeFish }}

;bitmapCrossHover := new gdip.Bitmap

drawFrameObj := { gdip: gdip, shapeBackground: shapeBackground, win1: win1, obj1: obj1, fishCount: fishCount, fishZip: fishZip, UnScaledSize: UnScaledSize, shapeCross: shapeCross, shapeFish: shapeFish }
obj1.DrawFrame("Update", 200, drawFrameObj)
return

;#####################################################################################

HoverIn(shape, e, paramsObj)
{
	for k,v in paramsObj
		%k% := v
	shape.Opacity := 1
}

HoverOut(shape, e, paramsObj)
{
	for k,v in paramsObj
		%k% := v
	shape.Opacity := 0.5
}

Close(shape, e, paramsObj)
{
	for k,v in paramsObj
		%k% := v
	;ExitApp
	;shape.SlideUp(10, { "startHeight": 13 })
	shapeFish.Opacity := 0.2
	;MsGBox, % shapeFish.Opacity
}

FishHover(shape, e, paramsObj)
{
	for k,v in paramsObj
		%k% := v
	;Tooltip, % "fish hover" "`nx: " e.x "`ny: " e.y "`nparams: " test
}

;#####################################################################################

Update(obj, params)
{
	static i = 0, z := 1
	for k, v in params
		%k% := v

	obj.DrawShape(shapeBackground)
		
	i := (i > fishCount * 2) ? 1 : i + 1
	j := i // 2
	shapeFish.Bitmap := gdip.BitmapFromZip(fishZip, j).Resize(1)
	;shapeFish.Opacity := 0.2
	;Tooltip, % shapeFish.Opacity
	;shapeFish := new gdip.Shape("Image", gdip.BitmapFromZip(fishZip, j).Resize(1), new gdip.Point(10, 30))
	;shapeFish.hoverIn := { function: "FishHover", parameters: {}}
	obj.DrawShape(shapeFish)
	obj.DrawShape(shapeCross)
	win1.Update(obj)
}

/*
;#####################################################################################

SlideUp(shape, e, params)
{
	for k, v in params
		%k% := v
	shapeBackground.SlideUp(obj1.DrawFrameObj.Interval, { "startHeight": shapeBackground.FullHeight, "onComplete": Func("SlideDown"), "parameters": params })
}

;#####################################################################################

SlideDown(shape, e, params)
{
	for k, v in params
		%k% := v
	shapeBackground.SlideDown(obj1.DrawFrameObj.Interval, { "endHeight": shapeBackground.FullHeight, "onComplete": Func("SlideUp"), "parameters": params })
}

;#####################################################################################

*/

Esc::
ExitApp
return