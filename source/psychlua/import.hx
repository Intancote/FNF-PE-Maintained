#if (LUA_ALLOWED && !macro)
#if hxluajit
import hxluajit.Types;
import hxluajit.Lua;
import hxluajit.LuaL;
#else
import llua.Convert;
import llua.Lua;
import llua.State as LuaState;
import llua.LuaL;
#end
#end