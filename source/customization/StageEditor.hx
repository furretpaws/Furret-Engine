package customization;

//coded by furret ! !

//i am actually proud of this

import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import Discord.DiscordClient;
import flixel.FlxObject;
import openfl.sensors.Accelerometer;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class StageEditor extends MusicBeatState
{
    var camHUD:FlxCamera;
	var boyfriendX:FlxText;
	var boyfriendY:FlxText;
	var dadSelected:Bool = false;
	var bfSelected:Bool = false;
	var gfSelected:Bool = false;
	var gfX:FlxText;
	var gfY:FlxText;
	var camStage:FlxCamera;
	var camMenu:FlxCamera;
	var loadedAssets:FlxTypedGroup<FlxSprite>;
	var camMove:Int = 500;
	var camFollow:FlxObject;
	var boyfriend:Character;
	var gf:Character;
	var UI_box:FlxUITabMenu;
	var curStage:String = 'stage';
	var spritesLabel:FlxText;
	var boyfriendLabel:FlxText;
	var modifyBoyfriend:FlxButton;
	var objectsLoaded:FlxText;
	var gfLabel:FlxText;
	var dadX:FlxText;
	var dadY:FlxText;
	var dad:Character;
	var curSelected:Int = 0;
	var mouseIsOnAFlxUI:Bool = false;
	var currentlySelectingSomething:Bool = false;
	var objectMoving:Bool = false;

	var DisableObjectMoving:FlxUICheckBox;

	var spriteSelectionThing:FlxUINumericStepper;

	var objectSelected:Bool = false;

	var typingShit:FlxInputText;

	var sprites_UI:FlxUI;

	var UI_tools:FlxUITabMenu;

	var DisableCharacterMoving:FlxUICheckBox;

	var uiToolsFlxUI:FlxUI;

	var characterMoving:Bool = true;

	var script:Dynamic = ''; //wish me luck.
	
    override public function create()
    {
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
		}
		
		camStage = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camStage);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camMenu, false);

		FlxCamera.defaultCameras = [camStage];

		FlxG.mouse.visible = true;
		Conductor.changeBPM(180);
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		DiscordClient.changePresence("Editing a stage", "Stage: " + curStage, null);

		loadedAssets = new FlxTypedGroup<FlxSprite>();
		add(loadedAssets);

        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
		bg.antialiasing = true;
		bg.scrollFactor.set();
		bg.active = false;
		loadedAssets.add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set();
		stageFront.active = false;
		loadedAssets.add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set();
		stageCurtains.active = false;
		loadedAssets.add(stageCurtains);

		trace(stageCurtains.graphic.key);

		add(stageCurtains);

		gf = new Character(343, 74, "gf", false);
		gf.cameras = [camStage];
		add(gf);

		boyfriend = new Character(836, 387, "bf", false);
		boyfriend.playAnim("idle", true);
		boyfriend.flipX = false;
		boyfriend.cameras = [camStage];
		add(boyfriend);

		dad = new Character(140, 23, "dad", false);

		dad.playAnim("idle", true);
		dad.cameras = [camStage];
		add(dad);

		//UI

		var stageEditorTitle:FlxText = new FlxText(0, 20, FlxG.width);
		stageEditorTitle.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		stageEditorTitle.text = "Stage Editor";
		stageEditorTitle.borderSize = 2;
		stageEditorTitle.scrollFactor.set();
		stageEditorTitle.antialiasing = true;
		add(stageEditorTitle);
		stageEditorTitle.cameras = [camHUD];

		objectsLoaded = new FlxText(20, 20, FlxG.width);
		objectsLoaded.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		objectsLoaded.text = "Loaded objects: " + loadedAssets.length;
		objectsLoaded.scrollFactor.set();
		objectsLoaded.antialiasing = true;
		add(objectsLoaded);
		objectsLoaded.cameras = [camHUD];

		boyfriendX = new FlxText(0, 60, FlxG.width);
		boyfriendX.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		boyfriendX.text = "Boyfriend X: " + boyfriend.x;
		boyfriendX.borderSize = 2;
		boyfriendX.scrollFactor.set();
		boyfriendX.antialiasing = true;
		add(boyfriendX);
		boyfriendX.cameras = [camHUD];

		boyfriendY = new FlxText(0, 90, FlxG.width);
		boyfriendY.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		boyfriendY.text = "Boyfriend Y: " + boyfriend.y;
		boyfriendY.borderSize = 2;
		boyfriendY.scrollFactor.set();
		boyfriendY.antialiasing = true;
		add(boyfriendY);
		boyfriendY.cameras = [camHUD];

		gfX = new FlxText(0, 120, FlxG.width);
		gfX.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		gfX.text = "GF X: " + gf.x;
		gfX.borderSize = 2;
		gfX.scrollFactor.set();
		gfX.antialiasing = true;
		add(gfX);
		gfX.cameras = [camHUD];

		gfY = new FlxText(0, 150, FlxG.width);
		gfY.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		gfY.text = "GF Y: " + gf.y;
		gfY.borderSize = 2;
		gfY.scrollFactor.set();
		gfY.antialiasing = true;
		add(gfY);
		gfY.cameras = [camHUD];

		dadX = new FlxText(0, 180, FlxG.width);
		dadX.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		dadX.text = "Dad X: " + dad.y;
		dadX.borderSize = 2;
		dadX.scrollFactor.set();
		dadX.antialiasing = true;
		add(dadX);
		dadX.cameras = [camHUD];

		dadY = new FlxText(0, 210, FlxG.width);
		dadY.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		dadY.text = "Dad Y: " + dad.y;
		dadY.borderSize = 2;
		dadY.scrollFactor.set();
		dadY.antialiasing = true;
		add(dadY);
		dadY.cameras = [camHUD];

		var tabs = [
			{name: 'Sprites', label: 'Sprites'},
			{name: 'Stage', label: 'Stage'}
		];

		var tools_tabs = [
			{name: "Tools", label: "Tools"}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.x = 4;
		UI_box.y = 240;
		UI_box.resize(350, 450);
		UI_box.cameras = [camMenu];
		add(UI_box);

		UI_tools = new FlxUITabMenu(null, tools_tabs, true);
		UI_tools.x = 970;
		UI_tools.y = 500;
		UI_tools.resize(300, 200);
		UI_tools.cameras = [camMenu];
		add(UI_tools);

		//other stuff

		FlxG.camera.follow(camFollow, LOCKON, 1);

		FlxG.camera.zoom = 0.6;

		addSpritesUI();
		addToolsUI();

		super.create();
    }

	function addSpritesUI()
	{
		sprites_UI = new FlxUI(null, UI_box);
		spritesLabel = new FlxText(20, 20);
		spritesLabel.text = 'Sprites: ' + loadedAssets.length;
		spritesLabel.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		spritesLabel.antialiasing = true;
		sprites_UI.add(spritesLabel);
		
		sprites_UI.name = "Sprites";
 
		var addObjectButton:FlxButton;
		addObjectButton = new FlxButton(20, 60, "Add Sprite", function(){
			trace("THIS DOESN'T DO ANYTHING, REDO TIME!");
		});

		for (i in 0...loadedAssets.length)
		{
			var loadedAsset:FlxText = new FlxText(20, 100 + (i * 10));
			loadedAsset.size = 10;
			trace(loadedAssets.members[i].graphic.key);
			var split = loadedAssets.members[i].graphic.key.split("/");
			var key:String = null;
			for (i in 0...split.length)
			{
				if (split[i].endsWith(".png"))
				{
					var anotherFuckingSplit = split[i].split(".");
					key = anotherFuckingSplit[0];
				}
			}
			loadedAsset.text = (i + 1) + ". " + key + " (ID: " + i + ")";
			sprites_UI.add(loadedAsset);
		}
		sprites_UI.add(addObjectButton);

		UI_box.addGroup(sprites_UI);
	}

	function addToolsUI()
	{
		uiToolsFlxUI = new FlxUI(null, UI_tools);
		DisableCharacterMoving = new FlxUICheckBox(10, 10, null, null, "Disable Character Selection", 100, null, function()
		{
			if (!characterMoving)
			{
				characterMoving = true;
			}
			else
			{
				characterMoving = false;
			}
		});
		uiToolsFlxUI.name = 'Tools';
		uiToolsFlxUI.add(DisableCharacterMoving);
		uiToolsFlxUI.add(new FlxText(DisableCharacterMoving.x, DisableCharacterMoving.y + 20, 0, "Select Sprite to move"));

		spriteSelectionThing = new FlxUINumericStepper(DisableCharacterMoving.x, DisableCharacterMoving.y + 40, 1, 0, 0, loadedAssets.length - 1);

		uiToolsFlxUI.add(spriteSelectionThing);

		DisableObjectMoving = new FlxUICheckBox(DisableCharacterMoving.x + 170, DisableCharacterMoving.y, null, null, "Object Selection", 100, null);

		uiToolsFlxUI.add(DisableObjectMoving);

		UI_tools.addGroup(uiToolsFlxUI);
	}

	function reloadSpritesUI()
	{
		for (i in 0...sprites_UI.length)
		{
			sprites_UI.remove(sprites_UI.members[i]);
		}
		addSpritesUI();
	}

	function reloadToolsUI() //DOES NOT RELOAD IT ENTIRELY
	{
		for (i in 0...uiToolsFlxUI.length)
		{
			uiToolsFlxUI.remove(uiToolsFlxUI.members[i]);
		}
		addToolsUI();
	}
	
	public function addSprite(Sprite:String, ?scaleX:Float, ?scaleY:Float)
	{
		var objectToAdd:FlxSprite;
		objectToAdd = new FlxSprite(0, 0, "assets/images/" + Sprite + ".png");
		if (scaleX != null && scaleY != null)
		{
			objectToAdd.scale.set(scaleX, scaleY);
		}
		loadedAssets.add(objectToAdd);
		reloadSpritesUI();
	}

	function saveScript() //i want to cry
	{
		script = '//Auto-generated by Furret Engine ' + MainMenuState.furretEngineVer + "\n//DO NOT MODIFY THIS SCRIPT, OR ELSE IT WON'T BE READABLE FOR THE STAGE EDITOR!\n \n";

		for (i in 0...loadedAssets.length)
		{
			var split = loadedAssets.members[i].graphic.key.split("/");
			var key:String = null;
			for (i in 0...split.length)
			{
				if (split[i].endsWith(".png"))
				{
					var anotherFuckingSplit = split[i].split(".");
					key = anotherFuckingSplit[0];
				}
			}

			script += "var " + key + "_SPRITES = ['" + loadedAssets.members[i].graphic.key + "', " + loadedAssets.members[i].x + ", " + loadedAssets.members[i].y + "];" + "\n";
		}

		script += '\n//Please do not remove the values from above, you can add stuff like "boyfriend.alpha" or stuff like that, but please do not touch the upper values\n \n';

		script += 'setBfPosition(' + Math.floor(boyfriend.x) + ", " + Math.floor(boyfriend.y) + ");\n";
		script += 'setDadPosition(' + Math.floor(dad.x) + ", " + Math.floor(dad.y) + ");\n";
		script += 'setGfPosition(' + Math.floor(gf.x) + ", " + Math.floor(gf.y) + ");\n \n";

		for (i in 0...loadedAssets.length)
		{
			var split = loadedAssets.members[i].graphic.key.split("/");
			var key:String = null;
			for (i in 0...split.length)
			{
				if (split[i].endsWith(".png"))
				{
					var anotherFuckingSplit = split[i].split(".");
					key = anotherFuckingSplit[0];
				}
			}
			script += "var " + key + "_OBJECT = new FlxSprite();\n";
			script += key + "_OBJECT.x = " + key + "_SPRITES[1];\n";
			script += key + "_OBJECT.y = " + key + "_SPRITES[2];\n";
			script += key + "_OBJECT.loadGraphic(CoolUtil.getBitmap(" + key + "_SPRITES[0]" + "));\n";
			script += "add(" + key + "_OBJECT);\n\n";
		}

		script += "//End of script";

		#if sys
		File.saveContent("assets/images/stageData.hx", script);
		#end
	}

	override function update(elapsed:Float)
	{
		curSelected = Math.floor(spriteSelectionThing.value); //:cryingskull:

		if (FlxG.keys.justPressed.M)
		{
			saveScript();
		}

		objectMoving = DisableObjectMoving.checked;
		
		if (FlxG.mouse.overlaps(loadedAssets.members[curSelected]) && !mouseIsOnAFlxUI && objectMoving)
		{
			if (FlxG.mouse.pressed)
			{
				loadedAssets.members[curSelected].setPosition(FlxG.mouse.getPosition().x - loadedAssets.members[curSelected].width / 2, FlxG.mouse.getPosition().y - loadedAssets.members[curSelected].height /2); //this is a fucking mess
				currentlySelectingSomething = true;
			}
			else if (FlxG.mouse.justReleased)
			{
				currentlySelectingSomething = false;
			}
		}

		for (i in 0...loadedAssets.length)
		{
			loadedAssets.members[i].cameras = [camStage];
		}

		objectsLoaded.text = "Loaded objects: " + loadedAssets.length;
		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.mouse.overlaps(UI_box) || FlxG.mouse.overlaps(UI_tools))
		{
			mouseIsOnAFlxUI = true;
		}
		else
		{
			mouseIsOnAFlxUI = false;
		}

		if (!mouseIsOnAFlxUI && characterMoving && !currentlySelectingSomething)
		{
			if (FlxG.mouse.overlaps(boyfriend)) //This controls the x and y manipulation system, do not fuck with this
			{
				if (FlxG.mouse.pressed)
				{
					if (!gfSelected && !dadSelected)
					{
						boyfriend.setPosition(FlxG.mouse.getPosition().x - boyfriend.width /2, FlxG.mouse.getPosition().y - boyfriend.height /2);
						bfSelected = true;
					}
				}
				else if (FlxG.mouse.justReleased)
				{
					if (bfSelected)
					{
						bfSelected = false;
					}
				}
			}
		
			if (FlxG.mouse.overlaps(gf))
			{
				if (FlxG.mouse.pressed)
				{
					if (!dadSelected && !bfSelected)
					{
						gf.setPosition(FlxG.mouse.getPosition().x - gf.width /2, FlxG.mouse.getPosition().y - gf.height /2);
						gfSelected = true;
					}
				}
				else if (FlxG.mouse.justReleased)
				{
					if (gfSelected)
					{
						gfSelected = false;
					}
				}
			}
		
			if (FlxG.mouse.overlaps(dad))
			{
				if (FlxG.mouse.pressed)
				{
					if (!bfSelected && !gfSelected)
					{
						dad.setPosition(FlxG.mouse.getPosition().x - dad.width /2, FlxG.mouse.getPosition().y - dad.height /2);
						dadSelected = true;
					}
				}
				else if (FlxG.mouse.justReleased)
				{
					if (dadSelected)
					{
						dadSelected = false;
					}
				}
			}
		}

		//texts? (UI)

		boyfriendX.text = "Boyfriend X: " + Math.round(boyfriend.x);
		boyfriendY.text = "Boyfriend Y: " + Math.round(boyfriend.y);

		gfX.text = "GF X: " + Math.round(gf.x);
		gfY.text = "GF Y: " + Math.round(gf.y);

		dadX.text = "Dad X: " + Math.round(dad.x);
		dadY.text = "Dad Y: " + Math.round(dad.y);

		//keys
		if (FlxG.keys.justPressed.Z)
		{
			trace(boyfriend.x);
			trace(boyfriend.y);
		}

		if (FlxG.keys.justPressed.Q)
		{
			FlxG.camera.zoom -= 0.1;
		}
		if (FlxG.keys.justPressed.E)
		{
			FlxG.camera.zoom += 0.1;
		}
		super.update(elapsed);
	}
}

class ModifyCharactersStage extends MusicBeatSubstate
{
    var isBF:Bool = false;
    var isDad:Bool = false;
    var isGF:Bool = false;
    var character:Character;
    var bg:FlxSprite;
    var colorInputText:FlxUIInputText;
    public function new(?x:Float, ?y:Float, characterToLoad:String = "bf")
    {
        super();
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        switch(characterToLoad.toLowerCase())
        {
            case 'bf':
            isBF = true;
            case 'dad':
            isDad = true;
            case 'gf':
            isGF = true;
        }

        if (isBF)
        {
            character = new Character(420, 50, "bf");
            character.flipX = false;
            character.playAnim("idle", true);
            character.scale.set(0.7, 0.7);
            add(character);
        }

        colorInputText = new FlxUIInputText(100, 200, 150, "", 12);
        add(colorInputText);

        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; //M1 Aether#9999 you're a fucking legend
    }

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxTween.tween(FlxG.camera, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				close();
			});
		}
		super.update(elapsed);
	}
}