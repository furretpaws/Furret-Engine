package;

import flixel.FlxG;

import lime.utils.Assets;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

class EngineFunctions //brief explanation: functions used for files and stuff. so i dont have to specify what to do for each target.
{
    public static var useManifestFiles:Bool = false;

    public static function loadSavedKeybinds()
    {
        if (FlxG.save.data.LEFTBind == null)
        {
            FlxG.save.data.LEFTBind = "A";
            FlxG.save.flush();
        }
        if (FlxG.save.data.DOWNBind == null)
        {
            FlxG.save.data.DOWNBind = "S";
            FlxG.save.flush();
        }
        if (FlxG.save.data.UPBind == null)
        {
            FlxG.save.data.UPBind = "W";
            FlxG.save.flush();
        }
        if (FlxG.save.data.RIGHTBind == null)
        {
            FlxG.save.data.RIGHTBind = "D";
            FlxG.save.flush();
        }
        else
        {
            trace("👍");
        }

        trace(FlxG.save.data.LEFTBind);
        trace(FlxG.save.data.DOWNBind);
        trace(FlxG.save.data.UPBind);
        trace(FlxG.save.data.RIGHTBind);
    }

    public static function getKey(k:String)
    {
        var key:String = null;
        key = Reflect.getProperty(FlxG.save.data, k + "Bind");
        return key;
    }

    public static function getContent(path:String)
    {
        #if sys
        var content = null;
        if (useManifestFiles)
        {
            if (Assets.exists(path))
            {
                content = Assets.getText(path);
            }
            else
            {
                content = "File doesn't exist";
            }
        }
        else
        {
            #if android
            if (FileSystem.exists(BootUpCheck.getPath() + path))
            #else
            if (FileSystem.exists(path))
            #end
            {
                #if android
                content = File.getContent(BootUpCheck() + path);
                #else
                content = File.getContent(path);
                #end
            }
            else
            {
                trace("File doesn't exist");
                content = "File doesn't exist";
            }
        }
        return content;
        #else
        var content:String = null;
        content = Assets.getText(path);

        return content;
        #end
    }

    public static function readDirectory(path:String) //THIS FUNCTION SHOULDN'T BE USED WITH MANIFEST FILES ! !
    {
        #if sys
        var content = null;
        if (!useManifestFiles)
        {
            #if android
            if (FileSystem.exists(BootUpCheck.getPath() + path))
            #else
            if (FileSystem.exists(path))
            #end
            {
                content = FileSystem.readDirectory(#if android BootUpCheck.getPath() + #end path);
            }
            else
            {
                content = ["File doesn't exist"]; //waaaa
                trace("File doesn't exist");
            }
        }
        return content;
        #else
        var content = null;
        return content;
        #end
    }

    public static function isDirectory(path:String) //THIS FUNCTION SHOULDN'T BE USED WITH MANIFEST FILES ! !
    {
        #if sys
        var isDirectory:Bool = false;
        if (!useManifestFiles)
        {
            isDirectory = #if android FileSystem.isDirectory(BootUpCheck.getPath() + path); #else FileSystem.isDirectory(path); #end
        }
        return isDirectory;
        #else
        return false;
        #end
    }

    public static function exists(path:String)
    {
        #if sys
        var exist:Bool = false;
        if (useManifestFiles)
        {
            if (Assets.exists(path))
            {
                exist = true;
            }
            else
            {
                exist = false;
            }
        }
        else if (!useManifestFiles)
        {
            #if android
            if (FileSystem.exists(BootUpCheck.getPath() + path)
            #else
            if (FileSystem.exists(path))
            #end
            {
                exist = true;
            }
            else
            {
                exist = false;
            }
        }
        return exist;
        #else
        var exist:Bool = false;
        exist = Assets.exists(path);
        return exist;
        #end
    }
}