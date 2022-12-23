package util;

import flixel.input.mouse.FlxMouse;


class FlxShaderToyRuntimeShader extends FlxRuntimeShader {
    var elapsedtime:Float = 0.0;
    public static final headerStuff:String = '
    #pragma header
    uniform vec3 iResolution;
    uniform float iTime;
    uniform float iTimeDelta;
    uniform float iFrame;
    uniform vec4 iMouse;
    ';
    public static final exampleFrag:String = '
    void mainImage( out vec4 fragColor, in vec2 fragCoord )
	{
		// Normalized pixel coordinates (from 0 to 1)
		vec2 uv = fragCoord/iResolution.xy;
		
		// Time varying pixel color
		vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
		
		// Output to screen
		fragColor = vec4(col,1.0);
	}
    ';
    public static final shaderConverter:String = '
    void main()
    {
        // set the color untouched (do nothing), 
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        // store coord so it can be altered (openfl_TextureCoordv is read only)
        vec2 coord = openfl_TextureCoordv;
        
        // convert to shader toy expected fragCoord
        vec2 fragCoord = (coord * openfl_TextureSize);
        
        // then process gl_FragColor with our copy of the shader toy mainImage function
        mainImage(gl_FragColor, fragCoord);
    }
    ';
    public static final vert:String = '
    #pragma header
		
    attribute float alpha;
    attribute vec4 colorMultiplier;
    attribute vec4 colorOffset;
    uniform bool hasColorTransform;
    
    void main(void)
    {
        #pragma body
        
        openfl_Alphav = openfl_Alpha * alpha;
        
        if (hasColorTransform)
        {
            openfl_ColorOffsetv = colorOffset / 255.0;
            openfl_ColorMultiplierv = colorMultiplier;
        }
    }
    ';
    public var fragment:String;
    public var finalShit:String;
    override public function new(fragment:String, w:Float, h:Float, glVer:Int = 120):Void {
        this.fragment = (fragment != null && fragment.length > 0) ? fragment : exampleFrag;
        collateShit();
        super(finalShit, vert, glVer);
        setFloatArray("iResolution", [w, h, 0.0]);
        setFloatArray("iTime", [0.0]);
        setFloatArray("iTimeDelta", [0.0]);
        setFloatArray("iFrame", [0.0]);
        setFloatArray("iMouse", [0.0, 0.0, 0.0, 0.0]);
    }

    function collateShit():Void {
        var stringThing = new StringBuf();
        stringThing.add(headerStuff);
        stringThing.add(fragment);
        stringThing.add(shaderConverter);
        finalShit = stringThing.toString();
    }

    public function update(elapsed:Float, mouse:FlxMouse):Void {
        elapsedtime += elapsed;
        setFloatArray("iTime", [elapsedtime]);
        setFloatArray("iTimeDelta", [elapsed]);
    }
}
