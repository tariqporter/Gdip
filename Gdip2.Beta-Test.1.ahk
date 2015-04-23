#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()
win1 := new gdip.Window({ "width":400, "height":400 })
css := { "width":200, "height": 200, "background-color":{A:100, R:20, G:40, B:200}, "border-radius":0, "border-width":20, "border-color":{A:200, R:50, G:150, B:130} }
win1.shapeInsert("#square1.square-class", new gdip.Shape(css))
css.x := 200
win1.shapeInsert("#square2.square-class", new gdip.Shape(css))
win1.Update({ x: (A_ScreenWidth - win1.width) / 2, y: (A_ScreenHeight - win1.height) / 2 })
win1.MainLoop("Update", 10, { tick: A_TickCount, time: 500 })
return

;#####################################################################################

Update(win, p)
{
	if (A_TickCount - p.tick > p.time)
	{
		p.tick := A_TickCount, p.on := !p.on
		css := { "border-color":{A:200, R:200, G:150, B:30}, "border-width":50, "border-radius": 10 }
		win.shapeMatch(p.on ? "#square1" : "#square2").css(css)
		css := { "border-color":{A:200, R:50, G:150, B:130}, "border-width":20, "border-radius": 0 }
		win.shapeMatch(p.on ? "#square2" : "#square1").css(css)
	}
}

;#####################################################################################

Esc::
ExitApp
return
