package multiplayer;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;

class MultiplayerState extends FlxState {
    var bg:FlxSprite;
    public var server:Server;
    override public function create() {
        FlxG.mouse.visible = true;
        bg = new FlxSprite().loadGraphic("assets/images/menuDesat.png");
		bg.antialiasing = true;
		bg.color = 0x87134B;
		add(bg);

        var upperBlackThing:FlxSprite;
        upperBlackThing = new FlxSprite(0, 0);
        upperBlackThing.makeGraphic(1280, 50);
        upperBlackThing.color = FlxColor.BLACK;
        upperBlackThing.alpha = 0.3;
        add(upperBlackThing);
        
        var multiplayerTitle:FlxText = new FlxText();
        multiplayerTitle.text = "Multiplayer mode";
        multiplayerTitle.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        multiplayerTitle.y = 8;
        multiplayerTitle.screenCenter(X);
        add(multiplayerTitle);
        FlxG.sound.playMusic(Paths.music('breakfast'), 0);

		FlxG.sound.music.fadeIn(4, 0, 0.7);

        var createServer = new FlxButton(1075, 250, "Create a server", function() {
            openSubState(new CreateServer());
        });
        createServer.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        createServer.setGraphicSize(300, 50);
		createServer.updateHitbox();
        createServer.label.fieldWidth = 300;
        createServer.color = FlxColor.WHITE;
        for (point in createServer.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(createServer);
        createServer.screenCenter(X);

        var joinAServer = new FlxButton(1075, 350, "Join a server", function() {
            openSubState(new CreateServer());
        });
        joinAServer.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        joinAServer.setGraphicSize(300, 50);
		joinAServer.updateHitbox();
        joinAServer.label.fieldWidth = 300;
        joinAServer.color = FlxColor.WHITE;
        for (point in joinAServer.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(joinAServer);
        joinAServer.screenCenter(X);

        var currentEngineVersion:FlxText = new FlxText();
        currentEngineVersion.text = "Current Furret Engine version: " + MainMenuState.furretEngineVer;
        currentEngineVersion.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        currentEngineVersion.x = 4;
        currentEngineVersion.y = 698;
        add(currentEngineVersion);

        trace("tf");
        
        
        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}

class CreateServer extends FlxSubState {
    var ipInputText:FlxUIInputText;
    var portInputText:FlxUIInputText;
    var maxPlayersText:FlxUIInputText;
    public function new() {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super();
    }
    override public function create() {
        var bgTint:FlxSprite = new FlxSprite();
        bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgTint.alpha = 0.4;
        add(bgTint);

        var blackBlock:FlxSprite = new FlxSprite();
        blackBlock.makeGraphic(1190, 645, FlxColor.BLACK);
        blackBlock.x = 45;
        blackBlock.y = 37;
        add(blackBlock);

        var createServerLabel:FlxText = new FlxText();
        createServerLabel.text = "Create server";
        createServerLabel.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        createServerLabel.y = 75;
        createServerLabel.screenCenter(X);
        add(createServerLabel);

        var IP:FlxText = new FlxText();
        IP.text = "IP";
        IP.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        IP.x = 82;
        IP.y = 129;
        add(IP);

        ipInputText = new FlxUIInputText(87, 187, 268, "", 16);
        portInputText = new FlxUIInputText(87, 307, 100, "", 16);
        maxPlayersText = new FlxUIInputText(87, 418, 100, "", 16);

        var Port:FlxText = new FlxText();
        Port.text = "Port";
        Port.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        Port.x = 83;
        Port.y = 249;
        add(Port);

        var MaxPlayers:FlxText = new FlxText();
        MaxPlayers.text = "Max players";
        MaxPlayers.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        MaxPlayers.x = 87;
        MaxPlayers.y = 360;
        add(MaxPlayers);

        var Reminder:FlxText = new FlxText();
        Reminder.text = "Maximum players are 4, for now";
        Reminder.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        Reminder.x = 96;
        Reminder.y = 490;
        add(Reminder);

        add(ipInputText);
        add(portInputText);
        add(maxPlayersText);

        var OKButton = new FlxButton(1021, 617, "OK", function() {
            if ((ipInputText.text != null || ipInputText.text != "") && (portInputText.text != null || portInputText.text != "")) {
                //basically, valid
                if (Std.parseInt(maxPlayersText.text) <= 4) {
                    //valid, continue
                    trace("continue!");
                }
            }
        });
        OKButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        OKButton.setGraphicSize(200, 52);
		OKButton.updateHitbox();
        OKButton.label.fieldWidth = 300;
        OKButton.color = FlxColor.WHITE;
        for (point in OKButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(OKButton);

        var BackButton = new FlxButton(798, 617, "Back", function() {
            close();
        });
        BackButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        BackButton.setGraphicSize(200, 52);
		BackButton.updateHitbox();
        BackButton.label.fieldWidth = 300;
        BackButton.color = FlxColor.WHITE;
        for (point in BackButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(BackButton);
        super.create();
    }
    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}