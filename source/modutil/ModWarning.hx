package modutil;

/**
    I don't wanna use any imports
**/

class ModWarning extends MusicBeatSubstate {
    var bgTint:flixel.FlxSprite;
    var message:String;
    public function new (message:String) { this.message = message; super();}
    override function create() {
        var bgTint = new flixel.FlxSprite(0,0);
        bgTint.makeGraphic(flixel.FlxG.width, flixel.FlxG.height, flixel.util.FlxColor.BLACK);
        bgTint.scrollFactor.set(0, 0);
        bgTint.updateHitbox();
        bgTint.alpha = 0;
        add(bgTint);
        flixel.tweens.FlxTween.tween(bgTint, {alpha: 0.65}, 0.2);
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}