package modutil;

import flixel.FlxG;

class ModsHandler {
    public static function getJSONDataFromSong(songName:String, jsonToLookFor:String) {
        var returnData:String = "";
        for (i in 0...FlxG.save.data.modsLoaded.length) {
            if (EngineFunctions.exists("mods/" + FlxG.save.data.modsLoaded[i] + "/assets/data"))
            {
                var readDirectory = EngineFunctions.readDirectory("mods/" + FlxG.save.data.modsLoaded[i] + "/assets/data/");
                if (readDirectory.contains(songName.toLowerCase()))
                {
                    var readAgain = EngineFunctions.readDirectory("mods/" + FlxG.save.data.modsLoaded[i] + "/assets/data/" + songName.toLowerCase());
                    if (readAgain.contains(jsonToLookFor))
                    {
                        returnData = EngineFunctions.getContent("mods/" + FlxG.save.data.modsLoaded[i] + "/assets/data/" + songName.toLowerCase() + "/" + jsonToLookFor);
                    }
                    else
                    {
                        returnData = null;
                    }
                }
            }
        }
        return returnData;
    }

    public static function getModFromSong(songName:String) {
        var mod:String = "";
        for (i in 0...FlxG.save.data.modsLoaded.length) {
            var readDirectory = EngineFunctions.readDirectory("mods/");
            for (i in 0...readDirectory.length)
            {
                if (EngineFunctions.isDirectory("mods/" + readDirectory[i])) {
                    var readAgain = EngineFunctions.readDirectory("mods/" + readDirectory[i]);
                    if (readAgain.contains("assets"))
                    {
                        var readAssets = EngineFunctions.readDirectory("mods/" + readDirectory[i] + "/assets");
                        if (readAssets.contains("data"))
                        {
                            var readData = EngineFunctions.readDirectory("mods/" + readDirectory[i] + "/assets/data");
                            if (readData.contains(songName.toLowerCase())) {
                                mod = readDirectory[i];
                            }
                        }
                    }
                }
            }
        }
        return mod;
    }

    public static function getLoadedMods():Array<String> {
        return FlxG.save.data.modsLoaded;
    }
}