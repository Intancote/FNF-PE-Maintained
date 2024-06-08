package mobile.psychlua;

import psychlua.CustomSubstate;
#if LUA_ALLOWED
import lime.ui.Haptic;
import psychlua.FunkinLua;
import mobile.backend.TouchFunctions;
#if android import mobile.backend.PsychJNI; #end

class MobileFunctions
{
	public static function implement(funk:FunkinLua)
	{
		funk.set('mobileControlsMode', getMobileControlsAsString());

		funk.set("extraButtonPressed", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.pressed;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.pressed;
				}
			}
			return false;
		});

		funk.set("extraButtonJustPressed", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.justPressed;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.justPressed;
				}
			}
			return false;
		});

		funk.set("extraButtonJustReleased", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.instance.mobileControls != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.instance.mobileControls.current.buttonExtra2.justReleased;
					default:
						return MusicBeatState.instance.mobileControls.current.buttonExtra.justReleased;
				}
			}
			return false;
		});

		funk.set("vibrate", (duration:Null<Int>, ?period:Null<Int>) ->
		{
			if (duration == null)
				return FunkinLua.luaTrace('vibrate: No duration specified.');
			else if (period == null)
				period = 0;
			return Haptic.vibrate(period, duration);
		});

		funk.set("addVirtualPad", (DPadMode:String, ActionMode:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1) ->
		{
			PlayState.instance.makeLuaVirtualPad(DPadMode, ActionMode);
			if (addToCustomSubstate)
			{
				if (PlayState.instance.luaVirtualPad != null || !PlayState.instance.members.contains(PlayState.instance.luaVirtualPad))
					CustomSubstate.insertLuaVpad(posAtCustomSubstate);
			}
			else
				PlayState.instance.addLuaVirtualPad();
		});

		funk.set("removeVirtualPad", () ->
		{
			PlayState.instance.removeLuaVirtualPad();
		});

		funk.set("addVirtualPadCamera", () ->
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				FunkinLua.luaTrace('addVirtualPadCamera: Virtual Pad does not exist.');
				return;
			}
			PlayState.instance.addLuaVirtualPadCamera();
		});

		funk.set("virtualPadJustPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				return false;
			}
			return PlayState.instance.luaVirtualPadJustPressed(button);
		});

		funk.set("virtualPadPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				return false;
			}
			return PlayState.instance.luaVirtualPadPressed(button);
		});

		funk.set("virtualPadJustReleased", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaVirtualPad == null)
			{
				return false;
			}
			return PlayState.instance.luaVirtualPadJustReleased(button);
		});

		funk.set("touchJustPressed", TouchFunctions.touchJustPressed);
		funk.set("touchPressed", TouchFunctions.touchPressed);
		funk.set("touchJustReleased", TouchFunctions.touchJustReleased);
		funk.set("touchPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchPressed;
		});

		funk.set("touchJustPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustPressed;
		});

		funk.set("touchJustReleasedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustReleased;
		});

		funk.set("touchOverlapsObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchOverlapsObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj);
		});
	}

	public static function getMobileControlsAsString():String
	{
		switch (MobileControls.mode)
		{
			case 0:
				return 'left';
			case 1:
				return 'right';
			case 2:
				return 'custom';
			case 3:
				return 'duo';
			case 4:
				return 'hitbox';
			case 5:
				return 'none';
		}
		return 'unknown';
	}
}

#if android
class AndroidFunctions
{
	static var spicyPillow:AndroidBatteryManager = new AndroidBatteryManager();
	public static function implement(funk:FunkinLua)
	{
		//funk.set("isRooted", AndroidTools.isRooted());
		funk.set("isDolbyAtmos", AndroidTools.isDolbyAtmos());
		funk.set("isAndroidTV", AndroidTools.isAndroidTV());
		funk.set("isTablet", AndroidTools.isTablet());
		funk.set("isChromebook", AndroidTools.isChromebook());
		funk.set("isDeXMode", AndroidTools.isDeXMode());

		funk.set("backJustPressed", FlxG.android.justPressed.BACK);
		funk.set("backPressed", FlxG.android.pressed.BACK);
		funk.set("backJustReleased", FlxG.android.justReleased.BACK);

		funk.set("menuJustPressed", FlxG.android.justPressed.MENU);
		funk.set("menuPressed", FlxG.android.pressed.MENU);
		funk.set("menuJustReleased", FlxG.android.justReleased.MENU);

		funk.set("setOrientation", function(hint:Null<String>):Void
		{
			switch (hint.toLowerCase())
			{
				case 'portrait':
					hint = 'Portrait';
				case 'portraitupsidedown' | 'upsidedownportrait' | 'upsidedown':
					hint = 'PortraitUpsideDown';
				case 'landscapeleft' | 'leftlandscape':
					hint = 'LandscapeLeft';
				case 'landscaperight' | 'rightlandscape' | 'landscape':
					hint = 'LandscapeRight';
				default:
					hint = null;
			}
			if (hint == null)
				return FunkinLua.luaTrace('setOrientation: No orientation specified.');
			PsychJNI.setOrientation(FlxG.stage.stageWidth, FlxG.stage.stageHeight, false, hint);
		});

		funk.set("minimizeWindow", () -> AndroidTools.minimizeWindow());
		funk.set("showToast", function(text:String, duration:Null<Int>, ?xOffset:Null<Int>, ?yOffset:Null<Int>) //, ?gravity:Null<Int>
		{
			if (text == null)
				return FunkinLua.luaTrace('showToast: No text specified.');
			else if (duration == null)
				return FunkinLua.luaTrace('showToast: No duration specified.');

			if (xOffset == null)
				xOffset = 0;
			if (yOffset == null)
				yOffset = 0;

			AndroidToast.makeText(text, duration, -1, xOffset, yOffset);
		});

		funk.set("isCharging", spicyPillow.isCharging());
	}
}
#end
#end
