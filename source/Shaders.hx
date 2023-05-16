package;

import flixel.system.FlxAssets.FlxShader;

class GlitchEffect
{
	public var shader(default, null):GlitchShader = new GlitchShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
	public var Enabled(default, set):Bool = true;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_Enabled(v:Bool):Bool
	{
		Enabled = v;
		shader.uEnabled.value = [Enabled];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
}

class DistortBGEffect
{
	public var shader(default, null):DistortBGShader = new DistortBGShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
}

class PulseEffect
{
	public var shader(default, null):PulseShader = new PulseShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
	public var Enabled(default, set):Bool = false;

	public function new():Void
	{
		shader.uTime.value = [0];
		shader.uampmul.value = [0];
		shader.uEnabled.value = [false];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_Enabled(v:Bool):Bool
	{
		Enabled = v;
		shader.uEnabled.value = [Enabled];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
}

class InvertColorsEffect
{
	public var shader(default, null):InvertShader = new InvertShader();
}

class GlitchShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }')
	public function new()
	{
		super();
	}
}

class InvertShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    

    vec4 sineWave(vec4 pt)
    {
        return vec4(1.0 - pt.x, 1.0 - pt.y, 1.0 - pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv));
    }')
	public function new()
	{
		super();
	}
}

class DistortBGShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //gives the character a glitchy, distorted outline
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    vec4 makeBlack(vec4 pt)
    {
        return vec4(0, 0, 0, pt.w);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = makeBlack(texture2D(bitmap, uv)) + texture2D(bitmap,openfl_TextureCoordv);
    }')
	public function new()
	{
		super();
	}
}

class PulseShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    uniform float uampmul;

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec4 sineWave(vec4 pt, vec2 pos)
    {
        if (uampmul > 0.0)
        {
            float offsetX = sin(pt.y * uFrequency + uTime * uSpeed);
            float offsetY = sin(pt.x * (uFrequency * 2.) - (uTime / 2.) * uSpeed);
            float offsetZ = sin(pt.z * (uFrequency / 2.) + (uTime / 3.) * uSpeed);
            pt.x = mix(pt.x,sin(pt.x / 2. * pt.y + (5. * offsetX) * pt.z),uWaveAmplitude * uampmul);
            pt.y = mix(pt.y,sin(pt.y / 3. * pt.z + (2. * offsetZ) - pt.x),uWaveAmplitude * uampmul);
            pt.z = mix(pt.z,sin(pt.z / 6. * (pt.x * offsetY) - (50. * offsetZ) * (pt.z * offsetX)),uWaveAmplitude * uampmul);
        }


        return vec4(pt.x, pt.y, pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv),uv);
    }')
	public function new()
	{
		super();
	}
}

class BloomEffect extends Effect{
	public var shader:BloomShader = new BloomShader();
	public function new(?blurSize:Float, ?intensity:Float){
		shader.data.blurSize.value = [blurSize];
		shader.data.intensity.value = [intensity];
	}
}


class BloomShader extends FlxShader{
	@:glFragmentSource("////pragma header
	#pragma header
	uniform float intensity;
	uniform float blurSize;
	void main()
	{
	   vec4 sum = vec4(0);
	   vec2 texcoord = openfl_TextureCoordv;
	   int j;
	   int i;

	   //thank you! http://www.gamerendering.com/2008/10/11/gaussian-blur-filter-shader/ for the 
	   //blur tutorial
	   // blur in y (vertical)
	   // take nine samples, with the distance blurSize between them
	   sum += texture2D(bitmap, vec2(texcoord.x - 4.0*1.0/512.0, texcoord.y)) * 0.05;
	   sum += texture2D(bitmap, vec2(texcoord.x - 3.0*1.0/512.0, texcoord.y)) * 0.09;
	   sum += texture2D(bitmap, vec2(texcoord.x - 2.0*1.0/512.0, texcoord.y)) * 0.12;
	   sum += texture2D(bitmap, vec2(texcoord.x - 1.0/512.0, texcoord.y)) * 0.15;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
	   sum += texture2D(bitmap, vec2(texcoord.x + 1.0/512.0, texcoord.y)) * 0.15;
	   sum += texture2D(bitmap, vec2(texcoord.x + 2.0*1.0/512.0, texcoord.y)) * 0.12;
	   sum += texture2D(bitmap, vec2(texcoord.x + 3.0*1.0/512.0, texcoord.y)) * 0.09;
	   sum += texture2D(bitmap, vec2(texcoord.x + 4.0*1.0/512.0, texcoord.y)) * 0.05;

		// blur in y (vertical)
	   // take nine samples, with the distance blurSize between them
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y - 4.0*1.0/512.0)) * 0.05;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y - 3.0*1.0/512.0)) * 0.09;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y - 2.0*1.0/512.0)) * 0.12;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y - 1.0/512.0)) * 0.15;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y + 1.0/512.0)) * 0.15;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y + 2.0*1.0/512.0)) * 0.12;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y + 3.0*1.0/512.0)) * 0.09;
	   sum += texture2D(bitmap, vec2(texcoord.x, texcoord.y + 4.0*1.0/512.0)) * 0.05;

	   //increase blur with intensity!
	  gl_FragColor = sum*0.35 + flixel_texture2D(bitmap, texcoord); 
	  // if(sin(iTime) > 0.0)
	   //    gl_FragColor = sum * sin(iTime)+ texture(bitmap, texcoord);
	  // else
		//   gl_FragColor = sum * -sin(iTime)+ texture(bitmap, texcoord);
	}")
	public function new() {
		super();
	}
}

class Effect {
	public function setValue(shader:FlxShader, variable:String, value:Float){
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}
}
