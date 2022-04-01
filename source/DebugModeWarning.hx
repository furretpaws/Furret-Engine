package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class DebugModeWarning extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";

	override function create()
	{
		#if !(mobile)
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		#if !(android)
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"WARNING!\n"
			+ "Furret Engine is in debug mode!\n"
			+ "\n"
			+ "If you are seeing this in the final build. Recompile the game without\n"
			+ "the -debug argument\n"
			+ "Press ENTER to continue",
			32);
		#end
		#if android
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"WARNING!\n"
			+ "Furret Engine is in debug mode!\n"
			+ "\n"
			+ "If you are seeing this in the final build. Recompile the game without\n"
			+ "the -debug argument\n"
			+ "Press A to continue",
			32);
		#end
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		#else
		leftState = true;
		FlxG.switchState(new TitleState());
		#end 
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			leftState = true;
			FlxG.switchState(new TitleState());
		}
		super.update(elapsed);
	}
}
