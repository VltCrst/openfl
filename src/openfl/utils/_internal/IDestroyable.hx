package openfl.utils._internal;

#if flixel
typedef IDestroyable = flixel.util.FlxDestroyUtil.IFlxDestroyable;
#else
interface IDestroyable
{
	function destroy():Void;
}
#end
