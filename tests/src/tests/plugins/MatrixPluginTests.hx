package tests.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.Shape;
#elseif flash
import flash.display.Shape;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.MatrixPlugin;
import utest.Assert;
import utest.Test;

class MatrixPluginTests extends Test {

	private var tween:GTween;

	public function setupClass():Void
	{
		MatrixPlugin.install();
	}

	public function teardownClass():Void
	{
		// other tests might be affected by this plugin's properties
		// so disable the plugin by default when we're done testing it
		MatrixPlugin.enabled = false;
	}
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testMatrixProperties():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {a:2.0, d: 5.0, tx: 5.0, ty: 4.0}, null, {MatrixEnabled: true});

		Assert.equals(1.0, shape.transform.matrix.a);
		Assert.equals(1.0, shape.transform.matrix.d);
		Assert.equals(0.0, shape.transform.matrix.tx);
		Assert.equals(0.0, shape.transform.matrix.ty);

		tween.position = 0.5 * tween.duration;
		Assert.equals(1.5, shape.transform.matrix.a);
		Assert.equals(3.0, shape.transform.matrix.d);
		Assert.equals(2.5, shape.transform.matrix.tx);
		Assert.equals(2.0, shape.transform.matrix.ty);

		tween.position = tween.duration;
		Assert.equals(2.0, shape.transform.matrix.a);
		Assert.equals(5.0, shape.transform.matrix.d);
		Assert.equals(5.0, shape.transform.matrix.tx);
		Assert.equals(4.0, shape.transform.matrix.ty);
	}

	public function testWithDefaultMatrixEnabled():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {a:2.0});

		Assert.equals(1.0, shape.transform.matrix.a);

		tween.position = 0.5 * tween.duration;
		Assert.equals(1.5, shape.transform.matrix.a);

		tween.position = tween.duration;
		Assert.equals(2.0, shape.transform.matrix.a);
	}

	public function testWithMatrixEnabledSetToFalse():Void
	{
		var shape = new Shape();
		
		tween = new GTween(shape, 0.5, {a:2.0}, null, {MatrixEnabled: false});

		Assert.equals(1.0, shape.transform.matrix.a);

		// it tries to set shape.a, which is a property that doesn't exist
		Assert.raises(() -> 
		{
			tween.position = 0.5 * tween.duration;
		});
	}
}
#end