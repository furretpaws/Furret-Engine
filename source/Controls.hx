package;
#if android
import utils.AndroidData;
import flixel.group.FlxGroup;
import ui.Hitbox;
import ui.FlxVirtualPad;
import flixel.ui.FlxButton;
#end
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

#if (haxe >= "4.0.0")
enum abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
	var SECONDARY = "secondary";
	var TERTIARY = "tertiary";

	var L1 = "l1";
	var U1 = "u";
	var R1 = "r1";
	var L2 = "l2";
	var D1 = "d";
	var R2 = "r2";

	var L1_P = "l1-press";
	var U1_P = "u-press";
	var R1_P = "r1-press";
	var L2_P = "l2-press";
	var D1_P = "d-press";
	var R2_P = "r2-press";

	var L1_R = "l1-release";
	var U1_R = "u-release";
	var R1_R = "r1-release";
	var L2_R = "l2-release";
	var D1_R = "d-release";
	var R2_R = "r2-release";

	var A0 = "a0";
	var A1 = "a1";
	var A2 = "a2";
	var A3 = "a3";
	var A4 = "a4";
	var A5 = "a5";
	var A6 = "a6";

	var A0_P = "a0-press";
	var A1_P = "a1-press";
	var A2_P = "a2-press";
	var A3_P = "a3-press";
	var A4_P = "a4-press";
	var A5_P = "a5-press";
	var A6_P = "a6-press";

	var A0_R = "a0-release";
	var A1_R = "a1-release";
	var A2_R = "a2-release";
	var A3_R = "a3-release";
	var A4_R = "a4-release";
	var A5_R = "a5-release";
	var A6_R = "a6-release";


	var N0 = "n0";
	var N1 = "n1";
	var N2 = "n2";
	var N3 = "n3";
	var N4 = "n4";
	var N5 = "n5";
	var N6 = "n6";
	var N7 = "n7";
	var N8 = "n8";

	var N0_P = "n0-press";
	var N1_P = "n1-press";
	var N2_P = "n2-press";
	var N3_P = "n3-press";
	var N4_P = "n4-press";
	var N5_P = "n5-press";
	var N6_P = "n6-press";
	var N7_P = "n7-press";
	var N8_P = "n8-press";

	var N0_R = "n0-release";
	var N1_R = "n1-release";
	var N2_R = "n2-release";
	var N3_R = "n3-release";
	var N4_R = "n4-release";
	var N5_R = "n5-release";
	var N6_R = "n6-release";
	var N7_R = "n7-release";
	var N8_R = "n8-release";
}
#else
@:enum
abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";

	var L1 = "l1";
	var U1 = "u";
	var R1 = "r1";
	var L2 = "l2";
	var D1 = "d";
	var R2 = "r2";

	var L1_P = "l1-press";
	var U1_P = "u-press";
	var R1_P = "r1-press";
	var L2_P = "l2-press";
	var D1_P = "d-press";
	var R2_P = "r2-press";

	var L1_R = "l1-release";
	var U1_R = "u-release";
	var R1_R = "r1-release";
	var L2_R = "l2-release";
	var D1_R = "d-release";
	var R2_R = "r2-release";


	var N0 = "n0";
	var N1 = "n1";
	var N2 = "n2";
	var N3 = "n3";
	var N4 = "n4";
	var N5 = "n5";
	var N6 = "n6";
	var N7 = "n7";
	var N8 = "n8";

	var N0_P = "n0-press";
	var N1_P = "n1-press";
	var N2_P = "n2-press";
	var N3_P = "n3-press";
	var N4_P = "n4-press";
	var N5_P = "n5-press";
	var N6_P = "n6-press";
	var N7_P = "n7-press";
	var N8_P = "n8-press";

	var N0_R = "n0-release";
	var N1_R = "n1-release";
	var N2_R = "n2-release";
	var N3_R = "n3-release";
	var N4_R = "n4-release";
	var N5_R = "n5-release";
	var N6_R = "n6-release";
	var N7_R = "n7-release";
	var N8_R = "n8-release";
}
#end

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;	
	SECONDARY;
	TERTIARY;
	L1;
	U1;
	R1;
	L2;
	D1;
	R2;
	A0;
	A1;
	A2;
	A3;
	A4;
	A5;
	A6;
	N0;
	N1;
	N2;
	N3;
	N4;
	N5;
	N6;
	N7;
	N8;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);
	var _secondary = new FlxActionDigital(Action.SECONDARY);
	var _tertiary = new FlxActionDigital(Action.TERTIARY);


	var _l1 = new FlxActionDigital(Action.L1);
	var _l1P = new FlxActionDigital(Action.L1_P);
	var _l1R = new FlxActionDigital(Action.L1_R);

	var _u = new FlxActionDigital(Action.U1);
	var _uP = new FlxActionDigital(Action.U1_P);
	var _uR = new FlxActionDigital(Action.U1_R);

	var _r1 = new FlxActionDigital(Action.R1);
	var _r1P = new FlxActionDigital(Action.R1_P);
	var _r1R = new FlxActionDigital(Action.R1_R);

	var _l2 = new FlxActionDigital(Action.L2);
	var _l2P = new FlxActionDigital(Action.L2_P);
	var _l2R = new FlxActionDigital(Action.L2_R);

	var _d = new FlxActionDigital(Action.D1);
	var _dP = new FlxActionDigital(Action.D1_P);
	var _dR = new FlxActionDigital(Action.D1_R);

	var _r2 = new FlxActionDigital(Action.R2);
	var _r2P = new FlxActionDigital(Action.R2_P);
	var _r2R = new FlxActionDigital(Action.R2_R);

	var _a0 = new FlxActionDigital(Action.A0);
	var _a1 = new FlxActionDigital(Action.A1);
	var _a2 = new FlxActionDigital(Action.A2);
	var _a3 = new FlxActionDigital(Action.A3);
	var _a4 = new FlxActionDigital(Action.A4);
	var _a5 = new FlxActionDigital(Action.A5);
	var _a6 = new FlxActionDigital(Action.A6);

	var _a0P = new FlxActionDigital(Action.A0_P);
	var _a1P = new FlxActionDigital(Action.A1_P);
	var _a2P = new FlxActionDigital(Action.A2_P);
	var _a3P = new FlxActionDigital(Action.A3_P);
	var _a4P = new FlxActionDigital(Action.A4_P);
	var _a5P = new FlxActionDigital(Action.A5_P);
	var _a6P = new FlxActionDigital(Action.A6_P);

	var _a0R = new FlxActionDigital(Action.A0_R);
	var _a1R = new FlxActionDigital(Action.A1_R);
	var _a2R = new FlxActionDigital(Action.A2_R);
	var _a3R = new FlxActionDigital(Action.A3_R);
	var _a4R = new FlxActionDigital(Action.A4_R);
	var _a5R = new FlxActionDigital(Action.A5_R);
	var _a6R = new FlxActionDigital(Action.A6_R);



	var _n0 = new FlxActionDigital(Action.N0);
	var _n1 = new FlxActionDigital(Action.N1);
	var _n2 = new FlxActionDigital(Action.N2);
	var _n3 = new FlxActionDigital(Action.N3);
	var _n4 = new FlxActionDigital(Action.N4);
	var _n5 = new FlxActionDigital(Action.N5);
	var _n6 = new FlxActionDigital(Action.N6);
	var _n7 = new FlxActionDigital(Action.N7);
	var _n8 = new FlxActionDigital(Action.N8);

	var _n0P = new FlxActionDigital(Action.N0_P);
	var _n1P = new FlxActionDigital(Action.N1_P);
	var _n2P = new FlxActionDigital(Action.N2_P);
	var _n3P = new FlxActionDigital(Action.N3_P);
	var _n4P = new FlxActionDigital(Action.N4_P);
	var _n5P = new FlxActionDigital(Action.N5_P);
	var _n6P = new FlxActionDigital(Action.N6_P);
	var _n7P = new FlxActionDigital(Action.N7_P);
	var _n8P = new FlxActionDigital(Action.N8_P);

	var _n0R = new FlxActionDigital(Action.N0_R);
	var _n1R = new FlxActionDigital(Action.N1_R);
	var _n2R = new FlxActionDigital(Action.N2_R);
	var _n3R = new FlxActionDigital(Action.N3_R);
	var _n4R = new FlxActionDigital(Action.N4_R);
	var _n5R = new FlxActionDigital(Action.N5_R);
	var _n6R = new FlxActionDigital(Action.N6_R);
	var _n7R = new FlxActionDigital(Action.N7_R);
	var _n8R = new FlxActionDigital(Action.N8_R);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();
	public var SECONDARY(get, never):Bool;
	inline function get_SECONDARY()
		return _secondary.check();
	public var TERTIARY(get,never):Bool;
	inline function get_TERTIARY()
		return _tertiary.check();
	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();


	public var L1(get, never):Bool;

	inline function get_L1()
		return _l1.check();

	public var L1_P(get, never):Bool;

	inline function get_L1_P()
		return _l1P.check();

	public var L1_R(get, never):Bool;

	inline function get_L1_R()
		return _l1R.check();	

	public var D1(get, never):Bool;

	inline function get_D1()
		return _d.check();

	public var D1_P(get, never):Bool;

	inline function get_D1_P()
		return _dP.check();

	public var D1_R(get, never):Bool;

	inline function get_D1_R()
		return _dR.check();

	public var R1(get, never):Bool;

	inline function get_R1()
		return _r1.check();

	public var R1_P(get, never):Bool;

	inline function get_R1_P()
		return _r1P.check();

	public var R1_R(get, never):Bool;

	inline function get_R1_R()
		return _r1R.check();	


	public var L2(get, never):Bool;

	inline function get_L2()
		return _l2.check();

	public var L2_P(get, never):Bool;

	inline function get_L2_P()
		return _l2P.check();

	public var L2_R(get, never):Bool;

	inline function get_L2_R()
		return _l2R.check();	

	public var U1(get, never):Bool;

	inline function get_U1()
		return _u.check();

	public var U1_P(get, never):Bool;

	inline function get_U1_P()
		return _uP.check();

	public var U1_R(get, never):Bool;

	inline function get_U1_R()
		return _uR.check();

	public var R2(get, never):Bool;

	inline function get_R2()
		return _r2.check();

	public var R2_P(get, never):Bool;

	inline function get_R2_P()
		return _r2P.check();

	public var R2_R(get, never):Bool;

	inline function get_R2_R()
		return _r2R.check();

	public var A0(get, never):Bool;
	public var A1(get, never):Bool;
	public var A2(get, never):Bool;
	public var A3(get, never):Bool;
	public var A4(get, never):Bool;
	public var A5(get, never):Bool;
	public var A6(get, never):Bool;

	public var A0_P(get, never):Bool;
	public var A1_P(get, never):Bool;
	public var A2_P(get, never):Bool;
	public var A3_P(get, never):Bool;
	public var A4_P(get, never):Bool;
	public var A5_P(get, never):Bool;
	public var A6_P(get, never):Bool;

	public var A0_R(get, never):Bool;
	public var A1_R(get, never):Bool;
	public var A2_R(get, never):Bool;
	public var A3_R(get, never):Bool;
	public var A4_R(get, never):Bool;
	public var A5_R(get, never):Bool;
	public var A6_R(get, never):Bool;

	inline function get_A0() return _a0.check();
	inline function get_A1() return _a1.check();
	inline function get_A2() return _a2.check();
	inline function get_A3() return _a3.check();
	inline function get_A4() return _a4.check();
	inline function get_A5() return _a5.check();
	inline function get_A6() return _a6.check();

	inline function get_A0_P() return _a0P.check();
	inline function get_A1_P() return _a1P.check();
	inline function get_A2_P() return _a2P.check();
	inline function get_A3_P() return _a3P.check();
	inline function get_A4_P() return _a4P.check();
	inline function get_A5_P() return _a5P.check();
	inline function get_A6_P() return _a6P.check();

	inline function get_A0_R() return _a0R.check();
	inline function get_A1_R() return _a1R.check();
	inline function get_A2_R() return _a2R.check();
	inline function get_A3_R() return _a3R.check();
	inline function get_A4_R() return _a4R.check();
	inline function get_A5_R() return _a5R.check();
	inline function get_A6_R() return _a6R.check();


	public var N0(get, never):Bool;
	public var N1(get, never):Bool;
	public var N2(get, never):Bool;
	public var N3(get, never):Bool;
	public var N4(get, never):Bool;
	public var N5(get, never):Bool;
	public var N6(get, never):Bool;
	public var N7(get, never):Bool;
	public var N8(get, never):Bool;

	public var N0_P(get, never):Bool;
	public var N1_P(get, never):Bool;
	public var N2_P(get, never):Bool;
	public var N3_P(get, never):Bool;
	public var N4_P(get, never):Bool;
	public var N5_P(get, never):Bool;
	public var N6_P(get, never):Bool;
	public var N7_P(get, never):Bool;
	public var N8_P(get, never):Bool;

	public var N0_R(get, never):Bool;
	public var N1_R(get, never):Bool;
	public var N2_R(get, never):Bool;
	public var N3_R(get, never):Bool;
	public var N4_R(get, never):Bool;
	public var N5_R(get, never):Bool;
	public var N6_R(get, never):Bool;
	public var N7_R(get, never):Bool;
	public var N8_R(get, never):Bool;

	inline function get_N0() return _n0.check();
	inline function get_N1() return _n1.check();
	inline function get_N2() return _n2.check();
	inline function get_N3() return _n3.check();
	inline function get_N4() return _n4.check();
	inline function get_N5() return _n5.check();
	inline function get_N6() return _n6.check();
	inline function get_N7() return _n7.check();
	inline function get_N8() return _n8.check();

	inline function get_N0_P() return _n0P.check();
	inline function get_N1_P() return _n1P.check();
	inline function get_N2_P() return _n2P.check();
	inline function get_N3_P() return _n3P.check();
	inline function get_N4_P() return _n4P.check();
	inline function get_N5_P() return _n5P.check();
	inline function get_N6_P() return _n6P.check();
	inline function get_N7_P() return _n7P.check();
	inline function get_N8_P() return _n8P.check();

	inline function get_N0_R() return _n0R.check();
	inline function get_N1_R() return _n1R.check();
	inline function get_N2_R() return _n2R.check();
	inline function get_N3_R() return _n3R.check();
	inline function get_N4_R() return _n4R.check();
	inline function get_N5_R() return _n5R.check();
	inline function get_N6_R() return _n6R.check();
	inline function get_N7_R() return _n7R.check();
	inline function get_N8_R() return _n8R.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		add(_l1);
		add(_l1P);
		add(_l1R);
		add(_d);
		add(_dP);
		add(_dR);
		add(_r1);
		add(_r1P);
		add(_r1R);

		add(_l2);
		add(_l2P);
		add(_l2R);
		add(_u);
		add(_uP);
		add(_uR);
		add(_r2);
		add(_r2P);
		add(_r2R);

		add(_a0);
		add(_a1);
		add(_a2);
		add(_a3);
		add(_a4);
		add(_a5);
		add(_a6);

		add(_a0P);
		add(_a1P);
		add(_a2P);
		add(_a3P);
		add(_a4P);
		add(_a5P);
		add(_a6P);

		add(_a0R);
		add(_a1R);
		add(_a2R);
		add(_a3R);
		add(_a4R);
		add(_a5R);
		add(_a6R);


		add(_n0);
		add(_n1);
		add(_n2);
		add(_n3);
		add(_n4);
		add(_n5);
		add(_n6);
		add(_n7);
		add(_n8);

		add(_n0P);
		add(_n1P);
		add(_n2P);
		add(_n3P);
		add(_n4P);
		add(_n5P);
		add(_n6P);
		add(_n7P);
		add(_n8P);

		add(_n0R);
		add(_n1R);
		add(_n2R);
		add(_n3R);
		add(_n4R);
		add(_n5R);
		add(_n6R);
		add(_n7R);
		add(_n8R);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		loadKeyBinds();
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		add(_l1);
		add(_l1P);
		add(_l1R);
		add(_d);
		add(_dP);
		add(_dR);
		add(_r1);
		add(_r1P);
		add(_r1R);

		add(_l2);
		add(_l2P);
		add(_l2R);
		add(_u);
		add(_uP);
		add(_uR);
		add(_r2);
		add(_r2P);
		add(_r2R);


		add(_n0);
		add(_n1);
		add(_n2);
		add(_n3);
		add(_n4);
		add(_n5);
		add(_n6);
		add(_n7);
		add(_n8);

		add(_n0P);
		add(_n1P);
		add(_n2P);
		add(_n3P);
		add(_n4P);
		add(_n5P);
		add(_n6P);
		add(_n7P);
		add(_n8P);

		add(_n0R);
		add(_n1R);
		add(_n2R);
		add(_n3R);
		add(_n4R);
		add(_n5R);
		add(_n6R);
		add(_n7R);
		add(_n8R);

		for (action in digitalActions)
			byName[action.name] = action;
			
		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	#if android
	public var trackedinputs:Array<FlxActionInput> = [];

	public function addbutton(action:FlxActionDigital, button:FlxButton, state:FlxInputState) {
		var input = new FlxActionInputDigitalIFlxInput(button, state);
		trackedinputs.push(input);
		
		action.add(input);
		//action.addInput(button, state);
	}
	
	public function setHitBox(hitbox:Hitbox) 
	{
		inline forEachBound(Control.UP, (action, state) -> addbutton(action, hitbox.buttonUp, state));
		inline forEachBound(Control.DOWN, (action, state) -> addbutton(action, hitbox.buttonDown, state));
		inline forEachBound(Control.LEFT, (action, state) -> addbutton(action, hitbox.buttonLeft, state));
		inline forEachBound(Control.RIGHT, (action, state) -> addbutton(action, hitbox.buttonRight, state));	
	}

	
	public function setVirtualPad(virtualPad:FlxVirtualPad, ?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		if (DPad == null)
			DPad = NONE;
		if (Action == null)
			Action = NONE;
		
		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.UP, (action, state) -> addbutton(action, virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> addbutton(action, virtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.LEFT, (action, state) -> addbutton(action, virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> addbutton(action, virtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.UP, (action, state) -> addbutton(action, virtualPad.buttonUp, state));
				inline forEachBound(Control.LEFT, (action, state) -> addbutton(action, virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> addbutton(action, virtualPad.buttonRight, state));
			case FULL | RIGHT_FULL:
				inline forEachBound(Control.UP, (action, state) -> addbutton(action, virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> addbutton(action, virtualPad.buttonDown, state));
				inline forEachBound(Control.LEFT, (action, state) -> addbutton(action, virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> addbutton(action, virtualPad.buttonRight, state));
			
			case NONE:
		}

		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbutton(action, virtualPad.buttonA, state));
			case A_B:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbutton(action, virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addbutton(action, virtualPad.buttonB, state));
			case A_B_C:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbutton(action, virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addbutton(action, virtualPad.buttonB, state));
			case A_B_X_Y:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbutton(action, virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addbutton(action, virtualPad.buttonB, state));
			case NONE:
		}
	}
	

	public function removeFlxInput(Tinputs) {
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			
			while (i-- > 0)
			{
				var input = action.inputs[i];
				/*if (input.device == IFLXINPUT_OBJECT)
					action.remove(input);*/

				var x = Tinputs.length;
				while (x-- > 0)
					if (Tinputs[x] == input)
						action.remove(input);
			}
		}
	}
	

	
	#if android
	public function addAndroidBack() {
		// fix this later

		/*
		var BACK = #if (openfl >= "8.0.0") 0x4000010E #else 27 #end;
		_back.addKey(BACK, JUST_RELEASED);
		_back.addKey(BACK, JUST_PRESSED);
		_back.addKey(BACK, PRESSED);
		*/
	}
	#end
	#end

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
			case SECONDARY: _secondary;
			case TERTIARY: _tertiary;

			case L1: _l1;
			case D1: _d;
			case R1: _r1;
			case L2: _l2;
			case U1: _u;
			case R2: _r2;

			case A0: _a0;
			case A1: _a1;
			case A2: _a2;
			case A3: _a3;
			case A4: _a4;
			case A5: _a5;
			case A6: _a6;

			case N0: _n0;
			case N1: _n1;
			case N2: _n2;
			case N3: _n3;
			case N4: _n4;
			case N5: _n5;
			case N6: _n6;
			case N7: _n7;
			case N8: _n8;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
			case SECONDARY:
				func(_secondary, JUST_PRESSED);
			case TERTIARY:
				func(_tertiary, JUST_PRESSED);

			case L1:
				func(_l1, PRESSED);
				func(_l1P, JUST_PRESSED);
				func(_l1R, JUST_RELEASED);
			case U1:
				func(_u, PRESSED);
				func(_uP, JUST_PRESSED);
				func(_uR, JUST_RELEASED);
			case R1:
				func(_r1, PRESSED);
				func(_r1P, JUST_PRESSED);
				func(_r1R, JUST_RELEASED);
			case L2:
				func(_l2, PRESSED);
				func(_l2P, JUST_PRESSED);
				func(_l2R, JUST_RELEASED);
			case D1:
				func(_d, PRESSED);
				func(_dP, JUST_PRESSED);
				func(_dR, JUST_RELEASED);
			case R2:
				func(_r2, PRESSED);
				func(_r2P, JUST_PRESSED);
				func(_r2R, JUST_RELEASED);

			case A0:
				func(_a0, PRESSED);
				func(_a0P, JUST_PRESSED);
				func(_a0R, JUST_RELEASED);
			case A1:
				func(_a1, PRESSED);
				func(_a1P, JUST_PRESSED);
				func(_a1R, JUST_RELEASED);
			case A2:
				func(_a2, PRESSED);
				func(_a2P, JUST_PRESSED);
				func(_a2R, JUST_RELEASED);
			case A3:
				func(_a3, PRESSED);
				func(_a3P, JUST_PRESSED);
				func(_a3R, JUST_RELEASED);
			case A4:
				func(_a4, PRESSED);
				func(_a4P, JUST_PRESSED);
				func(_a4R, JUST_RELEASED);
			case A5:
				func(_a5, PRESSED);
				func(_a5P, JUST_PRESSED);
				func(_a5R, JUST_RELEASED);
			case A6:
				func(_a6, PRESSED);
				func(_a6P, JUST_PRESSED);
				func(_a6R, JUST_RELEASED);

			case N0:
				func(_n0, PRESSED);
				func(_n0P, JUST_PRESSED);
				func(_n0R, JUST_RELEASED);
			case N1:
				func(_n1, PRESSED);
				func(_n1P, JUST_PRESSED);
				func(_n1R, JUST_RELEASED);
			case N2:
				func(_n2, PRESSED);
				func(_n2P, JUST_PRESSED);
				func(_n2R, JUST_RELEASED);
			case N3:
				func(_n3, PRESSED);
				func(_n3P, JUST_PRESSED);
				func(_n3R, JUST_RELEASED);
			case N4:
				func(_n4, PRESSED);
				func(_n4P, JUST_PRESSED);
				func(_n4R, JUST_RELEASED);
			case N5:
				func(_n5, PRESSED);
				func(_n5P, JUST_PRESSED);
				func(_n5R, JUST_RELEASED);
			case N6:
				func(_n6, PRESSED);
				func(_n6P, JUST_PRESSED);
				func(_n6R, JUST_RELEASED);
			case N7:
				func(_n7, PRESSED);
				func(_n7P, JUST_PRESSED);
				func(_n7R, JUST_RELEASED);
			case N8:
				func(_n8, PRESSED);
				func(_n8P, JUST_PRESSED);
				func(_n8R, JUST_RELEASED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
				byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
					  gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true,buttons:String="wasd")
		{
			loadKeyBinds();
			/*if (reset)
				removeKeyboard();
	
			keyboardScheme = scheme;
			trace("USDFJSDFJKLFSDJK");
			trace(buttons);
			trace(buttons.substring(2,3));
	
			#if (haxe >= "4.0.0")
			inline bindKeys(Control.N0, [A]);
			inline bindKeys(Control.N1, [S]);
			inline bindKeys(Control.N2, [D]);
			inline bindKeys(Control.N3, [F]);
			inline bindKeys(Control.N4, [FlxKey.SPACE]);
			inline bindKeys(Control.N5, [H]);
			inline bindKeys(Control.N6, [J]);
			inline bindKeys(Control.N7, [K]);
			inline bindKeys(Control.N8, [L]);
			switch (scheme)
			{
				case Solo:
					
					inline bindKeys(Control.UP, [buttons.substring(2,3), FlxKey.UP]);
					inline bindKeys(Control.DOWN, [buttons.substring(1,2), FlxKey.DOWN]);
					inline bindKeys(Control.LEFT, [buttons.substring(0,1), FlxKey.LEFT]);
					inline bindKeys(Control.RIGHT, [buttons.substring(3,4	), FlxKey.RIGHT]);
					inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
					inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
					inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
					inline bindKeys(Control.RESET, [R]);
					inline bindKeys(Control.SECONDARY, [E]);
					inline bindKeys(Control.TERTIARY,[Q]);
	
					inline bindKeys(Control.L1, [S]);
					inline bindKeys(Control.U1, [D]);
					inline bindKeys(Control.R1, [F]);
					inline bindKeys(Control.L2, [J]);
					inline bindKeys(Control.D1, [K]);
					inline bindKeys(Control.R2, [L]);
				case Duo(true):
					inline bindKeys(Control.UP, [W, FlxKey.UP]);
					inline bindKeys(Control.DOWN, [S, FlxKey.DOWN]);
					inline bindKeys(Control.LEFT, [A, FlxKey.LEFT]);
					inline bindKeys(Control.RIGHT, [D, FlxKey.RIGHT]);
					inline bindKeys(Control.ACCEPT, [G, Z, SPACE, ENTER]);
					inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
					inline bindKeys(Control.RESET, [R]);
					inline bindKeys(Control.SECONDARY, [E]);
					inline bindKeys(Control.TERTIARY, [Q]);
	
					inline bindKeys(Control.L1, [A]);
					inline bindKeys(Control.U1, [S]);
					inline bindKeys(Control.R1, [D]);
					inline bindKeys(Control.L2, [FlxKey.LEFT]);
					inline bindKeys(Control.D1, [FlxKey.DOWN]);
					inline bindKeys(Control.R2, [FlxKey.RIGHT]);
				case Duo(false):
					inline bindKeys(Control.UP, [FlxKey.UP]);
					inline bindKeys(Control.DOWN, [FlxKey.DOWN]);
					inline bindKeys(Control.LEFT, [FlxKey.LEFT]);
					inline bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
					inline bindKeys(Control.ACCEPT, [O]);
					inline bindKeys(Control.BACK, [P]);
					inline bindKeys(Control.PAUSE, [ENTER]);
					inline bindKeys(Control.RESET, [BACKSPACE]);
					inline bindKeys(Control.SECONDARY, [E]);
					inline bindKeys(Control.TERTIARY, [Q]);
				case None: // nothing
				case Custom: // nothing
			}
		#else
		bindKeys(Control.A0, [S]);
		bindKeys(Control.A1, [D]);
		bindKeys(Control.A2, [F]);
		bindKeys(Control.A3, [FlxKey.SPACE]);
		bindKeys(Control.A4, [J]);
		bindKeys(Control.A5, [K]);
		bindKeys(Control.A6, [L]);
		bindKeys(Control.N0, [A]);
		bindKeys(Control.N1, [S]);
		bindKeys(Control.N2, [D]);
		bindKeys(Control.N3, [F]);
		bindKeys(Control.N4, [FlxKey.SPACE]);
		bindKeys(Control.N5, [H]);
		bindKeys(Control.N6, [J]);
		bindKeys(Control.N7, [K]);
		bindKeys(Control.N8, [L]);
		switch (scheme)
		{
			case Solo:
				bindKeys(Control.UP, [W, FlxKey.UP]);
				bindKeys(Control.DOWN, [S, FlxKey.DOWN]);
				bindKeys(Control.LEFT, [A, FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [D, FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				bindKeys(Control.RESET, [R]);

				bindKeys(Control.L1, [S]);
				bindKeys(Control.U1, [D]);
				bindKeys(Control.R1, [F]);
				bindKeys(Control.L2, [J]);
				bindKeys(Control.D1, [K]);
				bindKeys(Control.R2, [L]);
			case Duo(true):
				bindKeys(Control.UP, [W]);
				bindKeys(Control.DOWN, [S]);
				bindKeys(Control.LEFT, [A]);
				bindKeys(Control.RIGHT, [D]);
				bindKeys(Control.ACCEPT, [G, Z]);
				bindKeys(Control.BACK, [H, X]);
				bindKeys(Control.PAUSE, [ONE]);
				bindKeys(Control.RESET, [R]);

				bindKeys(Control.L1, [A]);
				bindKeys(Control.U1, [S]);
				bindKeys(Control.R1, [D]);
				bindKeys(Control.L2, [FlxKey.LEFT]);
				bindKeys(Control.D1, [FlxKey.DOWN]);
				bindKeys(Control.R2, [FlxKey.RIGHT]);
			case Duo(false):
				bindKeys(Control.UP, [FlxKey.UP]);
				bindKeys(Control.DOWN, [FlxKey.DOWN]);
				bindKeys(Control.LEFT, [FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [O]);
				bindKeys(Control.BACK, [P]);
				bindKeys(Control.PAUSE, [ENTER]);
				bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#end
		*/
	}

	public function loadKeyBinds()
	{

		//trace(FlxKey.fromString(FlxG.save.data.upBind));

		removeKeyboard();
	
		inline bindKeys(Control.UP, [FlxKey.fromString(FlxG.save.data.upBind), FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.fromString(FlxG.save.data.downBind), FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.fromString(FlxG.save.data.leftBind), FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.fromString(FlxG.save.data.rightBind), FlxKey.RIGHT]);

		inline bindKeys(Control.L1, [FlxKey.fromString(FlxG.save.data.mania6LeftBind)]);
		inline bindKeys(Control.U1, [FlxKey.fromString(FlxG.save.data.mania6UpBind)]);
		inline bindKeys(Control.R1, [FlxKey.fromString(FlxG.save.data.mania6RightBind)]);
		inline bindKeys(Control.N4, [FlxKey.fromString(FlxG.save.data.maniaCenterBind)]);
		inline bindKeys(Control.L2, [FlxKey.fromString(FlxG.save.data.mania6Left2Bind)]);
		inline bindKeys(Control.D1, [FlxKey.fromString(FlxG.save.data.mania6DownBind)]);
		inline bindKeys(Control.R2, [FlxKey.fromString(FlxG.save.data.mania6Right2Bind)]);

		inline bindKeys(Control.N0, [FlxKey.fromString(FlxG.save.data.mania8LeftBind)]);
		inline bindKeys(Control.N1, [FlxKey.fromString(FlxG.save.data.mania8DownBind)]);
		inline bindKeys(Control.N2, [FlxKey.fromString(FlxG.save.data.mania8UpBind)]);
		inline bindKeys(Control.N3, [FlxKey.fromString(FlxG.save.data.mania8RightBind)]);
		inline bindKeys(Control.N4, [FlxKey.fromString(FlxG.save.data.maniaCenterBind)]);
		inline bindKeys(Control.N5, [FlxKey.fromString(FlxG.save.data.mania8Left2Bind)]);
		inline bindKeys(Control.N6, [FlxKey.fromString(FlxG.save.data.mania8Down2Bind)]);
		inline bindKeys(Control.N7, [FlxKey.fromString(FlxG.save.data.mania8Up2Bind)]);
		inline bindKeys(Control.N8, [FlxKey.fromString(FlxG.save.data.mania8Right2Bind)]);

		inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
		inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
		inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
		inline bindKeys(Control.RESET, [R]);
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);
		
		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#else
		addGamepadLiteral(id, [
			//Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			//Swap Y and X for switch
			Control.RESET => [Y],
			Control.CHEAT => [X]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
