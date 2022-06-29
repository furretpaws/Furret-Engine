package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	private var isPixel:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var ability:String = '';
	public var value1:String = '';
	public var value2:String = '';

	public var mania:Int = 0;

	public static var scales:Array<Float> = [0.7, 0.6, 0.46];

	public var noteScore:Float = 1;

	public static var swagWidth:Float;
	public static var noteScale:Float;

	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var EX1_NOTE:Int = 4;
	public static var EX2_NOTE:Int = 5;

	public var rating:String = "shit";
	public static var tooMuch:Float = 30;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?customImage:Null<BitmapData>, ?customXml:Null<String>, ?customEnds:Null<BitmapData>)
	{
		swagWidth = 160 * 0.7; //factor not the same as noteScale
		noteScale = 0.7;
		mania = 0;
		if (PlayState.SONG.mania == 1)
		{
			swagWidth = 120 * 0.7;
			noteScale = 0.6;
			mania = 1;
		}
		else if (PlayState.SONG.mania == 2)
		{
			swagWidth = 90 * 0.7;
			noteScale = 0.46;
			mania = 2;
		}
		else if (PlayState.SONG.mania == 3)
		{
			swagWidth = 140 * 0.7;
			noteScale = 0.66;
			mania = 3;
		}
		else if (PlayState.SONG.mania == 4)
		{
			swagWidth = 110 * 0.7;
			noteScale = 0.58;
			mania = 4;
		}
		else if (PlayState.SONG.mania == 5)
		{
			swagWidth = 100 * 0.7;
			noteScale = 0.55;
			mania = 5;
		}
		else if (PlayState.SONG.mania == 6)
		{
			swagWidth = 200 * 0.7;
			noteScale = 0.7;
			mania = 6;
		}
		else if (PlayState.SONG.mania == 7)
		{
			swagWidth = 180 * 0.7;
			noteScale = 0.7;
			mania = 7;
		}
		else if (PlayState.SONG.mania == 8)
		{
			swagWidth = 170 * 0.7;
			noteScale = 0.7;
			mania = 8;
		}
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		if (PlayState.SONG.mania == 2)
		{
			x -= tooMuch;
		}
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (PlayState.SONG.uiType)
		{
			case 'pixel':
				loadGraphic('assets/images/weeb/pixelUI/arrows-pixels.png', true, 17, 17);
				isPixel = true;
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic('assets/images/weeb/pixelUI/arrowEnds.png', true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			case 'normal':
				frames = Paths.getSparrowAtlas('NOTE_assets');
	
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('whiteScroll', 'white0');
				animation.addByPrefix('yellowScroll', 'yellow0');
				animation.addByPrefix('violetScroll', 'violet0');
				animation.addByPrefix('blackScroll', 'black0');
				animation.addByPrefix('darkScroll', 'dark0');
	
	
				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('whiteholdend', 'white hold end');
				animation.addByPrefix('yellowholdend', 'yellow hold end');
				animation.addByPrefix('violetholdend', 'violet hold end');
				animation.addByPrefix('blackholdend', 'black hold end');
				animation.addByPrefix('darkholdend', 'dark hold end');
	
				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('whitehold', 'white hold piece');
				animation.addByPrefix('yellowhold', 'yellow hold piece');
				animation.addByPrefix('violethold', 'violet hold piece');
				animation.addByPrefix('blackhold', 'black hold piece');
				animation.addByPrefix('darkhold', 'dark hold piece');
	
				animation.addByPrefix('kill', 'kill');
				animation.addByPrefix('live', 'live');
	
				setGraphicSize(Std.int(width * noteScale));
				updateHitbox();
				antialiasing = true;
			default:
				if (FileSystem.exists('assets/images/custom_ui/ui_packs/'+PlayState.SONG.uiType+"/NOTE_assets.xml") && FileSystem.exists('assets/images/custom_ui/ui_packs/'+PlayState.SONG.uiType+"/NOTE_assets.png")) {

					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('whiteScroll', 'white0');
					animation.addByPrefix('yellowScroll', 'yellow0');
					animation.addByPrefix('violetScroll', 'violet0');
					animation.addByPrefix('blackScroll', 'black0');
					animation.addByPrefix('darkScroll', 'dark0');


					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('whiteholdend', 'white hold end');
					animation.addByPrefix('yellowholdend', 'yellow hold end');
					animation.addByPrefix('violetholdend', 'violet hold end');
					animation.addByPrefix('blackholdend', 'black hold end');
					animation.addByPrefix('darkholdend', 'dark hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('whitehold', 'white hold piece');
					animation.addByPrefix('yellowhold', 'yellow hold piece');
					animation.addByPrefix('violethold', 'violet hold piece');
					animation.addByPrefix('blackhold', 'black hold piece');
					animation.addByPrefix('darkhold', 'dark hold piece');

					animation.addByPrefix('kill', 'kill');
					animation.addByPrefix('live', 'live');

					setGraphicSize(Std.int(width * noteScale));
					updateHitbox();
					antialiasing = true;
					// when arrowsEnds != arrowEnds :laughing_crying:
				} else if (FileSystem.exists('assets/images/custom_ui/ui_packs/'+PlayState.SONG.uiType+"/arrows-pixels.png") && FileSystem.exists('assets/images/custom_ui/ui_packs/'+PlayState.SONG.uiType+"/arrowEnds.png")){

					loadGraphic(customImage, true, 17, 17);
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
					isPixel = true;
					if (isSustainNote)
					{
						var noteEndPic = BitmapData.fromFile('assets/images/custom_ui/ui_packs/'+PlayState.SONG.uiType+"/arrowEnds.png");
						loadGraphic(noteEndPic, true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				} else {
					// no crashing today :)
					trace(PlayState.SONG.uiType);
					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('whiteScroll', 'white0');
					animation.addByPrefix('yellowScroll', 'yellow0');
					animation.addByPrefix('violetScroll', 'violet0');
					animation.addByPrefix('blackScroll', 'black0');
					animation.addByPrefix('darkScroll', 'dark0');


					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('whiteholdend', 'white hold end');
					animation.addByPrefix('yellowholdend', 'yellow hold end');
					animation.addByPrefix('violetholdend', 'violet hold end');
					animation.addByPrefix('blackholdend', 'black hold end');
					animation.addByPrefix('darkholdend', 'dark hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('whitehold', 'white hold piece');
					animation.addByPrefix('yellowhold', 'yellow hold piece');
					animation.addByPrefix('violethold', 'violet hold piece');
					animation.addByPrefix('blackhold', 'black hold piece');
					animation.addByPrefix('darkhold', 'dark hold piece');

					animation.addByPrefix('kill', 'kill');
					animation.addByPrefix('live', 'live');

					setGraphicSize(Std.int(width * noteScale));
					updateHitbox();
					antialiasing = true;
				}	
		}


		switch (noteData)
		{
			case 0:
			//nada
		}
		var frameN:Array<String> = ['purple', 'blue', 'green', 'red'];
		if (mania == 1) frameN = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
		else if (mania == 2) frameN = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
		else if (mania == 3) frameN = ['purple', 'blue', 'white', 'green', 'red'];
		else if (mania == 4) frameN = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
		else if (mania == 5) frameN = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'black', 'dark'];
		else if (mania == 6) frameN = ['white'];
		else if (mania == 7) frameN = ['purple', 'red'];
		else if (mania == 8) frameN = ['purple', 'white', 'red'];

		x += swagWidth * noteData;
		animation.play(frameN[noteData] + 'Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			animation.play(frameN[noteData] + 'holdend');
			switch (noteData)
			{
				case 0:
				//nada
			}

			updateHitbox();

			x -= width / 2;

			if (isPixel)
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
					//nada
				}
				prevNote.animation.play(frameN[prevNote.noteData] + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed * (0.7 / noteScale);
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}