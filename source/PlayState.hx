package;

import randomShit.dumb.FNBUINotificationBar;
import randomShit.util.DumbUtil;
#if desktop
import Discord.DiscordClient;
#end
import randomShit.util.CheckinMultiple;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import NewCharacterSelect.SelectableFile as BussyWater;
import randomShit.util.CustomRandom;
import randomShit.dumb.Bonk;

#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	static final BASE_SONG_LIST:Array<String> = [
		'tutorial',
		'bopeebo',
		'fresh',
		'dad-battle',
		'eggnog',
		'fresh',
		'high',
		'blammed',
		'cocoa',
		'milf',
		'monster',
		'philly-nice',
		'pico',
		'roses',
		'senpai',
		'satin-panties',
		'south',
		'spookeez',
		'thorns',
		'winter-horrorland' // TEST IS LEFT OUT AS I HAVE A MOD DIALOGUE FOR IT. LOL
	];
	static inline final WEEK4 = 'week4';

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	var swagNoteGlitch:FlxGlitchEffect;
	var areYaHavinFun:FlxSound;
	var coconut:Coconut;
	public static var snowdriftDiedCheating:Bool = false;
	public var weHaveNotifications:Bool = false;
	public var modchartNotifications:Map<String, ModchartNotification> = new Map<String, ModchartNotification>();

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	//public var noteOverrideMap:Map<String, String> = new Map();

	var bfOverride:String;
	/**if you trigger the FuckYouToo message this gets set to true for the song that plays after it exits.*/
	public static var dunFuckedUpNow:Bool = false;

	public var lastVanessa:Int = 0;
	var whiteWoman:Bool = false;
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var instrumentalShit:String = null;
	public static var isStoryMode:Bool = false;
	public static var isDebugLaunch:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var vocals:FlxSound;

	public var dad:Character;
	public var dadGlitch:FlxGlitchEffect;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	var alreadyStartedVannyDeath:Bool = false;
	var boyPussy:BussyWater;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];
	var fuckBg:FlxSprite;
	var fuckText:FlxText;

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	private static var shared:String = 'shared';
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	static var ntPowerAffectsHealthRegain:Bool = false;
	var ntPowerLevel:Int = 100;
	static var playerCanRegainHealth:Bool = true;
	var ntPowerBar:FlxBar;
	var ntPowerBG:AttachedSprite;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var healthLossMisses:Bool = false;
	public var healthDrain:Float = 0; // IT'LL BE A DECIMAL OF WHATEVER VALUE YOU SET!
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var weDoALittleTrollin:Bool = false;
	public var practiceMode:Bool = false;
	public var freeplayCutscenes:Bool = false;
	public var freeplayCutsceneRepeats:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	var stupidEngineWater:FlxText;
	var cumMonster:String = '';
	var curCum:String = '';

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;
	public var vanSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var vanny:FlxText;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var originalBfX:Float;
	var originalBfY:Float;
	var snowdriftHat:BGSprite;
	var originalBfWidth:Float;
	var originalBfHeight:Float;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	var vussy:FlxSprite;
	var vanJump:FlxSprite;
	public var vanHit:Bool = false;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	var songLength:Float = 0;
	static var ntCharsWithPL:Array<String> = [
		'nt-stuck',
		'ralph',
		'ralph-LowPower'
	];

	var notifBarLua:FNBUINotificationBar;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var instancealt:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	/**Finish what you started.*/
	public static var fwys:Bool = false;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	var commonVariations:Array<String> = [
		'-car',
		'-christmas',
		'-pixel'
	];
	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	var existingVannyNotes:Array<Dynamic> = [];
	var nonVannyNotes:Array<Dynamic> = [];
	function checkMoreVannyNotes(notes:FlxTypedGroup<Note>):Void {
		
		notes.forEachAlive(function (daNote:Note) {
			if (daNote.noteType == 'Vanny Note') {
				// trace(daNote);
				if (!existingVannyNotes.contains(daNote)) existingVannyNotes.push(daNote);
				// trace(existingVannyNotes[daNote]);
			} else {
				if (!nonVannyNotes.contains(daNote)) nonVannyNotes.push(daNote);
			}

			if (existingVannyNotes.length == 0) {
				vanSound.stop();
				if (dadGlitch.active) dadGlitch.active = false;
				if (swagNoteGlitch.active) swagNoteGlitch.active = false;
			}
		});
	}
	public function showLuaNotification(name:String, length:Int) {
		if (notifBarLua != null) {
			notifBarLua.changeMsg(modchartNotifications[name].notifText);
			notifBarLua.show(length);
		}
	}

	public function makeNotifBar(yPos:Float) {
		if (notifBarLua == null) {
			notifBarLua = new FNBUINotificationBar('PLACEHOLDER!!', yPos);
			notifBarLua.cameras = [camOther];
			add(notifBarLua);
		}
	}
	function checkForDialogue(SongName:String) {
		if (FileSystem.exists('assets/data/' + SongName + '/dialogue.json')) {
			dialogueJson = parseDiaJson('assets/data/' + SongName + '/dialogue.json');
			startDialogue(dialogueJson);
		} else if (FileSystem.exists('mods/data/' + SongName + '/dialogue.json')) {
			dialogueJson = parseDiaJson('mods/data/' + SongName + '/dialogue.json');
			startDialogue(dialogueJson);
		} else if (FileSystem.exists('mods/' + Paths.currentModDirectory + '/data/' + SongName + '/dialogue.json')) {
			dialogueJson = parseDiaJson('mods/' + Paths.currentModDirectory + '/data/' + SongName + '/dialogue.json');
			startDialogue(dialogueJson);
		} else {
			trace('no dialogue for ' + SongName + ' oh well');
			startCountdown();
		}
	}

	function parseDiaJson(input:String):DialogueFile {
		var bussy = cast Json.parse(sys.io.File.getContent(input));
		trace(bussy);
		return bussy;
	}

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		trace(1 * (FlxG.save.data.framerate * 0.5 / 10));
		// for lua
		instance = this;
		if (FlxG.camera.bgColor != FlxColor.BLACK) {
			trace('RESETTING CAMERA COLOUR');
			FlxG.camera.bgColor = FlxColor.BLACK;
		}
		if (SelectChara.bfOverride != null) {
			bfOverride = SelectChara.bfOverride;
		} else {
			bfOverride = SONG.player1;
		}
		vanSound = new FlxSound();
		vanSound.loadEmbedded(Paths.sound('vannyNoteSound', 'shared'), true, false);
		FlxG.sound.list.add(vanSound);
		trace(weDoALittleTrollin);
		

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));


		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];
		
		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		healthDrain = Std.parseFloat("0." + ((ClientPrefs.getGameplaySetting('healthDrain', 0) < 10) ? "0" : "") + ClientPrefs.getGameplaySetting('healthDrain', 0)); // this SHOULD make it 0.15 if you've set it to 15, 0.04 if you have it set to 4!
		healthLossMisses = ClientPrefs.getGameplaySetting('healthlossmulti', false);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		weDoALittleTrollin = ClientPrefs.getGameplaySetting('botplayTroll', false);
		freeplayCutscenes = ClientPrefs.getGameplaySetting('fpScenes', false);
		freeplayCutsceneRepeats = ClientPrefs.getGameplaySetting('fpScenesRepeat', false);

		ntPowerAffectsHealthRegain = ClientPrefs.ntPowerIsEnabled;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode && !dunFuckedUpNow)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else if (dunFuckedUpNow && SONG.song.toLowerCase() == 'cheating') {
			detailsText = "CLOWNING!!";
		} else if (dunFuckedUpNow && SONG.song.toLowerCase() != 'cheating') {
			detailsText = "Probably debugging? ?????????????";
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		vussy = new FlxSprite(0, 0);
		vussy.frames = Paths.getSparrowAtlas('vanessa');
		vussy.animation.addByPrefix('vanny', 'You Get No Vussy Today, Sir', 24, false);
		vussy.animation.addByIndices('andTheyDontSmellLikeCheetos', "You Get No Vussy Today, Sir", [32, 33], "", 24, false);
		vussy.animation.play('andTheyDontSmellLikeCheetos');
		vussy.visible = false;
		vanJump = new FlxSprite(0, 0);
		vanJump.frames = Paths.getSparrowAtlas('vabussy');
		vanJump.animation.addByPrefix('bussy', 'Are you having fun yet', 24, false);
		vanJump.animation.addByPrefix('static', 'youre done', 24, false);
		vanJump.animation.addByIndices('vannybussy', 'Are you having fun yet', [101, 102], "", 24, false);
		vanJump.animation.play('vannybussy');
		vanJump.visible = false;
		vanJump.cameras = [camOther];
		vanJump.screenCenter();
		vanJump.setGraphicSize(1280, 720);
		areYaHavinFun = new FlxSound();
		areYaHavinFun.loadEmbedded(Paths.sound('areYaHavinFunYet', shared), false);
		add(vussy);
		add(vanJump);
		// checkMoreVannyNotes(notes);
		// CoolUtil.precacheSound('jumpedYaMom');
		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
			if (snowdriftDiedCheating && (bfOverride != 'snowdrift' && bfOverride != 'snowdrift-car')) {
				snowdriftHat = new BGSprite('snowdriftHat', BF_X, BF_Y - 100, 1, 1, null, null, 'shared');
				add(snowdriftHat);
			}

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<BGSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:BGSprite = new BGSprite('philly/win' + i, city.x, city.y, 0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:BGSprite = new BGSprite('philly/street', -40, 50);
				add(street);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1, null, WEEK4);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4, null, WEEK4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true, WEEK4);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4, null, WEEK4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false, WEEK4);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true, WEEK4);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160, null, WEEK4);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				CoolUtil.precacheSound('Lights_Shut_off');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/

				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);
		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}


		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		dadGlitch = new FlxGlitchEffect(3, 3, 0.05, HORIZONTAL);
		if (dad.curCharacter == 'amor' && existingVannyNotes.length >= 1) {
		dadGlitch.apply(dad.graphic.bitmap);
		dadGlitch.size = 1;
		}
		dadGlitch.active = false;
		// add(dadGlitch);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		// dadGroup.add(dadGlitch);
		startCharacterLua(dad.curCharacter);
		
		//boyfriend = new Boyfriend(0, 0, SONG.player1);
		boyfriend = new Boyfriend(0, 0, bfOverride);
		if (FileSystem.exists(Paths.modsSelectable(bfOverride))) {
			boyPussy = cast Json.parse(sys.io.File.getContent(Paths.modsSelectable(bfOverride)));
		}
		if (snowdriftDiedCheating && (bfOverride != 'snowdrift' && bfOverride != 'snowdrift-car')) {
			GameOverSubstate.characterName = 'bf';
			snowdriftHat.x = boyfriend.positionArray[0];
			snowdriftHat.y = boyfriend.positionArray[1] + 150;
		}
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		setGameOverShit();
		// GameOverSubstate.characterName = SONG.player1;
		originalBfWidth = boyfriend.width;
		originalBfHeight = boyfriend.height;
		startCharacterLua(boyfriend.curCharacter);

		coconut = new Coconut(0, -500, boyfriend.curCharacter);
		coconut.visible = false;
		add(coconut);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.contains('gf') /* || dad.curCharacter == 'bfafter' */) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false; // bfafter is gitignored
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}
		if (randomShit.util.TitleShit.pubic != null) {
			cumMonster = randomShit.util.TitleShit.pubic;
			curCum = cumMonster;
		} else {
			cumMonster = FlxG.random.getObject(["Piss", "Shitpost", "Beetle", "69"]);
			if (cumMonster == "69") cumMonster += " (Nice)";
			curCum = cumMonster;
		}
		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		ntPowerBG = new AttachedSprite('ntPowerBar');
		//ntPowerBG.x = 0;
		//ntPowerBG.y = 50
		ntPowerBG.x = 0;
		ntPowerBG.screenCenter(X);
		ntPowerBG.y = FlxG.width * 0.78;
		ntPowerBG.scrollFactor.set();
		ntPowerBG.alpha = 1;
		ntPowerBG.color = FlxColor.BLACK;
		ntPowerBG.xAdd = -4;
		ntPowerBG.yAdd = -4;
		ntPowerBG.visible = true;
		ntPowerBar = new FlxBar(ntPowerBG.x + 4, ntPowerBG.y + 4, LEFT_TO_RIGHT, Std.int(ntPowerBG.width - 8), Std.int(ntPowerBG.height - 8), this, 'ntPowerLevel', 0, 100);
		ntPowerBar.scrollFactor.set();
		ntPowerBar.createFilledBar(0xFF000000, FlxColor.fromRGB(0, 0, 127, 255));
		ntPowerBar.numDivisions = 400;
		ntPowerBar.alpha = 1;
		ntPowerBar.visible = ntPowerBG.visible;
		add(ntPowerBG);
		add(ntPowerBar);
		ntPowerBG.sprTracker = ntPowerBar;
		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
		fuckBg = new FlxSprite(0).makeGraphic(FlxG.width, 26, FlxColor.fromRGB(255, 0, 0, 128));
		fuckBg.cameras = [camOther];
		if (dunFuckedUpNow) add(fuckBg);
		fuckText = new FlxText(0, 4, FlxG.width, 'Just know you did this to yourself. Ghost tapping is forced off! Fuck you!');
		fuckText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fuckText.cameras = [camOther];
		if (dunFuckedUpNow) add(fuckText);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		if (dad.curCharacter == 'nobody') {
			iconP2.changeIcon(gf.healthIcon);
		}
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		if (ClientPrefs.smallScreenFix) scoreTxt.y = (0.11 * FlxG.height) + 36;

		stupidEngineWater = new FlxText(0, (0.85 * FlxG.height), 0, SONG.song + " - " + ((storyDifficultyText.length > 0) ? storyDifficultyText : "Suspicious") + " | " + cumMonster + " Engine " + MainMenuState.stupidEngineVersion + " (Hi there!)");
		stupidEngineWater.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		stupidEngineWater.scrollFactor.set();
		stupidEngineWater.borderSize = 1.25;
		stupidEngineWater.visible = ClientPrefs.showWatermark;
		add(stupidEngineWater);
		if (ClientPrefs.smallScreenFix) stupidEngineWater.y = 0;

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		if (weDoALittleTrollin) botplayTxt.text = '';
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		stupidEngineWater.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		ntPowerBG.cameras = [camHUD];
		ntPowerBar.cameras = [camHUD];
		

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;


		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if ((isStoryMode || freeplayCutscenes) && (!seenCutscene || freeplayCutsceneRepeats))
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				
				case 'starcrossed':
					dialogueJson = cast Json.parse(sys.io.File.getContent('mods/data/starcrossed/dialogue.json'));
					startDialogue(dialogueJson);
				case 'test':
						dialogueJson = cast Json.parse(sys.io.File.getContent('mods/data/test/dialogue.json'));
						startDialogue(dialogueJson);
				case 'cheating':
						dialogueJson = cast Json.parse(sys.io.File.getContent('mods/data/cheating/dialogue.json'));
						startDialogue(dialogueJson);
				default:
					checkForDialogue(PlayState.SONG.song.toLowerCase());
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		/* CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3'); */

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		if (SONG.player2 == 'nobody') {
			healthBar.createFilledBar(FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		} else {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					bfOverride = newCharacter;
					setGameOverShit();
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.contains('gf') /* || char.curCharacter == 'bfafter' */) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	/**sets game over character better than i did before*/
	function setGameOverShit() {
		trace('fail prevention is go');
		if (boyPussy == null) {
		for (penis in commonVariations) {
			if (bfOverride.contains(penis)) {
				switch (penis) {
					case '-car':
						GameOverSubstate.characterName = bfOverride.substr(0, bfOverride.length - 4);
					case '-christmas':
						GameOverSubstate.characterName = bfOverride.substr(0, bfOverride.length - 10);
					case '-pixel':
						if (FileSystem.exists(Paths.characterJson(bfOverride + '-dead'))) {
							GameOverSubstate.characterName = bfOverride + '-dead';
						} else {
							GameOverSubstate.characterName = 'bf-pixel-dead';
						}
				}
 			}
		}
		if (boyfriend.animOffsets.exists('firstDeath')) {
			GameOverSubstate.characterName = boyfriend.curCharacter;
		}
	} else {
		GameOverSubstate.characterName = (boyPussy.DeathName != null) ? boyPussy.DeathName : boyPussy.CharName;
	}
	}
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			if (dialogueFile.dialogueMusic != null) {
				FlxG.sound.playMusic(dialogueFile.dialogueMusic, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			}
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	var ntStartSong:Bool = false;
	var shitty:FlxTween;
	var YourMother:Float = 0;
	function doNtHealthShit() {
		if (ntPowerBG.y != FlxG.height * 0.78) {
			ntPowerBG.y = FlxG.height * 0.78;
			ntPowerBG.screenCenter(X);
			if (ntPowerBG.alpha != 1) {
				ntPowerBG.alpha = 1;
			}
			ntPowerBG.visible = true;
			ntPowerBG.cameras = [camHUD];
		}
		ntPowerBG.visible = true;
		if (ntStartSong && ntPowerLevel > 0) {
			if (YourMother < 30) {
				YourMother += 0.5;
				trace(ntPowerLevel);
				trace(YourMother);
			} else {
				YourMother = 0;
			}
		}
		if (ntStartSong && ntPowerLevel > 0 && YourMother == 30) {
			ntPowerLevel -= 2;
			trace('NT POWER LEVEL: ' + ntPowerLevel);
		}
		if (ntPowerLevel <= 0) {
			ntPowerLevel = 0;
			if (playerCanRegainHealth) {
				trace('HEALTH REGAIN DISABLED!');
				playerCanRegainHealth = false;
			}
		}
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.name != 'jumpy')
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.contains('gf') && /* dad.curCharacter != 'bfafter' && */ !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
								if (ntCharsWithPL.contains(SONG.player1) || ntCharsWithPL.contains(bfOverride)) ntStartSong = true;
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (instrumentalShit != null) {
			trace("LOADING CUSTOM INSTRUMENTAL!!");
			FlxG.sound.playMusic(Paths.inst(instrumentalShit), 1, false);
		} else FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(ntPowerBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(ntPowerBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			// if (storyDifficultyText == 'EX') vocals = new FlxSound().loadEmbedded(Paths.voicesEX(PlayState.SONG.song)); // i gitignored bob and bosip assets
			/* else */ vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		// trace(Paths.voicesEX(PlayState.SONG.song));
		FlxG.sound.list.add(vocals);
		/* if (storyDifficultyText == 'EX') FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.instEX(PlayState.SONG.song))) else */ FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst((instrumentalShit != null ? instrumentalShit : PlayState.SONG.song))));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:Array<Dynamic> = [newEventNote[0] + ClientPrefs.noteOffset - eventNoteEarlyTrigger(newEventNote), newEventNote[1], newEventNote[2], newEventNote[3]];
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				swagNoteGlitch = new FlxGlitchEffect(1, 1, 0.05, HORIZONTAL);
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if (swagNote.noteType == 'Vanny Note') swagNoteGlitch.apply(swagNote.graphic.bitmap);
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1)
							{ //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:Array<Dynamic> = [newEventNote[0] + ClientPrefs.noteOffset - eventNoteEarlyTrigger(newEventNote), newEventNote[1], newEventNote[2], newEventNote[3]];
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;


//	function checkMoreVannyNotes(notes:FlxTypedGroup<Note>) {}

	function checkMoreVannyNotes(notes:FlxTypedGroup<Note>) {}

	// var ntPowerBar:FlxSprite;

	//var ntPowerBar:FlxBar;
}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[1]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[2].toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event[2]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[3];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[1])) {
			eventPushedMap.set(event[1], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[1]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[1]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				if (ntCharsWithPL.contains(SONG.player1) || ntCharsWithPL.contains(bfOverride)) {
					@:privateAccess
					babyArrow.set_texture('NT_NOTE_ASSETS');
				} else if (OOTIS.check([SONG.player1, bfOverride], 'meta') || OOTIS.check([SONG.player1, bfOverride], 'bf')) {
					@:privateAccess
					babyArrow.set_texture('OC_NOTES_1');
				} else if (boyfriend.notesOverride != null) {
					@:privateAccess babyArrow.set_texture(boyfriend.notesOverride);
				}
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				if (dad.notesOverride != null) {
					@:privateAccess babyArrow.set_texture(dad.notesOverride);
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (vanSound.playing) {
				vanSound.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		if (dadGlitch.active) vanSound.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}
		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if (ntPowerBG != null) {
			ntPowerBG.update(elapsed);
		}

		if (cumMonster != curCum) {
			curCum = cumMonster;
			stupidEngineWater.text = SONG.song + " - " + ((storyDifficultyText.length > 0) ? storyDifficultyText : "Suspicious") + " | " + cumMonster + " Engine " + MainMenuState.stupidEngineVersion + " (Hi there!)";
		}
		if(ratingName == '?') {
			if (ntCharsWithPL.contains(SONG.player1) || ntCharsWithPL.contains(bfOverride) || (boyfriend != null && ntCharsWithPL.contains(boyfriend.curCharacter))) {
				scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (HIT A NOTE!) | Nextor Power Lv.: ' + ntPowerLevel;
			} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (HIT SOME NOTES%)';
			}
		} else {
			if (ntCharsWithPL.contains(SONG.player1) || ntCharsWithPL.contains(bfOverride) || (boyfriend != null && ntCharsWithPL.contains(boyfriend.curCharacter))) {
				scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC + ' | Nextor Power Lv.: ' + ntPowerLevel;
			} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
			}
		}
		
		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				#if debug
				openSubState(new randomShit.dumb.TheNewSandwich(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#end
				//}
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene && !dunFuckedUpNow)
		{
			openChartEditor();
		} else if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene && dunFuckedUpNow) {
			crashGame();
		}
		#if debug
		if (FlxG.keys.justPressed.BACKSPACE && startedCountdown && canPause) {
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			}
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20 && boyfriend.curCharacter == 'decktop') {
			if(boyfriend.curCharacter != 'decktop-were') {
				if(!boyfriendMap.exists('decktop-were')) {
					addCharacterToList('decktop-were', 0);
				}

				var lastAlpha:Float = boyfriend.alpha;
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get('decktop-were');
				boyfriend.alpha = lastAlpha;
				iconP1.changeIcon(boyfriend.healthIcon);
			}
			setOnLuas('boyfriendName', boyfriend.curCharacter);
		} else if (healthBar.percent >= 21 && boyfriend.curCharacter == 'decktop-were' && songMisses <= 10 && SONG.player1 != 'decktop-were') {
			if(boyfriend.curCharacter != 'decktop') {
				if(!boyfriendMap.exists('decktop')) {
					addCharacterToList('decktop', 0);
				}

				var lastAlpha:Float = boyfriend.alpha;
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get('decktop');
				boyfriend.alpha = lastAlpha;
				iconP1.changeIcon(boyfriend.healthIcon);
			}
			setOnLuas('boyfriendName', boyfriend.curCharacter);
		}
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else {
			if (healthBar.percent > 80 && boyfriend.curCharacter == 'decktop') {
				iconP1.changeIcon('decktop-gf');
				iconP1.animation.curAnim.curFrame = 1;
			} else if (healthBar.percent > 80 && boyfriend.curCharacter == 'decktop-were') {
				iconP1.changeIcon('decktop-Wgf');
				iconP1.animation.curAnim.curFrame = 1;
			}
			else if (iconP1.animation.name == 'decktop-gf' && boyfriend.curCharacter != 'decktop-gf' && healthBar.percent > 20 && healthBar.percent < 80) {
				iconP1.animation.curAnim.curFrame = 0;
				iconP1.changeIcon('decktop');
				} else if (iconP1.animation.name == 'decktop-Wgf' && boyfriend.curCharacter != 'decktop-were-gf' && healthBar.percent > 20 && healthBar.percent < 80) { 
					iconP1.changeIcon('decktopW');
					iconP1.animation.curAnim.curFrame = 0;
				}
					else {
			iconP1.animation.curAnim.curFrame = 0;
				}
		}
		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		/* var prevBeat:Int = 0;
		vanny = new FlxText(FlxG.width * 0.1 - 25, FlxG.height * 0.1 - 25, FlxG.width, "");
		vanny.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		vanny.cameras = [camHUD];
		#if debug
		add(vanny);
		#end
		if (curBeat > prevBeat) {
			prevBeat++;
			vanessaTimer();
		}
		if (FlxG.keys.justPressed.SPACE) {
			if (boyfriend.curCharacter == 'devan' && lastVanessa >= 15) {
				lastVanessa = 0;
				whiteWoman = false;
				boyfriend.setGraphicSize(1280, 720);
				boyfriend.x = 0;
				boyfriend.y = 0;
				boyfriend.updateHitbox();
				boyfriend.playAnim('jumpy', false);
				FlxG.sound.play(Paths.sound('jumpedYaMom'), 1, false);
				revertBf();
			} else {
				trace('What the fuck are you doing? Vanessa already spooked within past 15 seconds');
				FlxG.sound.play(Paths.sound('missnote' + Random.int(1,3)), 1, false);
			}
		} */ // This is all shit that I had for the devan character but scrapped in favour of an event lmfao
		if (vussy.visible && vussy.animation.finished && vussy.animation.curAnim.name == 'vanny') {
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				vussy.animation.play('andTheyDontSmellLikeCheetos');
				vussy.visible = false;
			});
		}
		if (vanHit && !alreadyStartedVannyDeath) {
			alreadyStartedVannyDeath = true;
			boyfriend.cameras = [camOther];
			if (boyfriend.animation.getByName('fart') != null) {
				boyfriend.playAnim('fart');
			} else if (SONG.player1 == 'edd') {
				boyfriend.playAnim('jumped');
			} else {
				boyfriend.playAnim('scared');
			}
				
			vanJump.visible = true;
			vanJump.animation.play('bussy');
			FlxG.sound.play(Paths.sound('jumpedYerDed'), 0.5, false);
			new FlxTimer().start(1.5, function(tmr:FlxTimer) {
				vanJump.animation.play('static');
				new FlxTimer().start(3.5, function(tmr:FlxTimer) {
					health -= 500;
				});
			});
		}

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(songSpeed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/

				// i am so fucking sorry for this if condition
				if (daNote.noteType == 'Vanny Note' && !vanSound.playing) {
					vanSound.play();
				}
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
					if (OOTIS.check([SONG.player1, bfOverride], 'meta') || OOTIS.check([SONG.player1, bfOverride], 'bf')) {
						@:privateAccess daNote.reloadNote('', 'OC_NOTES_1');
					} else if (ntCharsWithPL.contains(SONG.player1) || ntCharsWithPL.contains(bfOverride)) {
						@:privateAccess daNote.reloadNote('', 'NT_NOTE_ASSETS');
					} else if (boyfriend.notesOverride != null) {
						@:privateAccess daNote.reloadNote('', boyfriend.notesOverride);
					}
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
					if (dad.notesOverride != null) {
						@:privateAccess daNote.reloadNote('', dad.notesOverride);
					}
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						if (daNote.isSustainNote && !ClientPrefs.keSustains) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if(!ClientPrefs.keSustains)
						{
							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if (daNote.isSustainNote
									&& daNote.y + daNote.offset.y * daNote.scale.y <= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * songSpeed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if(ClientPrefs.keSustains && daNote.isSustainNote && daNote.wasGoodHit) doKill = true;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}
					if (daNote.noteType == 'Vanny Note') {
						if (!areYaHavinFun.playing) areYaHavinFun.play();
						existingVannyNotes.remove(daNote);
						checkMoreVannyNotes(notes);
					}
					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled || weDoALittleTrollin) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}
	function crashGame() {
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		CustomFadeTransition.nextCamera = camOther;
		MusicBeatState.switchState(new shitpost.YouThoughtYouAte());

		#if desktop
		DiscordClient.changePresence("Fucked Up... BAD", null, null, true);
		#end
	}
	public function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		CustomFadeTransition.nextCamera = camOther;
		MusicBeatState.switchState(new editors.ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				if (bfOverride == 'snowdrift' && dunFuckedUpNow && SONG.song.toLowerCase() == 'cheating') snowdriftDiedCheating = true;
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][2] != null)
				value1 = eventNotes[0][2];

			var value2:String = '';
			if(eventNotes[0][3] != null)
				value2 = eventNotes[0][3];

			triggerEventNote(eventNotes[0][1], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}
	var eventDadStuf:Array<String> = ['dad', 'Dad', 'DAD', 'daddy'];
	var eventGfStuf:Array<String> = ['girlfriend', 'gf', 'GF', 'Girlfriend', 'Gf', 'GIRLFRIEND'];
	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.contains('gf') /* || dad.curCharacter == 'bfafter' */) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}
			case 'Bonk':
				coconut.visible = true;
				if (eventDadStuf.contains(value1)) {
					coconut.x = dad.getGraphicMidpoint().x;
					coconut.y = dad.getGraphicMidpoint().y - 1000;
					coconut.targetY = dad.getGraphicMidpoint().y;
					coconut.target = 'Dad';
				} else if (eventGfStuf.contains(value1)) {
					coconut.x = gf.getGraphicMidpoint().x;
					coconut.y = gf.getGraphicMidpoint().y - 1000;
					coconut.targetY = gf.getGraphicMidpoint().y;
					coconut.target = 'GF';
				} else {
					coconut.x = boyfriend.getGraphicMidpoint().x;
					coconut.y = boyfriend.getGraphicMidpoint().y - 1000;
					coconut.targetY = boyfriend.getGraphicMidpoint().y;
					coconut.target = 'BF';
				}
				if (value2.length >= 1 && coconut.target == 'BF') {
					doCoconuttyThings(Std.parseFloat(value2));
				} else {
					doCoconuttyThings();
				}
			case 'White Woman Jumpscare':
				vussy.setGraphicSize(1280, 720);
				vussy.cameras = [camOther];
				vussy.screenCenter();
				vussy.visible = true;
				vussy.animation.play('vanny', true);
				FlxG.sound.play(Paths.sound('jumpedYaMom'), 1, false);
				if (value1.length >= 1) {
					triggerEventNote('Change Character', '0', value1); // this is a funny trick tho
				}
			case 'Well Well Well': //WELL WELL WELL
				FlxG.sound.play(Paths.sound('daFunniWell'), 2);
			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.contains('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.contains('gf')) {
								if(wasGf /* || dad.curCharacter == 'bfafter' */) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = gf.alpha;
							gf.alpha = 0.00001;
							gf = gfMap.get(value2);
							gf.alpha = lastAlpha;
						}
						setOnLuas('gfName', gf.curCharacter);
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0];
			camFollow.y += gf.cameraPosition[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					if (boyfriend.curCharacter == 'decktop-were' && health <= 0.05 * healthLoss) health = 0.05 * healthLoss else health -= 0.05 * healthLoss;
					trace('Health VALUE: ' + health + '\nHealth PERCENT: ' + healthBar.percent);
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					if (boyfriend.curCharacter == 'decktop-were' && health <= 0.05 * healthLoss) health = 0.05 * healthLoss else health -= 0.05 * healthLoss;
					trace('Health VALUE: ' + health + '\nHealth PERCENT: ' + healthBar.percent);
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					if (!TitleState.fuckinAsshole) {
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					} else {
						FlxG.sound.playMusic(Paths.music('clownTheme'));
					}

					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();
					

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;
					
					if (PlayState.storyPlaylist[0] == 'test' && difficulty == 'easy') { PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0]);} else {
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					}
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				if (!dunFuckedUpNow) {
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				if (!TitleState.fuckinAsshole) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				} else {
					FlxG.sound.playMusic(Paths.music('clownTheme'));
				}
				changedDifficulty = false;
			} else {
				trace('YOU BEAT IT???');
				dunFuckedUpNow = false;
				if (options.SnowdriftStuff.SnowdriftIntro.bambiHarassment) {
					options.SnowdriftStuff.SnowdriftIntro.bambiHarassment = false;
				}
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.playMusic(Paths.music('clownTheme'));
				changedDifficulty = false;
			}
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				bads++;
			case "good": // good
				totalNotesHit += 0.75;
				goods++;
			case "sick": // sick
				totalNotesHit += 1;
				sicks++;
		}


		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && (!cpuControlled || weDoALittleTrollin)) {
			songScore += score;
			songHits++;
			totalPlayed++;
			RecalculateRating();

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];


		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];


		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (dunFuckedUpNow) canMiss = true;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key); // WHAT ARE YOU DOING FNF LMAO
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.name != 'jumpy')
				boyfriend.dance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		if (boyfriend.curCharacter == 'decktop-were' && health <= 0.05 * healthLoss) health = 0.05 * healthLoss else health -= daNote.missHealth * healthLoss;
		trace('Health VALUE: ' + health + '\nHealth PERCENT: ' + healthBar.percent);
		if (ntCharsWithPL.contains(boyfriend.curCharacter) && ntPowerLevel > 0) ntPowerLevel -= 3;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		/* PlayState.instance.healthLoss = 1.0 + PlayState.instance.songMisses;
			trace(PlayState.instance.healthLoss); */
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			if (boyfriend.curCharacter == 'decktop-were' && health <= 0.05 * healthLoss) health = 0.05 * healthLoss else health -= 0.05 * healthLoss;
			trace('Health VALUE: ' + health + '\nHealth PERCENT: ' + healthBar.percent);
			if (ntCharsWithPL.contains(boyfriend.curCharacter) && ntPowerLevel > 0) ntPowerLevel -= 3;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
				/* PlayState.instance.healthLoss = 1.0 + PlayState.instance.songMisses;
				trace('removing ' + '0.05 * ' + healthLoss + ' from health.'); */
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			/* #if !html5
			FlxG.sound.play('assets/shared/sounds/missnote' + FlxG.random.int(1, 3) + '.ogg', FlxG.random.float(0.1, 0.2));
			#else
			FlxG.sound.play('assets/shared/sounds/missnote' + FlxG.random.int(1, 3) + '.mp3', FlxG.random.float(0.1, 0.2));
			#end */
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			char.playAnim(animToPlay, true);
			char.holdTimer = 0;
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		if (healthDrain >= 0.1) {
			health -= healthDrain;
		}
		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && !weDoALittleTrollin && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
							if (weDoALittleTrollin) {
								trace('WHAT THE FUCK');
								FlxG.log.warn('The note we just hit was a hurt note, what the fuck?!');
								/* susText.text = 'Suspicious hurt note hit';
								new FlxTimer().start(1, function(tmr:FlxTimer) {
									susText.text = ''; //reset sustext bc yes
								}); */
							}
						}
					case 'Vanny Note':
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
							boyfriend.stunned = true;
						}
						vanSound.volume = 0;
						if (dadGlitch.active) {
							dadGlitch.active = false;
						}
						vanHit = true;
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			if (playerCanRegainHealth) health += note.hitHealth * healthGain;
			trace('Health VALUE: ' + health + '\nHealth PERCENT: ' + healthBar.percent);

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				//if (note.isSustainNote){ wouldn't this be fun : P. i think it would be swell
					
					//if(note.gfNote) {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(gf.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	gf.playAnim(anim, true);
					//	gf.holdTimer = 0;
					//} else {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(boyfriend.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	boyfriend.playAnim(anim, true);
					//	boyfriend.holdTimer = 0;
					//}
				//}else{
					if(note.gfNote) {
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					} else {
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
					}
				//}
				if (note.ntRechargeNote && ntCharsWithPL.contains(boyfriend.curCharacter)) {
					trace('recharge!');
					ntPowerLevel += 5;
				}
				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, WEEK4), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf.animOffsets.exists('hairBlow')) { 
				gf.playAnim('hairBlow');
			gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		if (gf.animOffsets.exists('hairFall')) gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function whiteWomanJumpscare():Void {
		trace('sussy vussy');
		vussy.visible = true;
		vussy.animation.play('vanny', true);
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		doNtHealthShit();
	
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.name != 'jumpy' && boyfriend.animation.curAnim.name != 'fart' && !vanHit)
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.contains('gf') && dad.curCharacter != 'bfafter' && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

				setOnLuas('curBeat', curBeat);//DAWGG?????
		callOnLuas('onBeatHit', []);

	}

	function doCoconuttyThings(?DamageToDeal:Float) {
		coconut.visible = true;
		coconut.dealThis = DamageToDeal;
		coconut.fall();
	}

	public function doBonkShit(target:String, ?DamageToDeal:Float) {
		switch (target) {
			case 'BF':
				if (DumbUtil.getBfAnim('hurt')) {
					boyfriend.playAnim('hurt');
				} else {
					if (DumbUtil.getBfAnim('scared')) {
						boyfriend.playAnim('scared');
					}
				}
			case 'Dad':
				if (DumbUtil.getDaddyAnim('hurt')) {
					dad.playAnim('hurt'); // IF CHARACTER IS EITHER A BF CHARACTER OR THEY HAVE A HURT ANIM!
				} else {
					dad.playAnim('singDOWN');
				}
			case 'GF':
				if (DumbUtil.getGfAnim('hurt')) {
					gf.playAnim('hurt'); // SAME AS FOR DAD CASE!
				} else if (DumbUtil.getGfAnim('scared')) {
					gf.playAnim('scared');
				} else if (DumbUtil.getGfAnim('sad')) {
					gf.playAnim('sad');
				} else {
					trace('penis'); // idk
				}
		}
		if (DamageToDeal != null) health -= DamageToDeal;
		FlxG.sound.play(Paths.sound('bonk'));
	}
	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	/* public function vanessaTimer():Void {
		if (boyfriend.curCharacter == 'devan') {
			if (!whiteWoman && lastVanessa >= 15) {
				whiteWoman = true;
			}
			/* new FlxTimer().start(1, function(tmr:FlxTimer) {
				new FlxTimer().start(5, function(tmr:FlxTimer) { */
				/*	lastVanessa++;
				trace('Vanessa timer is now ' + lastVanessa);
				 });
			});
			// revertBf() doesn't fucking revert to the bf position, the fuck
			if (!whiteWoman) {
				vanny.destroy();
				vanny.text = 'Vanessa timer: ' + lastVanessa;
			} else {
				vanny.destroy();
				vanny.text = 'Are you having fun yet? (Debug timer: ' + lastVanessa + ')';
			}
		}
	} */ //this function isnt needed.

	/* private function revertBf() {
		if (boyfriend.animation.curAnim.name != 'jumpy') {
			boyfriend.width = originalBfWidth;
			boyfriend.height = originalBfHeight;
			boyfriend.x = BF_X;
			boyfriend.y = BF_Y;
			boyfriend.updateHitbox();
		}
	} */
	

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String>):String {
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
