package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.ColorTransformPlugin;
import utest.Assert;
import utest.Test;

class ColorTransformPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		ColorTransformPlugin.install();
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testColorTransformProperties():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {redMultiplier:0.5,redOffset:50,greenMultiplier:2.0,greenOffset:10,blueMultiplier:3.0,blueOffset:20}, null, {ColorTransformEnabled: true});

		Assert.equals(1.0, shape.transform.colorTransform.redMultiplier);
		Assert.equals(0.0, shape.transform.colorTransform.redOffset);
		Assert.equals(1.0, shape.transform.colorTransform.greenMultiplier);
		Assert.equals(0.0, shape.transform.colorTransform.greenOffset);
		Assert.equals(1.0, shape.transform.colorTransform.blueMultiplier);
		Assert.equals(0.0, shape.transform.colorTransform.blueOffset);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.75, shape.transform.colorTransform.redMultiplier);
		Assert.equals(25, shape.transform.colorTransform.redOffset);
		Assert.equals(1.5, shape.transform.colorTransform.greenMultiplier);
		Assert.equals(5, shape.transform.colorTransform.greenOffset);
		Assert.equals(2.0, shape.transform.colorTransform.blueMultiplier);
		Assert.equals(10, shape.transform.colorTransform.blueOffset);

		tween.position = tween.duration;
		Assert.equals(0.5, shape.transform.colorTransform.redMultiplier);
		Assert.equals(50, shape.transform.colorTransform.redOffset);
		Assert.equals(2.0, shape.transform.colorTransform.greenMultiplier);
		Assert.equals(10, shape.transform.colorTransform.greenOffset);
		Assert.equals(3.0, shape.transform.colorTransform.blueMultiplier);
		Assert.equals(20, shape.transform.colorTransform.blueOffset);
	}

	public function testWithDefaultColorTransformEnabled():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {redMultiplier:0.5});

		Assert.equals(1.0, shape.transform.colorTransform.redMultiplier);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.75, shape.transform.colorTransform.redMultiplier);

		tween.position = tween.duration;
		Assert.equals(0.5, shape.transform.colorTransform.redMultiplier);
	}

	public function testWithColorTransformEnabledSetToFalse():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {redMultiplier: 0.5}, null, {ColorTransformEnabled: false});

		Assert.equals(1.0, shape.transform.colorTransform.redMultiplier);

		// it tries to set shape.redMultiplier, which is a property that doesn't exist
		Assert.raises(() -> 
		{
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end