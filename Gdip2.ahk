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
	
	Dispose()
	{
		DllCall("gdiplus\GdiplusShutdown", "uptr", this.pToken)
		if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("FreeLibrary", "uptr", hModule)
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
		X := null
		Y := null
		__New(x, y)
		{
			this.X := x
			this.Y := y
		}
	}

	class Size
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 2)
			{
				if (IsObject(params[1]))
				{
					this.Width := Round(params[1].Width * params[2])
					this.Height := Round(params[1].Height * params[2])
				}
				else
				{
					this.Width := params[1]
					this.Height := params[2]
				}
			}
			else
				throw "Incorrect number of parameters for Size.New()"
		}
	}
	
	class Window
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 0)
			{
			}
			else if (c = 2)
			{
				point := params[1]
				size := params[2]
				this.hwnd := DllCall("CreateWindowEx", "uint", 0x80088, "str", "#32770", "ptr", 0, "uint", 0x940A0000,"int", point.X, "int", point.Y, "int", size.Width, "int", size.Height, "uptr", 0, "uptr", 0, "uptr", 0, "uptr", 0)
			}
			else
				throw "Incorrect number of parameters for Window.New()"
		}
		
		;obj
		;obj, point
		;obj, point, size
		;obj, point, size, alpha=255
		Update(params*)
		{
			c := params.MaxIndex()
			alpha := 255
			if (c = 1)
			{
				obj := params[1]
				x := 0, y := 0
				w := obj.Width
				h := obj.Height
			}
			if (c = 2)
			{
				obj := params[1]
				x := params[2].X
				y := params[2].Y
				w := obj.Width
				h := obj.Height
			}
			else if (c = 3)
			{
				obj := params[1]
				x := params[2].X
				y := params[2].Y
				w := params[3].Width
				h := params[3].Height
			}
			else if (c = 4)
			{
				obj := params[1]
				x := params[2].X
				y := params[2].Y
				w := params[3].Width
				h := params[3].Height
				alpha := params[4]
			}
			else
				throw "Incorrect number of parameters for Window.Update()"

			;MsgBox, % x "`n" y "`n" w "`n" h
			return this.UpdateLayeredWindow(this.hwnd, obj.hdc, x, y, w, h, alpha)
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
	
	class Bitmap
	{
		;file
		;width, height
		;width, height, format
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 0)
			{
			}
			else if (c = 1)
			{
				this.pointer := this.BitmapFromFile(params[1])
			}
			else if (c = 2)
			{
				this.pointer := this.CreateBitmap(params[1], params[2])
			}
			else if (c = 3)
			{
				this.pointer := this.CreateBitmap(params[1], params[2], params[3])
			}
			else
				throw "Incorrect number of parameters for Bitmap.New()"
			this.Width := this.GetImageWidth(this.pointer)
			this.Height := this.GetImageHeight(this.pointer)
			this.Size := new Gdip.Size(this.Width, this.Height)
		}
		
		Width[]
		{
			get { 
				return this.Width 
			}
		}
		
		Height[]
		{
			get {
				return this.Height
			}
		}
		
		Size[]
		{
			get {
				return this.Size
			}
		}
		
		__Delete()
		{
			this.Dispose(this.pointer)
		}
		
		Dispose()
		{
			this.DisposeImage(this.pointer)
		}
		
		DisposeImage(pBitmap)
		{
			return DllCall("gdiplus\GdipDisposeImage", "uptr", pBitmap)
		}
		
		DeleteGraphics(pGraphics)
		{
		   return DllCall("gdiplus\GdipDeleteGraphics", "uptr", pGraphics)
		}
		
		BitmapFromFile(file)
		{
			DllCall("gdiplus\GdipCreateBitmapFromFile", "uptr", &file, "uptr*", pBitmap)
			return pBitmap
		}

		CreateBitmap(width, height, format=0x26200A)
		{
			DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", width, "int", height, "int", 0, "int", format, "uptr", 0, "uptr*", pBitmap)
			return pBitmap
		}
		
		CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
		{
			DllCall("gdiplus\GdipCloneBitmapArea", "float", x, "float", y, "float", w, "float", h, "int", Format, "uptr", pBitmap, "uptr*", pBitmapDest)
			return pBitmapDest
		}
		
		GraphicsFromImage(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageGraphicsContext", "uptr", pBitmap, "uptr*", pGraphics)
			return pGraphics
		}
		
		;Scale
		;Width, Height
		Resize(params*)
		{
			c := params.MaxIndex()
			if (c = 1)
			{
				size := new Gdip.Size(this.Size, params[1])
			}
			else if (c = 2)
			{
				size := new Gdip.Size(params[1], params[2])
			}
			else
				throw "Incorrect number of parameters for Bitmap.Resize()"
				
			pBitmap := this.CreateBitmap(size.Width, size.Height)
			pGraphics := this.GraphicsFromImage(pBitmap)
			new Gdip.Object._DrawImage(pGraphics, this.pointer, 0, 0, size.Width, size.Height, 0, 0, this.Width, this.Height)
			this.Dispose()
			this.DeleteGraphics(pGraphics)
			this.pointer := pBitmap
			this.Size := size
			this.Width := size.Width
			this.Height := size.Height
		}
		
		GetImageWidth(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageWidth", "uptr", pBitmap, "uint*", width)
			return width
		}
		
		GetImageHeight(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageHeight", "uptr", pBitmap, "uint*", height)
			return height
		}
	}

	class Object
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 0)
			{
			}
			else if (c = 1)
			{
				size := params[1]
				this.Width := size.Width
				this.Height := size.Height
				this.hBitmap := this.CreateDIBSection(this.Width, this.Height)
				this.hdc := this.CreateCompatibleDC()
				this.hgdiObj := this.SelectObject(this.hdc, this.hBitmap)
				this.pGraphics := this.GraphicsFromHDC(this.hdc)
				this.SetSmoothingMode(this.pGraphics, 4)
			}
			else
				throw "Incorrect number of parameters for Object.New()"
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
		FillRectangle(params*)
		{
			c := params.MaxIndex()
			if (c = 3)
			{
				 E := this._FillRectangle(this.pGraphics, params[1].pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height)
			}
			else if (c = 6)
			{
				E := this._FillRectangle(params[1], params[2], params[3], params[4], params[5], params[6])
			}
			else
				throw "Incorrect number of parameters for Object.FillRectangle()"
			return E
		}
		
		_FillRectangle(pGraphics, pBrush, x, y, w, h)
		{
			return DllCall("gdiplus\GdipFillRectangle", "uptr", pGraphics, "uptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}
		
		;brush, point, size
		;pGraphics, brush, x, y, w, h
		FillEllipse(params*)
		{
			c := params.MaxIndex()
			if (c = 3)
			{
				 E := this._FillEllipse(this.pGraphics, params[1].pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height)
			}
			else if (c = 6)
			{
				E := this._FillEllipse(params[1], params[2], params[3], params[4], params[5], params[6])
			}
			else
				throw "Incorrect number of parameters for Object.FillEllipse()"
			return E
		}

		_FillEllipse(pGraphics, pBrush, x, y, w, h)
		{
			return DllCall("gdiplus\GdipFillEllipse", "uptr", pGraphics, "uptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}
		
		;Bitmap
		;Bitmap, point
		;Bitmap, point, size
		DrawImage(params*)
		{
			c := params.MaxIndex()
			if (c = 1)
			{
				bitmap := params[1]
				dx := 0, dy := 0
				dw := bitmap.Width, dh := bitmap.Height
			}
			else if (c = 2)
			{
				bitmap := params[1]
				point := params[2]
				dx := point.X, dy := point.Y
				dw := bitmap.Width, dh := bitmap.Height
			}
			else if (c = 3)
			{
				bitmap := params[1]
				point := params[2]
				size := params[3]
				dw := point.X, dh := point.Y
				dw := size.Width, dh := size.Height
			}
			else
				throw "Incorrect number of parameters for Object.DrawImage()"
			E := this._DrawImage(this.pGraphics, bitmap.pointer, dx, dy, dw, dh, 0, 0, bitmap.Width, bitmap.Height)
			return E
		}
		
		_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh)
		{
			E := DllCall("gdiplus\GdipDrawImageRectRect", "uptr", pGraphics, "uptr", pBitmap
						, "float", dx, "float", dy, "float", dw, "float", dh
						, "float", sx, "float", sy, "float", sw, "float", sh
						, "int", 2, "uptr", ImageAttr, "uptr", 0, "uptr", 0)
			return E
		}
	}
}