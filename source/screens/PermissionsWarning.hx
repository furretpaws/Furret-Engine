package screens;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.io.File;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if android //only android will use those
import lime.system.JNI;
import lime.system.CFFI;
import android.os.Build;
import android.Permissions;
import sys.io.File;
import sys.FileSystem;
import lime.app.Application;
#end

using StringTools;

class PermissionsWarning extends FlxState
{
    var info:FlxSprite;
    var permission:FlxText;
    var action:FlxText;
    var action2:FlxText;
    var warning:FlxText;
    var warning2:FlxText;
    var OKButton:FlxText;
    #if android
    private static var permissionsList:Array<Dynamic> = android.Permissions.getGrantedPermissions();
    #end
    override public function create()
    {
        info = new FlxSprite(542, 67);
		info.loadGraphic("assets/images/critical_ui/information_icon.png");
		info.scale.set(0.9, 0.9);
		info.antialiasing = true;
		info.scrollFactor.set();
		info.alpha = 0;
		info.updateHitbox();
		add(info);

        //                                WARNING! You are running a Android Build of Furret Engine
        permission = new FlxText(157, 296, 0, "In order to proceed, we will need some permissions");
		permission.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
		permission.alpha = 0;
		add(permission);

        action = new FlxText(58, 350, 0, "We need permissions to read files and make changes in the files. This is used for"); //the assets folder
		action.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER);
		action.alpha = 0;
		add(action);

        action2 = new FlxText(517, 394, 0, "the assets folder");
		action2.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, CENTER);
		action2.alpha = 0;
		add(action2);

        warning = new FlxText(194, 439, 0, "[!] When pressing OK, the application will ask you for permissions"); //the assets folder
		warning.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.RED, CENTER);
		warning.alpha = 0;
		add(warning);

        warning2 = new FlxText(176, 469, 0, "Do not deny them, or else you will be greeted with this screen again!"); //the assets folder
		warning2.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.RED, CENTER);
		warning2.alpha = 0;
		add(warning2);

        OKButton = new FlxText(575, 550, 0, "OK");
		OKButton.setFormat("assets/fonts/vcr.ttf", 96, FlxColor.GRAY, CENTER);
		OKButton.alpha = 0;
		add(OKButton);

        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            FlxG.sound.play("assets/sounds/UI/info1.ogg");
            FlxTween.tween(info, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(permission, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(action, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(action2, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(warning, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(warning2, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
            FlxTween.tween(OKButton, {alpha: 1}, 0.4, {ease: FlxEase.elasticInOut});
        });
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.Z)
        {
            trace(warning2.x);
            trace(warning2.y);
        }
        if (FlxG.mouse.overlaps(OKButton))
        {
            OKButton.color = FlxColor.WHITE;
            if (FlxG.mouse.justPressed)
            {
                FlxTween.tween(info, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(permission, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(action, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(action2, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(warning, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(warning2, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                FlxTween.tween(OKButton, {alpha: 0}, 0.4, {ease: FlxEase.elasticInOut});
                new FlxTimer().start(0.7, function(tmr:FlxTimer)
                {
                    android.Permissions.requestPermissions([android.Permissions.READ_EXTERNAL_STORAGE, android.Permissions.WRITE_EXTERNAL_STORAGE]);
                    new FlxTimer().start(0.4, function(tmr:FlxTimer)
                    {
                        if (permissionsList.contains(android.Permissions.READ_EXTERNAL_STORAGE) && permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
                        {
                            FlxG.switchState(new AndroidNoAssetsWarning());
                        }
                        else
                        {
                            FlxG.sound.play("assets/sounds/UI/error2.ogg");
                            new FlxTimer().start(0.4, function(tmr:FlxTimer)
                            {
                                FlxG.resetState();
                            });
                        }
                    });
                });
            }
        }
        else
        {
            OKButton.color = FlxColor.GRAY;
        }

        if (FlxG.keys.justPressed.Z)
        {
            trace(warning2.x);
            trace(warning2.y);
        }
    }
}