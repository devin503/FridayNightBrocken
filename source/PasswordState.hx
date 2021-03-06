package;

import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxTimer;
import editors.EditorPlayState;
#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import Character;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import Random;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.utils.Assets as OpenFlAssets;
import lime.media.AudioBuffer;
import haxe.io.Bytes;
import flash.geom.Rectangle;
import flixel.util.FlxSort;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
#end

using StringTools;
/**
 *  Password menu state. At the moment, the passwords are **hard-coded** into the game, so you'll have to do that too. Read the [README](source/README.md) to learn more about how to create a hard-coded unlockable.
 * @deprecated Unused. I may rework this later. - devin503
 */
class PasswordState extends MusicBeatState
{
    /**
     * Hardcoded password list. The commented passwords are either content that I do not have permission to upload on GitHub or do not want to upload.
     */
    static var passwordList:Array<String> = // Type any passwords you want to create here. If you know how to handle txt files in FNF, let me know how to implement that kind of thing. I'd love to improve this. Lol
    [
        'SuspiciousFool',
        'Grass',
        'KermitArson',
        'ExampleSongWord' //sussy
        // 'Amogus'
        /* 'YouReallyWantTheBlueBoi',
        'BosipBestShipOC',
        'ThoseShoesAreKindaSmall' */
    ];
    /**
     * Currently unused, but may have a purpose in the future ;)
     */
    var unlocks:Array<Dynamic>;
    /**
     * Character variable associated with Henry on the main screen of the state.
     * You *can* change who appears if you want.
     */
    var hen:Character;
    /**
     * Input text box associated with actually entering your password.
     */
    var pwInputBox:FlxUIInputText;
    /**
     * FlxButton for validating `pwInputBox` input
     */
    var pwValidateButton:FlxButton;
    /**
     * Prompt for input
     */
    var pwPromptText:FlxText;
    /**
     * Mini Saber's sprite. By default will have the `lockedShader` shader.
     */
    var miniSaber:FlxSprite;
    /**
     * Flamestarter's sprite. By default will have the `lockedShader` shader.
     */
    var youIdiot:FlxSprite;
    /**
     * Are we ready for some trollin?
     */
    var finishedCheck:Bool;
    /**
     * Set to `true` upon pressing the ESC key.
     */
    var exitingMenu:Bool = false;
    /**
     * Makes the BF appear.
     */
    var bfOpponent:FlxSprite;
    /**
     * Background
     */
    var bg:FlxSprite;
    /**
     *  List of flags the game is *supposed* to use to control unlocks. Though I don't know much about `FlxG.save` lmao
     */
    var sussyFlags:Array<String> = [/* 'unlockedBosipNotes', 'unlockedBobNotes', 'unlockedMiniShoeyNotes', */'unlockedMiniSaber', 'unlockedBfOpponent', 'unlockedArsonist'];
    /**
     * Sus text
     */
    var sussyText:FlxText;
    /**
     * Used for the saveLoop audio to prevent it from interrupting the saveStart audio
     */
    var loopBegin:Bool = false;
    /* var hahaBosip:FlxText;
    var hahaBob:FlxText;
    var hahaMiniShoey:FlxText; */
    var hahaSaber:FlxText;
    var hahaBfOp:FlxText;
    var hahaArson:FlxText;
    /* var ohnoBosip:FlxText;
    var ohnoBob:FlxText;
    var ohnoMiniShoey:FlxText; */
    var ohnoSaber:FlxText; 
    var ohnoBfOp:FlxText;
    var ohnoArson:FlxText;
    // var beginSave:FlxSound;
    var saveLoopFuckYou:FlxSound;
    var sussyBg:FlxSprite;
    /**
     * Content types.
     * 
     * When creating a custom hardcoded unlock:
     * 
     * `contentTypes[0]` - Character
     * 
     * `contentTypes[1]` - Song
     * 
     * `contentTypes[2]` - Noteskin
     */
    var contentTypes:Array<String> = ['Character', 'Song', 'Noteskin'];
    private var shaderArray:Array<ColorSwap> = [];
    /**
     * The shader used to hide content until it's unlocked.
     */
    var lockedShader:ColorSwap = new ColorSwap();
    /**
     * This array remains uninitialised until set to the usedPasswords array in `FlxG.save.data` by `new()`
     */
    var usedPasswords:Array<String>;
    var contentString:String;
    /**
     * A 6-entry array with the following key:
     * 
     * Entry 0 - Second content subtype if applicable
     * 
     * Entry 1 - Content subtype
     * 
     * Entry 2 - Friendly name for the content.
     * 
     * Entry 3 - Content type
     * 
     * Entry 4 - Unused, you can just put 0 here for now.
     * 
     * Entry 5 - The name a player needs to use to use the content in game. In the future, I'll create an FlxText that appears under unlocked content.
     */
    var unlockedContent:Array<Dynamic>;
    var useInstructions:Array<String>;
    /**
     * Debug password. Gets set to `ThisIsATest` by `new()` in release builds.
     * 
     * In debug builds, the game will prompt you to set it yourself by using the `DebugPasswordShit` substate.
     */
    var dbgPasswd:String;
    var needPasswd:Bool = false;
    var dbgNotice:FlxText;
    var dbgNoticeBg:FlxSprite;
    var speen:FlxSprite;
    var speenSus:FlxSprite;
    
    
    public function new() {
        super();
        #if debug
        if (!FileSystem.exists('assets/data/JOEMAMA.TXT')) {
            needPasswd = true;
            openSubState(new DebugPasswordShit());
        } else {
            dbgPasswd = sys.io.File.getContent('assets/data/JOEMAMA.TXT');
        }
        #else
            dbgPasswd = 'ThisIsATest'; //placeholder in case it crashes in release, tho im testing that as of this commit
        #end
        if (FlxG.save.data.usedPasswords == null) {
            FlxG.save.data.usedPasswords = [''];
            trace(FlxG.save.data.usedPasswords);
            FlxG.save.data.usedPasswords.push('your mom');
            usedPasswords = FlxG.save.data.usedPasswords;
        } else {
            trace(FlxG.save.data.usedPasswords);
            // FlxG.save.data.usedPasswords = ['your mom'];
            usedPasswords = FlxG.save.data.usedPasswords;
        }
        /* hahaBosip = new FlxText(0, 26, FlxG.width, '');
        hahaBob = new FlxText(0, 52, FlxG.width, '');
        hahaMiniShoey = new FlxText(0, 78, FlxG.width, ''); */
        hahaSaber = new FlxText(0, 104, FlxG.width, '');
        hahaBfOp = new FlxText(0, 130, FlxG.width, '');
        hahaArson = new FlxText(0, 156, FlxG.width, '');
        /* ohnoBosip = new FlxText(0, 26, FlxG.width, '');
        ohnoBob = new FlxText(0, 52, FlxG.width, '');
        ohnoMiniShoey = new FlxText(0, 78, FlxG.width, ''); */
        ohnoSaber = new FlxText(0, 104, FlxG.width, '');
        ohnoBfOp = new FlxText(0, 130, FlxG.width, '');
        ohnoArson = new FlxText(0, 156, FlxG.width, '');
        if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
    }
    override function create()
        {
        #if desktop
        // Updating Discord Rich Presence lmfao why tho
        DiscordClient.changePresence("Being sussy", null, 'bf');
        #end
        trace('adding bullshit');
        useInstructions = [];
        pwInputBox = new FlxUIInputText(0, 0, 500, '', 16, FlxColor.BLACK, FlxColor.WHITE);
        if (!needPasswd && finishedCheck && !exitingMenu) {
            finishedCheck = false;
            checkSus();
        } else if (needPasswd) {
            trace('lets get a password lmfao');
            FlxG.sound.music.stop();
            #if MODS_ALLOWED
            if (FileSystem.readDirectory('mods/songs') != null) FlxG.sound.playMusic(Paths.inst(Random.fromArray(FileSystem.readDirectory('assets/songs/'))), 1, true) else FlxG.sound.playMusic(Paths.inst(Random.fromArray(FileSystem.readDirectory('mods/songs/'))), 1, true);
            #else
            FlxG.sound.playMusic(Paths.inst(Random.fromArray(FileSystem.readDirectory('assets/songs/'))), 1, true);
            #end
        } else {
            trace('sussy');
            checkSus();
        }
    }
    override function update(elapsed:Float) {
        if (controls.BACK && !pwInputBox.hasFocus) {
            FlxG.sound.play('mods/sounds/jumpedYaMom.ogg'); // hate the paths system challenge /j
            if (finishedCheck) doCoolExit() else Sys.exit(420);
        }

        if (loopBegin && saveLoopFuckYou != null) {
            saveLoopFuckYou.play();
            saveLoopFuckYou.loopTime = saveLoopFuckYou.length;
            saveLoopFuckYou.looped = true;
            loopBegin = false;
        }
        
        if (finishedCheck && controls.ACCEPT && !pwInputBox.hasFocus) {
            trace('what are you doing this is graphical');
        } else if (!finishedCheck && controls.ACCEPT && !pwInputBox.hasFocus) {
            trace('sussy');
            Sys.exit(69);
        }
        if (miniSaber != null) {
            miniSaber.update(elapsed);
        }
        if (youIdiot != null) {
            youIdiot.update(elapsed);
        }
        if (bfOpponent != null) {
            bfOpponent.update(elapsed);
        }
        if (speen != null) {
            speen.update(elapsed);
        }
        if (hen != null) {
            hen.update(elapsed);
            if (hen.animation.curAnim.finished) {
                trace('haha beat my balls');
                hen.playAnim('idle');
            } else if (hen.animation.curAnim == null) {
                hen.playAnim('scared');
            }
        }
        if (pwInputBox != null) {
            pwInputBox.update(elapsed);
        }
        if (pwValidateButton != null) {
            pwValidateButton.update(elapsed);
        }
    }
    /**
     * Checks your save data flags to see if you've unlocked anything.
     */
    function checkSus() { // i need to  add speen here
        trace('CHECKING YOUR SAVE DATA...');
        sussyBg = new FlxSprite(-80).makeGraphic(1280, 720, FlxColor.BLUE, false);
        sussyBg.scrollFactor.set(0, 0);
        sussyBg.setGraphicSize(Std.int(sussyBg.width * 1.175));
        sussyBg.updateHitbox();
        sussyBg.screenCenter();
        add(sussyBg);
        speenSus = new FlxSprite(FlxG.width - 48, FlxG.height - 48);
        speenSus.frames = FlxAtlasFrames.fromSparrow('assets/images/editor/speen.png', 'assets/images/editor/speen.xml');
		speenSus.animation.addByPrefix('spin', 'spinner go brr', 24, true);
		speenSus.animation.play('spin');
        add(speenSus);
        sussyText = new FlxText(0, 0, FlxG.width, 'Checking save data...', 24);
        add(sussyText);
        
        for (i in 0...sussyFlags.length) {
            trace('checking flag ' + i + ' of ' + sussyFlags.length + ' (' + sussyFlags[i] + ')');
            trace(i);
            prepMainCreate(i);
            switch (sussyFlags[i]) {
                /* case 'unlockedBosipNotes':
                if (FlxG.save.data.unlockedBosipNotes != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBosipNotes);
                    hahaBosip.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBosipNotes;
                    add(hahaBosip);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedBosipNotes = false;
                    ohnoBosip.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoBosip);
                }
                case 'unlockedBobNotes':
                if (FlxG.save.data.unlockedBobNotes != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBobNotes);
                    hahaBob.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBobNotes;
                    add(hahaBob);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedBobNotes = false;
                    ohnoBob.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoBob);
                }
                case 'unlockedMiniShoeyNotes':
                if (FlxG.save.data.unlockedMiniShoeyNotes != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedMiniShoeyNotes);
                    hahaMiniShoey.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedMiniShoeyNotes;
                    add(hahaMiniShoey);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedMiniShoeyNotes = false;
                    ohnoMiniShoey.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoMiniShoey);
                } */
                case 'unlockedArsonist':
                if (FlxG.save.data.unlockedArsonist != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedArsonist);
                    hahaArson.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedArsonist;
                    add(hahaArson);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedArsonist = false;
                    ohnoArson.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoArson);
                }
                case 'unlockedMiniSaber':
                if (FlxG.save.data.unlockedMiniSaber != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedMiniSaber);
                    hahaSaber.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedMiniSaber;
                    add(hahaSaber);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedMiniSaber = false;
                    ohnoSaber.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoSaber);
                }
                case 'unlockedBfOpponent':
                if (FlxG.save.data.unlockedBfOpponent != null) {
                    trace('flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBfOpponent);
                    hahaBfOp.text = 'flag ' + sussyFlags[i] + ' exists, value: ' + FlxG.save.data.unlockedBfOpponent;
                    add(hahaBfOp);
                    prepMainCreate(sussyFlags.length);
                } else {
                    trace('flag ' + sussyFlags[i] + ' does not exist. initializing...');
                    FlxG.save.data.unlockedBfOpponent = false;
                    ohnoBfOp.text = 'flag ' + sussyFlags[i] + ' does not exist, initializing...';
                    add(ohnoBfOp);
                    prepMainCreate(sussyFlags.length);
                }
                
            }
            
        }
    }
    /**
     *  Because `create()` will call on `checkSus()`, I made `trueCreate()` as a means of getting around that and still having the main UI appear. I'm gonna be honest, I DO NOT like the way this screen looks and want to change it to a screen similar to `PreloadLargerCharacters` :skull:
     */
    function trueCreate() {
        /* if (FlxG.sound.music.playing || FlxG.sound.music == null) {
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music('mktFriends', "shared"), 1);
        } // THE MUSIC HERE IS GITIGNORED, JUST LET THE GAME PLAY THE DEFAULT */
        bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set(0, 0);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.color = FlxColor.fromRGB(69, 0, 0);
        add(bg);
        #if debug
        dbgNoticeBg = new FlxSprite(0).makeGraphic(FlxG.width, 26, 0xFF000000);
        dbgNoticeBg.alpha = 0.6;
        add(dbgNoticeBg);
        dbgNotice = new FlxText(dbgNoticeBg.x, dbgNoticeBg.y + 4, FlxG.width, "You're running the game as a debug build. Feel free to mess with the passwords to your heart's content.");
        dbgNotice.setFormat(Paths.font("funny.ttf"), 16, FlxColor.WHITE, CENTER);
        dbgNotice.scrollFactor.set();
        add(dbgNotice);
        #end
        
        hen = new Character(FlxG.width * 0.6, FlxG.height * 0.2, 'henry', false);
        hen.setGraphicSize(256, 256);
        hen.playAnim('idle');
        add(hen);
        
        
        pwInputBox.x = FlxG.width * 0.21;
        pwInputBox.y = FlxG.height * 0.21;
        // pwInputBox.screenCenter();
        pwInputBox.updateHitbox();
        add(pwInputBox);
        
        pwPromptText = new FlxText();
        pwPromptText.x = pwInputBox.x - 100;
        pwPromptText.y = pwInputBox.y - 50;
        pwPromptText.text = 'Enter a password below. Anything you have unlocked\nalready will be shown in colour\nbelow, anything you have NOT will be black.';
        pwPromptText.width = FlxG.width;
        pwPromptText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(pwPromptText);
        
        pwValidateButton = new FlxButton(0, 0, "Validate", function() {
            validateInput(pwInputBox.text);
        });
        pwValidateButton.x = pwInputBox.x + 100;
        pwValidateButton.y = pwInputBox.y + 100;
        pwValidateButton.updateHitbox();
        add(pwValidateButton);
        miniSaber = new FlxSprite(FlxG.width * 0.1, FlxG.height * 0.4);
        miniSaber.frames = FlxAtlasFrames.fromSparrow('mods/images/characters/MiniSaber.png', 'mods/images/characters/MiniSaber.xml');
        miniSaber.setGraphicSize(256, 256);
        miniSaber.animation.addByPrefix('idle', 'MSS idle dance', 24, true);
        miniSaber.animation.addByPrefix('hey', 'MSS PEACE', 24, false);
        miniSaber.animation.play('idle');
        if (!FlxG.save.data.unlockedMiniSaber) miniSaber.shader = lockedShader.shader;
        lockedShader.brightness = -100;
        add(miniSaber);

        bfOpponent = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.4);
        if (FileSystem.exists('mods/images/characters/BOYFRIEND.png')) bfOpponent.frames = FlxAtlasFrames.fromSparrow('mods/images/characters/BOYFRIEND.png', 'mods/images/characters/BOYFRIEND.xml') else bfOpponent.frames = FlxAtlasFrames.fromSparrow('assets/shared/images/characters/BOYFRIEND.png', 'assets/shared/images/characters/BOYFRIEND.xml');
        bfOpponent.setGraphicSize(256, 256);
        bfOpponent.animation.addByPrefix('fard', 'BF idle dance', 24, true);
        bfOpponent.animation.addByPrefix('shid', 'BF HEY', 24, false);
        bfOpponent.animation.play('fard');
        bfOpponent.flipX = true;
        if (!FlxG.save.data.unlockedBfOpponent) bfOpponent.shader = lockedShader.shader;
        add(bfOpponent);
        youIdiot = new FlxSprite(FlxG.width * 0.69, FlxG.height * 0.4);
        youIdiot.frames = FlxAtlasFrames.fromSparrow('mods/images/characters/Arsonist.png', 'mods/images/characters/Arsonist.xml');
        youIdiot.setGraphicSize(256, 256);
        youIdiot.animation.addByPrefix('actingsus', 'BF idle dance', 24, true);
        youIdiot.animation.addByPrefix('venting', 'BF HEY', 24, false);
        youIdiot.animation.play('actingsus');
        if (!FlxG.save.data.unlockedArsonist) youIdiot.shader = lockedShader.shader;
        add(youIdiot);
    }
    /**
     * Validates the input from the password input box. If it's in the password list, it checks for one of two things:
     *  1. Is this password in the list of used passwords?
     *  if `true` --> display error
     *  else --> unlock `funnyWord`'s associated content
     *  2. If in debug mode, is the password the debug password? Regular release builds will use a similar password to *reset* save flags.
     * 
     * @param funnyWord String value that takes input from `pwInputBox` and validates it against the list of passwords and your used passwords.
     */
    function validateInput(funnyWord:String) {
        trace('Checking input: ' + funnyWord);
        trace(passwordList);
        trace(usedPasswords);
        new FlxTimer().start(1.5, function (tmr:FlxTimer) {
            if (passwordList.contains(funnyWord) && !usedPasswords.contains(funnyWord)) {
                trace('Password good!');
                beginUnlockShit(funnyWord);
                // displayResultMsg(0);
            } else if (passwordList.contains(funnyWord) && usedPasswords.contains(funnyWord)) {
                trace('Password good, but already used!');
                displayResultMsg(2, 3);
            } else if (funnyWord == dbgPasswd) {
                for (i in 1...usedPasswords.length) {
                    trace(Std.int(i + 1) + ' of ' + usedPasswords.length + ': Removing ' + usedPasswords[i] + ' from the used passwords in your save data');
                    FlxG.save.data.usedPasswords.pop(usedPasswords[i]);
                }
                #if debug
                displayResultMsg(3, 3);
                #else
                displayResultMsg(4, 3);
                #end
            } else {
                trace('Invalid password. Check spelling maybe?');
                displayResultMsg(1, 3);
            }
        });
    }
    /**
     * Begins the process of unlocking content associated with a password. Currently works on a `switch` case basis, though I hope to implement jsons into this entire thing eventually.
     * 
     * To create your own unlock, using Mini Saber as an example:
     * ```haxe
     * case 'SuspiciousFool':
     *      trace('unlocking mini saber');
     *      setUnlockedContent(0); // replace with 1 or 2 if song or noteskin respectively
     *      #if debug
     *      displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Mini Saber', 'skin', 0, 'mss']);
     *      trace('dry run');
     *      #else
     *      unlockCharacter(['', '-opponent'], 'minisaber');
     *      displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Mini Saber', 'skin', 0, 'mss']);
     *      FlxG.save.data.unlockedMiniSaber = true;
     *      #end
     *      miniSaber.shader = null;
     *      miniSaber.animation.play('hey');
     * ```
     * @param funnyWords String value for the `switch` case mentioned above. May be deprecated in the future.
     */
    function beginUnlockShit(funnyWords:String) {
        trace('Just a sec...');
        FlxG.save.data.usedPasswords.push(funnyWords);
        switch (funnyWords) {
            case 'SuspiciousFool': 
                trace('unlocking mini saber');
                setUnlockedContent(0);
                #if debug
                displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Mini Saber', 'skin', 0, 'mss']);
                trace('dry run');
                #else
                unlockCharacter(['', '-opponent'], 'minisaber');
                displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Mini Saber', 'skin', 0, 'mss']);
                FlxG.save.data.unlockedMiniSaber = true;
                #end
                miniSaber.shader = null;
                miniSaber.animation.play('hey');
            case 'Grass':
                trace('unlocking bf opponent');
                bg.color = FlxColor.fromRGB(0, 69, 0);
                setUnlockedContent(0);
                #if debug
                displayResultMsg(0, 1, ['opponent', 'mod character', 'BF.xml', 'skin', 0, 'bf-opponent']);
                trace('dry run');
                #else
                unlockCharacter(['-opponent'], 'bf');
                displayResultMsg(0, 1, ['opponent', 'mod character', 'BF.xml', 'skin', 0, 'bf-opponent']);
                FlxG.save.data.unlockedBfOpponent = true;
                #end
                bfOpponent.shader = null;
                bfOpponent.animation.play('shid');
            case 'KermitArson':
                trace('unlocking arsonist');
                setUnlockedContent(0);
                #if debug
                displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Flamestarter', 'skin', 0, 'arson']);
                trace('dry run');
                #else
                unlockCharacter([''], 'arson');
                displayResultMsg(0, 1, ['boyfriend', 'mod character', 'Flamestarter', 'skin', 0, 'arson']);
                FlxG.save.data.unlockedArsonist = true;
                #end
                youIdiot.shader = null;
                youIdiot.animation.play('venting');
            case 'ExampleSongWord':
                trace('test song');
                setUnlockedContent(1);
                #if debug
                displayResultMsg(0, 1, ['example', 'example song', 'Test', 'song', 1, 'test']);
                trace('dry run');
                #else
                unlockSong('test', ['']);
                displayResultMsg(0, 1, ['example', 'example song', 'Test', 'song', 1, 'test']);
                FlxG.save.data.exampleSongUsed = true;
                #end
            /* case 'YouReallyWantTheBlueBoi':
                trace('unlocking bob notes');
                unlockNoteskin('bob');
            case 'ThoseShoesAreKindaSmall':
                trace('unlocking mini notes');
                unlockNoteskin('minishoey');
            case 'BosipBestShipOC':
                trace('unlocking bosip notes');
                unlockNoteskin('minishoey'); */
        }
    }
    /**
     * Character unlocker. For each entry of `charVars`, it'll copy a json file of `charName` with the variant in that entry attached.
     * @param charVars Character variants. Example: `['', '-opponent', '-pixel', '-pixel-dead']`
     * @param charName Character name.
     */
    function unlockCharacter(charVars:Array<String>, charName:String) {
        #if debug
        trace('dry run bc somehow we bypassed idk');
        #else
        for (i in 0...charVars.length) {
            trace(i + ' of ' + charVars.length + ': copying variation ' + charVars[i] + ' to characters folder...');
            File.copy('assets/locked/characters/' + charName.toLowerCase() + charVars[i] + '.json', 'mods/characters/' + charName.toLowerCase() + charVars[i] + '.json');
        }
        #end
    }
    /**
     * Noteskin unlocker.
     * @param skinName Name of the skin. Must be the EXACT name of the files. Case sensitive!
     * @param folderName Specify another folder to put your noteskin into. Defaults to `funnyNotes`, located in `mods/images`. (Optional)
     */
    function unlockNoteskin(skinName:String, ?folderName:String = 'funnyNotes') {
        var fileTypes:Array<String> = ['.png', '.xml'];
        for (i in 0...1) {
            File.copy('assets/locked/noteskins/' + skinName + fileTypes[i], 'mods/images/' + folderName + '/' + skinName + fileTypes[i]);
        }
        switch (skinName) {
            /* case 'bosip':
            FlxG.save.data.unlockedBosipNotes = true;
            trace('bosip skin unlocked');
            case 'bob':
            FlxG.save.data.unlockedBobNotes = true;
            trace('bob skin unlocked');
            case 'minishoey':
            FlxG.save.data.unlockedMiniShoeyNotes = true;
            trace('mini notes unlocked'); */
            default:
                trace('ass'); //placeholder
        }
    }
    /**
     * Song unlocker
     * @param songName Name of your song. Must be lowercase.
     * @param diffics Difficulty list in case your song has different difficulties from the defaults. (Optional)
     * @param needsVoices If your song needs voices, the game can copy those over too if you set this to `true`. (Optional)
     */
    function unlockSong(songName:String, ?diffics:Array<String>, ?needsVoices:Bool) {
        var diffics:Array<String> = ['-easy', '', '-hard'];
        for (i in 0...diffics.length) {
            trace(i + ' of ' + diffics.length + ': copying file ' + songName + diffics[i] + '.json to mods folder');
            if (FileSystem.exists('assets/locked/songs/' + songName + '/data/' + songName + diffics[i] + '.json')) {
                trace('tf, SKIPPPPPPPPP');
                File.copy('assets/locked/songs/' + songName + '/data/' + songName + diffics[i] + '.json', 'mods/data/' + songName + '/' + songName + diffics[i] + '.json');
            }
        }
        var copyThese:Array<String> = ['Inst', 'Voices'];
        var copyOnlyInst:String = 'Inst';
        if (needsVoices != null && !needsVoices) {
            File.copy('assets/locked/songs/' + songName + '/audio/' + copyOnlyInst + '.ogg', 'mods/songs/' + songName + '/' + copyOnlyInst + 'ogg');
        } else if (needsVoices == null && FileSystem.exists('assets/locked/songs/' + songName + '/audio/Voices.ogg')) {
            for (i in 0...copyThese.length) {
                File.copy('assets/locked/songs/' + songName + '/audio/' + copyThese[i] + '.ogg', 'mods/songs/' + songName + '/' + copyThese[i] + '.ogg');
            }
        } else {
            for (i in 0...copyThese.length) {
                File.copy('assets/locked/songs/' + songName + '/audio/' + copyThese[i] + '.ogg', 'mods/songs/' + songName + '/' + copyThese[i] + '.ogg');
            }
        }
    }
    /**
     * Set the unlocked content type.
     * @param contentType This entire function is unused atm
     */
    function setUnlockedContent(contentType:Int) {
        switch (contentType) {
            case 0:
            contentString = 'Character';
            case 1:
            contentString = 'Song';
            case 2:
            contentString = 'Noteskin';
        }
        trace(unlockedContent);
        // return unlockedContent;
        // displayResultMsg(0, contentType);
    }
    /**
     * Checks the progress of `checkSus()` and, if complete, calls `trueCreate()`.
     * @param i Flag number in `checkSus()`
     */
    function prepMainCreate(i:Int) {
        new FlxTimer().start(3, function (tmr:FlxTimer) {
            if (i == sussyFlags.length) {
                /* if (hahaBosip != null) {
                    hahaBosip.destroy();
                }
                if (hahaBob != null) {
                    hahaBob.destroy();
                }
                if (hahaMiniShoey != null) {
                    hahaMiniShoey.destroy();
                } */
                if (hahaSaber != null) {
                    hahaSaber.destroy();
                }
                if (hahaBfOp != null) {
                    hahaBfOp.destroy();
                }
                /* if (ohnoBosip != null) {
                    ohnoBosip.destroy();
                }
                if (ohnoBob != null) {
                    ohnoBob.destroy();
                }
                if (ohnoMiniShoey != null) {
                    ohnoMiniShoey.destroy();
                } */
                if (ohnoSaber != null) {
                    ohnoSaber.destroy();
                }
                if (ohnoBfOp != null) {
                    ohnoBfOp.destroy();
                }
                sussyText.destroy();
                sussyBg.destroy();
                speenSus.destroy();
                finishedCheck = true;
                trueCreate();
            }
        });
    }
    /**
     * Displays a message on screen depending on the result of `validateInput`. The results are defined in the definition for `suspiciousResultCode`, but not the array properties for `unlockedContent`, which are:
     * ```haxe
     * [
     * 'boyfriend', // subtype of content if applicable
     * 'mod character', // type of content but friendly
     * 'your uncle', // a friendly name for the character.
     * 'skin', // The content type. Should be `skin`, `noteskin`, or `song`.
     * 0, // Unused, you can leave this as 0. This may change in the future.
     * 'larry-cucumber'] // the name associated with the content in order to use it in game.
     * ```
     * @param suspiciousResultCode The result from `validateInput()`. If 0, displays a **green** window with a message stating what you unlocked, using the properties of `unlockedContent`. If 1, displays a **red** window with a message stating your entry was invalid. If 2, displays a **yellow** message stating your password has already been used. 3 and 4 have similar functions, but 4 actually resets your flag data.
     * @param fuckYouHaxe Currently unused variable.
     * @param unlockedContent What the player unlocked as a Dynamic array. Example: `['boyfriend', 'mod character', 'your uncle', 'skin', 0, 'larry-cucumber']`
     */
    function displayResultMsg(suspiciousResultCode:Int, fuckYouHaxe:Int, ?unlockedContent:Array<Dynamic>) {
        var errorBg:FlxSprite = new FlxSprite(0).makeGraphic(1280, 720, FlxColor.RED);
        errorBg.alpha = 0.3;
        errorBg.visible = false;
        errorBg.screenCenter();
        add(errorBg);
        trace(unlockedContent);
        /* switch (fuckYouHaxe) {
            case 0:
                useInstructions.push('To use this new character, go into the chart editor. Your new character will be in the character list as ' + unlockedContent[5]);
            case 1:
                useInstructions.push("To play the new song, check the Freeplay menu. If it's not there, its name is " + unlockedContent[2] + " and you can add it to a new week.");
            case 2:
                useInstructions.push("To set this noteskin, go into the chart editor. In the 'Song' section, type 'funnyNotes/" + unlockedContent[5] + "' in the note skin box and click reload notes.");
            case 3:
                trace('this is a very large oof');
        } */
        switch (suspiciousResultCode) {
            case 0:
                trace('done');
                errorBg.color = FlxColor.GREEN;
                errorBg.visible = true;
                var errorTxt:FlxText = new FlxText(0, 0, FlxG.width, 'You have unlocked the ' + unlockedContent[1] + ', which is a ' + unlockedContent[0] + ' ' + unlockedContent[3] + ': ' + unlockedContent[2] + ', enjoy!\nThe password you used to unlock this can not be used anymore.', 48);
                errorTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                errorTxt.screenCenter(Y);
                add(errorTxt);
                new FlxTimer().start(3, function (tmr:FlxTimer) {
                    errorTxt.destroy();
                    errorBg.visible = false;
                });
            case 1:
                trace('invalid pw');
                if (errorBg.color != FlxColor.RED) errorBg.color = FlxColor.RED;
                errorBg.visible = true;
                var errorTxt:FlxText = new FlxText(0, 0, FlxG.width, 'Invalid password. Please make sure you have entered the password correctly.\nPasswords ARE case sensitive!', 48);
                errorTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                errorTxt.screenCenter(Y);
                add(errorTxt);
                new FlxTimer().start(3, function (tmr:FlxTimer) {
                    errorTxt.destroy();
                    errorBg.visible = false;
                });
            case 2: 
                trace('already used');
                errorBg.color = FlxColor.YELLOW;
                errorBg.visible = true;
                var errorTxt:FlxText = new FlxText(0, 0, FlxG.width, 'You have already used this password!', 48);
                errorTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                errorTxt.screenCenter(Y);
                add(errorTxt);
                new FlxTimer().start(3, function (tmr:FlxTimer) {
                    errorTxt.destroy();
                    errorBg.visible = false;
                });
            case 3:
                trace('debug reset');
                errorBg.color = FlxColor.fromRGB(71, 117, 0);
                errorBg.visible = true;
                var errorTxt:FlxText = new FlxText(0, 0, FlxG.width, 'Debug flags reset.', 48);
                errorTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                errorTxt.screenCenter(Y);
                add(errorTxt);
                new FlxTimer().start(3, function (tmr:FlxTimer) {
                    if (miniSaber.shader == null) {
                        miniSaber.shader = lockedShader.shader;
                    }
                    if (bfOpponent.shader == null) {
                        bfOpponent.shader = lockedShader.shader;
                    }
                    if (youIdiot.shader == null) {
                        youIdiot.shader = lockedShader.shader;
                    }
                    errorTxt.destroy();
                    errorBg.visible = false;
                });
            case 4:
                trace('debug reset');
                errorBg.color = FlxColor.fromRGB(71, 117, 0);
                errorBg.visible = true;
                var errorTxt:FlxText = new FlxText(0, 0, FlxG.width, 'Unlocks have been reset. You will now be returned to the main menu.', 48);
                errorTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                errorTxt.screenCenter(Y);
                add(errorTxt);
                new FlxTimer().start(3, function (tmr:FlxTimer) {
                    if (miniSaber.shader == null) {
                        miniSaber.shader = lockedShader.shader;
                    }
                    if (bfOpponent.shader == null) {
                        bfOpponent.shader = lockedShader.shader;
                    }
                    if (youIdiot.shader == null) {
                        youIdiot.shader = lockedShader.shader;
                    }
                    errorTxt.destroy();
                    errorBg.visible = false;
                    for (i in 0...sussyFlags.length) {
                        //FlxG.save.resetFlag(sussyFlags[i], FlxG.save.data);
                        trace('test bc im dumb');
                    }
                    doCoolExit();
                });
        }
    }
	/**
	 * This function saves your game and exits.
	 */
	function doCoolExit() {
        var beginSave = FlxG.sound.load(Paths.music('saveStart'));
        FlxG.sound.list.add(beginSave);
        var saveLoopAudio = FlxG.sound.load(Paths.music('saveLoop'));
        saveLoopFuckYou = saveLoopAudio;
        FlxG.sound.list.add(saveLoopFuckYou);
        saveLoopFuckYou.volume = 5;
        #if !debug
        dbgNoticeBg = new FlxSprite(0).makeGraphic(FlxG.width, 26, 0xFF000000);
        dbgNoticeBg.alpha = 0.6;
        add(dbgNoticeBg);
        dbgNotice = new FlxText(dbgNoticeBg.x, dbgNoticeBg.y + 4, FlxG.width, "Saving the game, please wait...");
        dbgNotice.setFormat(Paths.font("funny.ttf"), 16, FlxColor.WHITE, CENTER);
        dbgNotice.scrollFactor.set();
        add(dbgNotice);
        #end
        speen = new FlxSprite(FlxG.width - 48, FlxG.height - 48);
        speen.frames = FlxAtlasFrames.fromSparrow('assets/images/editor/speen.png', 'assets/images/editor/speen.xml');
		speen.animation.addByPrefix('spin', 'spinner go brr', 24, true);
		speen.animation.play('spin');
        add(speen);
        beginSave.play();
        new FlxTimer().start(Std.int(beginSave.length / 1000), function(tmr:FlxTimer) {
            loopBegin = true;
        });
        new FlxTimer().start(5, function (tmr:FlxTimer) {
            FlxG.save.flush();
            trace(FlxG.save.data);
            LoadingState.loadAndSwitchState(new MainMenuState(), true);
        });
    }
}
/**
 * **DEBUG ONLY**
 * 
 * Password substate that allows you to set a password to reset the debug flags.
 */
class DebugPasswordShit extends MusicBeatSubstate {
    var enterPass:FlxUIInputText;
    var passPrompt:FlxText;
    var saveBg:FlxSprite;
    var promptBg:FlxSprite;
    var savingText:FlxText;
    var resetText:FlxText;
    var savePass:FlxButton;
    var saveLoopAudio:FlxSound;
    
    public function new() {
        super();
        saveLoopAudio = FlxG.sound.load(Paths.music('saveLoop'));
        promptBg = new FlxSprite(0).makeGraphic(1280, 720, FlxColor.fromRGB(128, 128, 0, 255));
        promptBg.screenCenter();
        promptBg.updateHitbox();
        enterPass = new FlxUIInputText(0, 0, 250, '', 24, FlxColor.RED, FlxColor.BLUE);
        enterPass.screenCenter();
        passPrompt = new FlxText(0, 0, FlxG.width, "This appears to be your first time opening this menu in debug mode. Please enter a password below to be able to reset your used passwords.");
        passPrompt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.SHADOW, FlxColor.LIME);
        passPrompt.y = enterPass.y - 250;
        savePass = new FlxButton(0, enterPass.y + 50, 'Save Password', function() {
            saveBg = new FlxSprite(0).makeGraphic(1280, 720, FlxColor.fromRGB(0, 128, 128, 128));
            saveBg.screenCenter();
            saveBg.updateHitbox();
            add(saveBg);
            savingText = new FlxText(0, 0, FlxG.width);
            savingText.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
            savingText.text = "Saving password...";
            savingText.screenCenter();
            add(savingText);
            saveLoopAudio.play(false);
            saveLoopAudio.loopTime = saveLoopAudio.length;
            saveLoopAudio.looped = true;
            new FlxTimer().start(5, function (tmr:FlxTimer) {
                sys.io.File.saveContent('assets/data/JOEMAMA.TXT', enterPass.text);
                savingText.visible = false;
                resetText = new FlxText(0, 0, FlxG.width);
                resetText.setFormat(Paths.font('funny.ttf'), 48, FlxColor.LIME, FlxTextAlign.CENTER, FlxTextBorderStyle.SHADOW, FlxColor.MAGENTA);
                resetText.text = 'Your password has been saved. You will be returned to the main menu shortly.';
                add(resetText);
                new FlxTimer().start(3, function(tmr:FlxTimer) {
                    MusicBeatState.switchState(new MainMenuState());
                });
            });
        });
        savePass.screenCenter(X);
        add(promptBg);
        add(enterPass);
        add(passPrompt);
        add(savePass);
    }
}