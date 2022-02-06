package;

import flash.display.BitmapData;
import lime.utils.Assets;
import tjson.TJSON;
import lime.app.Application;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

	public static var globalAntialiasing:Bool = true;

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;
		if(newValue < min) newValue = min;
		else if(newValue > max) newValue = max;
		return newValue;
	}

	public static var difficultyStuff:Array<Dynamic> = [
		['Easy', '-easy'],
		['Normal', ''],
		['Hard', '-hard']
	];

	public static function difficultyString():String
	{
		return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
	}
	
	public static function getString(dyn:Dynamic,key:String,jsonName:String,?d:String):String{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){
			trace("asdqwe6b");
			return d;
		}
		Application.current.window.alert('oopsy doopsy looks like you are missing "'+key+'" SOMEWHERE inside of your json at location '+jsonName);
		return "";
	}	public static function getInt(dyn:Dynamic,key:String,jsonName:String,?d:Int):Int{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('oopsy doopsy looks like you are missing "'+key+'" SOMEWHERE inside of your json at location '+jsonName);
		return 0;
	}public static function getDynamic(dyn:Dynamic,key:String,jsonName:String,crash:Bool):Dynamic{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(crash){
			Application.current.window.alert('oopsy doopsy looks like you are missing "'+key+'" SOMEWHERE inside of your json at location '+jsonName);
		}
		return null;
	}
	public static function getFloat(dyn:Dynamic,key:String,jsonName:String,?d:Float):Float{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('oopsy doopsy looks like you are missing "'+key+'" SOMEWHERE inside of your json at location '+jsonName);
		return 0;
	}	public static function getBool(dyn:Dynamic,key:String,jsonName:String,?d:Bool):Bool{
		if(Reflect.hasField(dyn,key)){
			return Reflect.field(dyn,key);
		}
		if(d!=null){

			return d;
		}
		Application.current.window.alert('oopsy doopsy looks like you are missing "'+key+'" SOMEWHERE inside of your json at location '+jsonName);
		return false;
	}
	public static function getBitmap(file:String):BitmapData{
		if(!FileSystem.exists(file)){
			Application.current.window.alert('oopsy doopsy looks like you are missing "'+file+'"');
		}
		return BitmapData.fromFile(file);
	}
	public static function getContent(file:String):String{
		if(!FileSystem.exists(file)){
			Application.current.window.alert('oopsy doopsy looks like you are missing "'+file+'"');
		}
		return File.getContent(file);
	}
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function parseJson(json:String):Dynamic {
		// the reason we do this is to make it easy to swap out json parsers

		return TJSON.parse(json);
	}
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function stringifyJson(json:Dynamic, ?fancy:Bool = true):String {
		// use tjson to prettify it
		var style:String = if (fancy) 'fancy' else null;
		return TJSON.encode(json,style);
	}
	public static function coolDynamicTextFile(path:String):Array<String>
		{
			var daList:Array<String> = File.getContent(path).trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function smoothColorChange(from:FlxColor, to:FlxColor, speed:Float):FlxColor

	{

	   	speed = speed / 10;

	    var result:FlxColor = FlxColor.fromRGBFloat
	    (
	        FlxMath.lerp(from.redFloat, to.redFloat, speed), //red

	        FlxMath.lerp(from.greenFloat, to.greenFloat, speed), //green

	        FlxMath.lerp(from.blueFloat, to.blueFloat, speed) //blue
	    );

	    return result;

	   

	}
	public static function camLerpShit(a:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * a;
	}
	public static function coolLerp(a:Float, b:Float, c:Float):Float
	{
		return a + CoolUtil.camLerpShit(c) * (b - a);
	}
}
