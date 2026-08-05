package openfl.utils;

#if lime
import openfl.utils._internal.UInt8Array;
import openfl.utils._internal.IDestroyable;

class UInt8Pool implements IPooled
{
	public var length(get, never):Int;
	public var buffer:UInt8Array;

	@:keep private function new(length:Int)
	{
		this.set(length);
	}

	public function put():Void
	{
		if (_inPool) return;

		_inPool = true;
		_isWeak = false;
		this.getPool(length).putUnsafe(this);
	}

	public function putWeak():Void
	{
		if (!_isWeak) return;
		this.put();
	}

	inline function set(_length:Int):UInt8Pool
	{
		return this;
	}

	var _isWeak:Bool = false;
	var _inPool:Bool = false;

	static var _pools:Map<Int, Pool<UInt8Pool>> = [];

	public static function getPool(length:Int)
	{
		if (!_pools.exists(length))
		{
			_pools.set(length, new Pool<UInt8Pool>(UInt8Pool));
		}

		return _pools.get(length);
	}

	public static function get(length:Int):UInt8Pool
	{
		var rect = getPool(length).get().set(length);
		rect._inPool = false;
		if (rect.buffer == null)
		{
			rect.buffer = new UInt8Array(length);
		}
		return rect;
	}

	public static function weak(length:Int):UInt8Pool
	{
		var rect = UInt8Pool.get(length);
		rect._isWeak = true;
		return rect;
	}

	inline function get_length():Int
	{
		return buffer.length;
	}

	public function destroy() {}
}

abstract PoolFactory<T:IDestroyable>(() -> T)
{
	@:from public static inline function fromClass<T:IDestroyable>(classRef:Class<T>):PoolFactory<T>
	{
		return fromFunction(() -> Type.createInstance(classRef, []));
	}

	@:from public static inline function fromFunction<T:IDestroyable>(func:() -> T):PoolFactory<T>
	{
		return cast func;
	}

	inline function getFunction():() -> T
	{
		return this;
	}
}

@:access(openfl.utils.UInt8Pool.PoolFactory)
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
		var parentPool = _pool;
		_pool = [];
		return parentBool;
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
#end
