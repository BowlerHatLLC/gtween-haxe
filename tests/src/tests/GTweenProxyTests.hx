package tests;

import com.gskinner.motion.GTween;
import utest.Assert;
import utest.Test;

class GTweenProxyTests extends Test {

	private var tween:GTween;
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
	}

	public function testProxyGetFieldFromTarget():Void
	{
		var target:Any = {a: 123.4, b: false, c: "hello"};
		var tween = new GTween(target);

		Assert.equals(123.4, tween.proxy.a);
		Assert.isFalse(tween.proxy.b);
		Assert.equals("hello", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(123.4, tween.proxy["a"]);
		Assert.isFalse(tween.proxy["b"]);
		Assert.equals("hello", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);
	}

	public function testProxySetField():Void
	{
		var target:Any = {a: 123.4, b: false, c: "hello"};
		var tween = new GTween(target);

		Assert.equals(123.4, tween.proxy.a);
		Assert.isFalse(tween.proxy.b);
		Assert.equals("hello", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(123.4, tween.proxy["a"]);
		Assert.isFalse(tween.proxy["b"]);
		Assert.equals("hello", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);

		tween.proxy.a = 432.1;
		tween.proxy.b = true;
		tween.proxy.c = "goodbye";

		Assert.equals(432.1, tween.proxy.a);
		Assert.isTrue(tween.proxy.b);
		Assert.equals("goodbye", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(432.1, tween.proxy["a"]);
		Assert.isTrue(tween.proxy["b"]);
		Assert.equals("goodbye", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);

		Assert.equals(123.4, Reflect.field(target, "a"));
		Assert.isTrue(Reflect.field(target, "b"));
		Assert.equals("goodbye", Reflect.field(target, "c"));

		tween.position = tween.duration;

		Assert.equals(432.1, Reflect.field(target, "a"));
		Assert.isTrue(Reflect.field(target, "b"));
		Assert.equals("goodbye", Reflect.field(target, "c"));
	}

	public function testProxyGetFieldFromValues():Void
	{
		var target = {a: 123.4, b: false, c: "hello"};
		var values = {a: 678.9}
		var tween = new GTween(target, 1, values);

		Assert.equals(678.9, tween.proxy.a);
		Assert.isFalse(tween.proxy.b);
		Assert.equals("hello", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(678.9, tween.proxy["a"]);
		Assert.isFalse(tween.proxy["b"]);
		Assert.equals("hello", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);
	}

	public function testProxySetValue():Void
	{
		var target:Any = {a: 123.4, b: false, c: "hello"};
		var values:Any = {a: 432.1};
		var tween = new GTween(target, 1, values);

		Assert.equals(432.1, tween.proxy.a);
		Assert.isFalse(tween.proxy.b);
		Assert.equals("hello", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(432.1, tween.proxy["a"]);
		Assert.isFalse(tween.proxy["b"]);
		Assert.equals("hello", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);

		tween.proxy.a = 678.9;
		tween.proxy.b = true;
		tween.proxy.c = "goodbye";

		Assert.equals(678.9, tween.proxy.a);
		Assert.isTrue(tween.proxy.b);
		Assert.equals("goodbye", tween.proxy.c);
		Assert.isNull(tween.proxy.d);
		Assert.equals(678.9, tween.proxy["a"]);
		Assert.isTrue(tween.proxy["b"]);
		Assert.equals("goodbye", tween.proxy["c"]);
		Assert.isNull(tween.proxy["d"]);

		Assert.equals(123.4, Reflect.field(target, "a"));
		Assert.isTrue(Reflect.field(target, "b"));
		Assert.equals("goodbye", Reflect.field(target, "c"));

		tween.position = tween.duration;

		Assert.equals(678.9, Reflect.field(target, "a"));
		Assert.isTrue(Reflect.field(target, "b"));
		Assert.equals("goodbye", Reflect.field(target, "c"));
	}
}
