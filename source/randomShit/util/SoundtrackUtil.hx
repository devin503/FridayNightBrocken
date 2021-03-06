package randomShit.util;

import randomShit.dumb.SoundtrackMenu;
import sys.io.FileOutput;
import lime.ui.FileDialog;
import haxe.exceptions.ArgumentException;
import randomShit.dumb.SoundtrackMenu.OSTData;
import Song.SwagSong; // cause i need it
#if sys
import sys.FileSystem;
import sys.io.File;
#else
import openfl.assets.Assets;
#end
import haxe.Json;
using StringTools;

/**Probably unnecessary util class for OST data.
    @since March 2022 (Emo Engine 0.2.0)
**/
class SoundtrackUtil {
    /**The preload path for base-game songs.*/
    static #if !ios inline #end final SoundtrackPath:String = "assets/ost/";
    /**The default path for mod songs.*/
    #if MODS_ALLOWED static #if !ios inline #end final ModSoundtrackPath:String = "mods/ost/"; #end
    public static function SETUP_DEFAULTS() {
        var baseList = SelectChara.baseSongs;
        var DEFAULTS_TO_CREATE:Array<OSTData> = [];
        for (i in 0...baseList.length) {
            if (FileSystem.exists(SoundtrackPath + baseList[i] + '.json')) continue;
            else {
                var player = knockOnWood(Paths.json(baseList[i] + '/' + baseList[i]));
                var pepperCat = cast Json.parse(Json.stringify(player.song, "\t"));
                //trace(pepperCat.song);

                var totalDramaIsland:OSTData = {
                    songName:pepperCat.song,
                    defaultOpponent: getOpponent(pepperCat),
                    defaultBf: pepperCat.player1,
                    songColor: null,
                    hasVoices: pepperCat.needsVoices,
                    bfIcon: pepperCat.player1,
                    dadIcon: null,
                    iconChanges: null
                };
                totalDramaIsland.dadIcon = totalDramaIsland.defaultOpponent;
                totalDramaIsland.songColor = DumbUtil.parseChars([totalDramaIsland.defaultOpponent])[0].healthbar_colors;
                DEFAULTS_TO_CREATE.push(totalDramaIsland);
                trace(totalDramaIsland);
            }
        }
        if (DEFAULTS_TO_CREATE.length >= 1) {
            for (file in DEFAULTS_TO_CREATE) {
                //var SussyFile:File;
                File.write(SoundtrackPath + Paths.formatToSongPath(file.songName.toLowerCase()) + '.json');
                File.saveContent(SoundtrackPath + Paths.formatToSongPath(file.songName.toLowerCase()) + '.json', Json.stringify(file, "\t"));
            }
        }
    }

    static function getOpponent(SongInfo:SwagSong):String {
        if (SongInfo.player2 != null && SongInfo.player2 != 'nobody') {
            return SongInfo.player2;
        } else if (SongInfo.player2 == 'nobody') {
            if (SongInfo.player3 != null) {
                return SongInfo.player3;
            } else if (SongInfo.gfVersion != null) {
                return SongInfo.gfVersion;
            } else return SongInfo.player1; // FALLBACK!!
        }
        return "LMAO";
    }
    public static function getSoundtrackList():Array<OSTData> {
        var fileList:Array<String> = [];
        var ReturnThese:Array<OSTData> = HarderThanMyDick.theseSongs();
        if (ReturnThese.length >= 1) {
            for (fuckYou in ReturnThese) {
                    trace("Song " + (ReturnThese.indexOf(fuckYou) + 1) + " of " + ReturnThese.length + ": " + fuckYou.songName + " is hardcoded!!");
                    SoundtrackMenu.hardDong.push(true);
            }
        }
        var KEKE = readPath(SoundtrackPath);
        for (file in KEKE) {
            if (file != "TEMPLATE.TXT") {
                fileList.push(SoundtrackPath + file);
                trace("Added base song file " + (KEKE.indexOf(file) + 1) + " of " + KEKE.length + ".");
            }
        }
        #if MODS_ALLOWED
        if (Paths.currentModDirectory.length >= 1) {
            var metalBeetle = readPath('mods/' + Paths.currentModDirectory + '/ost');
            if (metalBeetle[0] != "NO_FILES") {
                for (file in metalBeetle) {
                    trace(file);
                    if (!file.contains('TXT')) {
                        fileList.push('mods/' + Paths.currentModDirectory + '/ost/' + file);
                        trace("File " + (metalBeetle.indexOf(file) + 1) + " of " + metalBeetle.length + " in " + Paths.currentModDirectory + ": Found OST data for " + Json.parse(convertToRaw('mods/' + Paths.currentModDirectory + '/ost/' + file)).songName + "\n(Total files: " + fileList.length + ")");
                    } else {
                        trace("File " + (metalBeetle.indexOf(file) + 1) + " of " + metalBeetle.length + " in " + Paths.currentModDirectory + ": $file is not a JSON and will be skipped." + "\n(Total files: " + fileList.length + ")");
                    }
                }
            }
        }
        var KEKEKEKE = readPath(ModSoundtrackPath);
        if (KEKEKEKE[0] != "NO_FILES") {
            for (file in KEKEKEKE) {
                trace(file);
                if (!file.contains('TXT')) {
                    fileList.push(ModSoundtrackPath + file);
                    trace("File " + (KEKEKEKE.indexOf(file) + 1) + " of " + KEKEKEKE.length + ": Found OST data for " + Json.parse(convertToRaw('mods/ost/$file')).songName + "\n(Total files: " + fileList.length + ")");
                } else {
                    trace("File " + (KEKEKEKE.indexOf(file) + 1) + " of " + KEKEKEKE.length + " in " + Paths.currentModDirectory + ": $file is not a JSON and will be skipped." + "\n(Total files: " + fileList.length + ")");
                }
            }
        }
        #end
        for (file in fileList) {
            trace(file);
            ReturnThese.push(doFileParse(file));
            SoundtrackMenu.hardDong.push(false);
        }
        return ReturnThese;
    }

    static function readPath(DirectoryPath:String) {
        //if (FileSystem.exists(DirectoryPath)) return FileSystem.readDirectory(DirectoryPath);
        if (!FileSystem.exists(DirectoryPath) && DirectoryPath == SoundtrackPath) throw new haxe.exceptions.ArgumentException(DirectoryPath, "Directory not found. If this the path below matches the path above, please make sure it exists in the game folders!\n" + SoundtrackPath);
        else try {
            return FileSystem.readDirectory(DirectoryPath);
        }
        catch (e:haxe.Exception) {
            return ["NO_FILES"];
        }
    }

    static function doFileParse(FilePath:String) {
        var cyanDog:OSTData = gimmeABreak(FilePath);
        var trueIcons:Array<String> = DumbUtil.getIcons([cyanDog.defaultOpponent, cyanDog.defaultBf]);
        var expectedIcons:Array<String> = [cyanDog.defaultOpponent, cyanDog.defaultBf];
        if (trueIcons == expectedIcons) {
            return cyanDog; // no changes, just return it as is!
        } else {
            if (trueIcons[0] != expectedIcons[0]) {
                cyanDog.defaultOpponent = trueIcons[0];
            }
            if (trueIcons[1] != expectedIcons[1]) {
                cyanDog.defaultBf = trueIcons[1];
            }
            return cyanDog;
        }
    }

    static function knockOnWood(FileInput:String):SwagSong {
        if (FileInput.contains('{')) return cast Json.parse(FileInput) else return cast Json.parse(convertToRaw(FileInput));
    }

    static function gimmeABreak(FileInput:String) {
        if (FileInput.contains('{')) return cast Json.parse(FileInput) else return cast Json.parse(convertToRaw(FileInput));
    }

    static function convertToRaw(FilePath:String) {
        try {
            return File.getContent(FilePath);
        }
        catch (e:haxe.Exception) {
            trace("FILE DOES NOT EXIST!!" + FilePath);
            return File.getContent(SoundtrackPath + "TEMPLATE.TXT");
        }
    }
}

/**A class for hardcoding a song into the Soundtrack menu. These songs will appear **above** every other song, including base game songs.
    @since March 2022 (Emo Engine 0.2.0)*/
class HarderThanMyDick {
    var COPY_ME:OSTData = {
        songName: "Penis Music",
        displayName: "Bangin' Penis Music",
        defaultOpponent: "gf",
        defaultBf: "bf",
        dadIcon: "fuckyou",
        bfIcon: "cyan",
        songColorInfo: {
            red: 0,
            green: 69,
            blue: 69
        },
        hasVoices: false,
        iconChanges: [
            {
                time_ms: 6969,
                changeTarget: "bf",
                newIcon: "clownge"
            }
        ],
        preloadTrack: false
    };
    /**Add your hardcoded songs to this array. It'll be used when the game loads the song list.
        
    Separate individual songs with a comma.*/
    static var ADD_TO_ME_PLEASE:Array<OSTData> = [
        {
        "songName": "Splitathon",
        "defaultOpponent": "dave",
        "defaultBf": "bf",
        "songColorInfo": {
            "red": 24,
            "green": 175,
            "blue": 11
        },
        "hasVoices": true,
        "dadIcon": "dave",
        "bfIcon": "cyan",
        "displayName": "Dave's 10-Minute Splitathon!",
        "iconChanges": [
            {
                "time_ms": 313018,
                "changeTarget": "dad",
                "newIcon": "bambi"
            },
            {
                "time_ms": 379830,
                "changeTarget": "dad",
                "newIcon": "dave"
            },
            {
                "time_ms": 412912,
                "changeTarget": "dad",
                "newIcon": "bambi"
            },
            {
                "time_ms": 546708,
                "changeTarget": "dad",
                "newIcon": "dave"
            }
        ],
        "preloadTrack": true
    },
    {
        "songName": "Disability",
        "defaultOpponent": "disability",
        "defaultBf": "cyan",
        "songColorInfo": {
            "red": 24,
            "green": 175,
            "blue": 11
        },
        "hasVoices": true,
        "dadIcon": "disability",
        "bfIcon": "cyan"
    }
    ];

    public static function theseSongs() {
        if (ADD_TO_ME_PLEASE.length >= 1) {
            return ADD_TO_ME_PLEASE;
        } else return [];
    }
}