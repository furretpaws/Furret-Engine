package customization;

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

class EditorGateway extends MusicBeatState
{
	var bg:FlxSprite;
	var optionList:Array<String> = ['Stage editor', 'Character editor', 'Mods', 'Multiplayer Mode'];
	var curSelected:Int = 0; // isn't that obvious?
	var chosesoncemeting:FlxText;
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
			optionsGroup.members[optionsGroup.length-1].alpha = 1;
			trace(optionsGroup.length-1);
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
		bg.color = 0xff424242;
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

		chosesoncemeting = new FlxText();
		chosesoncemeting.text = "Choose an option. Press ESCAPE to quit to the main menu.";
		chosesoncemeting.fieldWidth = 1150; //idk if this will work
		chosesoncemeting.y = 640;
		chosesoncemeting.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		chosesoncemeting.screenCenter(X);
		add(chosesoncemeting);

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
					FlxG.switchState(new customization.StageEditor());
				case 1:
					FlxG.switchState(new customization.CustomizeGameplay());
				case 2:
					FlxG.switchState(new modutil.ModLoaderState());
				case 3:
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					FlxG.switchState(new multiplayer.MultiplayerState());
			}
		}
	}
}