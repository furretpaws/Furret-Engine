package;

import Alphabet;
import flixel.FlxSprite;
import flixel.tweens.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class GameplayChangersSubstate extends MusicBeatSubstate {
    var state:String = "";
    var pitch:Float = 1;
    var bgTint:FlxSprite;
    var optionsmenutitle:FlxText;
    var warningPitch:FlxText;
    var pitchAmountText:FlxText;
	var descriptions:Array<String> = [];
	var options:Array<String> = [];
	var optionValues:Array<Bool> = [];
	var curSelected:Int = 0;
	var typedGroupCheck:FlxTypedGroup<Checkbox> = new FlxTypedGroup<Checkbox>();
	var typedGroupTexts:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var offset:Int = 0;
	var description:FlxText;
    public function new(s:String) { s = this.state; super();}
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

        var checked:Bool = false;
        if (state == "da freeeeeeeeplay oh ma god")
        {
            checked = Reflect.getProperty(FreeplayState, optionName);
        }
        else
        {
            checked = Reflect.getProperty(StoryMenuState, optionName);
        }
        optionValues.push(checked);
        options.push(optionName);

        var checkboxthing:Checkbox = new Checkbox(checked, initCheckXY[0], initCheckXY[1] + offset);
        typedGroupCheck.add(checkboxthing);

        offset += 65;
        trace("added");
    }

    override public function create() {
        bgTint = new FlxSprite();
	    bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	    bgTint.alpha = 0;
	    add(bgTint);
	    FlxTween.tween(bgTint, {alpha: 0.7}, 0.4, {onComplete: (_) -> {
            add(optionsmenutitle);
		    add(typedGroupCheck);
		    add(typedGroupTexts);
            add(description);
            add(pitchAmountText);
            add(warningPitch);
        }});

        optionsmenutitle = new FlxText();
		optionsmenutitle.text = "Gameplay Changers Menu";
		optionsmenutitle.x = 0;
		optionsmenutitle.y = 66;
		optionsmenutitle.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionsmenutitle.screenCenter(X);
		optionsmenutitle.updateHitbox();

        pitchAmountText = new FlxText();
        pitchAmountText.text = Std.string(Std.int(pitch)) + " ";
		pitchAmountText.x = 0;
		pitchAmountText.y = 500;
        pitchAmountText.alpha = 0;
		pitchAmountText.setFormat("assets/fonts/vcr.ttf", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        pitchAmountText.screenCenter(X);
		pitchAmountText.updateHitbox();

        warningPitch = new FlxText();
        warningPitch.text = "[!] This will probably break most of the things from the song.";
		warningPitch.x = 0;
		warningPitch.y = 550;
        warningPitch.alpha = 0;
		warningPitch.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        warningPitch.screenCenter(X);
		warningPitch.updateHitbox();

		description = new FlxText();
		description.fieldWidth = 1150; //idk if this will work
		description.y = 640;
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);

        addOption("No death", "If checked, the player won't die when it's health goes to 0", "bool", "pitch");
        addOption("Play as opponent", "If checked, you'll play as the opponent", "bool", "pitch");
        addOption("Change rate", "Change the rate speed of the game (Press LEFT or RIGHT keybinds to change it", "bool", "pitch");
        
        description.text = descriptions[curSelected];

		for (i in 0...typedGroupTexts.length)
		{
			typedGroupTexts.members[i].x += -230;
		}

        trace(typedGroupCheck.length);
        typedGroupCheck.members[2].visible = false;
        typedGroupTexts.members[2].x -= 72;

		offset = 0;
		super.create();
		updateOptions();
    }

    function doNothing():Void
    {
        // do nothing dumbass
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

    function check():Void
    {
        if (curSelected != 2)
        {
            optionValues[curSelected] = !optionValues[curSelected];
            if (curSelected == 0)
            {
                FreeplayState.noDeath = optionValues[curSelected];
            }
            if (curSelected == 1)
            {
                FreeplayState.singAsOpponent = optionValues[curSelected];
            }
            typedGroupCheck.members[curSelected].changeCheck();
            trace(optionValues);
        }
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
            FreeplayState.pitch = this.pitch;
            FlxTween.tween(bgTint, {alpha: 0}, 0.4, {onComplete: (_) -> {
                close();
            }});
        }
    }

    override public function update(elapsed:Float) {
        control();
        if (curSelected == 2)
        {
            if (controls.LEFT_P)
            {
                pitch -= 0.1;
            }

            if (controls.RIGHT_P)
            {
                pitch += 0.1;
            }
            FlxTween.tween(pitchAmountText, {alpha: 1}, 0.1);
        }
        else
        {
            FlxTween.tween(pitchAmountText, {alpha: 0}, 0.1);
        }

        if (pitch != 1.0 || pitch != 1)
        {
            FlxTween.tween(warningPitch, {alpha: 1}, 0.7);
        }
        else
        {
            FlxTween.tween(warningPitch, {alpha: 0}, 0.7);
        }

        if (pitch < 0.5)
        {
            pitch = 0.5;
        }
        if (pitch > 2)
        {
            pitch = 2;
        }
        FlxG.sound.music.pitch = pitch;
        pitchAmountText.text = "> " + pitch + " <";
        pitchAmountText.screenCenter(X);
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