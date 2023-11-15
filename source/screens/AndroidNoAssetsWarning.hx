package screens; //i love custom screens :heart_eyes:

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if android //only android will use those
import lime.system.JNI;
import lime.system.CFFI;
import android.os.Build;
import sys.io.File;
import sys.FileSystem;
import lime.app.Application;
#end

using StringTools;

class AndroidNoAssetsWarning extends FlxState
{
	#if android
	private static var permissionsList:Array<Dynamic> = android.Permissions.getGrantedPermissions();
    public var androidDir:String = null;
    public var externalS:Dynamic = android.os.Environment.getExternalStorageDirectory();
    public function getPath() //this will be used for almost every single hx file, how exciting
    {   
        var applicationNameSplit:Dynamic /*removes spaces from "Furret Engine" ("Furret Engine" -> "FurretEngine")*/ = Application.current.meta.get("file").split(" ");
        var applicationName:String = "" + applicationNameSplit[0] + applicationNameSplit[1] + "";
        androidDir = externalS + "/" + "." + applicationName + "/";
        return androidDir;
    }
    #end

	var uhohididsomethingwrong:FlxSprite;
	var alert:FlxText;
	var alert2:FlxText;
	var alert3:FlxText;
	var alert4:FlxText;
	var alert5:FlxText;
	var OKButton:FlxText;

	override public function create()
	{
		trace("NO ASSETS?"); // no bitches reference, get it? please laugh
		#if android
		if (permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
		{
			FileSystem.createDirectory(getPath());
			trace("created");
		}
		else
		{
			trace("couldn't create directory");
		}
		#end
		uhohididsomethingwrong = new FlxSprite(542, 67);
		uhohididsomethingwrong.loadGraphic("assets/images/critical_ui/warning_icon.png");
		uhohididsomethingwrong.scale.set(0.9, 0.9);
		uhohididsomethingwrong.antialiasing = true;
		uhohididsomethingwrong.scrollFactor.set();
		uhohididsomethingwrong.alpha = 0;
		uhohididsomethingwrong.updateHitbox();
		add(uhohididsomethingwrong);

		alert = new FlxText(125, 300, 0, "WARNING! You are running a Android Build of Furret Engine");
		alert.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
		alert.alpha = 0;
		add(alert);

		alert2 = new FlxText(105, 346, 0, "You will need to copy the assets from the apk to the '.FurretEngine' folder");
		alert2.setFormat("assets/fonts/vcr.ttf", 26, FlxColor.WHITE, CENTER);
		alert2.alpha = 0;
		add(alert2);

		alert3 = new FlxText(125, 472, 0, "[!] Android builds are currently in beta and will not work as expected!");
		alert3.setFormat("assets/fonts/vcr.ttf", 26, FlxColor.RED, CENTER);
		alert3.alpha = 0;
		add(alert3);

		alert4 = new FlxText(153, 386, 0, "You have been redirected to this screen because we have detected that");
		alert4.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER);
		alert4.alpha = 0;
		add(alert4);

		alert5 = new FlxText(481, 414, 0, "there's no assets folder");
		alert5.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER);
		alert5.alpha = 0;
		add(alert5);

		OKButton = new FlxText(575, 550, 0, "OK");
		OKButton.setFormat("assets/fonts/vcr.ttf", 96, FlxColor.GRAY, CENTER);
		OKButton.alpha = 0;
		add(OKButton);

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.sound.play("assets/sounds/UI/error1.ogg");
			FlxTween.tween(uhohididsomethingwrong, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(alert, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(alert2, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(alert3, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(alert4, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(alert5, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
			FlxTween.tween(OKButton, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
		});

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.Z)
		{
			trace(OKButton.x);
			trace(OKButton.y);
		}
		if (FlxG.mouse.overlaps(OKButton))
		{
			OKButton.color = FlxColor.WHITE;
			if (FlxG.mouse.justPressed)
			{
				Sys.exit(0);
			}
		}
		else
		{
			OKButton.color = FlxColor.GRAY;
		}
		super.update(elapsed);
	}
}
