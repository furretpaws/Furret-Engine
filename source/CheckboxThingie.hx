package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;

using StringTools;

class CheckboxThingie extends FlxSprite
{

	public var sprTracker:FlxSpriteGroup;

	public override function new(x:Float, y:Float, ?checked:Bool = false)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('checkBoxThingie');
		animation.addByPrefix("static", "static", 24, false);
		animation.addByPrefix("checked", "checked", 24, false);
		antialiasing = true;
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		set_daValue(checked);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (animation.curAnim.name) 
		{
			case "checked":
				offset.set(10, 45);
			case "static":
				offset.set();
		}

		if (sprTracker != null)
			setPosition(10, sprTracker.y - 30);
		else
			destroy();

	}

	public function set_daValue(checked:Bool)
	{
		checked ? animation.play("checked", true) : animation.play("static");
	}
}