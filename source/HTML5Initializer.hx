package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;

class HTML5Initializer extends FlxState
{
    override function create()
    {
        if (FlxG.save.data.UPBind == null)
        {
            FlxG.save.data.UPBind = "W";
        }
        
        if (FlxG.save.data.DOWNBind == null)
        {
            FlxG.save.data.DOWNBind = "S";
        }

        if (FlxG.save.data.LEFTBind == null)
        {
            FlxG.save.data.LEFTBind = "A";
        }

        if (FlxG.save.data.RIGHTBind == null)
        {
            FlxG.save.data.RIGHTBind = "D";
        }
        FlxG.save.flush();

        FlxG.switchState(new TitleState());
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}