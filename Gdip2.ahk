#Persistent
#SingleInstance Force

Gdip1 := new Gdip()
point1 := new Gdip1.Point(500, 500)
size1 := new Gdip1.Size(300, 300)
win1 := new Gdip1.Window(point1, size1)
obj1 := new Gdip1.Object(size1)
brush1 := new Gdip1.Brush(0xff00ff00)
obj1.FillEllipse(brush1, new Gdip1.Point(0, 0), new Gdip1.Size(100, 100))
win1.Update(obj1, point1, size1)
brush1.Dispose()
obj1.Dispose()
Gdip1.Dispose()

/*
; Retain original methods to allow user to refine control if needed
Gdip2 := new Gdip()
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Show, NA
hwnd1 := WinExist()
win2 := new Gdip2.Window()
obj2 := new Gdip2.Object()
hBitmap := obj2.CreateDIBSection(300, 300)
hdc := obj2.CreateCompatibleDC()
hgdiObj := obj2.SelectObject(hdc, hBitmap)
pGraphics := obj2.GraphicsFromHDC(hdc)
obj2.SetSmoothingMode(pGraphics, 4)
brush1 := new Gdip2.Brush(0xff0000ff)
obj2.FillEllipse(pGraphics, brush1.pointer, 0, 0, 100, 100)
brush1.DeleteBrush()
win2.UpdateLayeredWindow(hwnd1, hdc, 650, 500, 300, 300)
obj2.SelectObject(hdc, hgdiObj)
obj2.DeleteObject(hBitmap)
obj2.DeleteDC(hdc)
obj2.DeleteGraphics(pGraphics)
Gdip2.Shutdown()
*/
return

;#######################################################################

Esc::ExitApp

;#######################################################################

class Gdip
{
	__New()
	{
		if !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus")
		VarSetCapacity(si, 16, 0), si := Chr(1)
		DllCall("gdiplus\GdiplusStartup", "uptr*", pToken, "uptr", &si, "uint", 0)
		this.pToken := pToken
	}
	
	__Delete()
	{
		this.Dispose()
	}
	
	Shutdown()
	{
		this.Dispose()
	}
	
	Dispose()
	{
		DllCall("gdiplus\GdiplusShutdown", "uptr", this.pToken)
		if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("FreeLibrary", "uptr", hModule)
		return 0
	}
	
	class Brush
	{
		__New(ARGB=0xff000000)
		{
			this.pointer := this.CreateSolid(ARGB)
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		DeleteBrush()
		{
			return this.Dispose()
		}
		
		Dispose()
		{
			return DllCall("gdiplus\GdipDeleteBrush", "uptr", this.pointer)
		}
		
		CreateSolid(ARGB=0xff000000)
		{
			DllCall("gdiplus\GdipCreateSolidFill", "uint", ARGB, "uptr*", pBrush)
			return pBrush
		}
	}
	
	class Point
	{
		x := null
		y := null
		__New(x, y)
		{
			this.x := x
			this.y := y
		}
	}

	class Size
	{
		w := null
		h := null
		__New(w, h)
		{
			this.w := w
			this.h := h
		}
	}
	
	class Window
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 2)
			{
				point := params[1]
				size := params[2]
				this.hwnd := DllCall("CreateWindowEx", "uint", 0x80088, "str", "#32770", "ptr", 0, "uint", 0x940A0000,"int", point.x, "int", point.y, "int", size.w, "int", size.h, "uptr", 0, "uptr", 0, "uptr", 0, "uptr", 0)
			}
		}
		
		Update(obj, point, size, alpha=255)
		{
			return this.UpdateLayeredWindow(this.hwnd, obj.hdc, point.x, point.y, size.w, size.h, alpha)
		}
		
		UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", alpha=255)
		{
			if ((x != "") && (y != ""))
				VarSetCapacity(pt, 8), NumPut(x, pt, 0, "uint"), NumPut(y, pt, 4, "uint")

			if ((w = "") || (h = ""))
				WinGetPos,,, w, h, ahk_id %hwnd%
				
			return DllCall("UpdateLayeredWindow", "uptr", hwnd, "uptr", 0, "uptr", ((x = "") && (y = "")) ? 0 : &pt, "int64*", w|h<<32, "uptr", hdc, "int64*", 0, "uint", 0, "uint*", alpha<<16|1<<24, "uint", 2)
		}
	}

	class Object
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c)
			{
				size := params[1]
				this.hBitmap := this.CreateDIBSection(size.w, size.h)
				this.hdc := this.CreateCompatibleDC()
				this.hgdiObj := this.SelectObject(this.hdc, this.hBitmap)
				this.pGraphics := this.GraphicsFromHDC(this.hdc)
				this.SetSmoothingMode(this.pGraphics, 4)
			}
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		Dispose()
		{
			this.SelectObject(this.hdc, this.hgdiObj)
			this.DeleteObject(this.hBitmap)
			this.DeleteDC(this.hdc)
			this.DeleteGraphics(this.pGraphics)
		}
		
		CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
		{
			hdc2 := hdc ? hdc : this.GetDC()
			VarSetCapacity(bi, 40, 0)

			NumPut(w, bi, 4, "uint")
			NumPut(h, bi, 8, "uint")
			NumPut(40, bi, 0, "uint")
			NumPut(1, bi, 12, "ushort")
			NumPut(0, bi, 16, "uint")
			NumPut(bpp, bi, 14, "ushort")

			hBitmap := DllCall("CreateDIBSection", "uptr", hdc2, "uptr", &bi, "uint", 0, "uptr*", ppvBits, "uptr", 0, "uint", 0)

			if !hdc
				this.ReleaseDC(hdc2)
			return hBitmap
		}
		
		CreateCompatibleDC(hdc=0)
		{
		   return DllCall("CreateCompatibleDC", "uptr", hdc)
		}

		SelectObject(hdc, hgdiObj)
		{
			return DllCall("SelectObject", "uptr", hdc, "uptr", hgdiObj)
		}
		
		GetDC(hwnd=0)
		{
			return DllCall("GetDC", "uptr", hwnd)
		}
		
		ReleaseDC(hdc, hwnd=0)
		{
			return DllCall("ReleaseDC", "uptr", hwnd, "uptr", hdc)
		}
		
		DeleteObject(hgdiObj)
		{
			return DllCall("DeleteObject", "uptr", hgdiObj)
		}
		
		DeleteDC(hdc)
		{
			return DllCall("DeleteDC", "uptr", hdc)
		}
		
		DeleteGraphics(pGraphics)
		{
			return DllCall("gdiplus\GdipDeleteGraphics", "uptr", pGraphics)
		}
		
		GraphicsFromHDC(hdc)
		{
			DllCall("gdiplus\GdipCreateFromHDC", "uptr", hdc, "uptr*", pGraphics)
			return pGraphics
		}

		SetSmoothingMode(pGraphics, smoothingMode)
		{
			return DllCall("gdiplus\GdipSetSmoothingMode", "uptr", pGraphics, "int", smoothingMode)
		}
		
		;brush, point, size
		;pGraphics, brush, x, y, w, h
		FillEllipse(params*)
		{
			c := params.MaxIndex()
			if (c = 3)
			{
				 E := this._FillEllipse(this.pGraphics, params[1].pointer, params[2].x, params[2].y, params[3].w, params[3].h)
			}
			else if (c = 6)
			{
				E := this._FillEllipse(params[1], params[2], params[3], params[4], params[5], params[6])
			}
			else
				throw "Incorrect number of parameters for FillEllipse"
			return E
		}

		_FillEllipse(pGraphics, pBrush, x, y, w, h)
		{
			return DllCall("gdiplus\GdipFillEllipse", "uptr", pGraphics, "uptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}
	}
}