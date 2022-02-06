package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class MiddleScrollWarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";

	override function create()
	{
		FlxG.sound.play(Paths.sound('error'), 1);
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"[!] WARNING\n"
			+ "This song contains a modchart, and middlescroll is enabled.\n"
			+ "\n"
			+ "Middlescroll and modcharts are not compatible!\n"
			+ "If you want to continue press ENTER (MIDDLESCROLL WILL BE DISABLED)\n"
			+ "Otherwise, press ESCAPE to go to the main menu",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.save.data.middlescroll = false;
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
