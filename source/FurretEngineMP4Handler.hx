package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import Song.SwagSong;

class FurretEngineMP4Handler extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var engineVer:String = "Furret Engine " + MainMenuState.furretEngineVer;

	public var playingCutscene:Bool = true;

	public static function playCutscene(name:String)
	{
		var playingCutscene:Bool = true;
		playingCutscene = true;
	}

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"This is the MP4 handler state, if you are reading this\n"
			+ "please restart the game!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.RED, CENTER);
		txt.screenCenter();

		if(playingCutscene)
		{
			var video:MP4Handler;

			video = new MP4Handler();
			video.finishCallback = function()
			{
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + StoryMenuState.diffic, PlayState.storyPlaylist[0].toLowerCase());
				LoadingState.loadAndSwitchState(new PlayState());
			}
			video.playVideo(Paths.video(PlayState.playstateVideoPath));
		}
	}

	override function update(elapsed:Float)
		{
			if (controls.ACCEPT)
			{
				FlxG.switchState(new PlayState());
				trace("fuck it");
			}
			super.update(elapsed);
		}
    }	
