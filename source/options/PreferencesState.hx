package options;

import Alphabet;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PreferencesState extends MusicBeatState
{
	var bg:FlxSprite;
	var optionsmenutitle:FlxText;
	var descriptions:Array<String> = [];
	var options:Array<String> = [];
	var optionValues:Array<Bool> = [];
	var curSelected:Int = 0;
	var typedGroupCheck:FlxTypedGroup<Checkbox> = new FlxTypedGroup<Checkbox>();
	var typedGroupTexts:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var offset:Int = 0;
	var description:FlxText;

	function addOption(name:String, description:String, type:String, optionName:String)
	{
		var initCheckXY:Array<Int> = [99, 141];
		var initTextXY:Array<Int> = [180, 161];

		descriptions.push(description);

		var alphabet = new Alphabet(-5, initTextXY[1] + offset + (-73), name, false, false);
		alphabet.x += 250;
		alphabet.scale.set(0.7, 0.7);
		for (i in 0...alphabet.length)
		{
			alphabet.members[i].x += 160;
		}
		typedGroupTexts.add(alphabet);

		/*var text = new FlxText(initTextXY[0], initTextXY[1] + offset + 5);
		text.text = name;
		text.size = 32;
		text.setFormat("assets/fonts/funkin.otf", 32, FlxColor.BLACK, RIGHT, OUTLINE, FlxColor.TRANSPARENT);
		typedGroupTexts.add(text);*/

		var checked:Bool = Reflect.getProperty(FlxG.save.data, optionName);
		optionValues.push(checked);
		options.push(optionName);

		var checkboxthing:Checkbox = new Checkbox(checked, initCheckXY[0], initCheckXY[1] + offset);
		typedGroupCheck.add(checkboxthing);

		offset += 75;
		trace("added");
	}

	function check():Void
	{
		Reflect.setProperty(FlxG.save.data, options[curSelected], !optionValues[curSelected]);
		optionValues[curSelected] = !optionValues[curSelected];
		typedGroupCheck.members[curSelected].changeCheck();
		//trace(optionValues);
		if (curSelected == 6)
		{
			Main.toggleFPS(FlxG.save.data.hideFPSCounter);
		}
		if (curSelected == 7)
		{
			//you did it but now we gotta make all the antializing checks well check for this. please furret engine creator code that.
		}
	}

	function doNothing():Void
	{
		// do nothing dumbass
	}

	function quit():Void
	{
		FlxG.save.flush();
		FlxG.switchState(new options.OptionsMenu());
	}

	function updateOptions():Void
	{
		for (i in 0...options.length)
		{
			typedGroupCheck.members[i].alpha = 0.6;
			typedGroupTexts.members[i].alpha = 0.6;
		}
		typedGroupCheck.members[curSelected].alpha = 1;
		typedGroupTexts.members[curSelected].alpha = 1;
		description.text = descriptions[curSelected];
		description.screenCenter(X);
	}

	function control():Void
	{
		if (FlxG.keys.justPressed.W)
		{
			if (curSelected == 0)
			{
				doNothing();
			}
			else
			{
				curSelected--;
				updateOptions();
				trace(curSelected);
			}
		}
		if (FlxG.keys.justPressed.S)
		{
			if (curSelected == options.length - 1)
			{
				doNothing();
			}
			else
			{
				curSelected++;
				updateOptions();
				trace(curSelected);
			}
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			check();
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			quit();
		}
	}

	override public function create()
	{
		trace(optionValues);
		
		bg = new FlxSprite().loadGraphic("assets/images/menuDesat.png");
		bg.antialiasing = true;
		//bg.color = 0xff0cbb00;
		bg.color = FlxColor.fromRGB(Std.random(255), Std.random(255), Std.random(255));
		add(bg);

		optionsmenutitle = new FlxText();
		optionsmenutitle.text = "Preferences menu";
		optionsmenutitle.x = 0;
		optionsmenutitle.y = 66;
		optionsmenutitle.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionsmenutitle.screenCenter(X);
		optionsmenutitle.updateHitbox();
		add(optionsmenutitle);
		add(typedGroupCheck);
		add(typedGroupTexts);

		description = new FlxText();
		description.fieldWidth = 1150; //idk if this will work
		description.y = 640;
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		add(description);

		//addOption("Ghost tapping", "666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666", "bool", "ghostTap"); //Enables or disables ghost tapping.
		//please do not ask about the code above this
		addOption("Ghost tapping", "Enables or disables ghost tapping.", "bool", "ghostTap");
		addOption("Downscroll", "Enables or disables downscroll", "bool", "downscroll");
		addOption("Middlescroll", "Moves the player strumline to the middle.", "bool", "midscroll");
		addOption("Note splash", "If checked, hitting \"Sick\" notes will show particles.", "bool", "noteSplash");
		addOption("Hide time bar", "If checked, the time bar will be hidden.", "bool", "hideTimeBar");
		addOption("Hide rating and combo", "If checked, the rating and combo will be hidden", "bool", "hideRC");
		addOption("Hide FPS counter", "If checked, the FPS counter will be hidden", "bool", "hideFPSCounter");
		addOption("Antializing", "Enables or disables antializing.", "bool", "antialize");

		description.text = descriptions[curSelected];

		for (i in 0...typedGroupTexts.length)
		{
			typedGroupTexts.members[i].x += -230;
		}

		offset = 0;
		super.create();
		updateOptions();
	}

	override public function update(elapsed:Float)
	{
		control();
		super.update(elapsed);
	}
}

class Checkbox extends FlxSprite
{
	var isChecked:Bool = false;

	public function new(check:Bool, x:Float, y:Float)
	{
		super(x - 18, y - 20);
		frames = FlxAtlasFrames.fromSparrow("assets/images/ui/checkboxanim.png", "assets/images/ui/checkboxanim.xml");
		animation.addByPrefix("unchecked", "checkbox0", 24, false);
		animation.addByPrefix("unchecking", "checkbox anim reverse", 24, false);
		animation.addByPrefix("checking", "checkbox anim0", 24, false);
		animation.addByPrefix("checked", "checkbox finish", 24, false);
		updateHitbox();
		changea(isChecked ? 'checking' : 'unchecking');
		animation.finishCallback = changea;
		switch (check)
		{
			case true:
				animation.play("checked");
				isChecked = true;
			case false:
				animation.play("unchecked");
				isChecked = false;
		}
		scale.set(0.5, 0.5);
	}

	public function changeCheck():Void
	{
		switch (isChecked)
		{
			case false:
				animation.play('checking', true);
				isChecked = true;
				offset.set(21, 19);
			case true:
				animation.play("unchecking", true);
				isChecked = false;
				offset.set(15.5, 17.5);
		}
	}

	public function changea(value:String)
	{
		switch (value)
		{
			case 'checking':
				animation.play('checked', true);
				offset.set(3, 12);

			case 'unchecking':
				animation.play('unchecked', true);
				offset.set(0, 2);
		}
	}
}
