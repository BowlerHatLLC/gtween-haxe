package tests.plugins;

#if openfl
import openfl.display.MovieClip;
#elseif flash
import flash.display.MovieClip;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.CurrentFramePlugin;
import utest.Assert;
import utest.Test;

class CurrentFramePluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		CurrentFramePlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		CurrentFramePlugin.enabled = false;
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testCurrentFrameWithDynamicMovieClip():Void
	{
		// a MovieClip created programmatically never has more than one frame
		var mc = new MovieClip();
				
		tween = new GTween(mc, 0.5, {currentFrame: 3}, null, {CurrentFrameEnabled: true});

		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end

		tween.position = 0.5 * tween.duration;
		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end

		tween.position = tween.duration;
		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end
	}

	public function testWithDynamicMovieClipAndDefaultCurrentFrameEnabled():Void
	{
		var mc = new MovieClip();
		
		tween = new GTween(mc, 0.5, {currentFrame:3});

		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end

		tween.position = 0.5 * tween.duration;
		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end

		tween.position = tween.duration;
		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end
	}

	#if flash
	public function testWithDynamicMovieClipAndCurrentFrameEnabledSetToFalse():Void
	{
		var mc = new MovieClip();
		
		tween = new GTween(mc, 0.5, {currentFrame: 5}, null, {CurrentFrameEnabled: false});

		#if openfl
		Assert.equals(1, mc.currentFrame);
		#else
		Assert.equals(0, mc.currentFrame);
		#end

		// it tries to set mc.currentFrame, which is a property that can't be set
		Assert.raises(() -> 
		{
			tween.position = 0.5 * tween.duration;
		});
	}
	#end
}

#if (!flash && !openfl)
private class MovieClip {
	public function new() {}

	public var currentFrame(get, never):Int;

	private function get_currentFrame():Int {
		return 0;
	}

	public function gotoAndStop(frame:Int):Void
	{
	}
}
#end