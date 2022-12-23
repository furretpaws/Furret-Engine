package customization; //inspired on Tr1Ngle Engine, it was stolen in other versions (now i made my own), i'm so sorry Tr1NgleBoss :( | THIS IS UNUSED AND SCRAPPED!

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import Alphabet;

class CustomControls extends MusicBeatState
{
    var bg:FlxSprite;

    var curSelected:Int = 0;

    var curState:String = "changing controls";

    var titleText:Alphabet;

    var controlTypes:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; //pene -isa
    var controlTypesSaved:Array<Dynamic> = [FlxG.save.data.LEFTBind, FlxG.save.data.DOWNBind, FlxG.save.data.UPBind, FlxG.save.data.RIGHTBind];

    var controlTextGroup:FlxTypedGroup<FlxText>;
    var controlAlphabetGroup:FlxTypedGroup<Alphabet>;

    var kindOfASubStateBG:FlxSprite;

    var selectControlBG:FlxSprite;

    override function create()
    {
        bg = new FlxSprite().loadGraphic(Paths.image("menuBG"));
	    bg.setGraphicSize(Std.int(bg.width * 1.1));
	    bg.updateHitbox();
	    bg.scrollFactor.x = 0;
        bg.scrollFactor.y = 0.18;
	    bg.screenCenter();
	    bg.antialiasing = true;
	    add(bg);

        titleText = new Alphabet(0, 100, "CONTROLS", true, false);
        add(titleText);
        titleText.screenCenter(X);

        controlTextGroup = new FlxTypedGroup<FlxText>();
        add(controlTextGroup);

        controlAlphabetGroup = new FlxTypedGroup<Alphabet>();
        add(controlAlphabetGroup);

        for (i in 0...controlTypes.length)
        {
            var daControlLabel:FlxText;
            daControlLabel = new FlxText(350, 100 * i);
            daControlLabel.text = controlTypes[i];
            daControlLabel.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
            daControlLabel.borderSize = 2;
            daControlLabel.antialiasing = true;
            controlTextGroup.add(daControlLabel);
        }

        for (i in 0...controlTypes.length)
        {
            var alphabet:Alphabet;
            alphabet = new Alphabet(-20, controlTextGroup.members[i].y + 158, controlTypesSaved[i], false, false);
            alphabet.antialiasing = true;
            alphabet.scale.set(0.5, 0.5);
            controlAlphabetGroup.add(alphabet);
        }

        for (i in 0...controlTypes.length)
        {
            controlTextGroup.members[i].y += 225;
            controlAlphabetGroup.members[i].x += 570;
        }
        controlAlphabetGroup.members[0].alpha = 1;
        controlAlphabetGroup.members[1].alpha = 0.5;
        controlAlphabetGroup.members[2].alpha = 0.5;
        controlAlphabetGroup.members[3].alpha = 0.5;

        kindOfASubStateBG = new FlxSprite();
        kindOfASubStateBG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        kindOfASubStateBG.alpha = 0.5;
        kindOfASubStateBG.visible = false;
        add(kindOfASubStateBG);

        selectControlBG = new FlxSprite();
        selectControlBG.makeGraphic(250, 250, FlxColor.BLACK);
        selectControlBG.x = FlxG.width / 2 - selectControlBG.width / 2;
        selectControlBG.y = FlxG.height / 2 - selectControlBG.height / 2;
        selectControlBG.alpha = 0.5;
        selectControlBG.visible = false;
        add(selectControlBG);
    }

    function changeSelection(amount:Int)
    {
        if (curState == 'changing controls')
        {
            curSelected += amount;
            switch(curSelected)
            {
                case 0:
                    controlAlphabetGroup.members[0].alpha = 1;
                    controlAlphabetGroup.members[1].alpha = 0.5;
                    controlAlphabetGroup.members[2].alpha = 0.5;
                    controlAlphabetGroup.members[3].alpha = 0.5;
                case 1:
                     controlAlphabetGroup.members[0].alpha = 0.5;
                     controlAlphabetGroup.members[1].alpha = 1;
                     controlAlphabetGroup.members[2].alpha = 0.5;
                     controlAlphabetGroup.members[3].alpha = 0.5;
                case 2:
                    controlAlphabetGroup.members[0].alpha = 0.5;
                    controlAlphabetGroup.members[1].alpha = 0.5;
                    controlAlphabetGroup.members[2].alpha = 1;
                    controlAlphabetGroup.members[3].alpha = 0.5;
                case 3:
                    controlAlphabetGroup.members[0].alpha = 0.5;
                    controlAlphabetGroup.members[1].alpha = 0.5;
                    controlAlphabetGroup.members[2].alpha = 0.5;
                    controlAlphabetGroup.members[3].alpha = 1;
            }
            if (curSelected > 5)
            {
                curSelected = 4; //don't move
            }
            if (curSelected < 0)
            {
                curSelected = 0; //same, don't move from there
            }
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
    }

    function changeControl(?sel:Int, ?quit:Bool)
    {
        if (sel != null && quit == null)
        {
            curState == 'choosing a control';
            kindOfASubStateBG.visible = true;
        }
        else
        {
            trace("quitted");
        }
    }

    override function update(elapsed:Float)
    {
        if (curState == 'changing controls')
        {
            if (controls.BACK)
            {
                FlxG.switchState(new OptionsMenu());
            }
        }
        else if (curState == 'choosing a control')
        {
            if (controls.BACK)
            {
                FlxG.switchState(new OptionsMenu());
            }
        }

        if (curState.toLowerCase() == "changing controls")
        {
            if (controls.UP_P)
            {
                changeSelection(-1);
            }
            if (controls.DOWN_P)
            {
                changeSelection(1);
            }
            if (FlxG.keys.justPressed.ENTER)
            {
                changeControl(curSelected);
            }
        }
    }
}   