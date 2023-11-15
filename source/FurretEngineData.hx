package;

import flixel.FlxG;

using StringTools;

class FurretEngineData
{
    //system shit
    #if sys
    public static var system:String = "null";
    public static var os:String = "null";
    public static var language:String = "null"; //no engine languages
    public static var formattedLanguage:String = "null";
    #end

    public static function init()
    {
        if (FlxG.save.data.ghostTap == null)
        {
            FlxG.save.data.ghostTap = true;
        }
        if (FlxG.save.data.downscroll == null)
        {
            FlxG.save.data.downscroll = false;
        }
        if (FlxG.save.data.midscroll == null)
        {
            FlxG.save.data.midscroll = false;
        }
        if (FlxG.save.data.noteSplash == null)
        {
            FlxG.save.data.noteSplash = true;
        }
        if (FlxG.save.data.hideTimeBar == null)
        {
            FlxG.save.data.hideTimeBar = false;
        }
        if (FlxG.save.data.hideRC == null)
        {
            FlxG.save.data.hideRC = false;
        }
        if (FlxG.save.data.hideFPSCounter == null)
        {
            FlxG.save.data.hideFPSCounter = false;
        }
        if (FlxG.save.data.antialize == null)
        {
            FlxG.save.data.antialize = false;
        }
        if (FlxG.save.data.ratingX == null)
        {
            FlxG.save.data.ratingX = 664;
        }
        if (FlxG.save.data.ratingY == null)
        {
            FlxG.save.data.ratingY = 224;
        }
        if (FlxG.save.data.autoPause == null)
        {
            FlxG.save.data.autoPause = true;
        }
        if (FlxG.save.data.modsLoaded == null)
        {
            FlxG.save.data.modsLoaded = [];
        }
        if (FlxG.save.data.note_opacity == null)
        {
            FlxG.save.data.note_opacity = 1.0;
        }
        if (FlxG.save.data.hide_background_on_left == null)
        {
            FlxG.save.data.hide_background_on_left = false;
        }
        if (FlxG.save.data.hide_background_on_right == null)
        {
            FlxG.save.data.hide_background_on_right = false;
        }

        #if sys
        if (openfl.system.Capabilities.os.contains("Android") && Sys.systemName() == "Linux")
        {
            system = "Android"; //so it doesnt say "Linux"
        }
        else
        {
            system = Sys.systemName();
        }

        os = openfl.system.Capabilities.os;

        language = openfl.system.Capabilities.language;

        if (openfl.system.Capabilities.language != null) //prevents crash? idk
        {
            switch (openfl.system.Capabilities.language)
            {
                case "cs":
                    formattedLanguage = "czech";
                case "da":
                    formattedLanguage = "danish";
                case "nl":
                    formattedLanguage = "dutch";
                case "en":
                    formattedLanguage = "english";
                case "fi":
                    formattedLanguage = "finnish";
                case "fr":
                    formattedLanguage = "french";
                case "de":
                    formattedLanguage = "german";
                case "hu":
                    formattedLanguage = "hungarian";
                case "it":
                    formattedLanguage = "italian";
                case "ja":
                    formattedLanguage = "japanese";
                case "ko":
                    formattedLanguage = "korean";
                case "no":
                    formattedLanguage = "norwegian";
                case "xu":
                    formattedLanguage = "english"; //it's unknown actually, but let's set it to english
                case "pl":
                    formattedLanguage = "polish";
                case "pt":
                    formattedLanguage = "portuguese";
                case "ru":
                    formattedLanguage = "russian";
                case "zh-CN":
                    formattedLanguage = "simplified chinese";
                case "es":
                    formattedLanguage = "spanish";
                case "sv":
                    formattedLanguage = "swedish";
                case "zh-TW":
                    formattedLanguage = "traditional chinese";
                case "tr":
                    formattedLanguage = "turkish";
                default:
                    formattedLanguage = "english";
            }
        }
        #end
    }
}
