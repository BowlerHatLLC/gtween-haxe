package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.MotionBlurPlugin;
import utest.Assert;
import utest.Test;

class MotionBlurPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		MotionBlurPlugin.install();
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testFiltersProperty():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {y:50}, {autoPlay:false}, {MotionBlurEnabled: true});
		Assert.isTrue(tween.paused);
		// the filter is not applied immediately
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		tween.position = 0.5 * tween.duration;
		// the filter is applied after the position changes
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		tween.position = tween.duration;
		// the filter is removed once the end position has been reached
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
	}

	public function testWithoutMotionBlurEnabled():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {y:50}, {autoPlay:false});
		Assert.isTrue(tween.paused);
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		tween.position = 0.5 * tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
	}

	public function testWithMotionBlurEnabledSetToFalse():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {y:50}, {autoPlay:false}, {MotionBlurEnabled: false});
		Assert.isTrue(tween.paused);
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		tween.position = 0.5 * tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
	}
}
#end