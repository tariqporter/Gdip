#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()

brush1 := new gdip.Brush(119, 0, 0, 0)
brush2 := new gdip.Brush(0xcc8FC3F7)
;brush3 := new gdip.Brush(0xFFC9DEF5)

pen1 := new gdip.Pen(0x88C9DEF5, 10)
pen2 := new gdip.Pen(0x88C9DEF5, 10)

point1 := new gdip.Point(0, 0)
size1 := new gdip.Size(450, 300)

bitmapCross := gdip.BitmapFromFile("Icons\IcoMoon\PNG\64px\0272-cross.png").ImageAttr([[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,0.6,0],[1,1,1,0,1]]).Resize(0.4)
bitmapCross2 := bitmapCross.Resize(0.7, 0)

shapeCross := new gdip.Shape("Image", bitmapCross2, new gdip.Point(410, 20))
shapeCross.hoverIn := { function: "CrossHover", parameters: { gdip: gdip, bitmapCross: bitmapCross, bitmapCross2: bitmapCross2 }}
shapeCross.hoverOut := shapeCross.hoverIn

win1 := new gdip.Window(size1)
obj1 := new gdip.Object(size1)

shapeBackground := new gdip.Shape("Rectangle", point1, size1, 20, brush1, 0)
shapeBackground.click := "Drag"

r := 0
;shapeBars := []

scBar := new gdip.ShapeCollection()
shapeBar1 := new gdip.Shape("Rectangle", new gdip.Point(20, 60), new gdip.Size(410, 130), r, 0, 0)
shapeBar2 := new gdip.Shape("Rectangle", shapeBar1.Point, shapeBar1.Size, shapeBar1.radius - shapebar1.Pen.Width, brush2, pen2)
scBar.Items.Insert(shapeBar1)
scBar.Items.Insert(shapeBar2)

;MsgBox, % scBar.Items.MaxIndex() "`n" scBar.Items[1].Shape

;shapeBar.click := { function: "MyProgressControl" }

/*
shapeBars.Insert(shapeBar)

shapeBar2 := new gdip.Shape("Rectangle", new gdip.Point(shapeBar.Point, 0, 160), new gdip.Size(410, 40), r, 0, 0)
shapeBar2.inner := new gdip.Shape("Rectangle", shapeBar2.Point, shapeBar2.Size, shapeBar2.radius - shapebar2.Pen.Width, brush2, pen2)
shapeBar2.click := { function: "MyProgressControl" }

shapeBars.Insert(shapeBar2)
*/

win1.Update(obj1, new gdip.Point((A_ScreenWidth - win1.Width) // 2 - 0, (A_ScreenHeight - win1.Height) // 2))

drawFrameObj := { gdip: gdip, win1: win1, shapeBackground: shapeBackground, scBar : scBar, shapeCross: shapeCross }
obj1.DrawFrame("Update", 10, drawFrameObj)
return

;#####################################################################################

CrossHover(shape, e, paramObj)
{
	for k, v in paramObj
		%k% := v
	
	if (e.type = "hoverIn")
	{
		shape.point := new gdip.Point(shape.point, -4, -4)
		shape.SetBitmap(bitmapCross)
		shape.opacity := 1
	}
	else if(e.type = "hoverOut")
	{
		shape.point := new gdip.Point(shape.point, 4, 4)
		shape.SetBitmap(bitmapCross2)
		shape.opacity := 0.6
	}
}

;#####################################################################################

MyProgressControl(shape, e, paramObj)
{
	;MsgBox, here
	s := shape.inner
	x := (x > s.width - 2 * s.Pen.width) ? s.width - 2 * s.Pen.width : e.x
	shape.inner.animate(10, { time: 300, width: x })
	;e.stopPropagation := true
}

;#####################################################################################

Update(obj, paramObj)
{
	for k, v in paramObj
		%k% := v

	obj.DrawShape(shapeBackground)
	/*
	for k, v in shapeBars
	{
		obj.DrawShape(v)
		obj.DrawShape(v.inner)
	}
	*/
	obj.DrawShapeCollection(scBar)
	obj.DrawShape(shapeCross)
	win1.Update(obj)
}

Esc::
ExitApp
return