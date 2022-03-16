package random.util;

import PlayState;
import Character;
import Boyfriend;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import sys.FileSystem;
import DialogueBoxPsych.DialogueFile;
import haxe.Json;

using StringTools;

/**A few dumb utils to save typing time, really. Idk
    @since Emo Engine 0.1.2 (March 2022)*/
class DumbUtil {
    // var PlayStation:PlayState;
    // static var BitchOne:Boyfriend;
    // static var BitchTwo:Character;

    public static function getBfAnim(AnimName:String):Bool {
        var PlayStation:PlayState = PlayState.instance;
        var BitchOne:Boyfriend = PlayStation.boyfriend;
        trace(BitchOne.animation.getByName(AnimName));
        if (BitchOne.animation.getByName(AnimName) != null) {
            return true;
        } else return false;
    }

    public static function getGfAnim(AnimName:String):Bool {
        var PlayStation:PlayState = PlayState.instance;
        var BitchTwo:Character = PlayStation.gf;
        trace(BitchTwo.animation.getByName(AnimName));
        if (BitchTwo.animation.getByName(AnimName) != null) {
            return true;
        } else return false;
    }

    public static function getDaddyAnim(AnimName:String):Bool {
        var PlayStation:PlayState = PlayState.instance;
        var BitchTwo:Character = PlayStation.dad;
        trace(BitchTwo.animation.getByName(AnimName));
        if (BitchTwo.animation.getByName(AnimName) != null) {
            return true;
        } else return false;
    }

    public static function getAllChars():Array<String> {
        var charList:Array<String> = [];
        var baseGameChars = FileSystem.readDirectory('assets/characters');
        for (i in 0...baseGameChars.length) {
            if (getExt(baseGameChars[i]) == 'json') charList.push(baseGameChars[i]);
        }
        #if MODS_ALLOWED
        var modCharBase = FileSystem.readDirectory('mods/characters');
        for (i in 0...modCharBase.length) {
            if (getExt(modCharBase[i]) == 'json') charList.push(modCharBase[i]);
        }
        if (Paths.currentModDirectory != '') {
            var modCharCur = FileSystem.readDirectory('mods/' + Paths.currentModDirectory + '/characters');
            for (i in 0...modCharCur.length) {
                if (getExt(modCharCur[i]) == 'json') charList.push(modCharCur[i]);
            }
        }
        #end
        return charList;
    }

    public static function getExt(FileName:String):String {
        if (!FileName.contains('.')) {
            return 'no ext found';
        } else {
            var benis = FileName.split('.');
            return benis[1];
        }
    }

    public static function parseSnowdriftChatter(Chatter:String):DialogueFile {
        return cast Json.parse(Chatter);
    }
}