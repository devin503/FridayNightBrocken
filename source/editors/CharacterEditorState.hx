package editors;

import lime.math.Rectangle;
import sys.io.FileOutput;
import openfl.geom.Matrix;
import lime.math.ColorMatrix;
import lime.ui.FileDialogType;
import openfl.net.FileFilter;
import flixel.addons.ui.FlxButtonPlus;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import lime.ui.FileDialog;
import randomShit.util.ColorUtil;
import editors.TestPlayState.ConfirmYourContent;
import editors.HealthIconFromGrid;
import flixel.system.FlxSound;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import sys.io.File;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISlider;
// import lime.app.Event as LimeEvent;
import haxe.SysTools;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

/**
*DEBUG MODE
*/
class CharacterEditorState extends MusicBeatState
{
	var char:Character;
	var ghostChar:Character;
	var textAnim:FlxText;
	var bgLayer:FlxTypedGroup<FlxSprite>;
	var charLayer:FlxTypedGroup<Character>;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var speen:FlxSprite;
	//var animList:Array<String> = [];
	var curAnim:Int = 0;
	public var daAnim:String = 'spooky';
	var goToPlayState:Bool = true;
	var camFollow:FlxObject;
	public static var savingYourShit:Bool = false;
	
	public function new(daAnim:String = 'spooky', goToPlayState:Bool = true)
		{
		super();
		this.daAnim = daAnim;
		this.goToPlayState = goToPlayState;
	}
	
	var UI_box:FlxUITabMenu;
	var UI_characterbox:FlxUITabMenu;
	var UI_testbox:FlxUITabMenu;
	var parsedCharJson:CharacterFile;
	
	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	public var camMenu:FlxCamera;
	
	var changeBGbutton:FlxButton;
	var leHealthIcon:HealthIcon;
	var characterList:Array<String> = [];
	
	var cameraFollowPointer:FlxSprite;
	var healthBarBG:FlxSprite;
	
	override function create()
		{
		//FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);
		
		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		
		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [camEditor];
		
		bgLayer = new FlxTypedGroup<FlxSprite>();
		add(bgLayer);
		charLayer = new FlxTypedGroup<Character>();
		add(charLayer);
		FlxG.sound.cache(Paths.music('saveStart'));
		FlxG.sound.cache(Paths.music('saveLoop'));
		
		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);
		
		changeBGbutton = new FlxButton(FlxG.width - 360, 25, "", function()
			{
			onPixelBG = !onPixelBG;
			reloadBGs();
		});
		changeBGbutton.cameras = [camMenu];
		
		loadChar(!daAnim.startsWith('bf'), false);
		
		healthBarBG = new FlxSprite(30, FlxG.height - 75).loadGraphic(Paths.image('healthBar'));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBarBG.cameras = [camHUD];
		
		leHealthIcon = new HealthIcon(char.healthIcon, false);
		leHealthIcon.y = FlxG.height - 150;
		add(leHealthIcon);
		leHealthIcon.cameras = [camHUD];
		
		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];
		
		textAnim = new FlxText(300, 16);
		textAnim.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.size = 32;
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);
		
		genBoyOffsets();
		
		speen = new FlxSprite(FlxG.width - 48, FlxG.height - 48);
		speen.frames = FlxAtlasFrames.fromSparrow('assets/images/editor/speen.png', 'assets/images/editor/speen.xml');
		speen.animation.addByPrefix('spin', 'spinner go brr', 30, true);
		speen.animation.addByIndices('spun', 'spinner go brr', [42, 0], '', 0, false);
		speen.animation.play('spin');
		speen.cameras = [camHUD];
		add(speen);
		
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		reParseCharJson('bf');
		
		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0,
			"E/Q - Camera Zoom In/Out
			\nJKLI - Move Camera
			\nW/S - Previous/Next Animation
			\nSpace - Play Animation
			\nArrow Keys - Move Character Offset
			\nZ - Reset Current Offset
			\nHold Shift to Move 10x faster\n", 12);
			tipText.cameras = [camHUD];
			tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			tipText.scrollFactor.set();
			tipText.borderSize = 1;
			tipText.x -= tipText.width;
			tipText.y -= tipText.height - 10;
			add(tipText);
			
			FlxG.camera.follow(camFollow);
			
			var tabs = [
				//{name: 'Offsets', label: 'Offsets'},
				{name: 'Settings', label: 'Settings'},
			];
			
			UI_box = new FlxUITabMenu(null, tabs, true);
			UI_box.cameras = [camMenu];
			
			UI_box.resize(250, 120);
			UI_box.x = FlxG.width - 275;
			UI_box.y = 25;
			UI_box.scrollFactor.set();
			
			var tabs = [
				{name: 'Character', label: 'Character'},
				{name: 'Animations', label: 'Animations'},
				{name: 'Charting', label: 'Charting'},
			];
			UI_characterbox = new FlxUITabMenu(null, tabs, true);
			UI_characterbox.cameras = [camMenu];
			
			UI_characterbox.resize(350, 250);
			UI_characterbox.x = UI_box.x - 100;
			UI_characterbox.y = UI_box.y + UI_box.height;
			UI_characterbox.scrollFactor.set();
			add(UI_characterbox);
			add(UI_box);
			add(changeBGbutton);
			
			//addOffsetsUI();
			addSettingsUI();
			
			addCharacterUI();
			addAnimationsUI();
			addTestCharUI();
			UI_characterbox.selected_tab_id = 'Character';
			
			FlxG.mouse.visible = true;
			reloadCharacterOptions();
			
			super.create();
		}
		
		var onPixelBG:Bool = false;
		var OFFSET_X:Float = 300;
		function reloadBGs() {
			var i:Int = bgLayer.members.length-1;
			while(i >= 0) {
				var memb:FlxSprite = bgLayer.members[i];
				if(memb != null) {
					memb.kill();
					bgLayer.remove(memb);
					memb.destroy();
				}
				--i;
			}
			bgLayer.clear();
			var playerXDifference = 0;
			if(char.isPlayer) playerXDifference = 670;
			
			if(onPixelBG) {
				var playerYDifference:Float = 0;
				if(char.isPlayer) {
					playerXDifference += 200;
					playerYDifference = 220;
				}
				
				var bgSky:BGSprite = new BGSprite('weeb/weebSky', OFFSET_X - (playerXDifference / 2) - 300, 0 - playerYDifference, 0.1, 0.1);
				bgLayer.add(bgSky);
				bgSky.antialiasing = false;
				
				var repositionShit = -200 + OFFSET_X - playerXDifference;
				
				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, -playerYDifference + 6, 0.6, 0.90);
				bgLayer.add(bgSchool);
				bgSchool.antialiasing = false;
				
				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, -playerYDifference, 0.95, 0.95);
				bgLayer.add(bgStreet);
				bgStreet.antialiasing = false;
				
				var widShit = Std.int(bgSky.width * 6);
				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800 - playerYDifference);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				bgLayer.add(bgTrees);
				bgTrees.antialiasing = false;
				
				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				changeBGbutton.text = "Regular BG";
			} else {
				var bg:BGSprite = new BGSprite('stageback', -600 + OFFSET_X - playerXDifference, -300, 0.9, 0.9);
				bgLayer.add(bg);
				
				var stageFront:BGSprite = new BGSprite('stagefront', -650 + OFFSET_X - playerXDifference, 500, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				bgLayer.add(stageFront);
				changeBGbutton.text = "Pixel BG";
			}
		}
		
		/*var animationInputText:FlxUIInputText;
		function addOffsetsUI() {
			var tab_group = new FlxUI(null, UI_box);
			tab_group.name = "Offsets";
			
			animationInputText = new FlxUIInputText(15, 30, 100, 'idle', 8);
			
			var addButton:FlxButton = new FlxButton(animationInputText.x + animationInputText.width + 23, animationInputText.y - 2, "Add", function()
				{
				var theText:String = animationInputText.text;
				if(theText != '') {
					var alreadyExists:Bool = false;
					for (i in 0...animList.length) {
						if(animList[i] == theText) {
							alreadyExists = true;
							break;
						}
					}
					
					if(!alreadyExists) {
						char.animOffsets.set(theText, [0, 0]);
						animList.push(theText);
					}
				}
			});
			
			var removeButton:FlxButton = new FlxButton(animationInputText.x + animationInputText.width + 23, animationInputText.y + 20, "Remove", function()
				{
				var theText:String = animationInputText.text;
				if(theText != '') {
					for (i in 0...animList.length) {
						if(animList[i] == theText) {
							if(char.animOffsets.exists(theText)) {
								char.animOffsets.remove(theText);
							}
							
							animList.remove(theText);
							if(char.animation.curAnim.name == theText && animList.length > 0) {
								char.playAnim(animList[0], true);
							}
							break;
						}
					}
				}
			});
			
			var saveButton:FlxButton = new FlxButton(animationInputText.x, animationInputText.y + 35, "Save Offsets", function()
				{
				saveOffsets();
			});
			
			tab_group.add(new FlxText(10, animationInputText.y - 18, 0, 'Add/Remove Animation:'));
			tab_group.add(addButton);
			tab_group.add(removeButton);
			tab_group.add(saveButton);
			tab_group.add(animationInputText);
			UI_box.addGroup(tab_group);
		}*/
		
		var TemplateCharacter:String = '{
			"animations": [
				{
					"loop": false,
					"offsets": [
						0,
						0
					],
					"fps": 24,
					"anim": "idle",
					"indices": [],
					"name": "Dad idle dance"
				},
				{
					"offsets": [
						0,
						0
					],
					"indices": [],
					"fps": 24,
					"anim": "singLEFT",
					"loop": false,
					"name": "Dad Sing Note LEFT"
				},
				{
					"offsets": [
						0,
						0
					],
					"indices": [],
					"fps": 24,
					"anim": "singDOWN",
					"loop": false,
					"name": "Dad Sing Note DOWN"
				},
				{
					"offsets": [
						0,
						0
					],
					"indices": [],
					"fps": 24,
					"anim": "singUP",
					"loop": false,
					"name": "Dad Sing Note UP"
				},
				{
					"offsets": [
						0,
						0
					],
					"indices": [],
					"fps": 24,
					"anim": "singRIGHT",
					"loop": false,
					"name": "Dad Sing Note RIGHT"
				}
			],
			"no_antialiasing": false,
			"image": "characters/DADDY_DEAREST",
			"position": [
				0,
				0
			],
			"healthicon": "face",
			"flip_x": false,
			"healthbar_colors": [
				161,
				161,
				161
			],
			"chartingButtonColour": "0xFFFF6666",
			"chartingButtonRGB": [
				255,
				102,
				102
			],
			"chartingButtonLabelTheme": "0xFF000000",
			"labelRGB": [
				0,
				0,
				0
			],
			"camera_position": [
				0,
				0
			],
			"sing_duration": 6.1,
			"scale": 1
		}';
		
		var charDropDown:FlxUIDropDownMenuCustom;
		function addSettingsUI() {
			var tab_group = new FlxUI(null, UI_box);
			tab_group.name = "Settings";
			
			var check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
			check_player.checked = daAnim.startsWith('bf');
			check_player.callback = function()
				{
				char.isPlayer = !char.isPlayer;
				char.flipX = !char.flipX;
				updatePointerPos();
				reloadBGs();
				ghostChar.flipX = char.flipX;
			};
			
			charDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String)
				{
				daAnim = characterList[Std.parseInt(character)];
				reParseCharJson(daAnim);
				check_player.checked = daAnim.startsWith('bf');
				loadChar(!check_player.checked);
				updatePresence();
				reloadCharacterDropDown();
			});
			charDropDown.selectedLabel = daAnim;
			reloadCharacterDropDown();
			
			var reloadCharacter:FlxButton = new FlxButton(140, 20, "Reload Char", function()
				{
				loadChar(!check_player.checked);
				reloadCharacterDropDown();
			});
			
			var templateCharacter:FlxButton = new FlxButton(140, 50, "Load Template", function()
				{
				var parsedJson:CharacterFile = cast Json.parse(TemplateCharacter);
				var characters:Array<Character> = [char, ghostChar];
				for (character in characters)
					{
					character.animOffsets.clear();
					character.animationsArray = parsedJson.animations;
					for (anim in character.animationsArray)
						{
						character.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
					}
					if(character.animationsArray[0] != null) {
						character.playAnim(character.animationsArray[0].anim, true);
					}
					
					character.singDuration = parsedJson.sing_duration;
					character.positionArray = parsedJson.position;
					character.cameraPosition = parsedJson.camera_position;
					
					character.imageFile = parsedJson.image;
					character.jsonScale = parsedJson.scale;
					character.noAntialiasing = parsedJson.no_antialiasing;
					character.originalFlipX = parsedJson.flip_x;
					character.healthIcon = parsedJson.healthicon;
					character.healthColorArray = parsedJson.healthbar_colors;
					character.chartingButtonRGB = parsedJson.chartingButtonRGB;
					character.chartingButtonColour = parsedJson.chartingButtonColour;
					character.chartingButtonLabelTheme = parsedJson.chartingButtonLabelTheme;
					character.labelRGB = parsedJson.labelRGB;
					character.setPosition(character.positionArray[0] + OFFSET_X + 100, character.positionArray[1]);
				}
				
				reloadCharacterImage();
				reloadCharacterDropDown();
				reloadCharacterOptions();
				resetHealthBarColor();
				resetButtonShit();
				updatePointerPos();
				genBoyOffsets();
			});
			templateCharacter.color = FlxColor.RED;
			templateCharacter.label.color = FlxColor.WHITE;
			
			tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
			tab_group.add(check_player);
			tab_group.add(reloadCharacter);
			tab_group.add(charDropDown);
			tab_group.add(reloadCharacter);
			tab_group.add(templateCharacter);
			UI_box.addGroup(tab_group);
		}
		function resetButtonShit() {
			chartColorStepperR.value = char.healthColorArray[0];
			chartColorStepperG.value = char.healthColorArray[1];
			chartColorStepperB.value = char.healthColorArray[2];
			//needa make a buttonhealthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			trace(char.chartingButtonRGB);
			trace(char.healthColorArray);
		}
		public static function saveImage(bitmapData:BitmapData)
			{
				var b:ByteArray = new ByteArray();
				b = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions(true), b);
				new FileDialog().save(b, "png", null, "file");
			}
		var imageInputText:FlxUIInputText;
		var healthIconInputText:FlxUIInputText;
		
		var singDurationStepper:FlxUINumericStepper;
		var scaleStepper:FlxUINumericStepper;
		var positionXStepper:FlxUINumericStepper;
		var positionYStepper:FlxUINumericStepper;
		var positionCameraXStepper:FlxUINumericStepper;
		var positionCameraYStepper:FlxUINumericStepper;
		
		var flipXCheckBox:FlxUICheckBox;
		var noAntialiasingCheckBox:FlxUICheckBox;
		
		var healthColorStepperR:FlxUINumericStepper;
		var healthColorStepperG:FlxUINumericStepper;
		var healthColorStepperB:FlxUINumericStepper;

		var cbColorSameAsHealth:FlxUICheckBox;
		var getFromOldGridStyle:FlxButton;
		
		function addCharacterUI() {
			var tab_group = new FlxUI(null, UI_box);
			tab_group.name = "Character";
			
			imageInputText = new FlxUIInputText(15, 30, 200, 'characters/BOYFRIEND', 8);
			var reloadImage:FlxButton = new FlxButton(imageInputText.x + 210, imageInputText.y - 3, "Reload Image", function()
				{
				char.imageFile = imageInputText.text;
				reloadCharacterImage();
				if(char.animation.curAnim != null) {
					char.playAnim(char.animation.curAnim.name, true);
				}
			});
			
			var decideIconColor:FlxButton = new FlxButton(reloadImage.x, reloadImage.y + 30, "Get Icon Color", function()
				{
				var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(leHealthIcon));
				healthColorStepperR.value = coolColor.red;
				healthColorStepperG.value = coolColor.green;
				healthColorStepperB.value = coolColor.blue;
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperR, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperG, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperB, null); 
			});

			getFromOldGridStyle = new FlxButton(decideIconColor.x - 100, decideIconColor.y, "Get from grid...", function () {
				openSubState(new HealthIconFromGrid());
			});
			
			healthIconInputText = new FlxUIInputText(15, imageInputText.y + 35, 75, leHealthIcon.getCharacter(), 8);
			
			singDurationStepper = new FlxUINumericStepper(15, healthIconInputText.y + 45, 0.1, 4, 0, 999, 1);
			
			scaleStepper = new FlxUINumericStepper(15, singDurationStepper.y + 40, 0.1, 1, 0.05, 10, 1);
			
			flipXCheckBox = new FlxUICheckBox(singDurationStepper.x + 80, singDurationStepper.y, null, null, "Flip X", 50);
			flipXCheckBox.checked = char.flipX;
			if(char.isPlayer) flipXCheckBox.checked = !flipXCheckBox.checked;
			flipXCheckBox.callback = function() {
				char.originalFlipX = !char.originalFlipX;
				char.flipX = char.originalFlipX;
				if(char.isPlayer) char.flipX = !char.flipX;
				
				ghostChar.flipX = char.flipX;
			};
			
			noAntialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 40, null, null, "No Antialiasing", 80);
			noAntialiasingCheckBox.checked = char.noAntialiasing;
			noAntialiasingCheckBox.callback = function() {
				char.antialiasing = false;
				if(!noAntialiasingCheckBox.checked && ClientPrefs.globalAntialiasing) {
					char.antialiasing = true;
				}
				char.noAntialiasing = noAntialiasingCheckBox.checked;
			};
			
			positionXStepper = new FlxUINumericStepper(flipXCheckBox.x + 110, flipXCheckBox.y, 10, char.positionArray[0], -9000, 9000, 0);
			positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, char.positionArray[1], -9000, 9000, 0);
			
			positionCameraXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 10, char.cameraPosition[0], -9000, 9000, 0);
			positionCameraYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 10, char.cameraPosition[1], -9000, 9000, 0);
			
			var saveCharacterButton:FlxButton = new FlxButton(reloadImage.x, noAntialiasingCheckBox.y + 40, "Save Character", function() {
				saveCharacter();
			});
			
			healthColorStepperR = new FlxUINumericStepper(singDurationStepper.x, saveCharacterButton.y, 20, char.healthColorArray[0], 0, 255, 0);
			healthColorStepperG = new FlxUINumericStepper(singDurationStepper.x + 65, saveCharacterButton.y, 20, char.healthColorArray[1], 0, 255, 0);
			healthColorStepperB = new FlxUINumericStepper(singDurationStepper.x + 130, saveCharacterButton.y, 20, char.healthColorArray[2], 0, 255, 0);
			
			tab_group.add(new FlxText(15, imageInputText.y - 18, 0, 'Image file name:'));
			tab_group.add(new FlxText(15, healthIconInputText.y - 18, 0, 'Health icon name:'));
			tab_group.add(new FlxText(15, singDurationStepper.y - 18, 0, 'Sing Animation length:'));
			tab_group.add(new FlxText(15, scaleStepper.y - 18, 0, 'Scale:'));
			tab_group.add(new FlxText(positionXStepper.x, positionXStepper.y - 18, 0, 'Character X/Y:'));
			tab_group.add(new FlxText(positionCameraXStepper.x, positionCameraXStepper.y - 18, 0, 'Camera X/Y:'));
			tab_group.add(new FlxText(healthColorStepperR.x, healthColorStepperR.y - 18, 0, 'Health bar R/G/B:'));
			tab_group.add(getFromOldGridStyle);
			tab_group.add(imageInputText);
			tab_group.add(reloadImage);
			tab_group.add(decideIconColor);
			tab_group.add(healthIconInputText);
			tab_group.add(singDurationStepper);
			tab_group.add(scaleStepper);
			tab_group.add(flipXCheckBox);
			tab_group.add(noAntialiasingCheckBox);
			tab_group.add(positionXStepper);
			tab_group.add(positionYStepper);
			tab_group.add(positionCameraXStepper);
			tab_group.add(positionCameraYStepper);
			tab_group.add(healthColorStepperR);
			tab_group.add(healthColorStepperG);
			tab_group.add(healthColorStepperB);
			tab_group.add(saveCharacterButton);
			UI_characterbox.addGroup(tab_group);
		}
		var warnLabel:FlxText;
		var characterSide:FlxUIDropDownMenu;
		var songList:FlxUIDropDownMenu;
		var charToTest:String;
		var songForTest:String;
		var curChar:String;
		var chartColorStepperR:FlxUINumericStepper;
		var chartColorStepperG:FlxUINumericStepper;
		var chartColorStepperB:FlxUINumericStepper;
		var chartButtonPreviewer:FlxButton;
		var constantCBPUpdate:FlxUICheckBox;
		var cbpUpdatesConstantly:Bool = false;
		var labelTheme:FlxUIDropDownMenuCustom;
		function addTestCharUI() {
			var tab_group = new FlxUI(null, UI_box);
			tab_group.name = "Charting";
			
			chartColorStepperR = new FlxUINumericStepper(15, 30, 20, char.chartingButtonRGB[0], 0, 255, 0);
			chartColorStepperG = new FlxUINumericStepper(80, 30, 20, char.chartingButtonRGB[1], 0, 255, 0);
			chartColorStepperB = new FlxUINumericStepper(145, 30, 20, char.chartingButtonRGB[2], 0, 255, 0);

			cbColorSameAsHealth = new FlxUICheckBox(chartColorStepperR.x, chartColorStepperR.y + 80, null, null, "Charting Button Colour = Health Colour", 80);
			cbColorSameAsHealth.checked = false;
			cbColorSameAsHealth.callback = function() {
				char.chartingButtonColour = ColorUtil.rgbaToHex(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2], 255);
				chartColorStepperR.value = char.healthColorArray[0];
				chartColorStepperG.value = char.healthColorArray[1];
				chartColorStepperB.value = char.healthColorArray[2];
				getEvent(FlxUINumericStepper.CHANGE_EVENT, chartColorStepperR, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, chartColorStepperG, null);
				getEvent(FlxUINumericStepper.CHANGE_EVENT, chartColorStepperB, null); 
				resetButtonShit();
			};

			chartButtonPreviewer = new FlxButton(Math.floor(chartColorStepperB.x + chartColorStepperR.x / 2), Math.floor(30 + 80 / 2), 'PREVIEW', function() {
				FlxG.sound.play(Paths.sound('missnote1', shared));
				chartButtonPreviewer.color = FlxColor.fromRGB(char.chartingButtonRGB[0], char.chartingButtonRGB[1], char.chartingButtonRGB[2]);
					chartButtonPreviewer.label.color = char.chartingButtonLabelTheme;
			});
			chartButtonPreviewer.color = char.chartingButtonColour;
			chartButtonPreviewer.label.color = char.chartingButtonLabelTheme;

			constantCBPUpdate = new FlxUICheckBox(cbColorSameAsHealth.x, cbColorSameAsHealth.y + 30, null, null, 'Constantly update preview', 80);
			constantCBPUpdate.checked = false;
			constantCBPUpdate.callback = function() {
				cbpUpdatesConstantly = !cbpUpdatesConstantly;
			};

			labelTheme = new FlxUIDropDownMenuCustom(constantCBPUpdate.x, constantCBPUpdate.y + 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(['light', 'dark'], false), function(theme:String) {
				if (labelTheme.selectedLabel == 'light') {
					trace('light');
					char.chartingButtonLabelTheme = 0xFFFFFFFF;
					chartButtonPreviewer.label.color = 0xFFFFFFFF;
				} else {
					char.chartingButtonLabelTheme = 0xFF000000;
					chartButtonPreviewer.label.color = 0xFF000000;
				}
			});
			labelTheme.selectedLabel = 'light';
			/* characterSide = new FlxUIDropDownMenu(15, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray(['boyfriend', 'girlfriend', 'dad'], true), function(charToTest:String) {
				trace('selected');
				charToTest = characterSide.selectedLabel;
			});
			charToTest = characterSide.selectedLabel;
			var dum = [''];
			var dumAss = FileSystem.readDirectory('assets/data/');
			var dumAssTwo = FileSystem.readDirectory('mods/data');
			for (i in 0...dumAss.length) {
				if (!dumAss[i].endsWith('.txt') && !dumAss[i].endsWith('.TXT') && !dumAss[i].endsWith('.xml') && !dumAss[i].endsWith('.json')) {
					trace(Std.int(i + 1) + ' of ' + dumAss.length + ': Added song ' + dumAss[i] + ' to songlist');
					dum.push(dumAss[i]);
				} else {
					trace(Std.int(i + dumAss.length + 1) + ' of ' + dumAssTwo.length + ': Skipping ' + dumAss[i] + ', file is of extension ' + dumAss[i].substr(this.length - 4));
				}
			}
			for (i in 0...dumAssTwo.length) {
				if (!dumAssTwo[i].endsWith('.txt') && !dumAssTwo[i].endsWith('.json')) {
					trace(Std.int(i + 1) + ' of ' + dumAssTwo.length + ': Added song ' + dumAssTwo[i] + 'to songlist');
					dum.push(dumAssTwo[i]);
				} else {
					trace(Std.int(i + dumAss.length + 1) + ' of ' + dumAssTwo.length + ': Skipping ' + dumAss[i] + ', file is of extension ' + dumAss[i].substr(this.length - 4));
				}
			}
			songList = new FlxUIDropDownMenu(15, characterSide.y + 69, FlxUIDropDownMenuCustom.makeStrIdLabelArray(dum, true), function(songForTest:String) {
				trace('selected ' + songList.selectedLabel);
				songForTest = songList.selectedLabel;
				trace(songForTest);
			});
			// songForTest = songList.selectedLabel;
			trace(songForTest);
			
			var beginTest:FlxButton = new FlxButton(characterSide.x + 210, characterSide.y - 3, "Test Char.", function()
				{
				if (imageInputText.text == parsedCharJson.image) curChar = daAnim else {
					curChar = 'unknown';
					daAnim = 'unknown';
					saveCharacter();
				}
				openSubState(new CharacterTestStarter(songList.selectedLabel, charToTest, curChar));
			});
			
			// healthIconInputText = new FlxUIInputText(15, imageInputText.y + 35, 75, leHealthIcon.getCharacter(), 8);
			
			tab_group.add(new FlxText(15, characterSide.y - 18, 0, 'Test character as:'));
			tab_group.add(new FlxText(15, songList.y - 18, 0, 'Test with song:'));
			tab_group.add(characterSide);
			tab_group.add(beginTest);
			// tab_group.add(healthIconInputText); I DON'T NEED THIS FOR THIS GROUP
			tab_group.add(songList); */ //I WANT TO REPURPOSE THIS FOR THE CHARTING SHIT
			tab_group.add(chartColorStepperB);
			tab_group.add(chartColorStepperG);
			tab_group.add(chartColorStepperR);
			tab_group.add(cbColorSameAsHealth);
			tab_group.add(chartButtonPreviewer);
			tab_group.add(constantCBPUpdate);
			tab_group.add(labelTheme);
			UI_characterbox.addGroup(tab_group);
		}
		
		var ghostDropDown:FlxUIDropDownMenuCustom;
		var animationDropDown:FlxUIDropDownMenuCustom;
		var animationInputText:FlxUIInputText;
		var animationNameInputText:FlxUIInputText;
		var animationIndicesInputText:FlxUIInputText;
		var animationNameFramerate:FlxUINumericStepper;
		var animationLoopCheckBox:FlxUICheckBox;
		function addAnimationsUI() {
			var tab_group = new FlxUI(null, UI_box);
			tab_group.name = "Animations";
			
			animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
			animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
			animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
			animationNameFramerate = new FlxUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
			animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, null, null, "Should it Loop?", 100);
			
			animationDropDown = new FlxUIDropDownMenuCustom(15, animationInputText.y - 55, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(pressed:String) {
				var selectedAnimation:Int = Std.parseInt(pressed);
				var anim:AnimArray = char.animationsArray[selectedAnimation];
				animationInputText.text = anim.anim;
				animationNameInputText.text = anim.name;
				animationLoopCheckBox.checked = anim.loop;
				animationNameFramerate.value = anim.fps;
				
				var indicesStr:String = anim.indices.toString();
				animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
			});
			
			ghostDropDown = new FlxUIDropDownMenuCustom(animationDropDown.x + 150, animationDropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(pressed:String) {
				var selectedAnimation:Int = Std.parseInt(pressed);
				ghostChar.visible = false;
				char.alpha = 1;
				if(selectedAnimation > 0) {
					ghostChar.visible = true;
					ghostChar.playAnim(ghostChar.animationsArray[selectedAnimation-1].anim, true);
					char.alpha = 0.85;
				}
			});
			
			var addUpdateButton:FlxButton = new FlxButton(70, animationIndicesInputText.y + 30, "Add/Update", function() {
				var indices:Array<Int> = [];
				var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
				speen.visible = true;
				speen.animation.play('spin');
				if(indicesStr.length > 1) {
					for (i in 0...indicesStr.length) {
						var index:Int = Std.parseInt(indicesStr[i]);
						if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1) {
							indices.push(index);
						}
						if (i == indicesStr.length) {
							speen.animation.play('spun');
							speen.visible = false;
						}
					}
				}
				
				var lastAnim:String = '';
				if(char.animationsArray[curAnim] != null) {
					lastAnim = char.animationsArray[curAnim].anim;
				}
				
				var lastOffsets:Array<Int> = [0, 0];
				for (anim in char.animationsArray) {
					if(animationInputText.text == anim.anim) {
						lastOffsets = anim.offsets;
						if(char.animation.getByName(animationInputText.text) != null) {
							char.animation.remove(animationInputText.text);
						}
						char.animationsArray.remove(anim);
					}
				}
				
				var newAnim:AnimArray = {
					anim: animationInputText.text,
					name: animationNameInputText.text,
					fps: Math.round(animationNameFramerate.value),
					loop: animationLoopCheckBox.checked,
					indices: indices,
					offsets: lastOffsets
				};
				if(indices != null && indices.length > 0) {
					char.animation.addByIndices(newAnim.anim, newAnim.name, newAnim.indices, "", newAnim.fps, newAnim.loop);
				} else {
					char.animation.addByPrefix(newAnim.anim, newAnim.name, newAnim.fps, newAnim.loop);
				}
				
				if(!char.animOffsets.exists(newAnim.anim)) {
					char.addOffset(newAnim.anim, 0, 0);
				}
				if (!ghostChar.animOffsets.exists(newAnim.anim)) {
					ghostChar.addOffset(newAnim.anim, 0, 0);
				}
				ghostChar.animationsArray.push(newAnim);
				char.animationsArray.push(newAnim);
				
				if(lastAnim == animationInputText.text) {
					var leAnim:FlxAnimation = char.animation.getByName(lastAnim);
					if(leAnim != null && leAnim.frames.length > 0) {
						char.playAnim(lastAnim, true);
						speen.animation.play('spun');
						speen.visible = false;
					} else {
						for(i in 0...char.animationsArray.length) {
							if(char.animationsArray[i] != null) {
								leAnim = char.animation.getByName(char.animationsArray[i].anim);
								if(leAnim != null && leAnim.frames.length > 0) {
									char.playAnim(char.animationsArray[i].anim, true);
									curAnim = i;
									speen.animation.play('spun');
									speen.visible = false;
									break;
								}
							}
						}
					}
				}
				
				reloadAnimationDropDown();
				reloadGhost();
				genBoyOffsets();
				trace('Added/Updated animation: ' + animationInputText.text);
			});
			
			var removeButton:FlxButton = new FlxButton(180, animationIndicesInputText.y + 30, "Remove", function() {
				for (anim in char.animationsArray) {
					if(animationInputText.text == anim.anim) {
						var resetAnim:Bool = false;
						if(char.animation.curAnim != null && anim.anim == char.animation.curAnim.name) resetAnim = true;
						
						if(char.animation.getByName(anim.anim) != null) {
							char.animation.remove(anim.anim);
						}
						if(char.animOffsets.exists(anim.anim)) {
							char.animOffsets.remove(anim.anim);
						}
						char.animationsArray.remove(anim);
						
						if(resetAnim && char.animationsArray.length > 0) {
							char.playAnim(char.animationsArray[0].anim, true);
						}
						reloadAnimationDropDown();
						reloadGhost();
						genBoyOffsets();
						trace('Removed animation: ' + animationInputText.text);
						break;
					}
				}
			}); 
			
			tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
			tab_group.add(new FlxText(ghostDropDown.x, ghostDropDown.y - 18, 0, 'Animation Ghost:'));
			tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
			tab_group.add(new FlxText(animationNameFramerate.x, animationNameFramerate.y - 18, 0, 'Framerate:'));
			tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation on .XML/.TXT file:'));
			tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));
			
			tab_group.add(animationInputText);
			tab_group.add(animationNameInputText);
			tab_group.add(animationIndicesInputText);
			tab_group.add(animationNameFramerate);
			tab_group.add(animationLoopCheckBox);
			tab_group.add(addUpdateButton);
			tab_group.add(removeButton);
			tab_group.add(ghostDropDown);
			tab_group.add(animationDropDown); 
			UI_characterbox.addGroup(tab_group);
		}
		
		override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
			if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
				if(sender == healthIconInputText) {
					leHealthIcon.changeIcon(healthIconInputText.text);
					char.healthIcon = healthIconInputText.text;
					updatePresence();
				}
				else if(sender == imageInputText) {
					char.imageFile = imageInputText.text;
				}
			} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
				if (sender == scaleStepper)
					{
					reloadCharacterImage();
					char.jsonScale = sender.value;
					char.setGraphicSize(Std.int(char.width * char.jsonScale));
					char.updateHitbox();
					reloadGhost();
					updatePointerPos();
					
					if(char.animation.curAnim != null) {
						char.playAnim(char.animation.curAnim.name, true);
					}
				}
				else if(sender == positionXStepper)
					{
					char.positionArray[0] = positionXStepper.value;
					char.x = char.positionArray[0] + OFFSET_X + 100;
					updatePointerPos();
				}
				else if(sender == positionYStepper)
					{
					char.positionArray[1] = positionYStepper.value;
					char.y = char.positionArray[1];
					updatePointerPos();
				}
				else if(sender == positionCameraXStepper)
					{
					char.cameraPosition[0] = positionCameraXStepper.value;
					updatePointerPos();
				}
				else if(sender == positionCameraYStepper)
					{
					char.cameraPosition[1] = positionCameraYStepper.value;
					updatePointerPos();
				}
				else if(sender == healthColorStepperR)
					{
					char.healthColorArray[0] = Math.round(healthColorStepperR.value);
					healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
				}
				else if(sender == healthColorStepperG)
					{
					char.healthColorArray[1] = Math.round(healthColorStepperG.value);
					healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
				}
				else if(sender == healthColorStepperB)
					{
					char.healthColorArray[2] = Math.round(healthColorStepperB.value);
					healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
				}
				else if(sender == chartColorStepperR)
					{
					char.chartingButtonRGB[0] = Math.round(chartColorStepperR.value);
					//needa make a buttonhealthBarBG.color = FlxColor.fromRGB(char.chartingButtonRGB[0], char.chartingButtonRGB[1], char.chartingButtonRGB[2]);
				}
				else if(sender == chartColorStepperG)
					{
					char.chartingButtonRGB[1] = Math.round(chartColorStepperG.value);
					// healthBarBG.color = FlxColor.fromRGB(char.chartingButtonRGB[0], char.chartingButtonRGB[1], char.chartingButtonRGB[2]);
				}
				else if(sender == chartColorStepperB)
					{
					char.chartingButtonRGB[2] = Math.round(chartColorStepperB.value);
					// healthBarBG.color = FlxColor.fromRGB(char.chartingButtonRGB[0], char.chartingButtonRGB[1], char.chartingButtonRGB[2]);
				}
			}
		}
		
		function reloadCharacterImage() {
			var lastAnim:String = '';
			if(char.animation.curAnim != null) {
				lastAnim = char.animation.curAnim.name;
			}
			
			var anims:Array<AnimArray> = char.animationsArray.copy();
			if(Paths.fileExists('images/' + char.imageFile + '.txt', TEXT)) {
				char.frames = Paths.getPackerAtlas(char.imageFile);
			} else {
				char.frames = Paths.getSparrowAtlas(char.imageFile);
			}
			
			if(char.animationsArray != null && char.animationsArray.length > 0) {
				for (anim in char.animationsArray) {
					var animAnim:String = '' + anim.anim;
					var animName:String = '' + anim.name;
					var animFps:Int = anim.fps;
					var animLoop:Bool = !!anim.loop; //Bruh
					var animIndices:Array<Int> = anim.indices;
					if(animIndices != null && animIndices.length > 0) {
						char.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					} else {
						char.animation.addByPrefix(animAnim, animName, animFps, animLoop);
					}
				}
			} else {
				char.quickAnimAdd('idle', 'BF idle dance');
			}
			
			if(lastAnim != '') {
				char.playAnim(lastAnim, true);
			} else {
				char.dance();
			}
			ghostDropDown.selectedLabel = '';
			reloadGhost();
		}
		
		function genBoyOffsets():Void
			{
			var daLoop:Int = 0;
			
			var i:Int = dumbTexts.members.length-1;
			while(i >= 0) {
				var memb:FlxText = dumbTexts.members[i];
				if(memb != null) {
					memb.kill();
					dumbTexts.remove(memb);
					memb.destroy();
				}
				--i;
			}
			dumbTexts.clear();
			
			for (anim => offsets in char.animOffsets)
				{
				var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
				text.setFormat(null, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.scrollFactor.set();
				text.borderSize = 1;
				dumbTexts.add(text);
				text.cameras = [camHUD];
				
				daLoop++;
			}
			
			textAnim.visible = true;
			if(dumbTexts.length < 1) {
				var text:FlxText = new FlxText(10, 38, 0, "ERROR! No animations found.", 15);
				text.scrollFactor.set();
				text.borderSize = 1;
				dumbTexts.add(text);
				textAnim.visible = false;
			}
		}
		
		function loadChar(isDad:Bool, blahBlahBlah:Bool = true) {
			var i:Int = charLayer.members.length-1;
			while(i >= 0) {
				var memb:Character = charLayer.members[i];
				if(memb != null) {
					memb.kill();
					charLayer.remove(memb);	
					memb.destroy();
				}
				--i;
			}
			charLayer.clear();
			ghostChar = new Character(0, 0, daAnim, !isDad);
			ghostChar.debugMode = true;
			ghostChar.alpha = 0.6;
			
			char = new Character(0, 0, daAnim, !isDad);
			if(char.animationsArray[0] != null) {
				char.playAnim(char.animationsArray[0].anim, true);
			}
			char.debugMode = true;
			
			charLayer.add(ghostChar);
			charLayer.add(char);
			
			char.setPosition(char.positionArray[0] + OFFSET_X + 100, char.positionArray[1]);
			
			/* THIS FUNCTION WAS USED TO PUT THE .TXT OFFSETS INTO THE .JSON
			
			for (anim => offset in char.animOffsets) {
				var leAnim:AnimArray = findAnimationByName(anim);
				if(leAnim != null) {
					leAnim.offsets = [offset[0], offset[1]];
				}
			}*/
			
			if(blahBlahBlah) {
				genBoyOffsets();
			}
			reloadCharacterOptions();
			reloadBGs();
			updatePointerPos();
		}
		
		function updatePointerPos() {
			var x:Float = char.getMidpoint().x;
			var y:Float = char.getMidpoint().y;
			if(!char.isPlayer) {
				x += 150 + char.cameraPosition[0];
			} else {
				x -= 100 + char.cameraPosition[0];
			}
			y -= 100 - char.cameraPosition[1];
			
			x -= cameraFollowPointer.width / 2;
			y -= cameraFollowPointer.height / 2;
			cameraFollowPointer.setPosition(x, y);
		}
		
		function findAnimationByName(name:String):AnimArray {
			for (anim in char.animationsArray) {
				if(anim.anim == name) {
					return anim;
				}
			}
			return null;
		}
		
		function reloadCharacterOptions() {
			if(UI_characterbox != null) {
				imageInputText.text = char.imageFile;
				healthIconInputText.text = char.healthIcon;
				singDurationStepper.value = char.singDuration;
				scaleStepper.value = char.jsonScale;
				flipXCheckBox.checked = char.originalFlipX;
				noAntialiasingCheckBox.checked = char.noAntialiasing;
				resetHealthBarColor();
				leHealthIcon.changeIcon(healthIconInputText.text);
				positionXStepper.value = char.positionArray[0];
				positionYStepper.value = char.positionArray[1];
				positionCameraXStepper.value = char.cameraPosition[0];
				positionCameraYStepper.value = char.cameraPosition[1];
				reloadAnimationDropDown();
				updatePresence();
			}
		}
		
		function reloadAnimationDropDown() {
			var anims:Array<String> = [];
			var ghostAnims:Array<String> = [''];
			for (anim in char.animationsArray) {
				anims.push(anim.anim);
				ghostAnims.push(anim.anim);
			}
			if(anims.length < 1) anims.push('NO ANIMATIONS'); //Prevents crash
			
			animationDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true));
			ghostDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(ghostAnims, true));
			reloadGhost();
		}
		
		function reloadGhost() {
			ghostChar.frames = char.frames;
			for (anim in char.animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					ghostChar.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				} else {
					ghostChar.animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				
				if(anim.offsets != null && anim.offsets.length > 1) {
					ghostChar.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}
			}
			
			char.alpha = 0.85;
			ghostChar.visible = true;
			if(ghostDropDown.selectedLabel == '') {
				ghostChar.visible = false;
				char.alpha = 1;
			}
			ghostChar.color = 0xFF666688;
			
			ghostChar.setGraphicSize(Std.int(ghostChar.width * char.jsonScale));
			ghostChar.updateHitbox();
		}
		
		function reloadCharacterDropDown() {
			var charsLoaded:Map<String, Bool> = new Map();
			
			#if MODS_ALLOWED
			characterList = [];
			var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/')];
			for (i in 0...directories.length) {
				var directory:String = directories[i];
				if(FileSystem.exists(directory)) {
					for (file in FileSystem.readDirectory(directory)) {
						var path = haxe.io.Path.join([directory, file]);
						if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
							var charToCheck:String = file.substr(0, file.length - 5);
							if(!charsLoaded.exists(charToCheck)) {
								characterList.push(charToCheck);
								charsLoaded.set(charToCheck, true);
							}
						}
					}
				}
			}
			#else
			characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
			#end
			
			charDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
			charDropDown.selectedLabel = daAnim;
		}
		
		function resetHealthBarColor() {
			healthColorStepperR.value = char.healthColorArray[0];
			healthColorStepperG.value = char.healthColorArray[1];
			healthColorStepperB.value = char.healthColorArray[2];
			healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
		}
		
		function updatePresence() {
			#if desktop
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Programming", "Character: " + daAnim, leHealthIcon.getCharacter());
			#end
		}
		
		override function update(elapsed:Float)
			{
			if(char.animationsArray[curAnim] != null) {
				textAnim.text = char.animationsArray[curAnim].anim;
				
				var curAnim:FlxAnimation = char.animation.getByName(char.animationsArray[curAnim].anim);
				if(curAnim == null || curAnim.frames.length < 1) {
					textAnim.text += ' (ERROR!)';
				}
			} else {
				textAnim.text = '';
			}

			if (!FlxG.mouse.useSystemCursor) {
				FlxG.mouse.cursorContainer.useHandCursor = true;
			}
			
			if (cbpUpdatesConstantly) {
				if (chartButtonPreviewer != null && chartButtonPreviewer.visible) {
					chartButtonPreviewer.color = FlxColor.fromRGB(char.chartingButtonRGB[0], char.chartingButtonRGB[1], char.chartingButtonRGB[2]);
					chartButtonPreviewer.label.color = char.chartingButtonLabelTheme;
				}
			}
			var inputTexts:Array<FlxUIInputText> = [animationInputText, imageInputText, healthIconInputText, animationNameInputText, animationIndicesInputText];
			for (i in 0...inputTexts.length) {
				if(inputTexts[i].hasFocus) {
					if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
						inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
						inputTexts[i].caretIndex = inputTexts[i].text.length;
						getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
					}
					if(FlxG.keys.justPressed.ENTER) {
						inputTexts[i].hasFocus = false;
					}
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					super.update(elapsed);
					return;
				}
			}
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			
			if(!charDropDown.dropPanel.visible) {
				if (FlxG.keys.justPressed.ESCAPE) {
					if(goToPlayState) {
						MusicBeatState.switchState(new PlayState());
					} else {
						MusicBeatState.switchState(new editors.MasterEditorMenu());
						if (!TitleState.fuckinAsshole) {
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
						} else {
							FlxG.sound.playMusic(Paths.music('clownTheme'));
						}
					}
					FlxG.mouse.visible = false;
					return;
				}
				
				if (FlxG.keys.justPressed.R) {
					FlxG.camera.zoom = 1;
				}
				
				if (FlxG.keys.justPressed.V) {
					var funnyData:Array<Dynamic> = [Std.string(FlxG.save.data)];
					trace('im dumb');
					// FlxG.save.resetFlag('unlockedMiniSaber', funnyData);
				}
				
				if (FlxG.keys.justPressed.COMMA) {
					openSubState(new SavingYourBullshit('minisaber'));
				}
				
				if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) {
					FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
					if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
				}
				if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
					FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
					if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
				}
				
				if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
					{
					var addToCam:Float = 500 * elapsed;
					if (FlxG.keys.pressed.SHIFT)
						addToCam *= 4;
					
					if (FlxG.keys.pressed.I)
						camFollow.y -= addToCam;
					else if (FlxG.keys.pressed.K)
						camFollow.y += addToCam;
					
					if (FlxG.keys.pressed.J)
						camFollow.x -= addToCam;
					else if (FlxG.keys.pressed.L)
						camFollow.x += addToCam;
				}
				
				if(char.animationsArray.length > 0) {
					if (FlxG.keys.justPressed.W)
						{
						curAnim -= 1;
					}
					
					if (FlxG.keys.justPressed.S)
						{
						curAnim += 1;
					}
					
					if (curAnim < 0)
						curAnim = char.animationsArray.length - 1;
					
					if (curAnim >= char.animationsArray.length)
						curAnim = 0;
					
					if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
						{
						char.playAnim(char.animationsArray[curAnim].anim, true);
						genBoyOffsets();
					}
					
					if (FlxG.keys.justPressed.R)
						{
						char.animationsArray[curAnim].offsets = [0, 0];
						
						char.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
						ghostChar.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
						genBoyOffsets();
					}
					
					var controlArray:Array<Bool> = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];
					
					
					
					for (i in 0...controlArray.length) {
						if(controlArray[i]) {
							var holdShift = FlxG.keys.pressed.SHIFT;
							var multiplier = 1;
							if (holdShift)
								multiplier = 10;
							
							var arrayVal = 0;
							if(i > 1) arrayVal = 1;
							
							var negaMult:Int = 1;
							if(i % 2 == 1) negaMult = -1;
							char.animationsArray[curAnim].offsets[arrayVal] += negaMult * multiplier;
							char.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
							ghostChar.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
							
							char.playAnim(char.animationsArray[curAnim].anim, false);
							if(ghostChar.animation.curAnim != null && char.animation.curAnim != null && char.animation.curAnim.name == ghostChar.animation.curAnim.name) {
								ghostChar.playAnim(char.animation.curAnim.name, false);
							}
							genBoyOffsets();
						}
					}
				}
			}
			camMenu.zoom = FlxG.camera.zoom;
			ghostChar.setPosition(char.x, char.y);
			super.update(elapsed);
		}
		
		var _file:FileReference;
		/*private function saveOffsets()
			{
			var data:String = '';
			for (anim => offsets in char.animOffsets) {
				data += anim + ' ' + offsets[0] + ' ' + offsets[1] + '\n';
			}
			
			if (data.length > 0)
				{
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(data, daAnim + "Offsets.txt");
			}
		}*/
		
		function onSaveComplete(_):Void
			{
			_file.removeEventListener(Event.COMPLETE, onSaveComplete);
			_file.removeEventListener(Event.CANCEL, onSaveCancel);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file = null;
			FlxG.log.notice("Successfully saved file.");
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
			FlxG.log.error("Problem saving file");
		}
		
		public function saveCharacter() {
			var json = {
				"animations": char.animationsArray,
				"image": char.imageFile,
				"scale": char.jsonScale,
				"sing_duration": char.singDuration,
				"healthicon": char.healthIcon,
				
				"position":	char.positionArray,
				"camera_position": char.cameraPosition,
				
				"flip_x": char.originalFlipX,
				"no_antialiasing": char.noAntialiasing,
				"healthbar_colors": char.healthColorArray,
				"chartingButtonColour": char.chartingButtonColour,
				"chartingButtonLabelTheme": char.chartingButtonLabelTheme,
				"shitpost": true,
			};
			
			// savingYourShit = true;
			
			var data:String = Json.stringify(json, "\t");
			
			if (data.length > 0)
				{
				// openSubState(new SavingYourBullshit('bf'));
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(data, daAnim + ".json");
			}
		}
		
		function ClipboardAdd(prefix:String = ''):String {
			if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
				{
				prefix = prefix.substring(0, prefix.length-1);
			}
			
			var text:String = prefix + Clipboard.text.replace('\n', '');
			return text;
		}

		/* function convertHealthToButtonColours () {
			trace('just a sec');
			if (!speen.visible) speen.visible = true;
			new FlxTimer().start(3, function (tmr:FlxTimer) {
				var tmpColour = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[1]);
				
			})
		} */
		
		function reParseCharJson(charName:String = 'spooky') {
			// char.visible = false;
			// textAnim.visible = false;
			var isModCharacter:Bool = false;
			var fuckinPaths:Array<String> = ['assets/characters/', 'mods/characters/'];
			var parseJsonBg:FlxSprite = new FlxSprite(0).makeGraphic(1280, 720, FlxColor.fromRGB(0, 128, 128, 128));
			var charFile:String;
			var speen:FlxSprite;
			/* parseJsonBg.screenCenter();
			parseJsonBg.cameras = [camMenu];
			add(parseJsonBg);
			var parseJsonText:FlxText = new FlxText(0, 0, FlxG.width, 'Parsing json: ' + charName + '\nPlease wait...');
			parseJsonText.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			parseJsonText.screenCenter();
			parseJsonText.cameras = [camMenu]; */
			speen = new FlxSprite(FlxG.width - 48, FlxG.height - 48);
			speen.frames = FlxAtlasFrames.fromSparrow('assets/images/editor/speen.png', 'assets/images/editor/speen.xml');
			speen.animation.addByPrefix('spin', 'spinner go brr', 30, true);
			speen.animation.play('spin');
			speen.cameras = [camMenu];
			add(speen);
			// add(parseJsonText);
			new FlxTimer().start(5, function (tmr:FlxTimer) {
				/* if (FileSystem.exists(fuckinPaths[0] + charName + '.json')) {
					charFile = fuckinPaths[0] + charName + '.json';
					#if debug
					parseJsonText.text = 'Character data for ' + charName + ' found. Output will be displayed in the console.';
					#else
					parseJsonText.text = 'Character data for ' + charName + ' found.';
					#end
					parseJsonText.updateHitbox();
					parsedCharJson = Json.parse(File.getContent(charFile)); */
					speen.visible = false;
					/* char.visible = true;
					textAnim.visible = true;
					#if debug
					trace(parsedCharJson);
					#end
				} else if (FileSystem.exists(fuckinPaths[1] + charName + '.json')) {
					charFile = fuckinPaths[1] + charName + '.json';
					#if debug
					parseJsonText.text = 'Character data for ' + charName + ' found. Output will be displayed in the console.';
					#else
					parseJsonText.text = 'Character data for ' + charName + ' found.';
					#end
					parseJsonText.updateHitbox();
					isModCharacter = true;
					parsedCharJson = Json.parse(File.getContent(charFile));
					speen.visible = false;
					/* char.visible = true;
					textAnim.visible = true;
					#if debug
					trace(parsedCharJson);
					#end
				} else {
					parseJsonBg.color = FlxColor.fromRGB(128, 0, 0, 128);
					parseJsonText.text = 'Could not find character data for ' + charName + ', is the file still there?';
					parseJsonText.updateHitbox();
					speen.visible = false;
					/*textAnim.visible = true;
					char.visible = true;
				}
				new FlxTimer().start(3, function(tmr:FlxTimer) {
					parseJsonBg.destroy();
					parseJsonText.destroy();
				}); */
			});
		}
		
		public static var instance:CharacterEditorState;
	
	var shared(default, null):Null<String> = 'shared';
}
	
	class CharacterTestStarter extends MusicBeatSubstate {
		var saveBg:FlxSprite;
		var saveTexts:Array<FlxText>;
		var saveNameBox:FlxUIInputText;
		var saveButton:FlxButton;
		var warningBg:FlxSprite;
		var warningText:FlxText;
		var confirmButton:FlxButton;
		var cancelButton:FlxButton;
		var camAmogus:FlxCamera;
		var camSussy:FlxCamera;
		
		public function new(songName:String, charType:String, charName:String = 'blaze') {
			super();
			camAmogus = new FlxCamera();
			camAmogus.bgColor.alpha = 0;
			camSussy = new FlxCamera();
			camSussy.bgColor.alpha = 0;
			FlxG.cameras.add(camAmogus);
			FlxG.cameras.add(camSussy);
			// update(elapsed);
			
			if (charName == 'unknown') {
				/* saveBg = new FlxSprite(0, 0);
				if (FileSystem.exists(Paths.image('editor/haha.png'))) saveBg.loadGraphic('assets/images/editor/haha.png') else saveBg.makeGraphic(1280, 720, FlxColor.fromRGB(0, 128, 128, 200));
				if (saveBg.alpha == 1) {
					saveBg.screenCenter();
					saveBg.setGraphicSize(FlxG.width, FlxG.height);
					saveBg.updateHitbox();
				} else {
					saveBg.screenCenter();
				}
				saveBg.cameras = [camSussy];
				var saveTextAsk:FlxText = new FlxText(0, FlxG.height - 500, FlxG.width);
				saveTextAsk.text = 'CAUTION: You currently have unsaved work. Do you want to save it? If so, give your character a name below.';
				saveTextAsk.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.RED, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.YELLOW);
				saveTextAsk.screenCenter(X);
				saveTexts.push(saveTextAsk);
				saveNameBox = new FlxUIInputText(0, 0, 500, charName, 16);
				saveNameBox.screenCenter();
				add(saveNameBox);
				var saveTextWarn:FlxText = new FlxText(saveTextAsk.x, saveNameBox.y - 25, FlxG.width);
				saveTextWarn.text = 'A character with this name already exists. If you continue, they will be overwritten.';
				saveTextWarn.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.RED, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.YELLOW);
				saveTexts.push(saveTextWarn);
				saveButton = new FlxButton(0, FlxG.height - 50, 'Save', function () {
					CharacterEditorState.instance.daAnim = saveNameBox.text;
					CharacterEditorState.instance.saveCharacter();
				});
				add(saveButton);
				for (i in 0...saveTexts.length) {
					add(saveTexts[i]);
				} */
				trace('information about what you testin:\nSONG: ' + songName + '\nCHARACTER IS A ' + charType + ' CHARACTER\nCHARACTER NAME: ' + charName);
				openSubState(new editors.ConfirmYourContent(1, 0, 'funnyNotes/gloopy', charName, charType, songName));
			} else {
				trace('information about what you testin:\nSONG: ' + songName + '\nCHARACTER IS A ' + charType + ' CHARACTER\nCHARACTER NAME: ' + charName);
				openSubState(new editors.ConfirmYourContent(1, 0, 'funnyNotes/gloopy', charName, charType, songName));
			}
		}
		
		function openTestUI(songName:String = 'Dad-battle', charType:String, charName:String) {
			warningBg = new FlxSprite(0).makeGraphic(FlxG.width, FlxG.height, FlxColor.ORANGE);
			warningBg.alpha = 0.5;
			warningBg.screenCenter();
			warningBg.cameras = [camAmogus];
			add(warningBg);
			warningText = new FlxText(0, 0, FlxG.width, '');
			warningText.setFormat(Paths.font('funny.ttf'), 48, FlxColor.WHITE, CENTER, SHADOW, FlxColor.GRAY);
			warningText.text = 'Have you saved your character? If not, make sure to save it to:\nmods/characters/' + charName + '.json\nMake sure you do this BEFORE clicking Start Test, as you CANNOT recover any unsaved edits you have made here once you click it.';
			warningText.cameras = [camAmogus];
			warningText.screenCenter();
			add(warningText);
			confirmButton = new FlxButton(warningText.x, warningText.y - 100, 'Continue', function() {
				PlayState.SONG = Song.loadFromJson(songName.toLowerCase(), songName.toLowerCase());
				switch (charType) {
					case 'boyfriend':
					PlayState.SONG.player1 = charName;
					case 'dad':
					PlayState.SONG.player2 = charName;
					case 'girlfriend':
					PlayState.SONG.gfVersion = charName;	
				}
				MusicBeatState.switchState(new PreloadLargerCharacters(songName, true));
			});
			confirmButton.cameras = [camAmogus];
			cancelButton = new FlxButton(confirmButton.x + 150, confirmButton.y, 'Cancel', function() {
				closeSubState();
			});
			cancelButton.cameras = [camAmogus];
			add(confirmButton);
			add(cancelButton);
		}
		
		// var elapsed(default, null):Float;
	}
	
	class SavingYourBullshit extends MusicBeatSubstate {
		var savingBg:FlxSprite;
		var savingText:FlxText;
		var saveDone:Bool = false;
		var savingChar:FlxSprite;
		var speen:FlxSprite; //for future use lmao
		var camSave:FlxCamera;
		var spiffy:FlxSound;
		public var instance:SavingYourBullshit; //dont want to cause bullshit
		var charas:Array<String> = [''];
		var startedLoop:Bool = false;
		
		public function new(randomChar:String) {
			super();
			// update(elapsed);
			var cumCar:Array<Dynamic> = [];
			/* var cummy = FileSystem.readDirectory('assets/characters');
			var cumSpice = FileSystem.readDirectory('mods/characters');
			for (i in 0...cummy.length) {
				trace(Std.int(i + 1) + ' of ' + cummy.length + ': Your shitbox looks nice, ' + cummy[i]);
				cumCar.push(cummy[i]);
			}
			for (i in 0...cumSpice.length) {
				trace(Std.int(i + cummy.length + 1) + ' of ' + Std.int(cummy.length + cumSpice.length) + ': Your shitbox looks nice, ' + cumSpice[i]);
				if (cumSpice[i] != 'huggy.json') cumCar.push('mods/images/characters/' + cumSpice[i].substr(0, this.length - 4));
			} */
			spiffy = new FlxSound();
			spiffy.loadEmbedded(Paths.sound('lookingSpiffy'), false);
			camSave = new FlxCamera();
			camSave.bgColor.alpha = 0;
			FlxG.cameras.add(camSave);
			savingBg = new FlxSprite(0).makeGraphic(1280, 720, FlxColor.GREEN);
			savingBg.alpha = 0.5;
			savingBg.screenCenter();
			savingBg.cameras = [camSave];
			add(savingBg);
			savingText = new FlxText(0, 0);
			savingText.text = 'Now saving your character!';
			savingText.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			savingText.screenCenter();
			savingText.cameras = [camSave];
			add(savingText);
			// randomChar = Random.fromArray(cumCar);
			/* savingChar = new FlxSprite(0, savingText.y - 128);
			savingChar.frames = Paths.getSparrowAtlas(Paths.modsImages('characters/Blitz_Assets').substr(0, this.length - 4));
			trace(Paths.modsImages('characters/Blitz_Assets'));
			trace(savingChar.frames);
			savingChar.animation.addByPrefix('idle', 'look at this CLOWN lfmoa', 24, true);
			savingChar.animation.addByPrefix('ayyy', 'CRINGE ASS DAB');
			savingChar.animation.play('idle');
			savingChar.cameras = [camSave];
			savingChar.screenCenter(X);
			add(savingChar); */
			speen = new FlxSprite(FlxG.width - 48, FlxG.height - 48);
			speen.frames = FlxAtlasFrames.fromSparrow('assets/images/editor/speen.png', 'assets/images/editor/speen.xml');
			speen.animation.addByPrefix('spin', 'spinner go brr', 30, true);
			speen.animation.play('spin');
			speen.cameras = [camSave];
			add(speen);
			FlxG.sound.playMusic(Paths.music('saveStart'), 1, false);
			new FlxTimer().start(Std.int(FlxG.sound.music.length / 1000), function(tmr:FlxTimer) {
				startedLoop = true;
			});
		}
		
		
		override function update(elapsed:Float) {
			if (savingChar != null) {
				savingChar.update(elapsed);
			}
			if (FlxG.sound.music != null && startedLoop) {
				startedLoop = false;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music('saveLoop'), 1, true);
			}
			if (speen != null) {
				speen.update(elapsed);
			}
			if (!CharacterEditorState.savingYourShit) {
				if (!saveDone) trace('save complete');
				saveDone = true;
				if (savingText != null) savingText.text = 'Save complete!\nClosing in 5 seconds';
				/* if (savingChar.animation.getByName('ayyy') != null) {
					savingChar.animation.play('ayyy');
				} */
				new FlxTimer().start(5, function (tmr:FlxTimer) {
					FlxG.sound.music.stop();
					if (!spiffy.playing) spiffy.play();
					// FlxG.sound.play('assets/sounds/lookingSpiffy.ogg');
					close();
				});
			}
		}
		
		var elapsed(default, null):Float;
	}

//i'm reworking the icon grid thing in its own file!!
