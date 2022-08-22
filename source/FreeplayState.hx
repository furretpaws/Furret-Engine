package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Song.SwagSong;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

#if sys
import sys.io.File;
import sys.FileSystem;

import flash.media.Sound;
#end
#if windows
import Discord.DiscordClient;
#end

using StringTools;
class SongMetadatas
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadatas> = [];
	var selector:FlxText;
	public static var rate:Float = 1.0;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	public static var id:Int = 1;
	var scoreText:FlxText;
	var diffText:FlxText;
	var previewtext:FlxText;
	var judgementTextTxt:FlxText;
	var lerpScore:Int = 0;
	var songText:Alphabet;
	var icon:HealthIcon;
	var intendedScore:Int = 0;
	var isInWarningMode:Bool = false;
	var warningIconText:FlxText;
	var warningText:FlxText;
	var warningLine2Text:FlxText;
	var yesSelectionText:FlxText;
	var noSelectionText:FlxText;
	var warningSelection:Int = 0;
	var tip1Text:FlxText;
	var tip2Text:FlxText;
	var tip3Text:FlxText;
	var warningBG:FlxSprite;

	var leftP = controls.LEFT_P;
	var rightP = controls.RIGHT_P;

	var secondBG:FlxSprite;

	var grpSongs:FlxTypedGroup<Alphabet>;
	var curPlaying:Bool = false;

	var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		var parsed = CoolUtil.parseJson(Assets.getText('assets/data/freeplaySongJson.jsonc'));
		var initSonglist:Dynamic = parsed[id].songs;
		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadatas(data[0], Std.parseInt(data[2]), data[1]));
		}

		 
		if (FlxG.sound.music != null) //null object reference so don't fuck with this
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		 

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			songText = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			icon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.50), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		if (Main.enableExperimentalFeatures)
		{
			var modifiersBG:FlxSprite = new FlxSprite(900, 530).makeGraphic(450, 200, 0xFF000000);
			modifiersBG.alpha = 0.6;
			add(modifiersBG);
		}

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		previewtext = new FlxText(scoreText.x - (-20), scoreText.y + 550, 0, "Speed: " + rate + "x", 24);
		previewtext.font = scoreText.font;
		if (Main.enableExperimentalFeatures)
		{
			add(previewtext);
		}

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		secondBG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		secondBG.alpha = 0;
		add(secondBG);

		warningBG = new FlxSprite(100, 90).makeGraphic(1100, 550, 0xFF000000);
		warningBG.alpha = 0;
		add(warningBG);
		super.create();

		warningIconText = new FlxText (600, 150);
		warningIconText.text = "[!]";
		warningIconText.alpha = 0;
		warningIconText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(warningIconText);
		
		warningText = new FlxText(80, 200);
		warningText.text = "Custom Speed is broken, this will be fixed in some\nFurret Engine update, are you sure you want to continue?";
		warningText.alpha = 0;
		warningText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(warningText);

		warningLine2Text = new FlxText(110, 240);
		warningLine2Text.text = "Furret Engine update, are you sure you want to continue?";
		warningLine2Text.alpha = 0;
		warningLine2Text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(warningLine2Text);

		tip1Text = new FlxText(110, 320);
		tip1Text.text = "NOTE: High speeds (such as 2x or 3x) are not recommended";
		tip1Text.alpha = 0;
		tip1Text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tip1Text);

		tip2Text = new FlxText(110, 360);
		tip2Text.text = "they may cause crashes or some looping at the end of the";
		tip2Text.alpha = 0;
		tip2Text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tip2Text);
		
		tip3Text = new FlxText(110, 400);
		tip3Text.text = "song, low speeds will work. Selected speed: " + rate;
		tip3Text.alpha = 0;
		tip3Text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tip3Text);

		yesSelectionText = new FlxText(150, 500);
		yesSelectionText.text = "YES";
		yesSelectionText.alpha = 0;
		yesSelectionText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(yesSelectionText);

		noSelectionText = new FlxText(1000, 500);
		noSelectionText.text = "NO";
		noSelectionText.alpha = 0;
		noSelectionText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(noSelectionText);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadatas(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['empty'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var previewRate:Float = rate;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		/*function changeWarningSelection(Selection:Int = 0) //this function doesn't work, i hate my life
		{
			if (Selection == 1)
			{
				yesSelectionText.alpha = 0.5;
				noSelectionText.alpha = 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 0;
			}
			else if (Selection == 0)
			{
				yesSelectionText.alpha = 1;
				noSelectionText.alpha = 0.5;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 1;
			}
		}

		if (leftP && isInWarningMode && warningSelection == 0)
		{
			changeWarningSelection(1);
		}
		if (leftP && isInWarningMode && warningSelection == 1)
		{
			changeWarningSelection(0);
		}
		else if (rightP && isInWarningMode && warningSelection == 0)
		{
			changeWarningSelection(1);
		}
		if (rightP && isInWarningMode && warningSelection == 1)
		{
			changeWarningSelection(0);
		}*/

		if (controls.LEFT_P && isInWarningMode)
		{
			if (warningSelection == 0)
			{
				yesSelectionText.alpha = 0.5;
				noSelectionText.alpha = 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 1;
			}
			else if (warningSelection == 1)
			{
				yesSelectionText.alpha = 1;
				noSelectionText.alpha = 0.5;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 0;
			}
		}

		if (controls.RIGHT_P && isInWarningMode)
		{
			if (warningSelection == 0)
			{
				yesSelectionText.alpha = 0.5;
				noSelectionText.alpha = 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 1;
			}
			else if (warningSelection == 1)
			{
				yesSelectionText.alpha = 1;
				noSelectionText.alpha = 0.5;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				warningSelection = 0;
			}
		}

		if (isInWarningMode && controls.ACCEPT)
		{
			switch(warningSelection)
			{
				case 0:
				var diffic = "";

				switch (curDifficulty)
				{
					case 0:
						diffic = '-easy';
					case 2:
						diffic = '-hard';
				}
				var poop:String = songs[curSelected].songName.toLowerCase() + diffic;
				/*#if windows
				if (!FileSystem.exists('assets/data/' + songs[curSelected].songName.toLowerCase() + '/' + poop.toLowerCase() + '.json'))
				{
					// assume we pecked up the difficulty, return to default difficulty
					trace("UH OH SONG IN SPECIFIED DIFFICULTY DOESN'T EXIST\nUSING DEFAULT DIFFICULTY");
					poop = songs[curSelected].songName;
					curDifficulty = 1;
				}
				#end*/
				diffic = "";
		
				switch (curDifficulty)
				{
					case 0:
						diffic = '-easy';
					case 2:
						diffic = '-hard';
				}

				PlayState.storyDifficulty = curDifficulty;
				//PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				
				trace('CUR WEEK' + PlayState.storyWeek);
				PlayState.songMultiplier = rate;
				LoadingState.loadAndSwitchState(new PlayState());

				case 1:
				FlxG.resetState();
			}
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (!isInWarningMode && upP)
		{
			changeSelection(-1);
		}
		if (!isInWarningMode && downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.pressed.SHIFT && Main.enableExperimentalFeatures)
		{
			if (FlxG.keys.justPressed.LEFT)
			{
				rate -= 0.05;
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				rate += 0.05;
			}
	
			if (rate > 5)
			{
				rate = 5;
			}
			else if (rate < 0.5)
			{
				rate = 0.5;
			}
	
			previewtext.text = "Speed: " + rate + "x";
		}

		if (!FlxG.keys.pressed.SHIFT)
		{
			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
		#end

		if (controls.BACK)
		{
			var parsed:Dynamic = CoolUtil.parseJson(Assets.getText('assets/data/freeplaySongJson.jsonc'));

			if(parsed.length==1){
				FlxG.switchState(new MainMenuState());
			}else{
				FlxG.switchState(new FreeplayCategory());
			}
		}

		if (accepted)
		{
			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}
			var poop:String = songs[curSelected].songName.toLowerCase() + diffic;
			#if windows
			/*if (!FileSystem.exists('assets/data/' + songs[curSelected].songName.toLowerCase() + '/' + poop.toLowerCase() + '.json'))
			{
				// assume we pecked up the difficulty, return to default difficulty
				trace("UH OH SONG IN SPECIFIED DIFFICULTY DOESN'T EXIST\nUSING DEFAULT DIFFICULTY");
				poop = songs[curSelected].songName;
				curDifficulty = 1;
			}*/
			#end
			diffic = "";
	
			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}
			if (!Main.ignoreWarningMessages)
			{
				if (rate != 1)
				{
					FlxTween.tween(secondBG, {alpha: 1}, 0.5, {ease: FlxEase.elasticInOut});
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						FlxTween.tween(warningBG, {alpha: 0.6}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(warningIconText, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(warningText, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(warningLine2Text, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(tip1Text, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(tip2Text, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(tip3Text, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(yesSelectionText, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
						FlxTween.tween(noSelectionText, {alpha: 0.5}, 0.4, {ease: FlxEase.elasticInOut});
						tip3Text.text = "song, low speeds will work. Selected speed: " + rate;
					});
					isInWarningMode = true;
				}
				else if (rate == 1)
				{
					PlayState.storyDifficulty = curDifficulty;
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					PlayState.isStoryMode = false;
		
					trace('CUR WEEK' + PlayState.storyWeek);
					PlayState.songMultiplier = rate;
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else if (Main.ignoreWarningMessages)
			{
				trace("1");
				PlayState.storyDifficulty = curDifficulty;
				trace("2");
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				trace("3");
				PlayState.isStoryMode = false;
				trace("4");
		
				trace('CUR WEEK' + PlayState.storyWeek);
				trace("5");
				PlayState.songMultiplier = rate;
				trace("6");
				LoadingState.loadAndSwitchState(new PlayState());
				trace("7");
			}
		}
	}

	function changeDiff(change:Int = 0)
		{

	
			curDifficulty += change;

			if (curDifficulty < 0)
				curDifficulty = 2;
			if (curDifficulty > 2)
				curDifficulty = 0;
	
			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			#end
	
			switch (curDifficulty)
			{
				case 0:
					diffText.text = "EASY";
				case 1:
					diffText.text = 'NORMAL';
				case 2:
					diffText.text = "HARD";
			}
		}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		#end

		var bullShit:Int = 0;


		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

