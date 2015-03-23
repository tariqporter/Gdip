
myClass := new MyClass()
myClass.MyMethod(1, 3)
;myClass.MyMethod1()
return

class MethodCheckClass
{
	__Call(name, params*)
	{
		funcRef := Func(this.__class "." name)
		MsgBox, % name "`n" params.MaxIndex() "`n" funcRef.MaxParams
		E := IsObject(funcRef)
		if !E
			throw "Method " name " does not exist"
		if (params.MaxIndex()+1 < funcRef.MinParams)
		{
			throw "Too few parameters passed to method " name
			E := 0
		}
		if (params.MaxIndex()+1 > funcRef.MaxParams && !funcRef.IsVariadic)
		{
			throw "Too many parameters passed to method " name
			E := 0
		}
		if !E
			ExitApp
	}
}

class MyClass extends MethodCheckClass
{
    MyMethod(x, y)
    {
        MsgBox, Here 2!
    }
}