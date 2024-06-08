package psychlua;

#if (VIDEOS_ALLOWED && ADVANCED_VIDEO_FUNCTIONS)
import objects.AdvancedVideoSprite;
import states.PlayState;
import substates.GameOverSubstate;

class VideoFunctions
{
	// nobody tell me to use game instead of PlayState.instance... IT ALLWAYS RETURN FUCKING NULL
	public static function implement(funk:FunkinLua)
	{
		funk.set("makeVideoSprite", function(tag:String, x:Float, y:Float)
		{
			tag = tag.replace('.', '');
			LuaUtils.resetVideoSpriteTag(tag);
			var video = new AdvancedVideoSprite(x, y);
			video.playbackRate = PlayState.instance.playbackRate;
			PlayState.instance.modchartVideoSprites.set(tag, video);
		});

		// when you don't give it a tag it plays a normal video cutscene
		funk.set("startVideo", function(videoName:String, ?tag:String = null, ?loop:Bool = false)
		{
			var videoPath = Paths.video(videoName);
			if (!FileSystem.exists(videoPath))
			{
				FunkinLua.luaTrace('startVideo: Video file not found: $videoName', false, false, FlxColor.RED);
				if (tag == null)
					PlayState.instance.startAndEnd();
				return false;
			}
			if (tag == null)
			{
				PlayState.instance.startVideo(videoName);
				PlayState.instance.video.onVideoEnd.addOnce(() ->
				{
					PlayState.instance.callOnLuas('onVideoEnd', ['']);
				});
				PlayState.instance.video.onVideoStart.addOnce(() ->
				{
					PlayState.instance.callOnLuas('onVideoStart', ['']);
				});
				return true;
			}
			else
			{
				var video = LuaUtils.getVideoSpriteObject(tag);
				if (video == null)
				{
					FunkinLua.luaTrace("startVideo: Video " + tag + " dosen't exist!", false, false, FlxColor.RED);
					return false;
				}
				video.startVideo(videoPath, loop);
				video.playbackRate = PlayState.instance.playbackRate;
				video.onVideoEnd.addOnce(() ->
				{
					PlayState.instance.callOnLuas('onVideoEnd', [tag]);
				});
				video.onVideoStart.addOnce(() ->
				{
					PlayState.instance.callOnLuas('onVideoStart', [tag]);
				});
				return true;
			}
		});

		funk.set("addVideoSprite", function(tag:String, front:Bool = false)
		{
			var video:AdvancedVideoSprite = null;
			if (PlayState.instance.modchartVideoSprites.exists(tag))
				video = PlayState.instance.modchartVideoSprites.get(tag);
			else if (PlayState.instance.variables.exists(tag))
				video = PlayState.instance.variables.get(tag);

			if (video == null)
				return false;

			if (front)
				LuaUtils.getTargetInstance().add(video);
			else
			{
				if (!PlayState.instance.isDead)
					PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), video);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), video);
			}
			return true;
		});

		funk.set("removeVideoSprite", function(tag:String, destroy:Bool = true)
		{
			if (!PlayState.instance.modchartVideoSprites.exists(tag))
			{
				return;
			}

			var video = PlayState.instance.modchartVideoSprites.get(tag);
			LuaUtils.getTargetInstance().remove(video, true);
			if (destroy)
			{
				video.destroy();
				PlayState.instance.modchartVideoSprites.remove(tag);
			}
		});
	}
}
#end
