package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Sprite;
import openfl.media.SoundTransform;
#elseif flash
import flash.display.Sprite;
import flash.media.SoundTransform;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.SoundTransformPlugin;
import utest.Assert;
import utest.Test;

class SoundTransformPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		SoundTransformPlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		SoundTransformPlugin.enabled = false;
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testSoundTransformProperties():Void
	{
		var sprite = new Sprite();
		sprite.soundTransform = new SoundTransform();
		
		tween = new GTween(sprite, 0.5, {volume: 0.5}, null, {SoundTransformEnabled: true});

		Assert.equals(1.0, sprite.soundTransform.volume);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.75, sprite.soundTransform.volume);

		tween.position = tween.duration;
		Assert.equals(0.5, sprite.soundTransform.volume);
	}

	public function testWithDefaultSoundTransformEnabled():Void
	{
		var sprite = new Sprite();
		sprite.soundTransform = new SoundTransform();
		
		tween = new GTween(sprite, 0.5, {volume: 0.5});

		Assert.equals(1.0, sprite.soundTransform.volume);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.75, sprite.soundTransform.volume);

		tween.position = tween.duration;
		Assert.equals(0.5, sprite.soundTransform.volume);
	}

	public function testWithSoundTransformSetToFalse():Void
	{
		var sprite = new Sprite();
		sprite.soundTransform = new SoundTransform();
		
		tween = new GTween(sprite, 0.5, {volume: 0.5}, null, {SoundTransformEnabled: false});

		Assert.equals(1.0, sprite.soundTransform.volume);

		Assert.raises(() -> {
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end