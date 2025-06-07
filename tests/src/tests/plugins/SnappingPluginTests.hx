package tests.plugins;

#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.SnappingPlugin;
import utest.Assert;
import utest.Test;

class SnappingPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		SnappingPlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		SnappingPlugin.enabled = false;
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testXProperty():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		#else
		var shape = {x: 0.0, y: 0.0};
		#end
		tween = new GTween(shape, 0.5, {x:1.25}, null, {AutoHideEnabled: true});

		Assert.equals(0, shape.x);

		tween.position = 0.5 * tween.duration;
		Assert.equals(1, shape.x);

		tween.position = tween.duration;
		Assert.equals(1, shape.x);
	}

	public function testYProperty():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		#else
		var shape = {x: 0.0, y: 0.0};
		#end
		tween = new GTween(shape, 0.5, {y:1.25}, null, {AutoHideEnabled: true});

		Assert.equals(0, shape.y);

		tween.position = 0.5 * tween.duration;
		Assert.equals(1, shape.y);

		tween.position = tween.duration;
		Assert.equals(1, shape.y);
	}

	public function testWithDefaultSnappingEnabled():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		#else
		var shape = {x: 0.0, y: 0.0};
		#end
		tween = new GTween(shape, 0.5, {y:1.25});

		Assert.equals(0, shape.y);

		tween.position = 0.5 * tween.duration;
		Assert.equals(1, shape.y);

		tween.position = tween.duration;
		Assert.equals(1, shape.y);
	}

	public function testWithSnappingEnabledSetToFalse():Void
	{
		#if (flash || openfl)
		var shape = new Shape();
		#else
		var shape = {x: 0.0, y: 0.0};
		#end
		tween = new GTween(shape, 0.5, {y:1.5}, null, {SnappingEnabled: false});

		Assert.equals(0, shape.y);

		tween.position = 0.5 * tween.duration;
		Assert.equals(0.75, shape.y);

		tween.position = tween.duration;
		Assert.equals(1.5, shape.y);
	}
}