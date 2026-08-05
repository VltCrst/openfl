package openfl.utils;

#if lime
import openfl.utils._internal.IDestroyable;

class Pool<T:IDestroyable> implements IPool<T>
{
	public var length(get, never):Int;

	var _pool:Array<T> = [];
	var _constructor:() -> T;
	var _count:Int = 0;

	public function new(constructor:PoolFactory<T>)
	{
		_constructor = constructor.getFunction();
	}

	public function get():T
	{
		final obj:T = if (_count == 0)
		{
			_constructor();
		}
		else
		{
			_pool[--_count];
		}

		return obj;
	}

	public function put(obj:T):Void
	{
		if (obj != null)
		{
			var i:Int = _pool.indexOf(obj);
			if (i == -1 || i >= _count) putHelper(obj);
		}
	}

	public function putUnsafe(obj:T):Void
	{
		if (obj != null) putHelper(obj);
	}

	public function preAllocate(num:Int):Void
	{
		while (num-- > 0)
		{
			_pool[_count++] = _constructor();
		}
	}

	public function clear():Array<T>
	{
		_count = 0;
		var oldPool = _pool;
		_pool = [];
		return oldPool;
	}

	inline function get_length():Int
	{
		return _count;
	}

	function putHelper(obj:T):Void
	{
		obj.destroy();
		_pool[_count++] = obj;
	}
}

interface IPooled extends IDestroyable
{
	function put():Void;
}

interface IPool<T:IDestroyable>
{
	function preAllocate(num:Int):Void;
	function clear():Array<T>;
}
#else
typedef Pool = Dynamic;
typedef IPooled = Dynamic;
typedef IPool = Dynamic;
#end
