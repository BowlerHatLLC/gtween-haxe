package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.AutoHidePlugin;
import utest.Assert;
import utest.Test;

class AutoHidePluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		AutoHidePlugin.install();
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testVisibleProperty():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {alpha:0}, null, {AutoHideEnabled: true});

		Assert.equals(1, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.5, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = tween.duration;
		Assert.equals(0.0, shape.alpha);
		Assert.isFalse(shape.visible);
	}

	public function testWithDefaultAutoHideEnabled():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {alpha:0});

		Assert.equals(1, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.5, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = tween.duration;
		Assert.equals(0.0, shape.alpha);
		Assert.isFalse(shape.visible);
	}

	public function testWithAutoHideEnabledSetToFalse():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {alpha:0}, null, {AutoHideEnabled: false});

		Assert.equals(1, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.5, shape.alpha);
		Assert.isTrue(shape.visible);

		tween.position = tween.duration;
		Assert.equals(0.0, shape.alpha);
		Assert.isTrue(shape.visible);
	}
}
#end