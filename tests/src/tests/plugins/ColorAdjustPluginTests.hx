package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
import openfl.filters.ColorMatrixFilter;
#elseif flash
import flash.display.Shape;
import flash.filters.ColorMatrixFilter;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.ColorAdjustPlugin;
import utest.Assert;
import utest.Test;

class ColorAdjustPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		ColorAdjustPlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		ColorAdjustPlugin.enabled = false;
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
		tween = new GTween(shape, 0.5, {brightness:2}, null, {ColorAdjustEnabled: true});
		// the filter is not applied immediately
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);

		tween.position = 0.5 * tween.duration;
		// the filter is applied after the position changes
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, ColorMatrixFilter);
		var cmFilter = cast(filter, ColorMatrixFilter);
		Assert.equals(1, cmFilter.matrix[4]);
		Assert.equals(1, cmFilter.matrix[9]);
		Assert.equals(1, cmFilter.matrix[14]);

		tween.position = tween.duration;
		// the filter is removed once the end position has been reached
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, ColorMatrixFilter);
		var cmFilter = cast(filter, ColorMatrixFilter);
		Assert.equals(2, cmFilter.matrix[4]);
		Assert.equals(2, cmFilter.matrix[9]);
		Assert.equals(2, cmFilter.matrix[14]);
	}

	public function testWithDefaultColorAdjustEnabled():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {brightness:2});
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);

		tween.position = 0.5 * tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, ColorMatrixFilter);
		var cmFilter = cast(filter, ColorMatrixFilter);
		Assert.equals(1, cmFilter.matrix[4]);
		Assert.equals(1, cmFilter.matrix[9]);
		Assert.equals(1, cmFilter.matrix[14]);

		tween.position = tween.duration;
		Assert.notNull(shape.filters);
		Assert.equals(1, shape.filters.length);
		var filter = shape.filters[0];
		Assert.isOfType(filter, ColorMatrixFilter);
		var cmFilter = cast(filter, ColorMatrixFilter);
		Assert.equals(2, cmFilter.matrix[4]);
		Assert.equals(2, cmFilter.matrix[9]);
		Assert.equals(2, cmFilter.matrix[14]);
	}

	public function testWithColorAdjustEnabledSetToFalse():Void
	{
		var shape = new Shape();
		tween = new GTween(shape, 0.5, {brightness:2}, null, {ColorAdjustEnabled: false});
		Assert.notNull(shape.filters);
		Assert.equals(0, shape.filters.length);

		Assert.raises(() -> {
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end