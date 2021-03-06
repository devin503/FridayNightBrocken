package options;

import flixel.FlxG;
import DialogueBoxPsych;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import haxe.Json;
import Paths;
import flixel.util.FlxTimer;

using StringTools;

/**Snowdrift stuff. Has some settings I'm too lazy to add to other things. (This is an options menu!)
    @since February 2022 (Emo Engine 0.1.1)*/
class SnowdriftStuff extends BaseOptionsMenu {

    public function new() {
        if (bg != null) bg.color = 0xFFAACCFF;
        trace('give me beans');
        title = 'Snowdrift\'s Menu';
        rpcTitle = 'Visiting Snowdrift in Options Menu';
        var option:Option = new Option('Small Screen Fix', //Name
			'Press H to know more about this!', //Description
			'smallScreenFix', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
        /*var option:Option = new Option('Preload certain states', //Name
			'Press H to know more about this!', //Description
			'preloadStates', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option); */
        var option:Option = new Option('Skip Character Select', //Name
			'Press H to know more about this!', //Description
			'skipCharaSelect', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
        sdOption = 'smallScreenFix';
        #if debug
        var option:Option = new Option('Show PC Info in Main Menu',
        'Press H to know more about this!',
        'showPCInfoMM',
        'bool',
        false);
        addOption(option);
        #end
        var option:Option = new Option('Autoload chart autosave',
        'Press H to know more about this!',
        'loadChartAutosave',
        'bool',
        true);
        addOption(option);
        inSnowdriftMenu = true;
        super();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.H) {
            inDialogue = true;
            super.startDialogue(dumb);
        }
        if (FlxG.sound.music.volume < 0.8) {
            FlxG.sound.music.volume = 0.8;
            FlxG.sound.playMusic(Paths.modsMusic('mktFriends'));
        }

        if (psychDialogue != null) {
            psychDialogue.update(elapsed);
        } //THIS WASNT EVEN NECESSARY LMFAO

        super.update(elapsed);
    }
}

/**funny intro thing idk*/
class SnowdriftIntro extends MusicBeatState {
    var bg:FlxSprite;
    var dumb:DialogueFile;
    var dialogueCount:Int = 0;
    var psychDialogue:DialogueBoxPsych;
    public static var bambiHarassment:Bool = false;

    public function new() {
        super();
        if (PlayState.snowdriftDiedCheating) {
            FlxG.sound.playMusic(Paths.music('ohMyGodWhat'));
        } else {
            FlxG.sound.playMusic(Paths.modsMusic('DaveDialogue'));
        }
        bg = new FlxSprite(0).loadGraphic(Paths.image('menuDesat'));
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.color = 0xFFAACCFF;
        add(bg);
        if (!PlayState.dunFuckedUpNow) { dumb = cast Json.parse(Paths.snowdriftChatter('firstIntro')); }
        else if (PlayState.snowdriftDiedCheating) {
            dumb = cast Json.parse(Paths.snowdriftChatter('fwys'));
        } else {
            dumb = cast Json.parse(Paths.snowdriftChatter('bambiCut'));
        }
        FlxG.console.registerObject('sdrift', this);
    }
    override function update(elapsed:Float) {
        if (psychDialogue != null) {
            psychDialogue.update(elapsed);
        }
    }
    override function create() {
        new FlxTimer().start(3, function(tmr:FlxTimer) {
            startDialogue(dumb);
        });
    }
    public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
        {
            // TO DO: Make this more flexible, maybe?
            if(psychDialogue != null) return;
    
            if(dialogueFile.dialogue.length > 0) {
                // inCutscene = true;
                CoolUtil.precacheSound('dialogue', 'shared');
                CoolUtil.precacheSound('dialogueClose', 'shared');
                psychDialogue = new DialogueBoxPsych(dialogueFile);
                psychDialogue.scrollFactor.set();
                    psychDialogue.finishThing = function() {
                        psychDialogue = null;
                        FlxG.save.data.seenSnowdriftIntro = true;
                        if (!PlayState.dunFuckedUpNow) {
                            MusicBeatState.switchState(new options.OptionsState());
                        } else if (PlayState.dunFuckedUpNow && !bambiHarassment) {
                            PlayState.SONG = Song.loadFromJson('cheating', 'cheating');
                            PlayState.SONG.player2 = 'bambi-old';
                            PlayState.SONG.gfVersion = 'gf-but-devin';
                            bambiHarassment = true;
                            LoadingState.loadAndSwitchState(new PlayState(), true);
                        } else if (bambiHarassment) {
                            PlayState.SONG = Song.loadFromJson('cheating-nt', 'cheating');
                            PlayState.SONG.player2 = 'bambi-old';
                            PlayState.SONG.gfVersion = 'nt-with-deddrift';
                            PlayState.fwys = true;
                            SelectChara.bfOverride = 'bf';
                            LoadingState.loadAndSwitchState(new PlayState(), true);
                        }
                    }
                psychDialogue.nextDialogueThing = startNextDialogue;
                psychDialogue.skipDialogueThing = skipDialogue;
                // psychDialogue.cameras = [camHUD];
                add(psychDialogue);
            } else {
                FlxG.log.warn('Your dialogue file is badly formatted!');
                MusicBeatState.switchState(new options.OptionsState());
            }
        }
        //var dialogueCount:Int = 0;
        function startNextDialogue() {
            dialogueCount++;
        }

        function skipDialogue() {
            //callOnLuas('onSkipDialogue', [dialogueCount]);
            trace('ass');
        }
}