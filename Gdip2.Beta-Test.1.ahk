#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()
win1 := new gdip.Window({ "width":400, "height":400 })
css := { "width": "200px", "height": "200px", "background-color": "rgb(238, 124, 28)", "border-radius": "0", "border-width": "20px", "border-color": "rgb(120, 190, 160)" }
win1.shapeInsert("#square1.square-class", css)
css.left := "200px"
win1.shapeInsert("#square2.square-class", css)
win1.Update({ x: (A_ScreenWidth - win1.width) / 2, y: (A_ScreenHeight - win1.height) / 2 })
win1.MainLoop("Update", 10, { tick: A_TickCount, time: 500 })
return

;#####################################################################################

Update(win, p)
{
	if (A_TickCount - p.tick > p.time)
	{
		p.tick := A_TickCount, p.on := !p.on
		css := { "border-color": "rgb(120, 190, 160)", "border-width": "50px" }
		win.shapeMatch(p.on ? "#square1" : "#square2").css(css)
		css := { "border-color": "#CC5E412C", "border-width": "20px" }
		win.shapeMatch(p.on ? "#square2" : "#square1").css(css)
		win.shapeMatch(".square-class").css(p.on ? { "border-radius": "10px" } : { "border-radius": "0" })
	}
}

;#####################################################################################

Esc::
ExitApp
return
