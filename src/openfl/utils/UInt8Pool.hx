package openfl.utils;

#if lime
import openfl.utils._internal.UInt8Array;
import openfl.utils.Pool;

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
		UInt8Pool.getPool(length).putUnsafe(this);
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
#end
