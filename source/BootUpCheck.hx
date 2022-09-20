package;

import flixel.FlxState;
import flixel.FlxG;
import lime.app.Application;
#if android //only android will use those
import lime.system.JNI;
import lime.system.CFFI;
import android.os.Build;
import android.Permissions;
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class BootUpCheck extends FlxState
{
    #if android
    public static var ignoreAssetsFolder:Bool = false; //This will disable the external assets folder, use it at your wrong risk!
    private static var permissionsList:Array<Dynamic> = android.Permissions.getGrantedPermissions();
    public static var androidDir:String = null;
    public static var externalS:Dynamic = android.os.Environment.getExternalStorageDirectory();
    public static function getPath() //this will be used for almost every single hx file, how exciting
    {   
        var applicationNameSplit:Dynamic /*removes spaces from "Furret Engine" ("Furret Engine" -> "FurretEngine")*/ = Application.current.meta.get("file").split(" ");
        var applicationName:String = "" + applicationNameSplit[0] + applicationNameSplit[1] + "";
        androidDir = externalS + "/" + "." + applicationName + "/";
        return androidDir;
    }
    #end

    override public function create()
    {
        trace("checking stuff...");
        #if debug //DEBUG SHIT
        trace("DEBUG MODE DETECTED!");
        #if android
        if (FileSystem.exists(getPath() + "/assets") && permissionsList.contains(android.Permissions.READ_EXTERNAL_STORAGE) && permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
        {
            FlxG.switchState(new TitleState()); //skips debug mode warning due to null object reference, so dont fuck with this
        }
        else
        {
            if (!ignoreAssetsFolder)
            {
                if (!permissionsList.contains(android.Permissions.READ_EXTERNAL_STORAGE) && !permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
                {
                    FlxG.switchState(new screens.PermissionsWarning());
                }
                else
                {
                    FlxG.switchState(new screens.AndroidNoAssetsWarning()); 
                }
            }
            else
            {
                FlxG.switchState(new TitleState()); //fuck it
            }
        }
        #end
        FlxG.switchState(new screens.DebugModeWarning());
        #elseif !(debug)
        FlxG.switchState(new TitleState());
        #end

        #if android //ANDROID SHIT
        trace("miau");
        trace(getPath());
        if (FileSystem.exists(getPath() + "/assets") && permissionsList.contains(android.Permissions.READ_EXTERNAL_STORAGE) && permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
        {
            FlxG.switchState(new TitleState()); //skips debug mode warning due to null object reference, so dont fuck with this
        }
        else
        {
            if (!ignoreAssetsFolder)
            {
                if (!permissionsList.contains(android.Permissions.READ_EXTERNAL_STORAGE) && !permissionsList.contains(android.Permissions.WRITE_EXTERNAL_STORAGE))
                {
                    FlxG.switchState(new screens.PermissionsWarning());
                }
                else
                {
                    FlxG.switchState(new screens.AndroidNoAssetsWarning()); 
                }
            }
            else
            {
                FlxG.switchState(new TitleState()); //fuck it
            }
        }
        #end
    }

    override public function update(elapsed:Float)
    {

    }
}