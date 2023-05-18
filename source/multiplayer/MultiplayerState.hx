package multiplayer;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import haxe.io.Bytes;
import flixel.util.FlxColor;
import sys.net.Host;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.FlxG;
import sys.net.Socket;
import flixel.FlxSubState;
import flixel.ui.FlxButton;

class MultiplayerState extends FlxState {
    var bg:FlxSprite;
    public static var server:Server;
    public var ownershipKey:FlxSprite;
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
            openSubState(new JoinServer());
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

class JoinServer extends FlxSubState {
    var ipInputText:FlxUIInputText;
    var blackShit:FlxSprite;
    var ipone:FlxText;
    var iptwo:FlxText;
    var ipthree:FlxText;
    var ipreprone:FlxText;
    var ipreprtwo:FlxText;
    var connectButton:FlxButton;
    var backButton:FlxButton;
    var isthisthecorrectserver:FlxText;
    var ipabouttoconnect:FlxText;
    var playersabouttoconnect:FlxText;
    var iacmabouttoconnect:FlxText;
    var noticeabouttoconnect:FlxText;
    var yesButton:FlxButton;
    var twoDotsButton:FlxButton;
    var noButton:FlxButton;

    public function new() {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super();
    }
    override public function create() {
        var bgTint:FlxSprite = new FlxSprite();
        bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgTint.alpha = 0.4;
        add(bgTint);

        blackShit = new FlxSprite(391, 221);
        blackShit.makeGraphic(496, 263, FlxColor.BLACK);
        add(blackShit);
        
        ipone = new FlxText(565, 252);
        ipone.text = "Connect to a server";
        ipone.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ipone.visible = true;
        add(ipone);

        iptwo = new FlxText(549, 328);
        iptwo.text = "The IP has to be typed like this";
        iptwo.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        iptwo.visible = true;
        add(iptwo);

        ipthree = new FlxText(607, 347);
        ipthree.text = "127.0.0.1:80";
        ipthree.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ipthree.visible = true;
        add(ipthree);

        ipreprone = new FlxText(549, 374);
        ipreprone.text = "127.0.0.1 represents the IP";
        ipreprone.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ipreprone.visible = true;
        add(ipreprone);

        ipreprtwo = new FlxText(549, 389);
        ipreprtwo.text = "80 represents the server port";
        ipreprtwo.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ipreprtwo.visible = true;
        add(ipreprtwo);

        ipInputText = new FlxUIInputText(422, 286, 435, "", 24);
        ipInputText.visible = true;
        add(ipInputText);

        connectButton = new FlxButton(481, 431, "Connect", function() {
            var didThatWork:Bool = true;
            connectButton.visible = false;
            backButton.visible = false;
            var socket:Socket = new Socket();
            var IPnPort:Array<String> = ipInputText.text.split(":");
            trace(IPnPort);
            var data:String = "";
            try {
                socket.connect(new Host(IPnPort[0]), Std.parseInt(IPnPort[1]));
            } catch (err:String) {
                trace(err);
                didThatWork = false;
            }
            if (didThatWork) {
                var req:Bytes = Bytes.ofString(haxe.Json.stringify({
                    action: "GET_INFO"
                }));
                socket.output.writeFullBytes(req, 0, req.length);
                var respond:Bool = false;
                var output:String = "";
                while (!respond) {
                    try {
                        var byteBuffer = Bytes.alloc(1024);
                        var bytesRead:Int = socket.input.readBytes(byteBuffer, 0, 1024);
                        var byteString = Bytes.alloc(bytesRead);
                        byteString.blit(0, byteBuffer, 0, bytesRead);
                        output = byteString.toString();
                        
                        if (bytesRead > 0) {
                            trace(bytesRead);
                            respond = true;
                        }
                    } catch (error:String) {
                        trace(error);
                    }
                }
                socket.close();
                var json:Dynamic = null;
                try {
                    json = haxe.Json.parse(output);
                } catch (err:String) {
                    trace(err);
                }
                ipone.visible = false;
                iptwo.visible = false;
                ipthree.visible = false;
                ipreprone.visible = false;
                ipreprtwo.visible = false;
                ipInputText.visible = false;
                twoDotsButton.visible = false;
                isthisthecorrectserver.visible = true;
                ipabouttoconnect.visible = true;
                playersabouttoconnect.visible = true;
                iacmabouttoconnect.visible = true;
                noticeabouttoconnect.visible = true;
                yesButton.visible = true;
                noButton.visible = true;
                ipabouttoconnect.text = "IP: " + ipInputText.text;
                playersabouttoconnect.text = "Players: " + json.d.users;
                var daTextUwu:String = "...";
                if (json.d.onAMatch) {
                    daTextUwu = "Yes";
                } else {
                    daTextUwu = "No";
                }
                iacmabouttoconnect.text = "In a current match?: " + daTextUwu;
            } else {
                Application.current.window.alert("Couldn't connect to " + IPnPort[0] + ":" + IPnPort[1] + ". The server is probably down. Closing the join a server popup.");
                close();
            }
        });
        connectButton.label.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        connectButton.setGraphicSize(137, 25);
		connectButton.updateHitbox();
        connectButton.label.fieldWidth = 137;
        connectButton.color = FlxColor.GREEN;
        connectButton.visible = true;
        for (point in connectButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 5);
        }
        add(connectButton);

        backButton = new FlxButton(655, 431, "Connect", function() {
            close();
        });
        backButton.label.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        backButton.setGraphicSize(137, 25);
		backButton.updateHitbox();
        backButton.label.fieldWidth = 137;
        backButton.color = FlxColor.RED;
        backButton.visible = true;
        for (point in backButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 5);
        }
        add(backButton);

        twoDotsButton = new FlxButton(422, 327, ":", function() {
            ipInputText.text += ":";
        });
        twoDotsButton.label.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        twoDotsButton.setGraphicSize(59, 53);
		twoDotsButton.updateHitbox();
        twoDotsButton.visible = true;
        twoDotsButton.label.fieldWidth = 59;
        twoDotsButton.color = FlxColor.WHITE;
        for (point in twoDotsButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(twoDotsButton);

        isthisthecorrectserver = new FlxText(511, 252);
        isthisthecorrectserver.text = "Is this the correct server?";
        isthisthecorrectserver.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        isthisthecorrectserver.visible = false;
        add(isthisthecorrectserver);

        ipabouttoconnect = new FlxText(411, 280);
        ipabouttoconnect.text = "IP: 127.0.0.1:80";
        ipabouttoconnect.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ipabouttoconnect.visible = false;
        add(ipabouttoconnect);

        playersabouttoconnect = new FlxText(411, 303);
        playersabouttoconnect.text = "Players: 1";
        playersabouttoconnect.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        playersabouttoconnect.visible = false;
        add(playersabouttoconnect);

        iacmabouttoconnect = new FlxText(411, 326);
        iacmabouttoconnect.text = "In a current match?: No";
        iacmabouttoconnect.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        iacmabouttoconnect.visible = false;
        add(iacmabouttoconnect);

        noticeabouttoconnect = new FlxText(413, 395);
        noticeabouttoconnect.text = "Pressing “Yes” will connect you to their game. \nPress it when you’re ready to join!";
        noticeabouttoconnect.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        noticeabouttoconnect.visible = false;
        add(noticeabouttoconnect);

        yesButton = new FlxButton(486, 444, "Yes", function() {
            FlxG.switchState(new Lobby(ipInputText.text));
        });
        yesButton.label.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        yesButton.setGraphicSize(137, 25);
		yesButton.updateHitbox();
        yesButton.label.fieldWidth = 137;
        yesButton.visible = false;
        yesButton.color = FlxColor.GREEN;
        for (point in yesButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 5);
        }
        add(yesButton);

        noButton = new FlxButton(648, 444, "No", function() {
            close();
        });
        noButton.label.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        noButton.setGraphicSize(137, 25);
		noButton.updateHitbox();
        noButton.label.fieldWidth = 137;
        noButton.visible = false;
        noButton.color = FlxColor.RED;
        for (point in noButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 5);
        }
        add(noButton);
    }
}

class CreateServer extends FlxSubState {
    var ipInputText:FlxUIInputText;
    var portInputText:FlxUIInputText;
    var maxPlayersText:FlxUIInputText;
    var blackBlock:FlxSprite;
    var logs:FlxText;
    var label:FlxText;
    var IP:FlxText;
    var Port:FlxText;
    var MaxPlayers:FlxText;
    var Reminder:FlxText;
    var OKButton:FlxButton;
    var BackButton:FlxButton;
    public function new() {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super();
    }
    override public function create() {
        var bgTint:FlxSprite = new FlxSprite();
        bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgTint.alpha = 0.4;
        add(bgTint);

        blackBlock = new FlxSprite();
        blackBlock.makeGraphic(1190, 645, FlxColor.BLACK);
        blackBlock.x = 45;
        blackBlock.y = 37;
        add(blackBlock);

        label = new FlxText();
        label.text = "Create server";
        label.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        label.y = 75;
        label.screenCenter(X);
        add(label);

        IP = new FlxText();
        IP.text = "IP";
        IP.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        IP.x = 82;
        IP.y = 129;
        add(IP);

        ipInputText = new FlxUIInputText(87, 187, 268, "", 16);
        portInputText = new FlxUIInputText(87, 307, 100, "", 16);
        maxPlayersText = new FlxUIInputText(87, 418, 100, "", 16);

        Port = new FlxText();
        Port.text = "Port";
        Port.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        Port.x = 83;
        Port.y = 249;
        add(Port);

        MaxPlayers = new FlxText();
        MaxPlayers.text = "Max players";
        MaxPlayers.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        MaxPlayers.x = 87;
        MaxPlayers.y = 360;
        add(MaxPlayers);

        Reminder = new FlxText();
        Reminder.text = "Maximum players are 4, for now";
        Reminder.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        Reminder.x = 96;
        Reminder.y = 490;
        add(Reminder);

        add(ipInputText);
        add(portInputText);
        add(maxPlayersText);

        logs = new FlxText();
        logs.visible = false;
        logs.text = "Establishing a new socket connection..";
        logs.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        logs.x += 40;
        logs.y = 125;
        add(logs);

        OKButton = new FlxButton(1021, 617, "OK", function() {
            if ((ipInputText.text != null || ipInputText.text != "") && (portInputText.text != null || portInputText.text != "")) {
                //basically, valid
                if (Std.parseInt(maxPlayersText.text) <= 4) {
                    label.text = "Creating server..";
                    ipInputText.visible = false;
                    portInputText.visible = false;
                    maxPlayersText.visible = false;
                    IP.visible = false;
                    Port.visible = false;
                    MaxPlayers.visible = false;
                    Reminder.visible = false;
                    OKButton.visible = false;
                    BackButton.visible = false;
                    logs.text = "Establishing a new socket connection..";
                    logs.visible = true;
                    var hasFailed:Bool = false;
                    var errorString:String = "";

                    var socket:Socket = new Socket();
                    try {
                        socket.bind(new Host(ipInputText.text), Std.parseInt(portInputText.text));
                    } catch (err:String) {
                        errorString += "Couldn't bind the server socket to " + ipInputText.text + ":" + portInputText.text + "\nError: " + err;
                        hasFailed = true;
                    }

                    if (hasFailed) {
                        logs.color = FlxColor.RED;
                        logs.text = errorString + "\nGoing back in 5 seconds..";
                        logs.size = 32;
                        new FlxTimer().start(5, function(tmr:FlxTimer)
                        {
                            close();
                            openSubState(new CreateServer());
                        });
                    } else {
                        socket.close();
                        logs.text += "\n" + ipInputText.text + ":" + portInputText.text + " is available. Generating ownership key..";
                        var chars:String = "abcdefghijklmnopqrstuvwxyz".toUpperCase() + "abcdefghijklmnñopqrstuvwxyz1234567890";
                        var unencryptedKey:String = "";
                        var key:String = "";
                        for (i in 0...32) {
                            unencryptedKey += chars.split("")[chars.split("").length];
                        }
                        //encrypt key! 
                        key = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(unencryptedKey));
                        logs.text += "\nOwnership key generated. Creating a new server instance.";
                        MultiplayerState.server = new Server(ipInputText.text, Std.parseInt(portInputText.text), key);
                        logs.text += "\nServer created. Taking you to the client panel in 3 seconds...";
                        new FlxTimer().start(3, function(tmr:FlxTimer)
                        {
                            FlxG.switchState(new Lobby(ipInputText.text + ":" + portInputText.text, key, MultiplayerState.server));
                        });
                    }
                }
            }
        });
        OKButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        OKButton.setGraphicSize(200, 52);
		OKButton.updateHitbox();
        OKButton.label.fieldWidth = 200;
        OKButton.color = FlxColor.WHITE;
        for (point in OKButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(OKButton);

        BackButton = new FlxButton(798, 617, "Back", function() {
            close();
        });
        BackButton.label.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        BackButton.setGraphicSize(200, 52);
		BackButton.updateHitbox();
        BackButton.label.fieldWidth = 200;
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