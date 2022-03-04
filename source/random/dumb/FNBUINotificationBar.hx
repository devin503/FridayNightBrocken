package random.dumb;

import flixel.FlxG;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import random.util.ColorUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

using StringTools; //just in case

/**
    Custom notification bar that uses FlxSprites and FlxText to display a message.

    This thing ONLY really needs a text value and a Y value at the moment, as the bar just extends across the whole screen.

    *I plan to allow for customisation in the future, such as changing the colour of the notification bar and text.*
    
    @author devin503*/
class FNBUINotificationBar extends FlxSprite {
    private var message:String;
    var msgDisplay:FlxText;
    public function new(text:String, y:Float) {
        super(0, y);

        message = text;

        makeGraphic(FlxG.width, 30, FlxColor.fromRGB(0, 128, 128, 235));
        alpha = 0; // BY DEFAULT IT'S 0.

        msgDisplay = new FlxText(0, this.y + 4, text.length * 2, text, 24);
        msgDisplay.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.LEFT);
        msgDisplay.visible = false;
    }
    var shittyTweenThing:FlxTween;
    public function show(duration:Int) {
        shittyTweenThing = FlxTween.tween(this, {alpha: 1}, 0.95, {onComplete: function(twn:FlxTween) {
            msgDisplay.visible = true;
            new FlxTimer().start(duration, function (tmr:FlxTimer) {
                msgDisplay.visible = false;
                shittyTweenThing = FlxTween.tween(this, {alpha: 0}, 0.95, {onComplete: function (twn:FlxTween) {
                    trace('penis');
                }});
            });
        }});
    }

    override function update(elapsed:Float) {
        if (msgDisplay != null) {
            msgDisplay.update(elapsed);
        }

        super.update(elapsed);
    }

    public function changeMsg(newText:String) {
        msgDisplay.text = newText;
        msgDisplay.fieldWidth = newText.length * 2;
        msgDisplay.scrollFactor.set();
    }
}