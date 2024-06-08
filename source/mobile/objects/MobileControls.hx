package mobile.objects;

import haxe.ds.Map;
import flixel.math.FlxPoint;
import mobile.flixel.input.FlxMobileInputManager;
import haxe.extern.EitherType;
import mobile.flixel.FlxButton;
import flixel.util.FlxSave;
import mobile.flixel.FlxHitbox.HitboxButton;
import mobile.flixel.FlxVirtualPad.TouchPadButton;
import flixel.util.typeLimit.OneOfTwo;

class MobileControls extends FlxTypedSpriteGroup<FlxMobileInputManager<Dynamic>>
{
	public var virtualPad:FlxVirtualPad = new FlxVirtualPad('NONE', 'NONE', NONE);
	public var hitbox:FlxHitbox = new FlxHitbox(NONE);
	// YOU CAN'T CHANGE PROPERTIES USING THIS EXCEPT WHEN IN RUNTIME!!
	public var current:CurrentManager;

	public static var mode(get, set):Int;
	public static var forcedControl:Null<Int>;
	public static var save:FlxSave;

	public function new(?forceType:Int, ?extra:Bool = true)
	{
		super();
		forcedControl = mode;
		if (forceType != null)
			forcedControl = forceType;
		switch (forcedControl)
		{
			case 0: // RIGHT_FULL
				initControler(0, extra);
			case 1: // LEFT_FULL
				initControler(1, extra);
			case 2: // CUSTOM
				initControler(2, extra);
			case 3: // BOTH
				initControler(3, extra);
			case 4: // HITBOX
				initControler(4, extra);
			case 5: // KEYBOARD
		}
		current = new CurrentManager(this);
		// Options related stuff
		current.target.alpha = 1;
		alpha = ClientPrefs.data.controlsAlpha;
		updateButtonsColors();
	}

	private function initControler(virtualPadMode:Int = 0, ?extra:Bool = true):Void
	{
		var extraAction = MobileData.extraActions.get(ClientPrefs.data.extraButtons);
		if (!extra)
			extraAction = NONE;
		switch (virtualPadMode)
		{
			case 0:
				virtualPad = new FlxVirtualPad('RIGHT_FULL', 'NONE', extraAction);
				add(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad('LEFT_FULL', 'NONE', extraAction);
				add(virtualPad);
			case 2:
				virtualPad = MobileControls.getCustomMode(new FlxVirtualPad('RIGHT_FULL', 'NONE', extraAction));
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad('BOTH', 'NONE', extraAction);
				add(virtualPad);
			case 4:
				hitbox = new FlxHitbox(extraAction);
				add(hitbox);
		}
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void
	{
		if (save.data.buttons == null)
		{
			save.data.buttons = new Array();
			for (buttons in virtualPad)
				save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			if (save.data.buttons[tempCount] != null)
			{
				buttons.x = save.data.buttons[tempCount].x;
				buttons.y = save.data.buttons[tempCount].y;
			}
			tempCount++;
		}

		return virtualPad;
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	static function set_mode(mode:Int = 0)
	{
		save.data.mobileControlsMode = mode;
		save.flush();
		return mode;
	}

	static function get_mode():Int
	{
		if (forcedControl != null)
			return forcedControl;

		if (save.data.mobileControlsMode == null)
		{
			save.data.mobileControlsMode = 0;
			save.flush();
		}

		return save.data.mobileControlsMode;
	}

	public function updateButtonsColors()
	{
		// Dynamic Controls Color
		var buttonsColors:Array<FlxColor> = [];
		var data:Dynamic;
		if (ClientPrefs.data.dynamicColors)
			data = ClientPrefs.data;
		else
			data = ClientPrefs.defaultData;

		buttonsColors.push(data.arrowRGB[0][0]);
		buttonsColors.push(data.arrowRGB[1][0]);
		buttonsColors.push(data.arrowRGB[2][0]);
		buttonsColors.push(data.arrowRGB[3][0]);
		if (mode == 3)
		{
			virtualPad.buttonLeft2.color = buttonsColors[0];
			virtualPad.buttonDown2.color = buttonsColors[1];
			virtualPad.buttonUp2.color = buttonsColors[2];
			virtualPad.buttonRight2.color = buttonsColors[3];
		}
		current.buttonLeft.color = buttonsColors[0];
		current.buttonDown.color = buttonsColors[1];
		current.buttonUp.color = buttonsColors[2];
		current.buttonRight.color = buttonsColors[3];
	}

	public static function initSave() {
		save = new FlxSave();
		save.bind('MobileControls', CoolUtil.getSavePath());
	}
}

class CurrentManager
{
	public var buttonLeft:TouchButton;
	public var buttonDown:TouchButton;
	public var buttonUp:TouchButton;
	public var buttonRight:TouchButton;
	public var buttonExtra:TouchButton;
	public var buttonExtra2:TouchButton;
	public var target:FlxMobileInputManager<Dynamic>;

	public function new(control:MobileControls)
	{
		if (MobileControls.mode == 4)
		{
			target = control.hitbox;
			buttonLeft = control.hitbox.buttonLeft;
			buttonDown = control.hitbox.buttonDown;
			buttonUp = control.hitbox.buttonUp;
			buttonRight = control.hitbox.buttonRight;
			buttonExtra = control.hitbox.buttonExtra;
			buttonExtra2 = control.hitbox.buttonExtra2;
		}
		else
		{
			target = control.virtualPad;
			buttonLeft = control.virtualPad.buttonLeft;
			buttonDown = control.virtualPad.buttonDown;
			buttonUp = control.virtualPad.buttonUp;
			buttonRight = control.virtualPad.buttonRight;
			buttonExtra = control.virtualPad.buttonExtra;
			buttonExtra2 = control.virtualPad.buttonExtra2;
		}
	}
}