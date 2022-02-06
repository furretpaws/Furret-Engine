package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OptionNotAvailable extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var engineVer:String = "Furret Engine " + MainMenuState.furretEngineVer;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"[!] This option is not available on " + engineVer + "\n"
			+ "Furret Engine is still in BETA and some options are not available at the moment\n"
			+ "Press ESCAPE or SPACE/ENTER to go back to the main menu!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.RED, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
		{
			if (controls.ACCEPT)
			{
				FlxG.switchState(new MainMenuState());
			}
			if (controls.BACK)
			{
				leftState = true;
				FlxG.switchState(new MainMenuState());
			}
			super.update(elapsed);
		}
	}	
