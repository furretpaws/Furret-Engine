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
				animation.add(char, [0, 1], 0, false, isPlayer);
			case 'bf-car':
				animation.add(char, [0, 1], 0, false, isPlayer);
			case 'bf-christmas':
				animation.add(char, [0, 1], 0, false, isPlayer);
			case 'bf-pixel':
				animation.add(char, [21, 21], 0, false, isPlayer);
			case 'spooky':
				animation.add(char, [2, 3], 0, false, isPlayer);
			case 'pico':
				animation.add(char, [4, 5], 0, false, isPlayer);
			case 'mom':
				animation.add(char, [6, 7], 0, false, isPlayer);
			case 'mom-car':
				animation.add(char, [6, 7], 0, false, isPlayer);
			case 'tankman':
				animation.add(char, [8, 9], 0, false, isPlayer);
			case 'face':
				animation.add(char, [10, 11], 0, false, isPlayer);
			case 'dad':
				animation.add(char, [12, 13], 0, false, isPlayer);
			case 'senpai':
				animation.add(char, [22, 22], 0, false, isPlayer);
			case 'senpai-angry':
				animation.add(char, [22, 22], 0, false, isPlayer);
			case 'spirit':
				animation.add(char, [23, 23], 0, false, isPlayer);
			case 'gf':
				animation.add(char, [16], 0, false, isPlayer);
			case 'parents-christmas':
				animation.add(char, [17], 0, false, isPlayer);
			case 'monster':
				animation.add(char, [19, 20], 0, false, isPlayer);
			case 'monster-christmas':
				animation.add(char, [19, 20], 0, false, isPlayer);
			default:
				var path:String = "";
				if (PlayState.customMod != "")
				{
					path = "mods/" + PlayState.customMod + "/assets/characters/" + char + "/" +char + "-icon.png";
				}
				else
				{
					path = "assets/characters/" + char + "/" +char + "-icon.png";
				}
				if (EngineFunctions.exists(path))
				{
					var jsonParse:Dynamic = haxe.Json.parse(EngineFunctions.getContent(path.split("-icon.png")[0] + ".json"));
					if (PlayState.customMod != "")
					{
						
					}
					if (jsonParse.icons != null)
					{
						var rawPic:BitmapData = null;
						if (PlayState.customMod != "")
						{
							#if android
							rawPic = BitmapData.fromFile(BootUpCheck.getPath() + "mods/" + PlayState.customMod + "/assets/characters/" + char + "/" +char + "-icon.png");
							#else
							rawPic = BitmapData.fromFile("mods/" + PlayState.customMod + "/assets/characters/" + char + "/" +char + "-icon.png");
							#end
						}
						else 
						{
							#if android
							rawPic = BitmapData.fromFile(BootUpCheck.getPath() + "assets/characters/" + char + "/" +char + "-icon.png");
							#else
							rawPic = BitmapData.fromFile("assets/characters/" + char + "/" +char + "-icon.png");
							#end
						}
						loadGraphic(rawPic, true, 150, 150);
						animation.add(char, jsonParse.icons, 0, false, isPlayer);
					}
					else
					{
						animation.add(char, [0, 1], 0, false, isPlayer);
						trace("JSON damaged");
					}
				}
				else
				{
					animation.add(char, [0, 1], 0, false, isPlayer);
					trace("There's no icon!");
				}
		}

		if (isPlayer)
		{
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
		}

		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
