package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
import openfl.filters.BlurFilter;
#elseif flash
import flash.display.Shape;
import flash.filters.BlurFilter;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.BlurPlugin;
import utest.Assert;
import utest.Test;

class BlurPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		BlurPlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		BlurPlugin.enabled = false;
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
		tween = new GTween(shape, 0.5, {blurX:2}, null, {BlurEnabled: true});
		// the filter is not applied immediately
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		tween.position = 0.5 * tween.duration;
		// the filter is applied after the position changes
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, BlurFilter);
		var blurFilter = cast(filter, BlurFilter);
		Assert.equals(1, blurFilter.blurX);
		tween.position = tween.duration;
		// the filter is removed once the end position has been reached
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, BlurFilter);
		var blurFilter = cast(filter, BlurFilter);
		Assert.equals(2, blurFilter.blurX);
	}

	public function testWithDefaultBlurEnabled():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {blurX:2});
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		tween.position = 0.5 * tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, BlurFilter);
		var blurFilter = cast(filter, BlurFilter);
		Assert.equals(1, blurFilter.blurX);
		tween.position = tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, BlurFilter);
		var blurFilter = cast(filter, BlurFilter);
		Assert.equals(2, blurFilter.blurX);
	}

	public function testWithBlurEnabledSetToFalse():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {blurX:2}, null, {BlurEnabled: false});
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);
		Assert.raises(() -> {
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end