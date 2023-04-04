package modutil; //we ain't using polymod :sunglasses:

import lime.media.openal.ALSource;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flash.system.System;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

class ModLoaderState extends MusicBeatState
{
    var oopsieText:FlxText;
    var bg:FlxSprite;
    var doesExist:Bool;
    var modsLength:Int;
    var modsArray:Array<Mod> = [];
    var description:FlxText;
    var curSelected:Int;
    var enableButton:FlxButton;
    var disableButton:FlxButton;
    var restartRequired:Bool = false;
    var newModButton:FlxText;

    private var grpMods:FlxTypedGroup<Alphabet>;
    override public function create()
    {
        FlxG.mouse.visible = true;
        if (FlxG.save.data.modsLoaded == null)
        {
            FlxG.save.data.modsLoaded = [];
        }

        bg = new FlxSprite().loadGraphic("assets/images/menuDesat.png");
		bg.antialiasing = true;
		bg.color = 0x1C0D53;
		add(bg);

        enableButton = new FlxButton(1075, 70, "Enable", function() {
            if (!FlxG.save.data.modsLoaded.contains(modsArray[curSelected].folderName))
            {
                FlxG.save.data.modsLoaded.push(modsArray[curSelected].folderName);
            }
            for (i in 0...grpMods.members[curSelected].length)
            {
                grpMods.members[curSelected].color = FlxColor.LIME;
            }
            trace(FlxG.save.data.modsLoaded);
            restartRequired = true;
        });
        enableButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        enableButton.setGraphicSize(170, 50);
		enableButton.updateHitbox();
        enableButton.label.fieldWidth = 170;
        enableButton.color = FlxColor.GREEN;
        for (point in enableButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(enableButton);

        disableButton = new FlxButton(1075, 140, "Disable", function() {
            if (FlxG.save.data.modsLoaded.contains(modsArray[curSelected].folderName))
            {
                FlxG.save.data.modsLoaded.remove(modsArray[curSelected].folderName);
            }
            for (i in 0...grpMods.members[curSelected].length)
            {
                grpMods.members[curSelected].color = FlxColor.WHITE;
            }
            trace(FlxG.save.data.modsLoaded);
            restartRequired = true;
        });
        disableButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        disableButton.setGraphicSize(170, 50);
		disableButton.updateHitbox();
        disableButton.label.fieldWidth = 170;
        disableButton.color = FlxColor.RED;
        for (point in disableButton.labelOffsets)
        {
            point.set(0, 10);
        }
        add(disableButton);

        oopsieText = new FlxText(0, 0, FlxG.width);
        oopsieText.text = "Error!\nIt seems that the mods directory does not exist. If this is the case, create a new folder named \"mods\" (It has to be in the root folder of the game!)\n\nPress ESCAPE to go back";
        oopsieText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        oopsieText.screenCenter(Y);
        oopsieText.borderSize = 2;

        description = new FlxText();
		description.fieldWidth = 1150; //idk if this will work
		description.y = 615;
		description.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);

        doesExist = EngineFunctions.exists("mods/");
        trace(doesExist);
        if (doesExist)
        {
            for (i in 0...EngineFunctions.readDirectory("mods/").length)
            {
                if (EngineFunctions.isDirectory("mods/" + EngineFunctions.readDirectory("mods/")[i]))
                {
                    modsLength++;
                    modsArray.push(new Mod(EngineFunctions.readDirectory("mods/")[i]));
                }
            }
            trace(modsLength != 0);
            if (modsLength != 0)
            {
                grpMods = new FlxTypedGroup<Alphabet>();
		        add(grpMods);
                for (i in 0...modsArray.length) {
                    var modText:Alphabet = new Alphabet(0, (70 * i) + 30, modsArray[i].name, false, false, true);
                    for (i in 0...FlxG.save.data.modsLoaded.length)
                    {
                        if (FlxG.save.data.modsLoaded.contains(modsArray[i].folderName))
                        {
                            for (i in 0...modText.members.length)
                            {
                                modText.members[i].color = FlxColor.LIME;
                            }
                        }
                    }
                    if (modsArray[i].damaged)
                    {
                        for (i in 0...modText.members.length)
                        {
                            modText.members[i].color = FlxColor.RED;
                        }
                    }
			        modText.isMenuItem = true;
			        modText.targetY = i;
			        grpMods.add(modText);
                }
                var upperBlackThing:FlxSprite;
                upperBlackThing = new FlxSprite(0, 0);
                upperBlackThing.makeGraphic(1280, 50);
                upperBlackThing.color = FlxColor.BLACK;
                upperBlackThing.alpha = 0.3;
                add(upperBlackThing);

                /*var lowerBlackThing:FlxSprite;
                lowerBlackThing = new FlxSprite(0);
                lowerBlackThing.x = 1;
                lowerBlackThing.y = 670;
                lowerBlackThing.makeGraphic(1280, 50);
                lowerBlackThing.alpha = 0.3;
                lowerBlackThing.color = FlxColor.BLACK;
                add(lowerBlackThing);*/

                var modsText:FlxText;
                modsText = new FlxText(0, 8);
                modsText.text = "Mods";
                modsText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                modsText.screenCenter(X);
                modsText.borderSize = 2;
                add(modsText);

                newModButton = new FlxText (1200, 0.6);
                newModButton.text = "+";
                newModButton.setFormat("assets/fonts/vcr.ttf", 48, FlxColor.GRAY, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                newModButton.borderSize = 2;
                add(newModButton);

                /*var reminder:FlxText;
                reminder = new FlxText(12, 675);
                reminder.text = "Press ENTER/SPACE for more information, or press ESCAPE to exit";
                reminder.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                reminder.screenCenter(X);
                reminder.borderSize = 2;
                add(reminder);*/

                changeSelection();
                add(description);
            }
            else
            {
                doesExist = false;
                oopsieText.text = "You have no mods installed. Add some mods in the mods folder. Or, you can even make your own mod! Check the zip file for more information.\n\nPress ESCAPE to go back";
                add(oopsieText);
                remove(enableButton);
                remove(disableButton);
            }
        }
        else
        {
            add(oopsieText);
        }
        super.create();
    }

    function changeSelection(change:Int = 0)
    {
        // NGio.logEvent('Fresh');
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if (curSelected < 0)
            curSelected = modsArray.length - 1;
        if (curSelected >= modsArray.length)
            curSelected = 0;

        // selector.y = (70 * curSelected) + 30;

        /*#if PRELOAD_ALL
        FlxG.sound.playMusic(flash.media.Sound.fromFile("assets/songs/" + songs[curSelected].songName + "/Inst.ogg"), 0);
        #end*/

        var bullShit:Int = 0;

        for (item in grpMods.members)
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

    override public function update(elapsed:Float)
    {
        if (doesExist) {
            if (controls.DOWN_P) {
                changeSelection(1);
            }
            
            if (controls.UP_P) {
                changeSelection(-1);
            }
    
            if (controls.BACK)
            {
                FlxG.save.flush();
                if (restartRequired) {
                    @:privateAccess
                    TitleState.initialized = false;
                    FlxG.sound.music.stop();
                    FlxG.camera.fade(FlxColor.BLACK, 0.5, false, () -> {
                        System.exit(0);
                    }, false);
                } else {
                    FlxG.switchState(new MainMenuState());
                    FlxG.mouse.visible = false;
                }
            }
    
            /*if (FlxG.keys.justPressed.SPACE) {
                openSubState(new ModViewer(modsArray[curSelected]));
            }*/
    
            if (doesExist) {
                description.text = modsArray[curSelected].description;
            }

            if (FlxG.mouse.overlaps(newModButton)) {
                newModButton.color = FlxColor.WHITE;
                if (FlxG.mouse.pressed) {
                    trace("Send bro to the mod editor");
                }
            }
            else {
                newModButton.color = FlxColor.GRAY;
            }
        }
        else
        {
            if (controls.BACK)
            {
                FlxG.switchState(new MainMenuState());
            }
        }
        super.update(elapsed);
    }
}

/*class ModViewer extends MusicBeatSubstate {
    var bgTint:FlxSprite;
    var bigBlock:FlxSprite;
    var modTitle:Alphabet;
    var description:FlxText;
    var daButton:FlxButton;
    var mod:Mod;
    public function new(m:Mod) {
        this.mod = m;
        super();
    }
    override public function create() {
        bgTint = new FlxSprite();
        bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgTint.alpha = 0.6;
        add(bgTint);

        modTitle = new Alphabet(0, 35, mod.name, true, false);
        modTitle.screenCenter(X);
        add(modTitle);

        description = new FlxText();
		description.fieldWidth = 1150; //idk if this will work
		description.y = 150;
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
        description.text = mod.description;
		add(description);

        super.create();
    }

    override public function update(elapsed:Float) {
        if (controls.BACK) {
            close();
        }
        super.update(elapsed);
    }
}*/

class Mod {
    public var folderName:String;
    public var name:String;
    public var description:String;
    public var damaged:Bool;
    public var json:Dynamic;
    public var ignore:Bool;
    public var damageCause:String;
    public function new(folderName:String) {
        this.folderName = folderName;
        if (!EngineFunctions.exists("mods/" + folderName))
        {
            damaged = true;
            ignore = true;
            this.folderName = folderName;
            this.name = null;
            this.description = null;
            this.json = null;
            this.damageCause = "The folder you've selected does not exist.";
        }
        else
        {
            if (!EngineFunctions.exists("mods/" + folderName + "/mod.json")) {
                damaged = true;
                ignore = false;
                this.folderName = folderName;
                this.name = folderName;
                this.description = null;
                this.json = null;
                this.damageCause = "There is no JSON file for this mod.";
            }
            else {
                var givenException:Bool = false;
                try {
                    this.json = haxe.Json.parse(EngineFunctions.getContent("mods/" + folderName + "/mod.json"));
                } catch (err) {
                    trace("Exception catched");
                    damaged = true;
                    this.name = folderName;
                    this.description = "This JSON file is damaged or malformed. / Exception: " + err.message;
                    this.json = null;
                    this.damageCause = "This JSON file is damaged or malformed. / Exception: " + err.message;
                    givenException = true;
                }
                if (!givenException) {
                    this.name = this.json.name;
                    this.description = this.json.description;
                }
            }
        }
    }
}