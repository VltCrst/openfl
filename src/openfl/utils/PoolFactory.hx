package openfl.utils;

#if lime
import openfl.utils._internal.IDestroyable;

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

	@:allow(openfl.utils.Pool)
	inline function getFunction():() -> T
	{
		return this;
	}
}
#else
typedef PoolFactory = Dynamic;
#end
