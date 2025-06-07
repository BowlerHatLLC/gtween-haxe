package tests.plugins;

#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.SmartRotationPlugin;
import utest.Assert;
import utest.Test;

class SmartRotationPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		SmartRotationPlugin.install();
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testRotationProperty():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		shape.rotation = 10;
		#else
		var shape = {rotation: 10};
		#end
		tween = new GTween(shape, 0.5, {rotation:200}, null, {SmartRotationEnabled: true});

		Assert.equals(10, shape.rotation);

		tween.position = 0.5 * tween.duration;
		Assert.equals(-75, shape.rotation);

		tween.position = tween.duration;
		Assert.isTrue(shape.rotation == -160 || shape.rotation == 200);
	}

	public function testWithDefaultSmartRotationEnabled():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		shape.rotation = 10;
		#else
		var shape = {rotation: 10};
		#end
		tween = new GTween(shape, 0.5, {rotation:200});

		Assert.equals(10, shape.rotation);

		tween.position = 0.5 * tween.duration;
		Assert.equals(-75, shape.rotation);

		tween.position = tween.duration;
		Assert.isTrue(shape.rotation == -160 || shape.rotation == 200);
	}

	public function testWithSmartRotationEnabledSetToFalse():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		shape.rotation = 10;
		#else
		var shape = {rotation: 10};
		#end
		tween = new GTween(shape, 0.5, {rotation:200}, null, {SmartRotationEnabled: false});

		Assert.equals(10, shape.rotation);

		tween.position = 0.5 * tween.duration;
		Assert.equals(105, shape.rotation);

		tween.position = tween.duration;
		Assert.isTrue(shape.rotation == -160 || shape.rotation == 200);
	}
}