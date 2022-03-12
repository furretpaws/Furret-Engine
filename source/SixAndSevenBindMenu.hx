package;

import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import flixel.util.FlxTimer;


using StringTools;

class SixAndSevenBindMenu extends MusicBeatState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var warningColorTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "UP", "RIGHT", "CENTER", "LEFT", "DOWN", "RIGHT"];
    var defaultKeys:Array<String> = ["S", "D", "F", FlxKey.SPACE, "J", "K", "L"];
    var curSelected:Int = 0;

    var keys:Array<String> = [FlxG.save.data.mania6LeftBind,
                              FlxG.save.data.mania6UpBind,
                              FlxG.save.data.mania6RightBind,
                              FlxG.save.data.maniaCenterBind,
                              FlxG.save.data.mania6Left2Bind,
                              FlxG.save.data.mania6DownBind,
                              FlxG.save.data.mania6Right2Bind];

    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE"];

    var state:String = "select";

    var menuBG:FlxSprite;

    var camFollow:FlxObject;

    private var grpControls:FlxTypedGroup<Alphabet>;
    private var grpControls2:FlxTypedGroup<Alphabet>;
    private var lables:FlxTypedGroup<Alphabet>;
    private var normalTexts:FlxTypedGroup<FlxText>;

    var blackBG:FlxSprite;
    var rebindBG:FlxSprite;
    var rebindText:Alphabet;
    var rebindText2:Alphabet;

	override function create()
	{	

        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }
	
		

		persistentUpdate = persistentDraw = true;

		menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
        menuBG.scrollFactor.x = 0;
        menuBG.scrollFactor.y = 0.18;
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);
        camFollow.screenCenter(X);

        /*keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(Paths.font("vcr.ttf"), 54, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 1;
		
        add(keyTextDisplay);*/

        normalTexts = new FlxTypedGroup<FlxText>();
        add(normalTexts);

        var txt:FlxText = new FlxText(0, -10, FlxG.width, "6 and 7 keys - Press F1 to switch.", 32);
        txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter(X);
        normalTexts.add(txt);

        grpControls = new FlxTypedGroup<Alphabet>();
        add(grpControls);
        grpControls2 = new FlxTypedGroup<Alphabet>();
        add(grpControls2);
        lables = new FlxTypedGroup<Alphabet>();
        add(lables);
        
        var controlLabel:Alphabet = new Alphabet(0, 40, "NOTES", true, false);
        controlLabel.screenCenter(X);
        lables.add(controlLabel);

        for (i in 0...5)
        {
            var ctrl:Alphabet = new Alphabet(0, (70 * i) + 110, "", true, false);
            ctrl.ID = i;
            ctrl.screenCenter(X);
            grpControls.add(ctrl);

            var ctrl2:Alphabet = new Alphabet(0, (70 * i) + 110, "", false, false);
            ctrl2.ID = i;
            ctrl2.screenCenter(X);
            grpControls2.add(ctrl2);
        }



        blackBG = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF000000);
        blackBG.alpha = 0.5;
        blackBG.screenCenter();
        add(blackBG);
        blackBG.visible = false;

        rebindBG = new FlxSprite(0, 100).makeGraphic(Std.int(FlxG.width * 0.85), 520, 0xFFFAFD6D);
        rebindBG.screenCenter(X);
        rebindBG.scrollFactor.set(0, 0);
        add(rebindBG);
        rebindBG.visible = false;
        //"\nPress any key to rebind\n\n\n\n    Escape to cancel"
        rebindText = new Alphabet(0, 185, "Press any key to rebind", true, false);
        rebindText.screenCenter(X);
        rebindText.scrollFactor.set(0, 0);
        add(rebindText);
        rebindText.visible = false;

        rebindText2 = new Alphabet(0, 500, "Escape to cancel", true, false);
        rebindText2.screenCenter(X);
        rebindText2.scrollFactor.set(0, 0);
        add(rebindText2);
        rebindText2.visible = false;

        


        keyWarning = new FlxText(0, 580, 1280, "WARNING:TRY ANOTHER KEY", 42);
		keyWarning.scrollFactor.set(0, 0);
		keyWarning.setFormat(Paths.font("vcr.ttf"), 54, FlxColor.RED + FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        keyWarning.borderSize = 3;
		keyWarning.borderQuality = 1;
        keyWarning.screenCenter(X);
        keyWarning.alpha = 0;
        add(keyWarning);
        

		

        warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0);
        warningColorTween = FlxTween.tween(menuBG, {color: 0xFFea71fd}, 0);

        textUpdate();
        changeItem(0);

        FlxG.camera.follow(camFollow, null, 0.06);
		super.create();
	}

	override function update(elapsed:Float)
	{
        if (FlxG.keys.justPressed.F1)
        {
            LoadingState.loadAndSwitchState(new EightAndNineBindMenu());
        }

        FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);
        

        switch(state){

            case "select":
                blackBG.visible = false;
                rebindBG.visible = false;
                rebindText.visible = false;
                rebindText2.visible = false;
                if (FlxG.keys.justPressed.UP)
				{
					
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					
					changeItem(1);
				}

                if (FlxG.keys.justPressed.ENTER){
                    FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
                   
                    state = "input";
                    
                    
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    quit();
                }
				else if (FlxG.keys.justPressed.BACKSPACE){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    reset();
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                state = "waiting";

            case "waiting":
                blackBG.visible = true;
                rebindBG.visible = true;
                rebindText.visible = true;
                rebindText2.visible = true;
                if(FlxG.keys.justPressed.ESCAPE){
                    keys[curSelected] = tempKey;
                    state = "select";
                    FlxG.sound.play(Paths.sound("cancelMenu"), 1, false);
                }
                else if(FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.UP && !FlxG.keys.justPressed.DOWN && !FlxG.keys.justPressed.LEFT && !FlxG.keys.justPressed.RIGHT){
                    addKey(FlxG.keys.getIsDown()[0].ID.toString());
                    save();
                    state = "select";
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.UP && !FlxG.keys.justPressed.DOWN && !FlxG.keys.justPressed.LEFT && !FlxG.keys.justPressed.RIGHT){
			textUpdate();
             
        }

		super.update(elapsed);
		
	}

    public function textUpdate(){

        

        for(i in 0...7)
        {

            //keyTextDisplay.text += textStart + keyText[i];
            grpControls.remove(grpControls.members[i]);
            var ctrl:Alphabet = new Alphabet(0, (70 * i) + 140, keyText[i], true, false);
            ctrl.ID = i;
            ctrl.screenCenter(X);
            ctrl.x = 200;
            grpControls.add(ctrl);

            grpControls2.remove(grpControls2.members[i]);
            var ctrl2:Alphabet = new Alphabet(0, (70 * i) + 110, (keys[i] != null ? keys[i] : "NOTHING"), false, false);
            ctrl2.ID = i;
            ctrl2.screenCenter(X);
            grpControls2.add(ctrl2);

            changeItem(0);
            
        }

        //keyTextDisplay.screenCenter();

        

    }

    public function save(){

        FlxG.save.data.mania6LeftBind = keys[0];
        FlxG.save.data.mania6UpBind = keys[1];
        FlxG.save.data.mania6RightBind = keys[2];
        FlxG.save.data.maniaCenterBind = keys[3];
        FlxG.save.data.mania6Left2Bind = keys[4];
        FlxG.save.data.mania6DownBind = keys[5];
        FlxG.save.data.mania6Right2Bind = keys[6];

        FlxG.save.flush();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    public function reset(){

        for(i in 0...8){
            keys[i] = defaultKeys[i];
        }
        quit();

    }

    public function quit(){

        state = "exiting";

        save();

        FlxG.switchState(new OptionsMenu());

    }

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in keys){
            if(x != tempKey){notAllowed.push(x);}
        }

        for(x in blacklist){notAllowed.push(x);}

        if(curSelected != 4){

            for(x in keyText){
                if(x != keyText[curSelected]){notAllowed.push(x);}
            }
            
        }
        else {for(x in keyText){notAllowed.push(x);}}

        trace(notAllowed);

        for(x in 0...keys.length)
            {
                var oK = keys[x];
                if(oK == r)
                    keys[x] = null;
            }
        

        if(shouldReturn){
            keys[curSelected] = r;
            trace("elpepe");
        }
        else{
            keys[curSelected] = tempKey;
            FlxG.sound.play(Paths.sound("cancelMenu"), 1, false);
            
        }
        
        changeItem(0);
	} 

    public function changeItem(_amount:Int = 0)
    {
        trace("elpepe");

        curSelected += _amount;

        if (curSelected < 0)
            curSelected = grpControls.length - 1;
        if (curSelected >= grpControls.length)
            curSelected = 0;

        var bullShit:Int = 0;

        
        camFollow.y = grpControls.members[curSelected].getGraphicMidpoint().y + 70;
        
        

        for (item in grpControls.members)
        {
            if(item.ID != curSelected)
                item.alpha = 0.6;
            if(item.ID == curSelected)
                item.alpha = 1;
        }
        for (item in grpControls2.members)
        {
            if(item.ID != curSelected)
                item.alpha = 0.6;
            if(item.ID == curSelected)
                item.alpha = 1;
        }
    }
}