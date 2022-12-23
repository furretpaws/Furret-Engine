package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.*;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class OptionsMenu extends MusicBeatState
{
	var bg:FlxSprite;
	var optionList:Array<String> = ['Preferences', 'Controls', 'Customize Gameplay'];
	var curSelected:Int = 0; // isn't that obvious?
	private var optionsGroup:FlxTypedGroup<Alphabet>;

	function changeSelection(times:Int)
	{
		curSelected += times;
		FlxG.sound.play(Paths.sound("scrollMenu"));
		for (i in 0...optionList.length)
		{
			optionsGroup.members[i].alpha = 0.5;
		}
		if (curSelected > optionList.length - 1)
		{
			optionsGroup.members[0].alpha = 1;
		}
		else if (curSelected < 0)
		{
			optionsGroup.members[3].alpha = 1;
		}
		else
		{
			optionsGroup.members[curSelected].alpha = 1;
		}
		trace(optionList.length - 1);
	}

	override public function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xff73317d;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		optionsGroup = new FlxTypedGroup<Alphabet>();
		add(optionsGroup);

		for (i in 0...optionList.length)
		{
			var optionLabel:Alphabet = new Alphabet(0, (100 * i) + 105, optionList[i], true, false);
			optionsGroup.add(optionLabel);
		}

		optionsGroup.forEach(function(optionLabel:Alphabet)
		{
			optionLabel.screenCenter(X);
		});

		changeSelection(0);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.UP_P)
		{
			changeSelection(-1);
		}

		if (curSelected > optionList.length - 1)
		{
			curSelected = 0;
		}
		else if (curSelected < 0)
		{
			curSelected = optionList.length - 1;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			switch (curSelected)
			{
				case 0:
					FlxG.switchState(new options.PreferencesState());
				case 1:
					openSubState(new ControlsSubState());
				case 2:
					FlxG.switchState(new customization.CustomizeGameplay());
			}
		}
	}
}

class ControlsSubState extends MusicBeatSubstate
{
	var bgTint:FlxSprite;

	var keys:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"]; // if you want to add custom controls for mechanics or extra keys, just add it here, the engine will set it up properly | Note: you will have to edit the controls.hx file
	var daText:FlxText;

	var pressAKey:FlxText = new FlxText(0, 150, FlxG.width);

	var currentState:String = 'selecting';

	var curSelected:Int = 0;

	var FlixelControlSave:Array<Dynamic> = [
		FlxG.save.data.LEFTBind,
		FlxG.save.data.DOWNBind,
		FlxG.save.data.UPBind,
		FlxG.save.data.RIGHTBind
	]; // same in thing in here

	var tempKey:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE"];

	var keyBinds:Array<Dynamic> = []; // WAAAAAAAA

	public function new()
	{
		super();

		for (i in 0...FlixelControlSave.length)
		{
			keyBinds.push(FlixelControlSave[i]);
		}
	}

	function endCallback(FlxTween:FlxTween)
	{
		quit();
	}

	function textUpdate()
	{
		daText.text = "\n\n";
		for (i in 0...keys.length)
		{
			var textStart = (i == curSelected) ? "> " : "  ";
			if (i == keys.length)
			{
				daText.text += textStart
					+ keys[i]
					+ ": "
					+ ((keyBinds[i] != keyBinds[i]) ? (keyBinds[i] + " / ") : "")
					+ keyBinds[i]
					+ (curSelected != keys.length ? " ARROW\n" : "\n");
			}
			else
			{
				daText.text += textStart + keys[i] + ": " + keyBinds[i] + "\n";
			}
		}
		daText.screenCenter();
	}

	function save()
	{
		for (i in 0...keys.length)
		{
			Reflect.setField(FlxG.save.data, keys[i] + "Bind", keyBinds[i]);
			trace(Reflect.getProperty(FlxG.save.data, keys[i] + "Bind"));
		}
		FlxG.save.flush();
		PlayerSettings.player1.controls.loadKeybinds();
	}

	function quit()
	{
		save();
		close();
	}

	function addKey(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = [];

		for (x in keys)
		{
			if (x != tempKey)
			{
				notAllowed.push(x);
			}
		}

		for (x in blacklist)
		{
			notAllowed.push(x);
		}

		if (curSelected != 4)
		{
			for (x in keys)
			{
				if (x != keys[curSelected])
				{
					notAllowed.push(x);
				}
			}
		}
		else
		{
			for (x in keys)
			{
				notAllowed.push(x);
			}
		}

		trace(notAllowed);

		for (x in 0...keys.length)
		{
			var oK = keys[x];
			if (oK == r)
				keyBinds[x] = null;
		}

		if (shouldReturn)
		{
			keyBinds[curSelected] = r;
			trace("elpepe");
		}
		else
		{
			keyBinds[curSelected] = tempKey;
			FlxG.sound.play(Paths.sound("cancelMenu"), 1, false);
		}

		changeItem(0);
	}

	override public function create()
	{
		bgTint = new FlxSprite();
		bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgTint.alpha = 0;
		add(bgTint);
		FlxTween.tween(bgTint, {alpha: 0.7}, 0.4);

		daText = new FlxText(0, 180, FlxG.width, "", 28);
		daText.setFormat('VCR OSD Mono', 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		daText.borderSize = 2.5;
		daText.borderQuality = 3;
		add(daText);

		textUpdate();

		pressAKey.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pressAKey.text = "Press a key to change the control.";
		pressAKey.borderSize = 2;
		pressAKey.alpha = 0;
		pressAKey.scrollFactor.set();
		pressAKey.antialiasing = true;
		add(pressAKey);

		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override public function update(elapsed:Float)
	{
		if (currentState != 'changing')
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxTween.tween(bgTint, {alpha: 0.0}, 0.4, {onComplete: endCallback});
			}
			super.update(elapsed);

			if (controls.UP_P || FlxG.keys.justPressed.UP)
			{
				changeItem(-1);
			}

			if (controls.DOWN_P || FlxG.keys.justPressed.DOWN)
			{
				changeItem(1);
			}

			if (curSelected < 0)
			{
				curSelected = keys.length - 1;
			}
			if (curSelected > keys.length - 1)
			{
				curSelected = 0;
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				new FlxTimer().start(0.0, function(tmr:FlxTimer)
				{
					currentState = "input";
				});
			}
			pressAKey.alpha = 0;
		}

		if (currentState == 'waiting')
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				keyBinds[curSelected] = tempKey;
				currentState = "selecting";
				FlxG.sound.play(Paths.sound("cancelMenu"), 1, false);
			}
			else if (FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.UP && !FlxG.keys.justPressed.DOWN && !FlxG.keys.justPressed.LEFT
				&& !FlxG.keys.justPressed.RIGHT)
			{
				addKey(FlxG.keys.getIsDown()[0].ID.toString());
				save();
				currentState = "select";
			}
			pressAKey.alpha = 1;
		}

		switch (currentState)
		{
			case "input":
				tempKey = keyBinds[curSelected];
				keyBinds[curSelected] = "?";
				currentState = "waiting";
		}
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		textUpdate();
	}
}
