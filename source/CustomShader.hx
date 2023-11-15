package;

import openfl.display.Shader;

class CustomShader extends Shader {
    public function new (fragShader:String, vertShader:String) {
        glFragmentSource = fragShader;
        glVertexSource = vertShader;
        super();
    }
}

class CustomEffect {
    public var shader(default, null):CustomShader = null;
}