package;

import flash.display.BitmapData;
import flash.media.Sound;
import haxe.Json;
import haxe.display.Display.EnumFieldOriginKind;
import sys.net.Host;
import sys.net.Socket;
import CustomShaderHandler;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var _noDeath:Bool = false;
	public static var _pitch:Float = 1;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	public var vocals:FlxSound;

	public var songStarted:Bool = false;

	public static var customMod:String = "";

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	var check:Int = 0;

	var doNotExecute:Bool = false;

	public var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;

	private var eventNotes:Array<Dynamic> = [];

	public static var prevCamFollow:FlxObject;

	var tankmanAscend:Bool = false; // funni (2021 nostalgia oh my god)

	var timeBar:FlxBar;
	var timeTxt:FlxText;

	var possibleNotes:Array<Note> = [];

	public static var videoInstances:Array<MP4Handler> = [];

	public static var videoIsPlaying:Bool = false;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;

	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var dadStrums:FlxTypedGroup<FlxSprite>;

	var elapsedtime:Float = 0.0;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public static var bfCameraOffsets:Array<Float> = [0, 0];
	public static var dadCameraOffsets:Array<Float> = [0, 0];

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
		{
			return Math.floor(value);
		}

		var mult:Float = 1;
		for (i in 0...decimals)
		{
			mult = mult * 10;
		}
		var daValue:Float = Math.floor(value * mult);
		return daValue / mult;
	}

	var picoStepJson:String = '{
		"right": [2,3,5,9,10,16,22,25,26,34,35,37,41,42,48,54,57,58,66,67,69,73,74,80,86,89,90,98,99,101,105, 106, 112, 118, 121, 122, 253, 260, 268, 280, 284, 292, 300, 312, 316, 317, 318, 320, 332, 336, 344, 358, 360, 362, 364, 372, 376, 388, 396, 404, 408, 412, 420, 428, 436, 440, 444, 452, 456, 460, 468, 472, 476, 484, 488, 492, 508, 509, 510, 516, 520, 524, 532, 540, 552, 556, 564, 568, 572, 580, 584, 588, 596, 604, 612, 616, 620, 636, 637, 638, 642, 643, 645, 649, 650, 656, 662, 665, 666, 674, 675, 677, 681, 682, 688, 694, 697, 698, 706, 707, 709, 713, 714, 720, 726, 729, 730, 738, 739, 741, 745, 746, 753, 758, 761, 762, 768, 788, 792, 796, 800, 820, 824, 828, 829, 830, 832, 852, 856, 860, 861, 862, 864, 865, 866, 884, 885, 886, 887, 892, 900, 912, 916, 924, 926, 936, 948, 958, 962, 966, 970, 974, 976, 980, 984, 988, 990, 1000, 1004, 1006, 1008, 1012, 1019, 1028, 1036, 1044, 1052, 1060, 1068, 1076, 1084, 1092, 1100, 1108, 1116, 1124, 1132, 1148, 1149, 1150, 1156, 1160, 1164, 1172, 1180, 1188, 1192, 1196, 1204, 1208, 1212, 1220, 1224, 1228, 1236, 1244, 1252, 1256, 1260, 1276, 1296, 1300, 1304, 1308, 1320, 1324, 1328, 1332, 1340, 1352, 1358, 1364, 1372, 1374, 1378, 1388, 1392, 1400, 1401, 1405, 1410, 1411, 1413, 1417, 1418, 1424, 1430, 1433, 1434],
		"left": [0,7,12,14,15,18,19,24,28,32,39,44,46,47,50,51,56,60,61,62,64,71,76,78,79,82,83,88,92,96,103,108,110,111,114,115,120,124,252,254,256,264,272,276,288,296,304,308,324,328,340,348,352,354,356,366,368,378,384,392,394,400,410,416,424,426,432,442,448,458,464,474,480,490,496,500,504,506,512,522,528,536,538,544,554,560,570,576,586,592,600,602,608,618,624,628,632,634,640,647,652,654,655,658,659,664,668,672,679,684,686,687,690,691,696,700,701,702,704,711,716,718,719,722,723,728,732,736,743,748,750,751,754,755,760,764,772,776,780,784,804,808,812,816,836,840,844,848,868,869,870,872,873,874,876,877,878,880,881,882,883,888,889,890,891,896,904,908,920,928,932,940,944,951,952,953,955,960,964,968,972,978,982,986,992,994,996,1016,1017,1021,1024,1034,1040,1050,1056,1066,1072,1082,1088,1098,1104,1114,1120,1130,1136,1140,1144,1146,1152,1162,1168,1176,1178,1184,1194,1200,1210,1216,1226,1232,1240,1242,1248,1258,1264,1268,1272,1280,1284,1288,1292,1312,1314,1316,1336,1344,1356,1360,1368,1376,1380,1384,1396,1404,1408,1415,1420,1422,1423,1426,1427,1432,1436,1437,1438]
	}';

	var tankStepJson:String = '{
		"right": [0, 14, 19, 32, 46, 51, 61, 71, 79, 88, 103, 111, 120, 254, 272, 296, 324, 348, 356, 378, 394, 416, 432, 458, 480, 500, 512, 536, 554, 576, 600, 618, 632, 647, 655, 664, 679, 687, 696, 702, 716, 722, 732, 748, 754, 764, 780, 808, 836, 848, 870, 874, 878, 882, 889, 896, 920, 940, 952, 960, 972, 986, 996, 1021, 1040, 1066, 1088, 1114, 1136, 1146, 1168, 1184],
		"left": [2, 9, 22, 34, 41, 54, 66, 73, 86, 98, 105, 118, 253, 280, 300, 317, 332, 358, 364, 388, 408, 428, 444, 460, 476, 492, 510, 524, 552, 568, 584, 604, 620, 638, 645, 656, 666, 677, 688, 698, 709, 720, 730, 741, 753, 762, 792, 820, 829, 852, 861, 865, 885, 892, 916, 936, 962, 974, 984, 1000, 1008, 1028, 1052, 1076, 1100, 1124, 1149, 1160, 1180]
	}';
	var picoStep:Dynamic;
	var tankStep:Dynamic;

	var FurretEngineWatermark:FlxText;

	var updateTime:Bool = true;

	var interp = new hscript.Interp();

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var accuracy:Float = 0.00;

	var loadHScript:Bool = false;

	public static var misses:Int = 0;

	// judge note counter
	public static var badCounter:Int = 0;
	public static var goodCounter:Int = 0;
	public static var shitCounter:Int = 0;
	public static var sickCounter:Int = 0;

	var customShader:CustomShaderHandler;

	public static var cpuControlled:Bool = false;

	var botplayTxt:FlxText;
	var botplaySine:Float = 0.0;

	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var steve:FlxSprite;
	var tankBop1:FlxSprite;
	var tankBop2:FlxSprite;
	var tankBop3:FlxSprite;
	var tankBop4:FlxSprite;
	var tankBop5:FlxSprite;
	var tankBop6:FlxSprite;
	var tower:FlxSprite;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var tankSpeedJohn:Array<Float> = [];
	var goingRightJohn:Array<Bool> = [];
	var endingOffsetJohn:Array<Float> = [];
	var strumTimeJohn:Array<Dynamic> = [];

	var sickCounterText:FlxText;
	var goodCounterText:FlxText;
	var badCounterText:FlxText;
	var shitCounterText:FlxText;

	var modifiersText:FlxText;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var johns:FlxTypedGroup<FlxSprite>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var scoreTxt:FlxText;

	var notesHit:Float = 0;

	public var played:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var songLength:Float = 0;

	var songPercent:Float = 0;

	var hscriptStates:Map<String, Interp> = [];

	function callAllHScript(func_name:String, args:Array<Dynamic>)
	{
		for (key in hscriptStates.keys())
		{
			callHscript(func_name, args, key);
		}
	}

	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String)
	{
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name))
		{
			// trace("Function doesn't exist, silently skipping..."); //i don't want the console getting flooded with traces
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch (args.length)
		{
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}

	function setHaxeVar(name:String, value:Dynamic, usehaxe:String)
	{
		hscriptStates.get(usehaxe).variables.set(name, value);
	}

	function getHaxeVar(name:String, usehaxe:String):Dynamic
	{
		return hscriptStates.get(usehaxe).variables.get(name);
	}

	function setAllHaxeVar(name:String, value:Dynamic)
	{
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		bfCameraOffsets = [0, 0];
		dadCameraOffsets = [0, 0];

		if (loadHScript)
		{
			setAllHaxeVar('camZooming', camZooming);
			setAllHaxeVar('gfSpeed', gfSpeed);
			setAllHaxeVar('health', health);
		}

		customShader = new CustomShaderHandler();

		PlayerSettings.player1.controls.loadKeybinds();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		misses = 0;
		sickCounter = 0;
		goodCounter = 0;
		badCounter = 0;
		shitCounter = 0;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		Conductor.setPlaybackRate(_pitch);
		Conductor.safeZoneOffset *= _pitch;

		Conductor.recalculateStuff(_pitch);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		if (customMod != "") {
			detailsText += " (Custom mod)";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		var gfVersion:String = 'gf';

		if (SONG.gf == null || SONG.gf == "") // dumb fix
		{
			gfVersion = "gf"; // screw you
		}
		else
		{
			gfVersion = SONG.gf;
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		switch (SONG.stage.toLowerCase())
		{
			case 'spooky':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
					add(street);
				}
			case 'limo':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					// add(limo);
				}
			case 'mall':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
				}
			case 'evilMall':
				{
					curStage = 'evilMall';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'school':
				{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
			case 'schoolEvil':
				{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);

						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);

						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);

						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);

						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();

						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			case 'stage':
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			case 'warzone':
				{
					defaultCamZoom = 0.9;
					curStage = 'warzone';
					var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('warzone/tankSky'));
					sky.scrollFactor.set(0, 0);
					sky.antialiasing = true;
					sky.setGraphicSize(Std.int(sky.width * 1.5));

					add(sky);

					var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('warzone/tankClouds'));
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.velocity.x = FlxG.random.float(5, 15);
					clouds.antialiasing = true;
					clouds.updateHitbox();

					add(clouds);

					var mountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('warzone/tankMountains'));
					mountains.scrollFactor.set(0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					mountains.antialiasing = true;

					add(mountains);

					var buildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('warzone/tankBuildings'));
					buildings.scrollFactor.set(0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					buildings.antialiasing = true;

					add(buildings);

					var ruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('warzone/tankRuins'));
					ruins.scrollFactor.set(0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					ruins.antialiasing = true;

					add(ruins);

					var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
					smokeLeft.frames = Paths.getSparrowAtlas('warzone/smokeLeft');
					smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
					smokeLeft.scrollFactor.set(0.4, 0.4);
					smokeLeft.antialiasing = true;
					smokeLeft.animation.play('idle');

					add(smokeLeft);

					var smokeRight:FlxSprite = new FlxSprite(1100, -100);
					smokeRight.frames = Paths.getSparrowAtlas('warzone/smokeRight');
					smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
					smokeRight.scrollFactor.set(0.4, 0.4);
					smokeRight.antialiasing = true;
					smokeRight.animation.play('idle');

					add(smokeRight);

					tower = new FlxSprite(100, 120);
					tower.frames = Paths.getSparrowAtlas('warzone/tankWatchtower');
					tower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
					tower.antialiasing = true;

					add(tower);

					steve = new FlxSprite(300, 300);
					steve.frames = Paths.getSparrowAtlas('tankRolling');
					steve.animation.addByPrefix('idle', "BG tank w lighting", 24, true);
					steve.animation.play('idle', true);
					steve.antialiasing = true;
					steve.scrollFactor.set(0.5, 0.5);
					add(steve);

					var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('warzone/tankGround'));
					ground.scrollFactor.set();
					ground.antialiasing = true;
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.scrollFactor.set(1, 1);

					ground.updateHitbox();
					add(ground);

					tankBop1 = new FlxSprite(-500, 650);
					tankBop1.frames = Paths.getSparrowAtlas('warzone/tank0');
					tankBop1.animation.addByPrefix('bop', 'fg tankhead far right', 24);
					tankBop1.scrollFactor.set(1.7, 1.5);
					tankBop1.antialiasing = true;
					add(tankBop1);

					tankBop2 = new FlxSprite(-300, 750);
					tankBop2.frames = Paths.getSparrowAtlas('warzone/tank1');
					tankBop2.animation.addByPrefix('bop', 'fg tankhead 5', 24);
					tankBop2.scrollFactor.set(2.0, 0.2);
					tankBop2.antialiasing = true;
					add(tankBop2);

					tankBop3 = new FlxSprite(450, 940);
					tankBop3.frames = Paths.getSparrowAtlas('warzone/tank2');
					tankBop3.animation.addByPrefix('bop', 'foreground man 3', 24);
					tankBop3.scrollFactor.set(1.5, 1.5);
					tankBop3.antialiasing = true;
					add(tankBop3);

					tankBop4 = new FlxSprite(1300, 1200);
					tankBop4.frames = Paths.getSparrowAtlas('warzone/tank3');
					tankBop4.animation.addByPrefix('bop', 'fg tankhead 4', 24);
					tankBop4.scrollFactor.set(3.5, 2.5);
					tankBop4.antialiasing = true;
					add(tankBop4);

					tankBop5 = new FlxSprite(1300, 900);
					tankBop5.frames = Paths.getSparrowAtlas('warzone/tank4');
					tankBop5.animation.addByPrefix('bop', 'fg tankman bobbin 3', 24);
					tankBop5.scrollFactor.set(1.5, 1.5);
					tankBop5.antialiasing = true;
					add(tankBop5);

					tankBop6 = new FlxSprite(1620, 700);
					tankBop6.frames = Paths.getSparrowAtlas('warzone/tank5');
					tankBop6.animation.addByPrefix('bop', 'fg tankhead far right', 24);
					tankBop6.scrollFactor.set(1.5, 1.5);
					tankBop6.antialiasing = true;
					add(tankBop6);
				}
			case 'warzone-stress':
				{
					picoStep = haxe.Json.parse(picoStepJson);
					tankStep = haxe.Json.parse(tankStepJson);

					defaultCamZoom = 0.9;
					curStage = 'warzone-stress';
					var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('warzone/tankSky'));
					sky.scrollFactor.set(0, 0);
					sky.antialiasing = true;
					sky.setGraphicSize(Std.int(sky.width * 1.5));

					add(sky);

					var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('warzone/tankClouds'));
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.velocity.x = FlxG.random.float(5, 15);
					clouds.antialiasing = true;
					clouds.updateHitbox();

					add(clouds);

					var mountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('warzone/tankMountains'));
					mountains.scrollFactor.set(0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					mountains.antialiasing = true;

					add(mountains);

					var buildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('warzone/tankBuildings'));
					buildings.scrollFactor.set(0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					buildings.antialiasing = true;

					add(buildings);

					var ruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('warzone/tankRuins'));
					ruins.scrollFactor.set(0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					ruins.antialiasing = true;

					add(ruins);

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);

					var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
					smokeLeft.frames = Paths.getSparrowAtlas('warzone/smokeLeft');
					smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
					smokeLeft.scrollFactor.set(0.4, 0.4);
					smokeLeft.antialiasing = true;
					smokeLeft.animation.play('idle');

					add(smokeLeft);

					var smokeRight:FlxSprite = new FlxSprite(1100, -100);
					smokeRight.frames = Paths.getSparrowAtlas('warzone/smokeRight');
					smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
					smokeRight.scrollFactor.set(0.4, 0.4);
					smokeRight.antialiasing = true;
					smokeRight.animation.play('idle');

					add(smokeRight);

					tower = new FlxSprite(100, 120);
					tower.frames = Paths.getSparrowAtlas('warzone/tankWatchtower');
					tower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
					tower.antialiasing = true;

					add(tower);

					steve = new FlxSprite(300, 300);
					steve.frames = Paths.getSparrowAtlas('tankRolling');
					steve.animation.addByPrefix('idle', "BG tank w lighting", 24, true);
					steve.animation.play('idle', true);
					steve.antialiasing = true;
					steve.scrollFactor.set(0.5, 0.5);
					add(steve);
					johns = new FlxTypedGroup<FlxSprite>();
					add(johns);

					var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('warzone/tankGround'));
					ground.scrollFactor.set();
					ground.antialiasing = true;
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.scrollFactor.set(1, 1);

					ground.updateHitbox();
					add(ground);

					tankBop1 = new FlxSprite(-500, 650);
					tankBop1.frames = Paths.getSparrowAtlas('warzone/tank0');
					tankBop1.animation.addByPrefix('bop', 'fg tankhead far right', 24);
					tankBop1.scrollFactor.set(1.7, 1.5);
					tankBop1.antialiasing = true;
					add(tankBop1);

					tankBop2 = new FlxSprite(-300, 750);
					tankBop2.frames = Paths.getSparrowAtlas('warzone/tank1');
					tankBop2.animation.addByPrefix('bop', 'fg tankhead 5', 24);
					tankBop2.scrollFactor.set(2.0, 0.2);
					tankBop2.antialiasing = true;
					add(tankBop2);

					tankBop3 = new FlxSprite(450, 940);
					tankBop3.frames = Paths.getSparrowAtlas('warzone/tank2');
					tankBop3.animation.addByPrefix('bop', 'foreground man 3', 24);
					tankBop3.scrollFactor.set(1.5, 1.5);
					tankBop3.antialiasing = true;
					add(tankBop3);

					tankBop4 = new FlxSprite(1300, 1200);
					tankBop4.frames = Paths.getSparrowAtlas('warzone/tank3');
					tankBop4.animation.addByPrefix('bop', 'fg tankhead 4', 24);
					tankBop4.scrollFactor.set(3.5, 2.5);
					tankBop4.antialiasing = true;
					add(tankBop4);

					tankBop5 = new FlxSprite(1300, 900);
					tankBop5.frames = Paths.getSparrowAtlas('warzone/tank4');
					tankBop5.animation.addByPrefix('bop', 'fg tankman bobbin 3', 24);
					tankBop5.scrollFactor.set(1.5, 1.5);
					tankBop5.antialiasing = true;
					add(tankBop5);

					tankBop6 = new FlxSprite(1620, 700);
					tankBop6.frames = Paths.getSparrowAtlas('warzone/tank5');
					tankBop6.animation.addByPrefix('bop', 'fg tankhead far right', 24);
					tankBop6.scrollFactor.set(1.5, 1.5);
					tankBop6.antialiasing = true;
					add(tankBop6);
				}
			default:
				{
					if (SONG.stage.toLowerCase() == null || SONG.stage.toLowerCase() == '')
					{
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = true;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}
					else
					{
						var pathThing:String = "";
						if (customMod != "")
						{
							pathThing = "mods/" + customMod + "/assets/stages/" + SONG.stage + "/stageData.hx";
						}
						else
						{
							pathThing = "assets/stages/" + SONG.stage.toLowerCase() + "/stageData.hx";
						}
						if (EngineFunctions.exists(pathThing)) // i love haxe - code taken from furret engine v1.7
						{
							curStage = SONG.stage.toLowerCase();
							var stageInterp = new hscript.Interp();
							var bitmap:BitmapData;
							stageInterp.variables.set("defaultCamZoom", defaultCamZoom);
							stageInterp.variables.set("setCamZoom", function(daZoom:Float)
							{
								defaultCamZoom = daZoom;
							});
							stageInterp.variables.set("getBitmap", function(image:String)
							{
								return CoolUtil.getBitmap("assets/stages/" + SONG.stage.toLowerCase() + "/" + image + ".png");
							});
							stageInterp.variables.set("CoolUtil", CoolUtil);
							stageInterp.variables.set("MP4Handler", MP4Handler);
							stageInterp.variables.set("EngineFunctions", EngineFunctions);
							stageInterp.variables.set("curStage", curStage);
							stageInterp.variables.set("FlxSprite", FlxSprite);
							stageInterp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
							stageInterp.variables.set("Std", Std);
							stageInterp.variables.set("FlxG", FlxG);
							stageInterp.variables.set("boyfriend", boyfriend);
							stageInterp.variables.set("gf", gf);
							stageInterp.variables.set("dad", dad);
							stageInterp.variables.set("Shader", openfl.display.Shader);
							stageInterp.variables.set("CustomShader", CustomShader);
							stageInterp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
							stageInterp.variables.set("setBfPosition", function(X:Int, Y:Int)
							{
								boyfriend.x += X;
								boyfriend.y += Y;
							});
							stageInterp.variables.set("setDadPosition", function(X:Int, Y:Int)
							{
								dad.x += X;
								dad.y += Y;
							});
							stageInterp.variables.set("setGfPosition", function(X:Int, Y:Int)
							{
								gf.x += X;
								gf.y += Y;
							});
							/*stageInterp.variables.set("setDadCameraPosition", function(X:Int, Y:Int) {
									dadCameraOffsetX = X;
									dadCameraOffsetY = Y;
								});
								stageInterp.variables.set("setBfCameraPosition", function(X:Int, Y:Int) {
									bfCameraOffsetX = X;
									bfCameraOffsetY = Y;
							});*/
							stageInterp.variables.set("modifySize", function(daSprite:FlxSprite, size:Float)
							{
								daSprite.setGraphicSize(Std.int(daSprite.width * 0.9));
							});
							stageInterp.variables.set("add", function(varSprite:FlxSprite)
							{
								add(varSprite);
							});
							stageInterp.variables.set("remove", function(varSprite:FlxSprite)
							{
								remove(varSprite);
							});
							var path:String = "";
							if (customMod != "")
							{
								path = "mods/" + customMod + "/assets/stages/" + SONG.stage + "/stageData.hx";
							}
							else
							{
								path = "assets/stages/" + SONG.stage + "/stageData.hx";
							}
							var getScript = EngineFunctions.getContent(path);
							var daScript:String = getScript;
							var daScriptParser = new hscript.Parser();
							daScriptParser.allowTypes = true;
							daScriptParser.allowMetadata = true;
							daScriptParser.allowJSON = true;
							var script = daScriptParser.parseString(daScript);
							stageInterp.execute(script);
						}
						else
						{
							defaultCamZoom = 0.9;
							curStage = 'stage';
							var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);

							var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
							stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
							stageFront.updateHitbox();
							stageFront.antialiasing = true;
							stageFront.scrollFactor.set(0.9, 0.9);
							stageFront.active = false;
							add(stageFront);

							var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
							stageCurtains.updateHitbox();
							stageCurtains.antialiasing = true;
							stageCurtains.scrollFactor.set(1.3, 1.3);
							stageCurtains.active = false;

							add(stageCurtains);
						}
					}
				}
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 180;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case 'warzone':
				gf.y += -55;
				gf.x -= 200;
				boyfriend.x += 40;
			case 'warzone-stress':
				// gf.y += 10;
				// gf.x -= 30;
				gf.y += -155;
				gf.x -= 90;
				boyfriend.x += 40;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		timeBar = new FlxBar(343.5, 20, LEFT_TO_RIGHT, Std.int(597), Std.int(25), this, 'songPercent', 0, 1, true);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.GRAY);
		timeBar.pixelPerfectPosition = true;
		timeBar.numDivisions = 400;
		if (FlxG.save.data.hideTimeBar)
		{
			timeBar.visible = false;
		}
		if (FlxG.save.data.downscroll)
		{
			timeBar.y = 678;
		}
		add(timeBar);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, 635).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		FurretEngineWatermark = new FlxText(0, 0, FlxG.width);
		FurretEngineWatermark.text = "Furret Engine " + MainMenuState.furretEngineVer + " | " + curSong + " - " + CoolUtil.difficultyString();
		FurretEngineWatermark.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (FlxG.save.data.downscroll)
		{
			FurretEngineWatermark.y = 698;
		}
		add(FurretEngineWatermark);

		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE, true, FlxColor.GRAY);
		add(timeBar);

		timeTxt = new FlxText(0, 23, FlxG.width);
		timeTxt.text = "--:-- / --:--";
		timeTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (FlxG.save.data.downscroll)
		{
			timeTxt.y = 698;
		}
		add(timeTxt);
		if (FlxG.save.data.hideTimeBar)
		{
			timeTxt.visible = false;
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

		scoreTxt = new FlxText(0, 678, FlxG.width,
			"Score: "
			+ songScore
			+ " // Misses: "
			+ misses
			+ " // Accuracy: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% - "
			+ Rating.generateRank(accuracy));
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		scoreTxt.scrollFactor.set();
		if (FlxG.save.data.downscroll)
		{
			scoreTxt.y = 100;
		}
		add(scoreTxt);

		sickCounterText = new FlxText();
		sickCounterText.text = "Sicks: 0";
		sickCounterText.x = 10;
		sickCounterText.y = 275;
		sickCounterText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		sickCounterText.borderSize = 2;
		sickCounterText.cameras = [camHUD];

		goodCounterText = new FlxText();
		goodCounterText.text = "Goods: 0";
		goodCounterText.x = 10;
		goodCounterText.y = 295;
		goodCounterText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		goodCounterText.borderSize = 2;
		goodCounterText.cameras = [camHUD];

		badCounterText = new FlxText();
		badCounterText.text = "Bads: 0";
		badCounterText.x = 10;
		badCounterText.y = 315;
		badCounterText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		badCounterText.borderSize = 2;
		badCounterText.cameras = [camHUD];

		shitCounterText = new FlxText();
		shitCounterText.text = "Shits: 0";
		shitCounterText.x = 10;
		shitCounterText.y = 335;
		shitCounterText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		shitCounterText.borderSize = 2;
		shitCounterText.cameras = [camHUD];

		modifiersText = new FlxText();
		modifiersText.text = "[!] There are active modifiers\nscore won't be saved";
		modifiersText.x = 10;
		modifiersText.y = 365;
		modifiersText.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.RED, RIGHT, OUTLINE, FlxColor.BLACK);
		modifiersText.visible = false;
		modifiersText.borderSize = 2;
		modifiersText.cameras = [camHUD];

		add(sickCounterText);
		add(goodCounterText);
		add(badCounterText);
		add(shitCounterText);
		add(modifiersText);

		botplayTxt.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		FurretEngineWatermark.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		#if sys
		var directory:Array<String> = [];
		if (customMod != "")
		{
			directory = EngineFunctions.readDirectory("mods/" + customMod + "/assets/data/" + curSong.toLowerCase());
		}
		else
		{
			directory = EngineFunctions.readDirectory("assets/data/" + curSong.toLowerCase());
		}
		for (i in directory)
		{
			if (directory[check].endsWith(".hx"))
			{
				if (customMod != "")
				{
					trace("Script detected! " + "mods/" + customMod + "/assets/data/" + curSong.toLowerCase() + "/" + directory[check]);
				}
				else
				{
					trace("Script detected! " + "assets/data/" + curSong.toLowerCase() + "/" + directory[check]);
				}
			}
			else
			{
				// do nothing
			}
			loadHScript = true;
			check++;
		}
		check = 0;
		#end

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (SONG.stage.toLowerCase())
			{
				case "mallEvil":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'school':
					if (curSong.toLowerCase() == 'senpai')
					{
						schoolIntro(doof);
					}
					else if (curSong.toLowerCase() == 'roses')
					{
						FlxG.sound.play(Paths.sound('ANGRY'));
						schoolIntro(doof);
					}
				case 'schoolEvil':
					schoolIntro(doof);
				case 'warzone':
					tankIntro();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function tankIntro()
	{
		inCutscene = true;
		FurretEngineWatermark.alpha = 0;
		timeBar.alpha = 0;
		timeTxt.alpha = 0;
		sickCounterText.alpha = 0;
		goodCounterText.alpha = 0;
		badCounterText.alpha = 0;
		shitCounterText.alpha = 0;
		scoreTxt.alpha = 0;
		healthBar.alpha = 0;
		healthBarBG.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		switch (curSong.toLowerCase())
		{
			case 'ugh':
				{
					var tankmanUgh:FlxSprite = new FlxSprite(dad.x - 20, dad.y);
					tankmanUgh.frames = FlxAtlasFrames.fromSparrow("assets/images/cutscenes/ugh.png", "assets/images/cutscenes/ugh.xml");
					tankmanUgh.animation.addByPrefix("www", "TANK TALK 1 P1", 24, false);
					tankmanUgh.animation.addByPrefix("ky", "TANK TALK 1 P2", 24, false);
					tankmanUgh.antialiasing = true;
					add(tankmanUgh);
					/*tankmanUgh.x += 130;
						tankmanUgh.y -= 60; */
					dad.visible = false;
					tankmanUgh.animation.play("www");
					camFollow.y += 80;
					camFollow.x += 70;
					trace(camFollow);
					FlxG.sound.play("assets/sounds/week7/wellWellWell.ogg");
					FlxG.sound.playMusic("assets/sounds/week7/DISTORTO.ogg", 0.1);
					new FlxTimer().start(2.5, function(ft:FlxTimer)
					{
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
						new FlxTimer().start(1, function(ft:FlxTimer)
						{
							boyfriend.playAnim("singUP");
							FlxG.sound.play("assets/sounds/week7/bfBeep.ogg");
							new FlxTimer().start(0.5, function(ft:FlxTimer)
							{
								boyfriend.dance();
								camFollow.x = 386;
								camFollow.y = 466.5;
								tankmanUgh.animation.play("ky");
								FlxG.sound.play("assets/sounds/week7/killYou.ogg");
								new FlxTimer().start(6, function(ft:FlxTimer)
								{
									FlxG.sound.music.stop();
									tankmanUgh.visible = false;
									dad.visible = true;
									FlxTween.tween(FurretEngineWatermark, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(sickCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(goodCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(badCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(shitCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(scoreTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(healthBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(healthBarBG, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(iconP2, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
									startCountdown();
								});
							});
						});
					});
				}

			case 'guns':
				{
					dad.visible = false;
					var tankmanGuns:FlxSprite = new FlxSprite(dad.x - 20, dad.y);
					tankmanGuns.frames = FlxAtlasFrames.fromSparrow("assets/images/cutscenes/guns.png", "assets/images/cutscenes/guns.xml");
					tankmanGuns.animation.addByPrefix("an", "TANK TALK 2", 24, false);
					tankmanGuns.antialiasing = true;
					add(tankmanGuns);
					tankmanGuns.animation.play("an");
					camFollow.x = 386;
					camFollow.y = 466.5;
					FlxG.sound.playMusic("assets/sounds/week7/DISTORTO.ogg", 0.1);
					FlxG.sound.play("assets/sounds/week7/tankSong2.ogg");
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
					new FlxTimer().start(4, function(ft:FlxTimer)
					{
						gf.playAnim('sad', true);
						gf.animation.finishCallback = function(n:String)
						{
							if (inCutscene)
								gf.playAnim("sad", true);
						}
						new FlxTimer().start(7.5, function(ft:FlxTimer)
						{
							FlxG.sound.music.stop();
							tankmanGuns.visible = false;
							dad.visible = true;
							FlxTween.tween(FurretEngineWatermark, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(sickCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(goodCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(badCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(shitCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(scoreTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(healthBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(healthBarBG, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(iconP2, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
							startCountdown();
						});
					});
				}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		trace(boyfriend.x);
		trace(boyfriend.y);

		var bf = boyfriend;

		if (loadHScript)
		{
			interp.variables.set("endSong", function()
			{
				endSong();
			});
			interp.variables.set("defaultCamZoom", defaultCamZoom);
			interp.variables.set("Conductor", Conductor);
			interp.variables.set("curBPM", Conductor.bpm);
			interp.variables.set("bpm", SONG.bpm);
			interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
			interp.variables.set("scrollSpeed", SONG.speed);
			interp.variables.set("crochet", Conductor.crochet);
			interp.variables.set("stepCrochet", Conductor.stepCrochet);
			interp.variables.set("songLength", FlxG.sound.music.length);
			interp.variables.set("isStoryMode", PlayState.isStoryMode);
			interp.variables.set("storyDifficulty", PlayState.storyDifficulty);
			interp.variables.set("FurretEngineVersion", MainMenuState.furretEngineVer);
			interp.variables.set("CoolUtil", CoolUtil);
			interp.variables.set("downscroll", FlxG.save.data.downscroll);
			interp.variables.set("ghostTapping", FlxG.save.data.newInput);
			interp.variables.set("hitsounds", FlxG.save.data.hitsoundspog);
			interp.variables.set("judgement", FlxG.save.data.judgement);
			interp.variables.set("middlescroll", FlxG.save.data.middlescroll);
			interp.variables.set("noteSplash", FlxG.save.data.noteSplashON);
			interp.variables.set("Shader", openfl.display.Shader);
			interp.variables.set("CustomShader", CustomShader);
			interp.variables.set("CustomEffect", CustomShader.CustomEffect);
			interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
			interp.variables.set("FlxSprite", FlxSprite);
			interp.variables.set("FlxSound", FlxSound);
			interp.variables.set("FlxGroup", flixel.group.FlxGroup);
			interp.variables.set("FlxAngle", flixel.math.FlxAngle);
			interp.variables.set("Paths", Paths);
			interp.variables.set("MP4Handler", MP4Handler);
			interp.variables.set("videoIsPlaying", videoIsPlaying);
			#if (sys && !mobile)
			interp.variables.set("addMP4Sprite", function(tag:MP4Handler, videoPath:String, x:Float, y:Float, width:Int, height:Int, ?camHUD:Bool)
			{
				if (EngineFunctions.exists(videoPath))
				{
					var animatedbg:FlxSprite = new FlxSprite();
					animatedbg.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
					// animatedbg.screenCenter();
					animatedbg.x = x;
					animatedbg.y = y;
					animatedbg.alpha = 0;
					add(animatedbg);
					remove(animatedbg);

					tag = new MP4Handler();
					tag.playMP4(("assets/videos/Undaunted Apocalypse - CC1.mp4"), null, animatedbg);
					videoInstances.push(tag);
				}
				else
				{
					trace("video doesn't exist!!");
				}
			});
			interp.variables.set("killMP4Sprite", function(tag:MP4Handler)
			{
				for (i in 0...videoInstances.length)
				{
					if (videoInstances[i] == tag)
					{
						videoInstances[i].kill();
					}
				}
			});
			#end
			interp.variables.set("Sound", flash.media.Sound);
			interp.variables.set("Math", Math);
			interp.variables.set("FlxMath", flixel.math.FlxMath);
			interp.variables.set("FlxPoint", flixel.math.FlxPoint);
			interp.variables.set("Point", flixel.math.FlxPoint);
			interp.variables.set("FlxRect", flixel.math.FlxRect);
			interp.variables.set("Rect", flixel.math.FlxRect);
			interp.variables.set("StringTools", StringTools);
			interp.variables.set("SHADOW", FlxTextBorderStyle.SHADOW);
			interp.variables.set("OUTLINE", FlxTextBorderStyle.OUTLINE);
			interp.variables.set("OUTLINE_FAST", FlxTextBorderStyle.OUTLINE_FAST);
			interp.variables.set("NONE", FlxTextBorderStyle.NONE);
			interp.variables.set("CENTER", FlxTextAlign.CENTER);
			interp.variables.set("JUSTIFY", FlxTextAlign.JUSTIFY);
			interp.variables.set("LEFT", FlxTextAlign.LEFT);
			interp.variables.set("RIGHT", FlxTextAlign.RIGHT);
			interp.variables.set("setCameraShader", function(type:String, ?shaderr:String)
			{
				switch (type.toLowerCase())
				{
					case "custom":
						CustomShaderHandler.shader = shaderr;
						FlxG.camera.setFilters([new ShaderFilter(customShader)]);
						// CustomShaderHandler.shader = "";
				}
			});
			interp.variables.set("SONG", SONG);
			interp.variables.set("camFollow", camFollow);
			interp.variables.set("Sys", Sys);
			#if (sys && !mobile)
			interp.variables.set("FileSystem", sys.FileSystem); // i shouldn't be doing this, people can do a lot of bad things with this
			interp.variables.set("File", sys.io.File);
			#end
			interp.variables.set("JSON", haxe.Json); // this isn't too bad isn't it?
			interp.variables.set("playerStrums", playerStrums);
			interp.variables.set("strumLineNotes", strumLineNotes);
			interp.variables.set("notes", notes);
			interp.variables.set("vocals", vocals);
			interp.variables.set("FurretEngineWatermark", FurretEngineWatermark);
			interp.variables.set("timeBar", timeBar);
			interp.variables.set("start", function(song)
			{
			});
			interp.variables.set("beatHit", function(beat)
			{
			});
			interp.variables.set("update", function(elapsed)
			{
			});
			interp.variables.set("stepHit", function(step)
			{
			});
			interp.variables.set("killPlayer", function()
			{
				health = health - 404;
			});
			interp.variables.set("camHUD", camHUD);
			interp.variables.set("camGame", camGame);
			interp.variables.set("sickCounterText", sickCounterText);
			interp.variables.set("goodCounterText", goodCounterText);
			interp.variables.set("badCounterText", badCounterText);
			interp.variables.set("shitCounterText", shitCounterText);
			interp.variables.set("botplayTxt", botplayTxt);
			interp.variables.set("healthBarBG", healthBarBG);
			interp.variables.set("healthBar", healthBar);
			interp.variables.set("scoreTxt", scoreTxt);
			interp.variables.set("TitleState", TitleState);
			interp.variables.set("makeRangeArray", CoolUtil.numberArray);
			interp.variables.set("FlxG", flixel.FlxG);
			interp.variables.set("FlxTimer", flixel.util.FlxTimer);
			interp.variables.set("FlxTween", flixel.tweens.FlxTween);
			interp.variables.set("Std", Std);
			interp.variables.set("iconP1", iconP1);
			interp.variables.set("iconP2", iconP2);
			interp.variables.set("BLACK", FlxColor.BLACK);
			interp.variables.set("BLUE", FlxColor.BLUE);
			interp.variables.set("BROWN", FlxColor.BROWN);
			interp.variables.set("CYAN", FlxColor.CYAN);
			interp.variables.set("GRAY", FlxColor.GRAY);
			interp.variables.set("GREEN", FlxColor.GREEN);
			interp.variables.set("LIME", FlxColor.LIME);
			interp.variables.set("MAGENTA", FlxColor.MAGENTA);
			interp.variables.set("ORANGE", FlxColor.ORANGE);
			interp.variables.set("PINK", FlxColor.PINK);
			interp.variables.set("PURPLE", FlxColor.PURPLE);
			interp.variables.set("RED", FlxColor.RED);
			interp.variables.set("TRANSPARENT", FlxColor.TRANSPARENT);
			interp.variables.set("WHITE", FlxColor.WHITE);
			interp.variables.set("YELLOW", FlxColor.YELLOW);
			interp.variables.set("addHaxeLibrary", function(nameReference:String, library:String)
			{
				try
				{
					setAllHaxeVar(nameReference, Type.resolveClass(library));
				}
				catch (e:Dynamic)
				{
					Application.current.window.alert('[!] An error has occurred!' + "\n" + e.message, 'Furret Engine');
				}
			});
			interp.variables.set("StringTools", StringTools);
			interp.variables.set("FlxTrail", FlxTrail);
			interp.variables.set("FlxEase", FlxEase);
			interp.variables.set("Reflect", Reflect);
			interp.variables.set("health", 0);
			interp.variables.set("curStep", 0);
			interp.variables.set("curBeat", 0);
			interp.variables.set("curSong", SONG.song);
			interp.variables.set("FlxText", FlxText);
			interp.variables.set("preloadImage", function(daThingToPreload:String)
			{ // mandatory if you want to add an image to hscript
				var preload = new FlxSprite(1000, -1000).loadGraphic(Paths.image(daThingToPreload));
				add(preload);
				remove(preload);
			});
			interp.variables.set("SONG", SONG);
			interp.variables.set("Boyfriend", Boyfriend);
			interp.variables.set("boyfriend", bf);
			interp.variables.set("dad", dad);
			interp.variables.set("gf", gf);
			interp.variables.set("setDiscordPresence", function(daPresence:String)
			{
				#if windows
				DiscordClient.changePresence(daPresence, null);
				#else
				trace("[!] Ignoring discord presence change as we are not on Windows");
				#end
			});
			interp.variables.set("changeCharacter", function(characterToReplace:String, characterThatWillBeReplaced, X:Int = 999999, Y:Int = 999999)
			{
				if (characterThatWillBeReplaced == 'dad')
				{
					remove(dad);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						dad = new Character(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						dad = new Character(X, Y, characterToReplace);
					}
					add(dad);
					SONG.player2 = characterToReplace;
					remove(iconP2);
					iconP2 = new HealthIcon(SONG.player2, false);
					iconP2.y = healthBar.y - (iconP2.height / 2);
					iconP2.cameras = [camHUD];
					add(iconP2);
					interp.variables.set("dad", dad);
				}
				else if (characterThatWillBeReplaced == 'bf' || characterThatWillBeReplaced == 'boyfriend')
				{
					remove(boyfriend);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						boyfriend = new Boyfriend(X, Y, characterToReplace);
					}
					add(boyfriend);
					interp.variables.set("boyfriend", bf);
				}
				else if (characterThatWillBeReplaced == 'dad')
				{
					remove(boyfriend);
					if (X == 999999 || Y == 999999 || X & Y == 999999)
					{
						boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
						trace("[!] Haxe script: No X or Y or both specified");
					}
					else
					{
						boyfriend = new Boyfriend(X, Y, characterToReplace);
					}
					add(boyfriend);
					SONG.player1 = characterToReplace;
					remove(iconP1);
					iconP1 = new HealthIcon(SONG.player1, false);
					iconP1.y = healthBar.y - (iconP1.height / 2);
					iconP1.cameras = [camHUD];
					add(iconP1);
				}
			});
			interp.variables.set("Character", Character);
			interp.variables.set("PlayState", this);
			interp.variables.set("FlxG", FlxG);
			interp.variables.set("ease", FlxEase);
			interp.variables.set("camHUD", camHUD);
			interp.variables.set("remove", function(something)
			{
				remove(something);
			});
			interp.variables.set("add", function(something)
			{
				add(something);
			});
			interp.variables.set("getFullscreen", function()
			{
				return FlxG.fullscreen;
			});
			interp.variables.set("setFullscreen", function(tf:Bool)
			{
				return FlxG.fullscreen = tf;
			});
			interp.variables.set("justPressed", FlxG.keys.justPressed);
			interp.variables.set("pressed", FlxG.keys.pressed);
			interp.variables.set("justReleased", FlxG.keys.justReleased);
			interp.variables.set("resizeGame", function(Width:Int, Height:Int)
			{
				return FlxG.resizeGame(Width, Height);
			});
			interp.variables.set("resizeWindow", function(Width:Int, Height:Int)
			{
				return FlxG.resizeWindow(Width, Height);
			});
			interp.variables.set("openURL", function(url:String)
			{
				return FlxG.openURL(url);
			});
			var directory:Array<String> = [];
			if (customMod != "")
			{
				directory = EngineFunctions.readDirectory("mods/" + customMod + "/assets/data/" + PlayState.SONG.song.toLowerCase());
			}
			else
			{
				directory = EngineFunctions.readDirectory("assets/data/" + PlayState.SONG.song.toLowerCase());
			}
			hscriptStates.set("interp", interp);
			for (i in directory) // I DID IT, I FUCKING DID IT, LMAO, TAKE THAT PSYCH ENGINE CODERS
			{
				if (directory[check].endsWith(".hx"))
				{
					var getScript:String = "";
					if (customMod != "")
					{
						getScript = EngineFunctions.getContent("mods/" + customMod + "/assets/data/" + PlayState.SONG.song.toLowerCase() + "/"
							+ directory[check]);
					}
					else
					{
						getScript = EngineFunctions.getContent("assets/data/" + PlayState.SONG.song.toLowerCase() + "/" + directory[check]);
					}
					var daScript:String = getScript;
					var daScriptParser = new hscript.Parser();
					daScriptParser.allowTypes = true;
					daScriptParser.allowJSON = true;
					var script:Dynamic = 'metete tu "Local variable script used without being initialized" por el fondo del ano';
					try
					{
						script = daScriptParser.parseString(daScript);
					}
					catch (e)
					{
						Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
						doNotExecute = true;
					}
					if (!doNotExecute)
					{
						try
						{
							interp.execute(script);
						}
						catch (e)
						{
							Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
							#if sys
							Sys.println("[!] Invalid script");
							#end
						}
						doNotExecute = false;
					}
					else
					{
						#if sys
						Sys.println("[!] Invalid script");
						#end
					}

					try
					{
						callHscript("start", [SONG.song], 'interp');
					}
					catch (e)
					{
						Application.current.window.alert('[!] Invalid script!\n' + e.message, 'Furret Engine');
						#if sys
						Sys.println("[!] Invalid script");
						#end
					}
					trace("[OK] A haxe state has been executed");
				}
				else
				{
					// do nothing
				}
				check++;
			}
			check = 0;
		}

		if (!FlxG.save.data.midscroll)
		{
			generateStaticArrows(0);
		}
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000 / _pitch, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if android
			if (customMod != "")
			{
				FlxG.sound.playMusic(Sound.fromFile(BootUpCheck.getPath() + "mods/" + customMod + "assets/songs/" + curSong.toLowerCase() + "/Inst.ogg"), 1,
					false);
			}
			else
			{
				FlxG.sound.playMusic(Sound.fromFile(BootUpCheck.getPath() + "assets/songs/" + curSong.toLowerCase() + "/Inst.ogg"), 1, false);
			}
			FlxG.sound.playMusic(Sound.fromFile(BootUpCheck.getPath() + 'assets/songs/' + curSong.toLowerCase() + "Inst.ogg"), 1, false);
			#elseif sys
			if (customMod != "")
			{
				FlxG.sound.playMusic(Sound.fromFile("mods/" + customMod + "/assets/songs/" + curSong.toLowerCase() + "/Inst.ogg"), 1, false);
			}
			else
			{
				FlxG.sound.playMusic(Sound.fromFile("assets/songs/" + curSong.toLowerCase() + "/Inst.ogg"), 1, false);
			}
			#elseif html5
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		Conductor.recalculateStuff(_pitch);

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end

		if (curSong.toLowerCase() == "guns") // added this to bring back the old 2021 fnf vibes, i wish the fnf fandom revives one day :(
		{
			var randomVar:Int = Std.random(15);
			trace(randomVar);
			if (randomVar == 8)
			{
				tankmanAscend = true;
			}
		}

		FlxG.sound.music.pitch = _pitch;
		songStarted = true;
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			#if android
			if (customMod != "")
			{
				vocals = new FlxSound().loadEmbedded(Sound.fromFile(BootUpCheck.getPath() + 'mods/' + customMod + '/assets/songs/' + curSong.toLowerCase()
					+ "/Voices.ogg"));
			}
			else
			{
				vocals = new FlxSound().loadEmbedded(Sound.fromFile(BootUpCheck.getPath() + 'assets/songs/' + curSong.toLowerCase() + "/Voices.ogg"));
			}
			#elseif (!android && sys)
			if (customMod != "")
			{
				vocals = new FlxSound().loadEmbedded(Sound.fromFile('mods/' + customMod + '/assets/songs/' + curSong.toLowerCase() + "/Voices.ogg"));
			}
			else
			{
				vocals = new FlxSound().loadEmbedded(Sound.fromFile('assets/songs/' + curSong.toLowerCase() + "/Voices.ogg"));
			}
			#elseif html5
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			#end
		else
			vocals = new FlxSound();

		vocals.pitch = _pitch;

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		if (EngineFunctions.exists("assets/data/" + curSong.toLowerCase() + "/events.json"))
		{
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', curSong.toLowerCase()).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if (songNotes[1] < 0)
					{
						eventNotes.push(songNotes.copy());
					}
				}
			}
		}

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			Conductor.recalculateStuff(_pitch);
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2;
					}
					else
					{
					}
				}
				else
				{ // Event Notes
					eventNotes.push(songNotes.copy());
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		if (eventNotes.length > 1)
		{
			eventNotes.sort(sortByTime);
		}

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y); // tengo sida uwu

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					dadStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 90; // así no se mete el pito -isa 2022
			babyArrow.x += ((FlxG.width / 2) * player);
			if (FlxG.save.data.midscroll && player == 1)
				babyArrow.x -= 333;
			if (FlxG.save.data.midscroll && player == 0)
				babyArrow.alpha = 0;

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		#if (sys && !mobile)
		if (videoIsPlaying && FlxG.autoPause)
		{
			MP4Handler.resumeAllBitmaps();
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused && FlxG.autoPause)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		#if (sys && !mobile)
		if (videoIsPlaying && FlxG.autoPause)
		{
			MP4Handler.pauseAllBitmaps();
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = _pitch;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = _pitch;
		}
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		elapsedtime += elapsed;

		if (accuracy > 100) // dumb fix but hey at least it works for now
		{
			accuracy = 100;
		}

		if (cpuControlled)
		{
			songScore = 0; // lol not today
		}

		if (customShader != null)
		{
			customShader.update(elapsed, FlxG.mouse);
		}

		if (tankmanAscend)
		{
			if (curStep > 895 && curStep < 1151)
			{
				camGame.zoom = 0.8;
			}
		}

		scoreTxt.text = "Score: " + songScore + " // Misses: " + misses + " // Accuracy: " + FlxMath.roundDecimal(accuracy, 2) + "% - "
			+ Rating.generateRank(accuracy);

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		songPercent = Conductor.songPosition / songLength;

		if (loadHScript)
		{
			callAllHScript('update', [elapsed]);
		}

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time / _pitch > (songLength - 100))
				{
					trace("we're fuckin ending the song");

					endingSong = true;
					new FlxTimer().start(2, function(timer)
					{
						endSong();
					});
				}
			}
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
			// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			case 'warzone':
				moveTank();
			case 'warzone-stress':
				var i = 0;
				for (spr in johns.members)
				{
					if (spr.x >= 1.2 * FlxG.width || spr.x <= -0.5 * FlxG.width)
						spr.visible = false;
					else
						spr.visible = true;
					if (spr.animation.curAnim.name == "run")
					{
						var fuck = 0.74 * FlxG.width + endingOffsetJohn[i];
						if (goingRightJohn[i])
						{
							fuck = 0.02 * FlxG.width - endingOffsetJohn[i];
							spr.x = fuck + (Conductor.songPosition - strumTimeJohn[i]) * tankSpeedJohn[i];
							spr.flipX = true;
						}
						else
						{
							spr.x = fuck - (Conductor.songPosition - strumTimeJohn[i]) * tankSpeedJohn[i];
							spr.flipX = false;
						}
					}
					if (Conductor.songPosition > strumTimeJohn[i])
					{
						spr.animation.play("shot");
						if (goingRightJohn[i])
						{
							spr.offset.y = 200;
							spr.offset.x = 300;
						}
					}
					if (spr.animation.curAnim.name == "shot" && spr.animation.curAnim.curFrame >= spr.animation.curAnim.frames.length - 1)
					{
						spr.kill();
					}
					i++;
				}
		}

		super.update(elapsed);

		if (cpuControlled)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.sound.music.stop();
			KillNotes();
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.5)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.5)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += (FlxG.elapsed * 1000) * _pitch;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += (FlxG.elapsed * 1000) * _pitch;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = Conductor.songPosition;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					songCalc = curTime;

					var sexLol:Int = Math.floor(songLength / 1000); // thank u villezen | thank u hayfi or whoever stole this

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false) + " / " + FlxStringUtil.formatTime(sexLol, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					default:
						camFollow.x += dadCameraOffsets[0];
						camFollow.y += dadCameraOffsets[1];
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				camFollow.x += bfCameraOffsets[0];
				camFollow.y += bfCameraOffsets[1];

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.max(0, Math.min(1, 1 - (elapsed * 3.125 * 1 * _pitch))));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.max(0, Math.min(1, 1 - (elapsed * 3.125 * 1 * _pitch))));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000; // shit be werid on 4:3

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					if (!cpuControlled)
					{
						vocals.volume = 0;
					}
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (!cpuControlled && health <= 0 && !_noDeath)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (_noDeath)
		{
			if (health < 0)
			{
				health = 0; // stay there
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (cpuControlled
				&& boyfriend.animation.curAnim != null
				&& boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch)
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				// boyfriend.animation.curAnim.finish();
			}

			if (cpuControlled)
			{
				boyfriend.holdTimer = 0;
			}

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (FlxG.save.data.downscroll)
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				else
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (cpuControlled)
				{
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (spr.animation.finished)
						{
							spr.animation.play('static');
							spr.centerOffsets();
						}
					});
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					if (SONG.stage.toLowerCase() != 'school' || SONG.stage.toLowerCase() != 'schoolEvil')
					{
						dadStrums.forEach(function(sprite:FlxSprite)
						{
							if (Math.abs(Math.round(Math.abs(daNote.noteData)) % 4) == sprite.ID)
							{
								sprite.animation.play('confirm', true);
								if (sprite.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									sprite.centerOffsets();
									sprite.offset.x -= 13;
									sprite.offset.y -= 13;
								}
								else
								{
									sprite.centerOffsets();
								}
								sprite.animation.finishCallback = function(name:String)
								{
									sprite.animation.play('static', true);
									sprite.centerOffsets();
								}
							}
						});
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					callAllHScript('opponentNoteHit', [Math.abs(daNote.noteData)]);

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (cpuControlled)
				{
					if (daNote.mustPress && cpuControlled)
					{
						if (daNote.isSustainNote)
						{
							if (daNote.canBeHit)
							{
								goodNoteHit(daNote);
							}
						}
						else if (daNote.strumTime <= Conductor.songPosition
							|| (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
						{
							goodNoteHit(daNote);
						}
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				// i'm going to jump off a cliff
				if (daNote.mustPress)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				else if (!daNote.wasGoodHit)
				{
					if (FlxG.save.data.midscroll)
					{
						daNote.visible = false;
					}
					else
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					}
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}

				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 17;

				if ((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
					&& daNote.mustPress) // Boyfriend misses the note (doesn't press it?)
				{
					if (!cpuControlled)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							noteMiss(daNote.noteData, daNote);
							health -= 0.0475;
							if (!cpuControlled)
							{
								vocals.volume = 0;
							}
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					updateStats();
				}
			});
		}

		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0][0];
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if (eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			switch (eventNotes[0][2])
			{
				case 'Set GF Speed':
					var value:Int = Std.parseInt(value1);
					if (Math.isNaN(value))
						value = 1;
					gfSpeed = value;

				case 'Add Camera Zoom':
					if (FlxG.camera.zoom < 1.35)
					{
						var cz:Float = Std.parseFloat(value1);
						var hd:Float = Std.parseFloat(value2);
						if (Math.isNaN(cz))
							cz = 0.015;
						if (Math.isNaN(hd))
							hd = 0.03;

						FlxG.camera.zoom += cz;
						camHUD.zoom += hd;
					}

				case 'Play Animation':
					trace('Anim to play: ' + value1);
					dad.playAnim(value1, true);
				default:
					trace("THIS HAS TO BE A CUSTOM EVENT FOR SURE");
					trace(eventNotes[0][2]);
					var path:String = "";
					if (customMod == "") {
						path = "assets/events/";
					}
					else {
						path = "mods/" + customMod + "/assets/events/";
					}
					trace(path + eventNotes[0][2] + ".hx");
					if (EngineFunctions.exists(path + eventNotes[0][2] + ".hx")){
						var bf = boyfriend;
						var interp = new hscript.Interp();
						interp.variables.set("endSong", function()
						{
							endSong();
						});
						interp.variables.set("defaultCamZoom", defaultCamZoom);
						interp.variables.set("Conductor", Conductor);
						interp.variables.set("curBPM", Conductor.bpm);
						interp.variables.set("bpm", SONG.bpm);
						interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
						interp.variables.set("scrollSpeed", SONG.speed);
						interp.variables.set("crochet", Conductor.crochet);
						interp.variables.set("stepCrochet", Conductor.stepCrochet);
						interp.variables.set("songLength", FlxG.sound.music.length);
						interp.variables.set("isStoryMode", PlayState.isStoryMode);
						interp.variables.set("storyDifficulty", PlayState.storyDifficulty);
						interp.variables.set("FurretEngineVersion", MainMenuState.furretEngineVer);
						interp.variables.set("CoolUtil", CoolUtil);
						interp.variables.set("downscroll", FlxG.save.data.downscroll);
						interp.variables.set("ghostTapping", FlxG.save.data.newInput);
						interp.variables.set("hitsounds", FlxG.save.data.hitsoundspog);
						interp.variables.set("judgement", FlxG.save.data.judgement);
						interp.variables.set("middlescroll", FlxG.save.data.middlescroll);
						interp.variables.set("noteSplash", FlxG.save.data.noteSplashON);
						interp.variables.set("Shader", openfl.display.Shader);
						interp.variables.set("CustomShader", CustomShader);
						interp.variables.set("CustomEffect", CustomShader.CustomEffect);
						interp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);
						interp.variables.set("FlxSprite", FlxSprite);
						interp.variables.set("FlxSound", FlxSound);
						interp.variables.set("FlxGroup", flixel.group.FlxGroup);
						interp.variables.set("FlxAngle", flixel.math.FlxAngle);
						interp.variables.set("Paths", Paths);
						interp.variables.set("MP4Handler", MP4Handler);
						interp.variables.set("videoIsPlaying", videoIsPlaying);
						#if (sys && !mobile)
						interp.variables.set("addMP4Sprite", function(tag:MP4Handler, videoPath:String, x:Float, y:Float, width:Int, height:Int, ?camHUD:Bool)
						{
							if (EngineFunctions.exists(videoPath))
							{
								var animatedbg:FlxSprite = new FlxSprite();
								animatedbg.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
								// animatedbg.screenCenter();
								animatedbg.x = x;
								animatedbg.y = y;
								animatedbg.alpha = 0;
								add(animatedbg);
								remove(animatedbg);
				
								tag = new MP4Handler();
								tag.playMP4(("assets/videos/Undaunted Apocalypse - CC1.mp4"), null, animatedbg);
								videoInstances.push(tag);
							}
							else
							{
								trace("video doesn't exist!!");
							}
						});
						interp.variables.set("killMP4Sprite", function(tag:MP4Handler)
						{
							for (i in 0...videoInstances.length)
							{
								if (videoInstances[i] == tag)
								{
									videoInstances[i].kill();
								}
							}
						});
						#end
						interp.variables.set("Sound", flash.media.Sound);
						interp.variables.set("Math", Math);
						interp.variables.set("FlxMath", flixel.math.FlxMath);
						interp.variables.set("FlxPoint", flixel.math.FlxPoint);
						interp.variables.set("Point", flixel.math.FlxPoint);
						interp.variables.set("FlxRect", flixel.math.FlxRect);
						interp.variables.set("Rect", flixel.math.FlxRect);
						interp.variables.set("StringTools", StringTools);
						interp.variables.set("SHADOW", FlxTextBorderStyle.SHADOW);
						interp.variables.set("OUTLINE", FlxTextBorderStyle.OUTLINE);
						interp.variables.set("OUTLINE_FAST", FlxTextBorderStyle.OUTLINE_FAST);
						interp.variables.set("NONE", FlxTextBorderStyle.NONE);
						interp.variables.set("CENTER", FlxTextAlign.CENTER);
						interp.variables.set("JUSTIFY", FlxTextAlign.JUSTIFY);
						interp.variables.set("LEFT", FlxTextAlign.LEFT);
						interp.variables.set("RIGHT", FlxTextAlign.RIGHT);
						interp.variables.set("setCameraShader", function(type:String, ?shaderr:String)
						{
							switch (type.toLowerCase())
							{
								case "custom":
									CustomShaderHandler.shader = shaderr;
									FlxG.camera.setFilters([new ShaderFilter(customShader)]);
									// CustomShaderHandler.shader = "";
							}
						});
						interp.variables.set("SONG", SONG);
						interp.variables.set("camFollow", camFollow);
						interp.variables.set("Sys", Sys);
						#if (sys && !mobile)
						interp.variables.set("FileSystem", sys.FileSystem); // i shouldn't be doing this, people can do a lot of bad things with this
						interp.variables.set("File", sys.io.File);
						#end
						interp.variables.set("JSON", haxe.Json); // this isn't too bad isn't it?
						interp.variables.set("playerStrums", playerStrums);
						interp.variables.set("strumLineNotes", strumLineNotes);
						interp.variables.set("notes", notes);
						interp.variables.set("vocals", vocals);
						interp.variables.set("FurretEngineWatermark", FurretEngineWatermark);
						interp.variables.set("timeBar", timeBar);
						interp.variables.set("start", function(song)
						{
						});
						interp.variables.set("beatHit", function(beat)
						{
						});
						interp.variables.set("update", function(elapsed)
						{
						});
						interp.variables.set("stepHit", function(step)
						{
						});
						interp.variables.set("killPlayer", function()
						{
							health = health - 404;
						});
						interp.variables.set("camHUD", camHUD);
						interp.variables.set("camGame", camGame);
						interp.variables.set("sickCounterText", sickCounterText);
						interp.variables.set("goodCounterText", goodCounterText);
						interp.variables.set("badCounterText", badCounterText);
						interp.variables.set("shitCounterText", shitCounterText);
						interp.variables.set("botplayTxt", botplayTxt);
						interp.variables.set("healthBarBG", healthBarBG);
						interp.variables.set("healthBar", healthBar);
						interp.variables.set("scoreTxt", scoreTxt);
						interp.variables.set("TitleState", TitleState);
						interp.variables.set("makeRangeArray", CoolUtil.numberArray);
						interp.variables.set("FlxG", flixel.FlxG);
						interp.variables.set("FlxTimer", flixel.util.FlxTimer);
						interp.variables.set("FlxTween", flixel.tweens.FlxTween);
						interp.variables.set("Std", Std);
						interp.variables.set("iconP1", iconP1);
						interp.variables.set("iconP2", iconP2);
						interp.variables.set("BLACK", FlxColor.BLACK);
						interp.variables.set("BLUE", FlxColor.BLUE);
						interp.variables.set("BROWN", FlxColor.BROWN);
						interp.variables.set("CYAN", FlxColor.CYAN);
						interp.variables.set("GRAY", FlxColor.GRAY);
						interp.variables.set("GREEN", FlxColor.GREEN);
						interp.variables.set("LIME", FlxColor.LIME);
						interp.variables.set("MAGENTA", FlxColor.MAGENTA);
						interp.variables.set("ORANGE", FlxColor.ORANGE);
						interp.variables.set("PINK", FlxColor.PINK);
						interp.variables.set("PURPLE", FlxColor.PURPLE);
						interp.variables.set("RED", FlxColor.RED);
						interp.variables.set("TRANSPARENT", FlxColor.TRANSPARENT);
						interp.variables.set("WHITE", FlxColor.WHITE);
						interp.variables.set("YELLOW", FlxColor.YELLOW);
						interp.variables.set("addHaxeLibrary", function(nameReference:String, library:String)
						{
							try
							{
								setAllHaxeVar(nameReference, Type.resolveClass(library));
							}
							catch (e:Dynamic)
							{
								Application.current.window.alert('[!] An error has occurred!' + "\n" + e.message, 'Furret Engine');
							}
						});
						interp.variables.set("StringTools", StringTools);
						interp.variables.set("FlxTrail", FlxTrail);
						interp.variables.set("FlxEase", FlxEase);
						interp.variables.set("Reflect", Reflect);
						interp.variables.set("health", 0);
						interp.variables.set("curStep", 0);
						interp.variables.set("curBeat", 0);
						interp.variables.set("curSong", SONG.song);
						interp.variables.set("FlxText", FlxText);
						interp.variables.set("preloadImage", function(daThingToPreload:String)
						{ // mandatory if you want to add an image to hscript
							var preload = new FlxSprite(1000, -1000).loadGraphic(Paths.image(daThingToPreload));
							add(preload);
							remove(preload);
						});
						interp.variables.set("SONG", SONG);
						interp.variables.set("Boyfriend", Boyfriend);
						interp.variables.set("boyfriend", bf);
						interp.variables.set("dad", dad);
						interp.variables.set("gf", gf);
						interp.variables.set("setDiscordPresence", function(daPresence:String)
						{
							#if windows
							DiscordClient.changePresence(daPresence, null);
							#else
							trace("[!] Ignoring discord presence change as we are not on Windows");
							#end
						});
						interp.variables.set("changeCharacter", function(characterToReplace:String, characterThatWillBeReplaced, X:Int = 999999, Y:Int = 999999)
						{
							if (characterThatWillBeReplaced == 'dad')
							{
								remove(dad);
								if (X == 999999 || Y == 999999 || X & Y == 999999)
								{
									dad = new Character(dad.x, dad.y, characterToReplace);
									trace("[!] Haxe script: No X or Y or both specified");
								}
								else
								{
									dad = new Character(X, Y, characterToReplace);
								}
								add(dad);
								SONG.player2 = characterToReplace;
								remove(iconP2);
								iconP2 = new HealthIcon(SONG.player2, false);
								iconP2.y = healthBar.y - (iconP2.height / 2);
								iconP2.cameras = [camHUD];
								add(iconP2);
								interp.variables.set("dad", dad);
							}
							else if (characterThatWillBeReplaced == 'bf' || characterThatWillBeReplaced == 'boyfriend')
							{
								remove(boyfriend);
								if (X == 999999 || Y == 999999 || X & Y == 999999)
								{
									boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
									trace("[!] Haxe script: No X or Y or both specified");
								}
								else
								{
									boyfriend = new Boyfriend(X, Y, characterToReplace);
								}
								add(boyfriend);
								interp.variables.set("boyfriend", bf);
							}
							else if (characterThatWillBeReplaced == 'dad')
							{
								remove(boyfriend);
								if (X == 999999 || Y == 999999 || X & Y == 999999)
								{
									boyfriend = new Boyfriend(dad.x, dad.y, characterToReplace);
									trace("[!] Haxe script: No X or Y or both specified");
								}
								else
								{
									boyfriend = new Boyfriend(X, Y, characterToReplace);
								}
								add(boyfriend);
								SONG.player1 = characterToReplace;
								remove(iconP1);
								iconP1 = new HealthIcon(SONG.player1, false);
								iconP1.y = healthBar.y - (iconP1.height / 2);
								iconP1.cameras = [camHUD];
								add(iconP1);
							}
						});
						interp.variables.set("Character", Character);
						interp.variables.set("PlayState", this);
						interp.variables.set("FlxG", FlxG);
						interp.variables.set("ease", FlxEase);
						interp.variables.set("camHUD", camHUD);
						interp.variables.set("remove", function(something)
						{
							remove(something);
						});
						interp.variables.set("add", function(something)
						{
							add(something);
						});
						interp.variables.set("getFullscreen", function()
						{
							return FlxG.fullscreen;
						});
						interp.variables.set("setFullscreen", function(tf:Bool)
						{
							return FlxG.fullscreen = tf;
						});
						interp.variables.set("justPressed", FlxG.keys.justPressed);
						interp.variables.set("pressed", FlxG.keys.pressed);
						interp.variables.set("justReleased", FlxG.keys.justReleased);
						interp.variables.set("resizeGame", function(Width:Int, Height:Int)
						{
							return FlxG.resizeGame(Width, Height);
						});
						interp.variables.set("resizeWindow", function(Width:Int, Height:Int)
						{
							return FlxG.resizeWindow(Width, Height);
						});
						interp.variables.set("openURL", function(url:String)
						{
							return FlxG.openURL(url);
						});
						var daScript:String = EngineFunctions.getContent(path + eventNotes[0][2] + ".hx");
						var daScriptParser = new hscript.Parser();
						daScriptParser.allowTypes = true;
						daScriptParser.allowMetadata = true;
						daScriptParser.allowJSON = true;
						var script = daScriptParser.parseString(daScript);
						interp.execute(script);
					}
			}
			eventNotes.shift();
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	public static function setDadCamOffsets(x:Float, y:Float)
	{
		dadCameraOffsets[0] = x;
		dadCameraOffsets[1] = y;
	}

	public static function setBfCamOffsets(x:Float, y:Float)
	{
		bfCameraOffsets[0] = x;
		bfCameraOffsets[1] = y;
	}

	function endSong():Void
	{
		trace("song ended");
		canPause = false;
		FlxG.sound.music.volume = 0;
		// vocals.volume = 0;
		vocals.destroy();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		#if (sys && !mobile)
		if (videoIsPlaying)
		{
			#if (!mobile)
			MP4Handler.killBitmaps();
			#end
			videoIsPlaying = false;
			videoInstances = [];
		}
		#end

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
				cpuControlled = false;
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			cpuControlled = false;
		}
	}

	var endingSong:Bool = false;

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		var amountHitNote:Float = 0.00;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			shitCounter++;
			amountHitNote = 0.25;
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			badCounter++;
			amountHitNote = 0.5;
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			goodCounter++;
			amountHitNote = 0.8;
			score = 200;
		}
		else
		{
			daRating = 'sick';
			sickCounter++;
			amountHitNote = 1;
			score = 350;
		}

		if (FlxG.save.data.noteSplash)
		{
			var sploosh:FlxSprite = new FlxSprite(daNote.x, playerStrums.members[daNote.noteData].y);
			if (!curStage.startsWith('school'))
			{
				sploosh.frames = FlxAtlasFrames.fromSparrow('assets/images/noteSplashes.png', 'assets/images/noteSplashes.xml');
				sploosh.animation.addByPrefix('splash 0 0', 'note impact 1 purple', 24, false);
				sploosh.animation.addByPrefix('splash 0 1', 'note impact 1  blue', 24, false);
				sploosh.animation.addByPrefix('splash 0 2', 'note impact 1 green', 24, false);
				sploosh.animation.addByPrefix('splash 0 3', 'note impact 1 red', 24, false);
				sploosh.animation.addByPrefix('splash 1 0', 'note impact 2 purple', 24, false);
				sploosh.animation.addByPrefix('splash 1 1', 'note impact 2 blue', 24, false);
				sploosh.animation.addByPrefix('splash 1 2', 'note impact 2 green', 24, false);
				sploosh.animation.addByPrefix('splash 1 3', 'note impact 2 red', 24, false);
				if (daRating == 'sick')
				{
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 0.6;
					sploosh.offset.x += 90;
					sploosh.offset.y += 80;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
				}
			}
		}

		notesHit += amountHitNote;

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		// trace(pixelShitPart1 + daRating + pixelShitPart2);
		rating.x = FlxG.save.data.ratingX;
		rating.y = FlxG.save.data.ratingY;
		rating.acceleration.y = 550 * _pitch * _pitch;
		rating.velocity.y -= FlxG.random.int(140, 175) * _pitch;
		rating.velocity.x -= FlxG.random.int(0, 10) * _pitch;
		rating.cameras = [camHUD];
		if (FlxG.save.data.hideRC)
		{
			rating.visible = false;
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = rating.x;
		comboSpr.y = rating.y + 100;
		comboSpr.acceleration.y = 600 * _pitch * _pitch;
		comboSpr.velocity.y -= 150 * _pitch * _pitch;
		comboSpr.cameras = [camHUD];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if (FlxG.save.data.hideRC)
		{
			comboSpr.visible = false;
		}
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) + 20;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * _pitch * _pitch;
			numScore.velocity.y -= FlxG.random.int(140, 160) * _pitch;
			numScore.velocity.x = FlxG.random.float(-5, 5) * _pitch;
			if (FlxG.save.data.hideRC)
			{
				numScore.visible = false;
			}

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / _pitch, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / _pitch
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / _pitch, {
			startDelay: Conductor.crochet * 0.001 / _pitch
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / _pitch, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001 / _pitch
		});

		updateStats();

		curSection += 1;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var releaseArray:Array<Bool> = [leftR, downR, upR, rightR];

		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			possibleNotes = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
				{
					possibleNotes.push(daNote);
				}
			});

			haxe.ds.ArraySort.sort(possibleNotes, function(a, b):Int
			{
				var notetypecompare:Int = Std.int(a.noteData - b.noteData);

				if (notetypecompare == 0)
				{
					return Std.int(a.strumTime - b.strumTime);
				}
				return notetypecompare;
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				var lasthitnote:Int = -1;
				var lasthitnotetime:Float = -1;

				for (note in possibleNotes)
				{
					if (!note.mustPress)
					{
						continue;
					}
					if (controlArray[note.noteData % 4])
					{
						if (lasthitnotetime > Conductor.songPosition - Conductor.safeZoneOffset
							&& lasthitnotetime < Conductor.songPosition +
							(Conductor.safeZoneOffset * 0.07)) // reduce the past allowed barrier just so notes close together that aren't jacks dont cause missed inputs
						{
							if ((note.noteData % 4) == (lasthitnote % 4))
							{
								lasthitnotetime = -999999; // reset the last hit note time
								continue; // the jacks are too close together
							}
						}
						lasthitnote = note.noteData;
						lasthitnotetime = note.strumTime;
						goodNoteHit(note);
					}
				}

				if (daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
			else if (!FlxG.save.data.ghostTap)
			{
				if (!inCutscene)
					badNoteCheck();
			}
		}

		if ((up || right || down || left) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if ((boyfriend.animation.curAnim.name.startsWith('sing')) && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
			{
				spr.animation.play('pressed');
			}
			if (releaseArray[spr.ID])
			{
				spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, note:Note):Void
	{
		if (true)
		{
			misses++;
			health -= 0.04;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			songScore -= 100;

			var deathSound:FlxSound = new FlxSound();
			switch (curSong.toLowerCase())
			{
				default:
					deathSound.loadEmbedded(Paths.soundRandom('missnote', 1, 3));
			}
			deathSound.volume = FlxG.random.float(0.1, 0.2);
			deathSound.play();

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateStats();
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var note:Note = null;

		if (note != null)
		{
			if (note.mustPress)
			{
				noteMiss(note.noteData, note);
			}
			return;
		}
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		for (i in 0...controlArray.length)
		{
			if (controlArray[i])
			{
				noteMiss(i, note);
			}
		}
	}

	function updateStats():Void
	{
		played++;
		accuracy = Math.max(0, notesHit / played * 100);
		sickCounterText.text = "Sicks: " + sickCounter;
		goodCounterText.text = "Goods: " + goodCounter;
		badCounterText.text = "Bads: " + badCounter;
		shitCounterText.text = "Shits: " + shitCounter;
	}

	public function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}
			else
			{
				notesHit++;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX = 400;

	function moveTank()
	{
		tankAngle += FlxG.elapsed * tankSpeed;
		steve.angle = tankAngle - 90 + 15;
		steve.x = tankX + 1500 * FlxMath.fastCos(FlxAngle.asRadians(tankAngle + 180));
		steve.y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(tankAngle + 180));
	}

	function resetJohn(x:Float, y:Int, goingRight:Bool, spr:FlxSprite, johnNum:Int)
	{
		spr.x = x;
		spr.y = y;
		goingRightJohn[johnNum] = goingRight;
		endingOffsetJohn[johnNum] = FlxG.random.float(50, 200);
		tankSpeedJohn[johnNum] = FlxG.random.float(0.6, 1);
		spr.flipX = if (goingRight) true else false;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (SONG.song.toLowerCase() == 'ugh')
		{
			switch (curStep)
			{
				case 60:
					dad.playAnim("ughAnim");
				case 444:
					dad.playAnim("ughAnim");
				case 524:
					dad.playAnim("ughAnim");
				case 540 | 541:
					dad.playAnim("ughAnim");
				case 828:
					dad.playAnim("ughAnim");
			}
		}
		if (tankmanAscend)
		{
			switch (curStep)
			{
				case 896:
					{
						dadStrums.forEachAlive(function(daNote:FlxSprite)
						{
							FlxTween.tween(daNote, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						});
						FlxTween.tween(FurretEngineWatermark, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(timeBar, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(sickCounterText, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(goodCounterText, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(badCounterText, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(shitCounterText, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(scoreTxt, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(healthBar, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(healthBarBG, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(iconP1, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(iconP2, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(timeTxt, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						dad.velocity.y = -35;
						camFollow.velocity.y = -33.5;
					}
				case 906:
					{
						playerStrums.forEachAlive(function(daNote:FlxSprite)
						{
							FlxTween.tween(daNote, {alpha: 0}, 0.5, {ease: FlxEase.expoOut,});
						});
					}
				case 1020:
					{
						playerStrums.forEachAlive(function(daNote:FlxSprite)
						{
							FlxTween.tween(daNote, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						});
					}
				case 1024:
					dad.velocity.y = 0;
					camFollow.velocity.y = -33.5;
					boyfriend.velocity.y = -33.5;
				case 1152:
					{
						FlxG.camera.flash(FlxColor.WHITE, 1);
						dadStrums.forEachAlive(function(daNote:FlxSprite)
						{
							FlxTween.tween(daNote, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						});
						FlxTween.tween(FurretEngineWatermark, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(sickCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(goodCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(badCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(shitCounterText, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(scoreTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(healthBar, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(healthBarBG, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(iconP2, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoOut,});
						dad.x = 100;
						dad.y = 280;
						boyfriend.x = 810;
						boyfriend.y = 450;
						dad.velocity.y = 0;
						boyfriend.velocity.y = 0;
						camFollow.velocity.y = 0;
					}
			}
		}
		if (SONG.song.toLowerCase() == 'stress')
		{
			for (i in 0...picoStep.right.length)
			{
				if (curStep == picoStep.right[i])
				{
					trace("Right shot detected!: " + curStep);
					gf.playAnim('shoot' + FlxG.random.int(1, 2), true);
				}
			}

			for (i in 0...picoStep.left.length)
			{
				if (curStep == picoStep.left[i])
				{
					trace("Left shot detected!: " + curStep);
					gf.playAnim('shoot' + FlxG.random.int(3, 4), true);
				}
			}

			// Left tankspawn
			for (i in 0...tankStep.left.length)
			{
				if (curStep == tankStep.left[i])
				{
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);

					tankmanRun.add(tankmanRunner);
				}
			}

			// Right spawn
			for (i in 0...tankStep.right.length)
			{
				if (curStep == tankStep.right[i])
				{
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
					tankmanRun.add(tankmanRunner);
				}
			}

			switch (curStep)
			{
				case 736:
					if (dad.curCharacter == "tankman")
					{
						dad.playAnim("singDOWN-alt", true);
					}
			}
		}

		if (loadHScript)
		{
			setAllHaxeVar('curStep', curStep);
			callAllHScript("stepHit", [curStep]);
		}
		var gamerValue = 20 * _pitch;

		if (FlxG.sound.music.time > Conductor.songPosition + gamerValue
			|| FlxG.sound.music.time < Conductor.songPosition - gamerValue
			|| FlxG.sound.music.time < 500
			&& (FlxG.sound.music.time > Conductor.songPosition + 5 || FlxG.sound.music.time < Conductor.songPosition - 5))
			resyncVocals();

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (loadHScript)
		{
			setAllHaxeVar('curBeat', curBeat);
			callAllHScript('beatHit', [curBeat]);
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (cpuControlled))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 60));
		iconP2.setGraphicSize(Std.int(iconP2.width + 60));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		if (curBeat % gfSpeed == 0)
		{
			curBeat % ((gfSpeed * 2) / 1) == 0 ? {
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);

				FlxTween.angle(iconP1, -15, 0, (Conductor.crochet / 1300) / 1 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, (Conductor.crochet / 1300) / 1 * gfSpeed, {ease: FlxEase.quadOut});
			} : {
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);

				FlxTween.angle(iconP2, -15, 0, (Conductor.crochet / 1300) / 1 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 15, 0, (Conductor.crochet / 1300) / 1 * gfSpeed, {ease: FlxEase.quadOut});
				}

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, (Conductor.crochet / 1250) / 1 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, (Conductor.crochet / 1250) / 1 * gfSpeed, {ease: FlxEase.quadOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case "warzone" | "warzone-stress":
				tankBop1.animation.play('bop', true);
				tankBop2.animation.play('bop', true);
				tankBop3.animation.play('bop', true);
				tankBop4.animation.play('bop', true);
				tankBop5.animation.play('bop', true);
				tankBop6.animation.play('bop', true);
				tower.animation.play('idle', true);
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
