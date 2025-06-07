package tests.plugins;

#if (openfl || flash)
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

		Assert.equals(0, mc.currentFrame);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0, mc.currentFrame);

		tween.position = tween.duration;
		Assert.equals(0, mc.currentFrame);
	}

	public function testWithDynamicMovieClipAndDefaultCurrentFrameEnabled():Void
	{
		var mc = new MovieClip();
		
		tween = new GTween(mc, 0.5, {currentFrame:3});

		Assert.equals(0, mc.currentFrame);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0, mc.currentFrame);

		tween.position = tween.duration;
		Assert.equals(0, mc.currentFrame);
	}

	public function testWithDynamicMovieClipAndCurrentFrameEnabledSetToFalse():Void
	{
		var mc = new MovieClip();
		
		tween = new GTween(mc, 0.5, {currentFrame: 5}, null, {CurrentFrameEnabled: false});

		Assert.equals(0, mc.currentFrame);

		// it tries to set mc.currentFrame, which is a property that doesn't exist
		Assert.raises(() -> 
		{
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end