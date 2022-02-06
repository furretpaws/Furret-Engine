package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class CreditsState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var engineVer:String = "Furret Engine " + MainMenuState.furretEngineVer;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"[i] Credits [i]\n"
			+ "Fusion Engine by kidsfreej on GitHub\n"
			+ "Furret Engine by Furret\n"
			+ "Kade Engine by KadeDev\n"
			+ "Press ESCAPE to go to the Main Menu screen",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
		{
			if (controls.BACK)
			{
				leftState = true;
				FlxG.switchState(new MainMenuState());
			}
			super.update(elapsed);
		}
	}	
