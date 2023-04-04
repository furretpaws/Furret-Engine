package;

import lime.utils.Assets;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flash.media.Sound;
import lime.app.Application;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	#if android
	public static var androidDir:String = null;
    public static var externalS:Dynamic = android.os.Environment.getExternalStorageDirectory();
    public static function getPath() //this will be used for almost every single hx file, how exciting
    {   
        var applicationNameSplit:Dynamic /*removes spaces from "Furret Engine" ("Furret Engine" -> "FurretEngine")*/ = Application.current.meta.get("file").split(" ");
        var applicationName:String = "" + applicationNameSplit[0] + applicationNameSplit[1] + "";
        androidDir = externalS + "/" + "." + applicationName + "/";
        return androidDir;
    }
	#end

	public static function getSound(path:String) 
	{
		#if android
		path = getPath() + path;
		#end
		#if sys
		if(!FileSystem.exists(path)){
			Application.current.window.alert('[!] Missing file: "'+path+'"');
		}
		#end
		var sound:Sound = Sound.fromFile(path);
		return sound;
	}

	public static function getBitmap(file:String):BitmapData{
		if (PlayState.customMod != "")
		{
			file = "mods/" + PlayState.customMod + "/" + file;
		}
		trace(file);
		#if android
		file = getPath() + file;
		#end
		#if sys
		if(!FileSystem.exists(file)){
			Application.current.window.alert('[!] Missing file: "'+file+'"');
		}
		#end
		return BitmapData.fromFile(file);
	}

	public static function getContent(file:String):String{
		if (PlayState.customMod != "") {
			file = "mods/" + PlayState.customMod + "/" + file;
		}
		var getContentThing = EngineFunctions.getContent(file); //made so older scripts work in fe 1.8
		return getContentThing;
	}

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = EngineFunctions.getContent(path).trim().split('\n');

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
}
