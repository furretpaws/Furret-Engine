package;

#if windows
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class ChartingState extends MusicBeatState
{
	var eventTypes:Array<Dynamic> =
	[
		['', "Nothing"],
		['Add Camera Zoom', "Used on Milf\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: HUD zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\nFormat: Duration and intensity (Example: 1, 0.05)"],
		['Play Animation', "Plays an animation on a character. \n \nValue 1: Animation to play \nValue 2:\n0: Dad\n1: Girlfriend\n2: Boyfriend"],
		['Switch Character', "Replaces a character. \n \nValue 1: Character to replace (Dad, BF or GF)\nValue 2: New character (Example: mom)"],
		['Screen Flash', 'The screen is filled with this color and gradually\nreturns to normal. \n \nValue 1: Color\nValue 2: Duration\n[!] If there is no valid color the event will be canceled'],
		['Tween Camera Zoom', 'Zoom in or zoom out the camera\n \nValue 1: Zoom\nValue 2: Duration']
	];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;
	var S_GRID_SIZE:Int = 40;
	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNotes:FlxTypedGroup<Note>;

	var nextRenderedSustains:FlxTypedGroup<FlxSprite>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;
	var gridMult:Int = 2;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var player1TextField:FlxInputText;
	var player2TextField:FlxInputText;
	var gfTextField:FlxInputText;
	var cutsceneTextField:FlxInputText;
	var uiTextField:FlxInputText;
	var stageTextField:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound = null;

	var gridBlackLine:FlxSprite;

	var gridBlack:FlxSprite;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var selectedEvents:Int = 0;

	var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", PlayState.SONG.song);
		#end

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 32);
		add(gridBG);
		gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 9), Std.int(gridBG.height / 2), FlxColor.BLACK);
		gridBlack.alpha = 0.4;
		add(gridBlack);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		var eventGridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(eventGridBlackLine);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);


		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		nextRenderedSustains = new FlxTypedGroup<FlxSprite>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				isHey: false,
				speed: 1,
				mania: 0,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				validScore: false
			};
		}
		
		if(curSection >= _song.notes.length) curSection = _song.notes.length - 1;

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(50, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 9), 4);
		add(strumLine);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Char", label: 'Char'},
			{name: "Events", label: 'Events'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addCharsUI();
		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		updateHeads();

		add(curRenderedSustains);
		add(nextRenderedSustains);
		add(curRenderedNotes);
		add(nextRenderedNotes);
		super.create();
	}

	var check_mute_inst:FlxUICheckBox = null;
	var metronome:FlxUICheckBox = null;

	function addCharsUI():Void
	{
		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(80, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(80, 120, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(80, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		var curStage = _song.stage;

		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";


		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);

		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();

	}
	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		check_mute_inst = new FlxUICheckBox(10, 230, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 30, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if(vocals != null) {
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		metronome = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Metronome', 100);
		metronome.checked = false;

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function()
		{
			PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
			FlxG.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = _song.song.toLowerCase();
			var file:String = Paths.json(songName + '/events');
			#if sys
			if (sys.FileSystem.exists(file))
			#else
			if (OpenFlAssets.exists(file))
			#end
			{
				PlayState.SONG = Song.loadFromJson('events', songName);
				FlxG.resetState();
			}
		});

		var clear_events:FlxButton = new FlxButton(loadAutosaveBtn.x, 320, 'Clear events', function()
			{
				for (sec in 0..._song.notes.length) {
					var count:Int = 0;
					while(count < _song.notes[sec].sectionNotes.length) {
						var note:Array<Dynamic> = _song.notes[sec].sectionNotes[count];
						if(note != null && note[1] < 0) {
							_song.notes[sec].sectionNotes.remove(note);
						} else {
							count++;
						}
					}
				}
				updateGrid();
			});
			
		var clear_notes:FlxButton = new FlxButton(loadAutosaveBtn.x, clear_events.y + 20, 'Clear notes', function()
			{
				for (sec in 0..._song.notes.length) {
					var count:Int = 0;
					while(count < _song.notes[sec].sectionNotes.length) {
						var note:Array<Dynamic> = _song.notes[sec].sectionNotes[count];
						if(note != null && note[1] > -1) {
							_song.notes[sec].sectionNotes.remove(note);
						} else {
							count++;
						}
					}
				}
				updateGrid();
			});

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 75, 0.5, 1, 1, 339, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
		tab_group_song.add(metronome);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'Song BPM:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(camPos);
	}

	var stepperLength:FlxUINumericStepper;
	var stepperAltAnim:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		stepperAltAnim = new FlxUINumericStepper(10, 200, 1, Conductor.bpm, 0, 999, 0);
		stepperAltAnim.value = 0;
		stepperAltAnim.name = 'alt_anim_number';
		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];

				var half = keyAmmo[_song.mania];
				note[1] = (note[1] + half) % (half * 2);
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		// check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		// check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		// tab_group_section.add(check_altAnim);
		tab_group_section.add(stepperAltAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; //I wanted to use a stepper but we can't scale these as far as i know :(
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		var ammolabel = new FlxText(10,35,64,'Keys amount:');

		var m_check = new FlxUICheckBox(10, 165, null, null, "6", 100);
		m_check.checked = (_song.mania == 1);
		m_check.callback = function()
		{
			_song.mania = 0;
			if (m_check.checked)
			{
				_song.mania = 1;
			}
			trace('Grid changed to 6 keys!');
			trace(_song.mania);
		};

		var m_check2 = new FlxUICheckBox(10, 225, null, null, "9", 100);
		m_check2.checked = (_song.mania == 2);
		m_check2.callback = function()
		{
			_song.mania = 0;
			if (m_check2.checked)
			{
				_song.mania = 2;
			}
			trace('Grid changed to 9 keys!');
			trace(_song.mania);
		};
		var m_check3 = new FlxUICheckBox(10, 145, null, null, "5", 100);
		m_check3.checked = (_song.mania == 3);
		m_check3.callback = function()
		{
			_song.mania = 0;
			if (m_check3.checked)
			{
				_song.mania = 3;
			}
			trace('Grid changed to 5 keys!');
			trace(_song.mania);
		};
		var m_check4 = new FlxUICheckBox(10, 185, null, null, "7", 100);
		m_check4.checked = (_song.mania == 4);
		m_check4.callback = function()
		{
			_song.mania = 0;
			if (m_check4.checked)
			{
				_song.mania = 4;
			}
			trace('Grid changed to 7 keys!');
			trace(_song.mania);
		};
		var m_check5 = new FlxUICheckBox(10, 205, null, null, "8", 100);
		m_check5.checked = (_song.mania == 5);
		m_check5.callback = function()
		{
			_song.mania = 0;
			if (m_check5.checked)
			{
				_song.mania = 5;
			}
			trace('Grid changed to 8 keys!');
			trace(_song.mania);
		};
		var m_check6 = new FlxUICheckBox(10, 65, null, null, "1", 100);
		m_check6.checked = (_song.mania == 5); 
		m_check6.callback = function()
		{
			_song.mania = 0;
			if (m_check6.checked)
			{
				_song.mania = 6;
			}
			trace('Grid changed to 1 key!');
			trace(_song.mania);
		};
		var m_check7 = new FlxUICheckBox(10, 85, null, null, "2", 100);
		m_check7.checked = (_song.mania == 7);
		m_check7.callback = function()
		{
			_song.mania = 0;
			if (m_check7.checked)
			{
				_song.mania = 7;
			}
			trace('Grid changed to 2 keys!');
			trace(_song.mania);
		};
		var m_check8 = new FlxUICheckBox(10, 105, null, null, "3", 100);
		m_check8.checked = (_song.mania == 5);
		m_check8.callback = function()
		{
			_song.mania = 0;
			if (m_check8.checked)
			{
				_song.mania = 8;
			}
			trace('Grid changed to 3 keys!');
			trace(_song.mania);
		};

		var m_check0 = new FlxUICheckBox(10, 125, null, null, "4", 100);
		m_check0.checked = (_song.mania == 0);
		m_check0.callback = function()
		{
			_song.mania = 0;
			if (m_check0.checked)
			{
				_song.mania = 0;
			}
			trace('Grid changed to 4 keys! (default)');
			trace(_song.mania);
		};

		tab_group_note.add(ammolabel);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(m_check0);
		tab_group_note.add(m_check);
		tab_group_note.add(m_check2);
		tab_group_note.add(m_check3);
		tab_group_note.add(m_check4);
		tab_group_note.add(m_check5);
		tab_group_note.add(m_check6);
		tab_group_note.add(m_check7);
		tab_group_note.add(m_check8);

		UI_box.addGroup(tab_group_note);

		UI_box.addGroup(tab_group_note);
	}

	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		var descText:FlxText = new FlxText(20, 200, 0, eventTypes[0][0]);

		var daEvents:Array<String> = [];
		for (i in 0...eventTypes.length) {
			daEvents.push(eventTypes[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		var eventDropDown = new FlxUIDropDownMenu(20, 50, FlxUIDropDownMenu.makeStrIdLabelArray(daEvents, true), function(pressed:String) {
			selectedEvents = Std.parseInt(pressed);
			descText.text = eventTypes[selectedEvents][1];
			if(curSelectedNote != null) {
				curSelectedNote[2] = eventTypes[selectedEvents][0];
			}
		});

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		#if sys
		FlxG.sound.playMusic(Sound.fromFile("assets/music/"+daSong+"_Inst"+TitleState.soundExt), 0.6);
		#else
		FlxG.sound.playMusic('assets/music/' + daSong + "_Inst" + TitleState.soundExt, 0.6);
		#end
		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		if (_song.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile("assets/music/"+daSong+"_Voices"+TitleState.soundExt);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded("assets/music/" + daSong + "_Voices" + TitleState.soundExt);
			#end
			FlxG.sound.list.add(vocals);

		}

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
		}


		FlxG.sound.music.onComplete = function()
		{
			if (_song.needsVoices) {
				vocals.pause();
				vocals.time = 0;
			}

			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateSong() {
		FlxG.sound.playMusic(Paths.inst(_song.song), 0.6, false);
		if (check_mute_inst != null && check_mute_inst.checked) FlxG.sound.music.volume = 0;

		FlxG.sound.music.onComplete = function()
		{
			generateSong();
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if(vocals != null) {
				vocals.play();
				vocals.pause();
				vocals.time = 0;
			}
			changeSection();
			curSection = 0;
			updateGrid();
			updateSectionUI();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateGrid();
					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			} else if (wname == 'alt_anim_number')
			{
				_song.notes[curSection].altAnimNum = Std.int(nums.value);
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText) && curSelectedNote != null) {
			if(sender == value1InputText) {
				curSelectedNote[3] = value1InputText.text;
			} else if(sender == value2InputText) {
				curSelectedNote[4] = value2InputText.text;
			} else if(sender == strumTimeInputText) {
				var value:Float = Std.parseFloat(strumTimeInputText.text);
				if(Math.isNaN(value)) value = 0;
				curSelectedNote[0] = value;
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + add)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();
		if (_song.mania == 8 && gridBG.width != GRID_SIZE * 6)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 7, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 7), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			gridBlackLine.x = 160;
		}
		if (_song.mania == 7 && gridBG.width != GRID_SIZE * 4)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 5, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 5), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			gridBlackLine.x = 120;
		}
		if (_song.mania == 6 && gridBG.width != GRID_SIZE * 2)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 3, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 3), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridBlackLine.x = 80;
			add(gridBlack);
		}
		if (_song.mania == 5 && gridBG.width != S_GRID_SIZE * 16)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 17, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 17), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridBlackLine.x = 357.895;
			add(gridBlack);
		}
		if (_song.mania == 4 && gridBG.width != S_GRID_SIZE * 14)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 15, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 15), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			gridBlackLine.x = 320;
		}
		if (_song.mania == 3 && gridBG.width != S_GRID_SIZE * 10)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 11, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 11), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			gridBlackLine.x = 239;
		}
		if (_song.mania == 2 && gridBG.width != S_GRID_SIZE * 18)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 19, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 19), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridBlackLine.x = 400;
			add(gridBlack);
		}
		if (_song.mania == 1 && gridBG.width != GRID_SIZE * 12)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 13, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 13), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			gridBlackLine.x = 281.081081081081;
		}
		if (_song.mania == 0 && gridBG.width != GRID_SIZE * 8)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 32);
			add(gridBG);
			remove(gridBlack);
			gridBlack = new FlxSprite(0, GRID_SIZE * 16).makeGraphic(Std.int(GRID_SIZE * 9), Std.int(gridBG.height / 2), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			add(gridBlack);
			remove(gridBlackLine);
			gridBlackLine = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
			add(gridBlackLine);
		}
		UI_box.x = FlxG.width / 2;// + 160 * _song.mania;
		UI_box.y = 20;
		if (_song.mania != 0)
		{
			UI_box.x = FlxG.width / 2 + 160;// + 160 * _song.mania;
			UI_box.y = 100;
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		_song.song = typingShit.text;
		_song.player1 = player1TextField.text;
		_song.player2 = player2TextField.text;
		_song.gf = gfTextField.text;
		_song.stage = stageTextField.text;
		_song.cutsceneType = cutsceneTextField.text;
		_song.uiType = uiTextField.text;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		camPos.y = strumLine.y;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.mouse.visible = false;
			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if(vocals != null) vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus && !value1InputText.hasFocus && !value2InputText.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if(vocals != null) vocals.pause();
				}
				else
				{
					if(vocals != null) {
						vocals.play();
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
						vocals.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();

				var holdingShift:Float = FlxG.keys.pressed.SHIFT ? 3 : 1;
				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				if (FlxG.keys.pressed.W)
				{
					FlxG.sound.music.time -= daTime;
				}
				else
					FlxG.sound.music.time += daTime;

				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
			if(curSection <= 0) {
				changeSection(_song.notes.length-1);
			} else {
				changeSection(curSection - shiftThing);
			}
		}

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep
			+ "\nBeat: "
			+ curBeat;

		var playedSound:Array<Bool> = [false, false, false, false]; //Prevents earrape GF ahegao sounds
		curRenderedNotes.forEachAlive(function(note:Note) {
			if(note.strumTime < Conductor.songPosition) {
				//do nothing
			} else {
				note.alpha = 1;
			}
		});
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		if(vocals != null) {
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
		}
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.setPosition(0, 100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
		else
		{
			rightIcon.setPosition(0, 100);
			leftIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}
		while (nextRenderedNotes.members.length > 0)
		{
			nextRenderedNotes.remove(nextRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (nextRenderedSustains.members.length > 0)
		{
			nextRenderedSustains.remove(nextRenderedSustains.members[0], true);
		}

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			//get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		// CURRENT SECTION
		for (i in _song.notes[curSection].sectionNotes)
		{
			var note:Note = setupNoteData(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
			{
				curRenderedSustains.add(setupSusNote(note));
			}
		}

		// NEXT SECTION
		if(curSection < _song.notes.length-1) {
			for (i in _song.notes[curSection+1].sectionNotes)
			{
				var note:Note = setupNoteData(i, true);
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					nextRenderedSustains.add(setupSusNote(note));
				}
			}
		}
	}

	function setupNoteData(i:Array<Dynamic>, isNextSection:Bool):Note
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];

		var note:Note = new Note(daStrumTime, daNoteInfo % (keyAmmo[_song.mania]));
		if(daNoteInfo > -1) { //Common note
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		} else { //Event note
			note.loadGraphic(Paths.image('eventArrow'));
			note.ability = daSus;
			note.value1 = i[3];
			note.value2 = i[4];
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		}
		note.updateHitbox();
		note.x = Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE;
		if(isNextSection && _song.notes[curSection].mustHitSection != _song.notes[curSection+1].mustHitSection) {
			if(daNoteInfo > 3) {
				note.x -= GRID_SIZE * 4;
			} else if(daNoteInfo > -1) {
				note.x += GRID_SIZE * 4;
			}
		}
		note.y = (GRID_SIZE * (isNextSection ? 16 : 0)) + Math.floor(getYfromStrum((daStrumTime - sectionStartTime(isNextSection ? 1 : 0)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
		return note;
	}

	function setupSusNote(note:Note):FlxSprite {
		var spr:FlxSprite = new FlxSprite(note.x + (GRID_SIZE * 0.4),
			note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, gridBG.height / gridMult)));
		return spr;
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			altAnimNum: 0
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % (keyAmmo[_song.mania]) == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % (keyAmmo[_song.mania]) == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteSus = 0;
		var daAlt = false;

		if(noteData > -1) {
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus]);
		} else {
			var event = eventTypes[selectedEvents][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, event, text1, text2]);
		}
		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL && noteData > -1)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (gridBG.height / gridMult), 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + (gridBG.height / gridMult));
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
