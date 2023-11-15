package customization;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

class CharacterEditorState extends MusicBeatState
{
    override public function create()
    {
        var stageEditorTitle:FlxText = new FlxText(0, 20, FlxG.width);
		stageEditorTitle.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		stageEditorTitle.text = "Character Editor";
		stageEditorTitle.borderSize = 2;
		stageEditorTitle.scrollFactor.set();
		stageEditorTitle.antialiasing = true;
		add(stageEditorTitle);
        
        super.create();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}