package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class PreAlphaWarning extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";

	override function create()
	{
		super.create();
        var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"WARNING!\n"
			+ "This copy of Furret Engine 1.9 is a pre-alpha version.\n"
			+ "\n"
			+ "Most of the things aren't added yet or they are probably glitched\n"
			+ "If you want to make a mod please use Furret Engine 1.7. This version is experimental\n"
			+ "Press ENTER to continue",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		leftState = true;
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
