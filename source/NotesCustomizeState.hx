package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class NotesCustomizeState extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var typeSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorSwap> = [];
	var curValue:Float = 0;
	var holdTime:Float = 0;
	var hsvText:Alphabet;
	var nextAccept:Int = 5;

	var posX = 250;
	public function new() {
		super();

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		for (i in 0...CoolUtil.arrowHSV.length) {
			var yPos:Float = (165 * i) + 35;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(0, yPos, Std.string(CoolUtil.arrowHSV[i][j]));
				optionText.x = posX + (225 * j) + 100 - ((optionText.lettersArray.length * 90) / 2);
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(posX - 70, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
			switch(i) {
				case 0:
					note.animation.addByPrefix('idle', 'purple0');
				case 1:
					note.animation.addByPrefix('idle', 'blue0');
				case 2:
					note.animation.addByPrefix('idle', 'green0');
				case 3:
					note.animation.addByPrefix('idle', 'red0');
			}
			note.animation.play('idle');
			note.antialiasing = CoolUtil.globalAntialiasing;
			grpNotes.add(note);

			var newShader:ColorSwap = new ColorSwap();
			note.shader = newShader.shader;
			newShader.hue = CoolUtil.arrowHSV[i][0] / 360;
			newShader.saturation = CoolUtil.arrowHSV[i][1] / 100;
			newShader.brightness = CoolUtil.arrowHSV[i][2] / 100;
			shaderArray.push(newShader);
		}
		hsvText = new Alphabet(0, 0, "Hue    Saturation  Brightness", false, false, 0, 0.65);
		add(hsvText);
		changeSelection();
	}

	var changingNote:Bool = false;
	var hsvTextOffsets:Array<Float> = [240, 90];
	override function update(elapsed:Float) {
		if(changingNote) {
			if(holdTime < 0.5) {
				if(controls.LEFT) {
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RIGHT) {
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RESET) {
					resetValue(curSelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if(controls.LEFT) {
					holdTime = 0;
				} else if(controls.LEFT) {
					holdTime += elapsed;
				}
			} else {
				var add:Float = 90;
				switch(typeSelected) {
					case 1 | 2: add = 50;
				}
				if(controls.LEFT) {
					updateValue(elapsed * -add);
				} else if(controls.RIGHT) {
					updateValue(elapsed * add);
				}
				if(controls.LEFT || controls.RIGHT) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}
		} else {
			if (controls.UP) {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.DOWN_P) {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.LEFT_P) {
				changeType(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.RIGHT_P) {
				changeType(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if(controls.RESET) {
				for (i in 0...3) {
					resetValue(curSelected, i);
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.ACCEPT && nextAccept <= 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changingNote = true;
				holdTime = 0;
				for (i in 0...grpNumbers.length) {
					var item = grpNumbers.members[i];
					item.alpha = 0;
					if ((curSelected * 3) + typeSelected == i) {
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length) {
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (curSelected == i) {
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			var intendedPos:Float = posX - 70;
			if (curSelected == i) {
				item.x = FlxMath.lerp(item.x, intendedPos + 100, lerpVal);
			} else {
				item.x = FlxMath.lerp(item.x, intendedPos, lerpVal);
			}
			for (j in 0...3) {
				var item2 = grpNumbers.members[(i * 3) + j];
				item2.x = item.x + 265 + (225 * (j % 3)) - (30 * item2.lettersArray.length) / 2;
				if(CoolUtil.arrowHSV[i][j] < 0) {
					item2.x -= 20;
				}
			}

			if(curSelected == i) {
				hsvText.setPosition(item.x + hsvTextOffsets[0], item.y - hsvTextOffsets[1]);
			}
		}

		if (controls.BACK || (changingNote && controls.ACCEPT)) {
			changeSelection();
			if(!changingNote) {
				grpNumbers.forEachAlive(function(spr:Alphabet) {
					spr.alpha = 0;
				});
				grpNotes.forEachAlive(function(spr:FlxSprite) {
					spr.alpha = 0;
				});
				close();
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new OptionsMenu());
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = CoolUtil.arrowHSV.length-1;
		if (curSelected >= CoolUtil.arrowHSV.length)
			curSelected = 0;

		curValue = CoolUtil.arrowHSV[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(1, 1);
			if (curSelected == i) {
				item.alpha = 1;
				item.scale.set(1.2, 1.2);
				hsvText.setPosition(item.x + hsvTextOffsets[0], item.y - hsvTextOffsets[1]);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0) {
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		curValue = CoolUtil.arrowHSV[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
	}

	function resetValue(selected:Int, type:Int) {
		curValue = 0;
		CoolUtil.arrowHSV[selected][type] = 0;
		switch(type) {
			case 0: shaderArray[selected].hue = 0;
			case 1: shaderArray[selected].saturation = 0;
			case 2: shaderArray[selected].brightness = 0;
		}
		grpNumbers.members[(selected * 3) + type].changeText('0');
	}
	function updateValue(change:Float = 0) {
		curValue += change;
		var roundedValue:Int = Math.round(curValue);
		var max:Float = 180;
		switch(typeSelected) {
			case 1 | 2: max = 100;
		}

		if(roundedValue < -max) {
			curValue = -max;
		} else if(roundedValue > max) {
			curValue = max;
		}
		roundedValue = Math.round(curValue);
		CoolUtil.arrowHSV[curSelected][typeSelected] = roundedValue;

		switch(typeSelected) {
			case 0: shaderArray[curSelected].hue = roundedValue / 360;
			case 1: shaderArray[curSelected].saturation = roundedValue / 100;
			case 2: shaderArray[curSelected].brightness = roundedValue / 100;
		}
		grpNumbers.members[(curSelected * 3) + typeSelected].changeText(Std.string(roundedValue));
	}
}