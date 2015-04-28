#Persistent
#SingleInstance Force

#include Gdip2.ahk

gdip := new Gdip()
win1 := new gdip.Window({ "width":400, "height":400 })

css := new gdip.StyleSheet(
(Join
	"#square2", {
		"left": "200px",
		"width": "180px",
		"border-color": "rgb(120, 190, 160)"
	},
	"#square3", {
		"top": "200px",
		"width": "380px",
		"height": "110px"
	},
	".squares", {
		"width": "200px", 
		"height": "200px", 
		"background-color": "rgb(238, 124, 28)",
		"border-radius": "20px",
		"border-width": "10px",
		"border-color": "#F0A832",
		"color": "rgba(60,130,20,0.9)",
		"text-align": "center",
		"font-size": "30px"
	},
	".other-class", {
		"background-color": "rgba(250, 230, 180, 0.5)"
	},
	".no-corner", {
		"border-radius": "0"
	},
	".border-class", {
		"border-color": "#CC5E412C",
		"border-width": "20px",
		"border-radius": "0"
	}
))
win1.styleSheetInsert(css)

win1.shapeInsert("#square1.squares.other-class").shapeInsert("#square2.squares").shapeInsert("#square3.squares.border-class")
win1.shapeMatch(".squares").text("Loading...")
win1.Update({ x: (A_ScreenWidth - win1.width) / 2 - 1200, y: (A_ScreenHeight - win1.height) / 2 })
win1.MainLoop("Update", 10, { tick: A_TickCount, time: 800 })
return

;#####################################################################################

Update(win, p)
{
	if (A_TickCount - p.tick > p.time)
	{
		p.tick := A_TickCount, p.on := !p.on
		win.shapeMatch(".squares").toggleClass("border-class").text(p.on ? "Hello" : "Bye!")
	}
}

;#####################################################################################

Esc::
ExitApp
return
