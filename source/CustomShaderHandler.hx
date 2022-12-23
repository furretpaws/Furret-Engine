package;

import util.FlxShaderToyShader;
import util.FlxShaderToyRuntimeShader;
import util.FlxRuntimeShader;

class CustomShaderHandler extends FlxShaderToyShader
{
    public static var shader:String = "";

    public function new()
    {
        super(shader);
    }
}