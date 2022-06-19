package;

import flixel.FlxG;

class Preferences {
    public static var downscroll:Bool = false;
    public static var middlescroll:Bool = false;
    public static var notesplash:Bool = false;
    public static var ghostTapping:Bool = false;
    public static var judgement:Bool = false;
    public static var botplay:Bool = false;
    public static var hitsounds:Bool = false;

    public static function refreshPreferences():Void {
        if (FlxG.save.data.downscroll) {
            downscroll = true;
        }
        else
        {
            downscroll = false;
        }
    
        if (FlxG.save.data.middlescroll) {
            middlescroll = true;
        }
        else
        {
            middlescroll = false;
        }
    
        if (FlxG.save.data.noteSplashON) {
            notesplash = true;
        }
        else
        {
            notesplash = false;
        }
    
        if (FlxG.save.data.newInput) {
            ghostTapping = true;
        }
        else
        {
            ghostTapping = false;
        }
    
        if (FlxG.save.data.judgement) {
            judgement = true;
        }
        else
        {
            judgement = false;
        }
    
        if (PlayState.cpuControlled) {
            botplay = true;
        }
        else
        {
            botplay = false;
        }
    
        if (FlxG.save.data.hitsoundspog) {
            hitsounds = true;
        }
        else
        {
            hitsounds = false;
        }
        
        if (downscroll) {
            FlxG.save.data.downscroll = true;
        }
        else
        {
            FlxG.save.data.downscroll = false;
        }
    
        if (middlescroll) {
            FlxG.save.data.middlescroll = true;
        }
        else
        {
            FlxG.save.data.middlescroll = false;
        }
    
        if (notesplash) {
            FlxG.save.data.noteSplashON = true;
        }
        else
        {
            FlxG.save.data.noteSplashON = false;
        }
    
        if (ghostTapping) {
            FlxG.save.data.newInput = true;
        }
        else
        {
            FlxG.save.data.newInput = false;
        }
    
        if (judgement) {
            FlxG.save.data.judgement = true;
        }
        else
        {
            FlxG.save.data.judgement = false;
        }
    
        if (botplay) {
            PlayState.cpuControlled = true;
        }
        else
        {
            PlayState.cpuControlled = false;
        }
    
        if (hitsounds) {
            FlxG.save.data.hitsoundspog = true;
        }
        else
        {
            FlxG.save.data.hitsoundspog = false;
        }
    }
}