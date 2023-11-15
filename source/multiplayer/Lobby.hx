package multiplayer;

import sys.net.Socket;
import sys.net.Host;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import haxe.io.Bytes;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import socket.Client;
import flixel.util.FlxTimer;
import flixel.FlxG;

class Lobby extends MusicBeatState {
    public static var connected:Bool = false;
    public var camHUD:FlxCamera;
    public var serverKey:String = "";
	public var camGame:FlxCamera;
    public var bgTint:FlxSprite;
    public var socket:Socket;
    public var IP:String = "";
    var multiplayerLabel:FlxText;
    var connectedTo:FlxText;
    var disconnectButton:FlxButton;
    var requestButton:FlxButton;
    var server:Server;
    var client:Client;
    var downloading:String = "";

    //ui shit
    var requiredUsername:FlxText;
    var blackBox:FlxSprite;
    var username:FlxUIInputText;
    var joinButton:FlxButton;

    public function new(ip:String, ?key:String = null, server:Server = null) {
        this.IP = ip;
        this.serverKey = key;
        this.server = server;
        super();
    }

    override public function create() {
        camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
		bg.antialiasing = true;
		bg.scrollFactor.set();
		bg.active = false;
        add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set();
		stageFront.active = false;
        add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set();
		stageCurtains.active = false;
        add(stageCurtains);
        
        bgTint = new FlxSprite();
        bgTint.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgTint.alpha = 0.4;
        bgTint.cameras = [camHUD];
        add(bgTint);

        blackBox = new FlxSprite();
        blackBox.makeGraphic(398, 192, FlxColor.BLACK);
        blackBox.x = 441;
        blackBox.y = 264;
        blackBox.cameras = [camHUD];
        add(blackBox);

        requiredUsername = new FlxText(450, 282);
        requiredUsername.text = "You are required to enter a username in order to join";
        requiredUsername.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        requiredUsername.antialiasing = true;
        requiredUsername.cameras = [camHUD];
        add(requiredUsername);

        username = new FlxUIInputText(490, 311, 301, "", 16);
        username.cameras = [camHUD];
        add(username);

        joinButton = new FlxButton(567, 412, "JOIN!", function() {
            var IPnPort:Array<String> = this.IP.split(":");
            trace(IPnPort);
            this.client = new socket.Client(IPnPort[0], Std.parseInt(IPnPort[1]));
            this.client.onData = (d:Bytes) -> {
                trace(d.toString());
                var failed:Bool = false;
                var json:Dynamic = null;
                try {
                    json = haxe.Json.parse(d.toString());
                } catch (err) {
                    failed = true;
                }
                if (!failed) {
                    switch(json.event) {
                        case "READY":
                            bgTint.visible = false;
                            blackBox.visible = false;
                            requiredUsername.visible = false;
                            username.visible = false;
                            joinButton.visible = false;
                            multiplayerLabel.visible = true;
                            connectedTo.visible = true;
                            disconnectButton.visible = true;
                            requestButton.visible = true;
                    }
                }
            }
            client.connect();
            var auth:Bytes = Bytes.ofString(haxe.Json.stringify({
                event: "CONNECT",
                d: {
                    username: username.text,
                    version: MainMenuState.furretEngineVer,
                    os: FurretEngineData.os
                }
            }));
            this.client.send(auth);
            /*if (this.serverKey != null && this.server != null) {
                var thing:Bytes = Bytes.ofString(haxe.Json.stringify({
                    action: "TAKE_OWNERSHIP",
                    d: {
                        key: this.serverKey,
                    }
                }));
                //this.client.sendData(thing);
            }*/
        });
        joinButton.label.setFormat("assets/fonts/vcr.ttf", 12, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        joinButton.setGraphicSize(146, 29);
		joinButton.updateHitbox();
        joinButton.label.fieldWidth = 137;
        joinButton.color = FlxColor.GREEN;
        joinButton.visible = true;
        joinButton.cameras = [camHUD];
        for (point in joinButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 5);
        }
        add(joinButton);

        multiplayerLabel = new FlxText();
        multiplayerLabel.text = "Multiplayer Mode";
        multiplayerLabel.y = 32;
        multiplayerLabel.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        multiplayerLabel.screenCenter(X);
        multiplayerLabel.antialiasing = true;
        multiplayerLabel.cameras = [camHUD];
        multiplayerLabel.visible = false;
        add(multiplayerLabel);

        connectedTo = new FlxText();
        connectedTo.text = "Connected to " + this.IP;
        connectedTo.y = 78;
        connectedTo.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        connectedTo.screenCenter(X);
        connectedTo.antialiasing = true;
        connectedTo.cameras = [camHUD];
        connectedTo.visible = false;
        add(connectedTo);

        disconnectButton = new FlxButton(16, 16, "Disconnect", function() {
            @:privateAccess
            this.client.socket.close();
            FlxG.switchState(new MainMenuState());
        });
        disconnectButton.label.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        disconnectButton.setGraphicSize(179, 36);
		disconnectButton.updateHitbox();
        disconnectButton.label.fieldWidth = 179;
        disconnectButton.cameras = [camHUD];
        disconnectButton.visible = false;
        disconnectButton.color = FlxColor.WHITE;
        for (point in disconnectButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }

        requestButton = new FlxButton(207, 16, "Request song", function() {
            @:privateAccess
            this.client.socket.close();
            FlxG.switchState(new MainMenuState());
        });
        requestButton.label.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, FlxTextAlign.CENTER, OUTLINE, FlxColor.BLACK);
        requestButton.setGraphicSize(179, 36);
		requestButton.updateHitbox();
        requestButton.label.fieldWidth = 179;
        requestButton.cameras = [camHUD];
        requestButton.visible = false;
        requestButton.color = FlxColor.WHITE;
        for (point in requestButton.labelOffsets) //thanks psych engine i really love you sometimes
        {
            point.set(0, 10);
        }
        add(disconnectButton);
        add(requestButton);
        FlxG.camera.zoom = 0.6;
        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}

class LobbyCharacter extends Character {
    public function new(char, x, y, username) {
        super(char, x, y);
    }
}