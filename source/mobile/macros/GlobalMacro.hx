package mobile.macros;

import lime.utils.Log;

class GlobalMacro {
    public static function haxelibWarning():Void {
        #if hxluajit
        Log.warn('hxluajit detected, using hxluajit is still experimental!!');
        #elseif (android && (linc_luajit && hxvlc))
        Log.warn('linc_luajit with hxvlc detected, lua will be die. Consider using EXPERIMENTAL_HXLUAJIT or ADVANCED_VIDEO_FUNCTIONS instead.');
        #end
    }
}