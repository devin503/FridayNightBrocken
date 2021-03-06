package editors;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class MasterEditorMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Character Editor',
		'Chart Editor',
		'Unlock Editor',
		'Selectable Character Editor',
		'OC Info Editor'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end
		FlxG.sound.play(Paths.sound('partsServiceThing', 'shared'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
		}
		
		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		
		for (folder in Paths.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Paths.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if(controls.UI_LEFT_P)
		{
			changeDirectory(-1);
		}
		if(controls.UI_RIGHT_P)
		{
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch(options[curSelected]) {
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case 'Chart Editor'://felt it would be cool maybe
					if (ClientPrefs.loadChartAutosave && FlxG.save.data.autosave != null && PlayState.SONG == null) {
						PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
						//ChartingState.loadedAutoSaveFromMEM = true;
					}
					LoadingState.loadAndSwitchState(new ChartingState());
				case 'Unlock Editor'://just puttin this here for the future
					if (directoryTxt.text != '< No Mod Directory Loaded >')
						LoadingState.loadAndSwitchState(new UnlockEditorState(true), false);
					else
						LoadingState.loadAndSwitchState(new UnlockEditorState(), false);
				case 'Selectable Character Editor':
					//LoadingState.loadAndSwitchState(new SelectChara.SelectableCreatorState('henry'), true);
					openSubState(new SelectChara.SCThing());
				case 'OC Info Editor':
						LoadingState.loadAndSwitchState(new randomShit.oc.OCEditorState());
			}
			FlxG.sound.music.volume = 0;
			#if PRELOAD_ALL
			FreeplayState.destroyFreeplayVocals();
			#end
		}
		
		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
	}
	function showModDirNotice(source:String) {
		var msgTxt:String = 'placeholder message, ignore this lmao';
		var msgBox:FlxSprite = new FlxSprite(0).makeGraphic(FlxG.width - 200, FlxG.height - 200, FlxColor.BLACK);
		msgBox.screenCenter();
		add(msgBox);
		switch (source) {
			case 'OC':
				msgTxt = 'The OC Info editor does not require any mod directory as it uses the main assets directory for its contents.\n\nPlease deselect the mod directory and try again.\n\n(this will disappear in 3 seconds)';
		}
		var msgDisp:FlxText = new FlxText(0, 0, FlxG.width - 200, msgTxt);
		msgDisp.scrollFactor.set();
		msgDisp.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.GREEN);
		add(msgDisp);
		new FlxTimer().start(3, function(tmr:FlxTimer) {
			msgBox.destroy();
			msgDisp.destroy();
		});
	}
	var noteBg:FlxSprite;
	var noteBox:FlxSprite;
	var noteTxt:FlxText;
	function showTempMsg() {
		noteBg = new FlxSprite(0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		noteBg.alpha = 0.69;
		noteBg.screenCenter();
		add(noteBg);
		noteBox = new FlxSprite(0).makeGraphic(FlxG.width - 250, FlxG.height - 200, FlxColor.WHITE);
		noteBox.screenCenter();
		add(noteBox);
		noteTxt = new FlxText(0, noteBox.getGraphicMidpoint().y, FlxG.width - 250, "This editor isn't ready just yet. Come back another time.");
		noteTxt.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLUE);
		add(noteTxt);
		new FlxTimer().start(3, function(tmr:FlxTimer) {
			noteBg.destroy();
			noteBox.destroy();
			noteTxt.destroy();
		});
	}
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if(curDirectory < 0)
			curDirectory = directories.length - 1;
		if(curDirectory >= directories.length)
			curDirectory = 0;
	
		WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = '< No Mod Directory Loaded >';
		else
		{
			Paths.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Paths.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}