package;

import flixel.FlxSprite;
import flash.display.BitmapData;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		switch(char)
		{
			case 'bf' | 'bf-holding-gf':
				animation.add('icon', [0, 1], 0, false, isPlayer);
			case 'bf-car':
				animation.add('icon', [0, 1], 0, false, isPlayer);
			case 'bf-christmas':
				animation.add('icon', [0, 1], 0, false, isPlayer);
			case 'bf-pixel':
				animation.add('icon', [21, 21], 0, false, isPlayer);
			case 'spooky':
				animation.add('icon', [2, 3], 0, false, isPlayer);
			case 'pico':
				animation.add('icon', [4, 5], 0, false, isPlayer);
			case 'mom':
				animation.add('icon', [6, 7], 0, false, isPlayer);
			case 'mom-car':
				animation.add('icon', [6, 7], 0, false, isPlayer);
			case 'tankman':
				animation.add('icon', [8, 9], 0, false, isPlayer);
			case 'face':
				animation.add('icon', [10, 11], 0, false, isPlayer);
			case 'dad':
				animation.add('icon', [12, 13], 0, false, isPlayer);
			case 'senpai':
				animation.add('icon', [22, 22], 0, false, isPlayer);
			case 'senpai-angry':
				animation.add('icon', [22, 22], 0, false, isPlayer);
			case 'spirit':
				animation.add('icon', [23, 23], 0, false, isPlayer);
			case 'gf':
				animation.add('icon', [16], 0, false, isPlayer);
			case 'parents-christmas':
				animation.add('icon', [17], 0, false, isPlayer);
			case 'monster':
				animation.add('icon', [19, 20], 0, false, isPlayer);
			case 'monster-christmas':
				animation.add('icon', [19, 20], 0, false, isPlayer);
			default:
				if (EngineFunctions.exists("assets/characters/" + char + "/" +char + "-icon.png"))
				{
					var jsonParse:Dynamic = haxe.Json.parse(EngineFunctions.getContent("assets/characters/" + char + "/" + char + ".json"));
					if (jsonParse.icons != null)
					{
						var rawPic:BitmapData = BitmapData.fromFile("assets/characters/" + char + "/" +char + "-icon.png");
						loadGraphic(rawPic, true, 150, 150);
						animation.add('icon', jsonParse.icons, 0, false, isPlayer);
					}
					else
					{
						animation.add('icon', [0, 1], 0, false, isPlayer);
						trace("JSON damaged");
					}
				}
				else
				{
					animation.add('icon', [0, 1], 0, false, isPlayer);
					trace("There's no icon!");
				}
		}

		if (isPlayer)
		{
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
		}

		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
