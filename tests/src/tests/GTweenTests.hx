package tests;

import com.gskinner.motion.GTween;
import utest.Assert;
import utest.Test;

class GTweenTests extends Test {

	private var tween:GTween;
	
	public function teardown():Void
	{
		if (tween != null)
		{
			tween.paused = true;
			tween = null;
		}
		#if (flash || openfl)
		Assert.isFalse(GTween.defaultDispatchEvents);
		#end
		Assert.isFalse(GTween.pauseAll);
		Assert.equals(1.0, GTween.timeScaleAll);
	}

	public function testDefaults():Void
	{
		tween = new GTween();
		Assert.isTrue(tween.autoPlay);
		Assert.isNull(tween.data);
		Assert.equals(0.0, tween.delay);
		#if (flash || openfl)
		Assert.equals(GTween.defaultDispatchEvents, tween.dispatchEvents);
		Assert.isFalse(GTween.defaultDispatchEvents);
		#end
		Assert.equals(1.0, tween.duration);
		Assert.equals(GTween.defaultEase, tween.ease);
		Assert.equals(GTween.linearEase, tween.ease);
		Assert.isNull(tween.nextTween);
		Assert.isNull(tween.onChange);
		Assert.isNull(tween.onComplete);
		Assert.isNull(tween.onInit);
		Assert.isFalse(tween.paused);
		Assert.equals(0.0, tween.position);
		Assert.equals(0.0, tween.ratio);
		Assert.isFalse(tween.reflect);
		Assert.equals(1, tween.repeatCount);
		Assert.isFalse(tween.suppressEvents);
		Assert.isNull(tween.target);
		Assert.equals(1.0, tween.timeScale);
		Assert.isFalse(tween.useFrames);
	}

	public function testAutoPlayFalse():Void
	{
		tween = new GTween(null, 1, null, {autoPlay: false});
		Assert.isTrue(tween.paused);
	}

	public function testAutoPlayTrue():Void
	{
		tween = new GTween(null, 1, null, {autoPlay: true});
		Assert.isFalse(tween.paused);
	}

	public function testTarget():Void
	{
		var target:Any = {abc123: 1.0};
		tween = new GTween(target);
		Assert.equals(target, tween.target);
	}

	public function testDuration():Void
	{
		tween = new GTween(null, 2.0);
		Assert.equals(2.0, tween.duration);
	}

	public function testOnInit():Void
	{
		var onInitCallCount = 0;
		function onInit(argTween:GTween):Void
		{
			onInitCallCount++;
			Assert.notNull(argTween);
			Assert.equals(tween, argTween);
		}
		var target:Any = {abc123: 123.4};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 1.0, values, {onInit: onInit});
		Assert.equals(0, onInitCallCount);
		tween.position = 0.5;
		Assert.equals(1, onInitCallCount);
		tween.position = 1.0;
		Assert.equals(1, onInitCallCount);
	}

	public function testOnChange():Void
	{
		var onChangeCallCount = 0;
		function onChange(argTween:GTween):Void
		{
			onChangeCallCount++;
			Assert.notNull(argTween);
			Assert.equals(tween, argTween);
		}
		var target:Any = {abc123: 123.4};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 1.0, values, {onChange: onChange});
		Assert.equals(0, onChangeCallCount);
		tween.position = 0.5;
		Assert.equals(1, onChangeCallCount);
		tween.position = 1.0;
		Assert.equals(2, onChangeCallCount);
	}

	public function testOnComplete():Void
	{
		var onCompleteCallCount = 0;
		function onComplete(argTween:GTween):Void
		{
			onCompleteCallCount++;
			Assert.notNull(argTween);
			Assert.equals(tween, argTween);
		}
		var target:Any = {abc123: 123.4};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 1, values, {onComplete: onComplete});
		Assert.equals(0, onCompleteCallCount);
		tween.position = 0.5;
		Assert.equals(0, onCompleteCallCount);
		tween.position = 1.0;
		Assert.equals(1, onCompleteCallCount);
	}

	public function testGetValuesWithoutTarget():Void
	{
		var values:Any = {abc123: 123.4, xyz456: -567.89};
		tween = new GTween(null, 1, values);
		Assert.notNull(tween.getValues());
		Assert.equals(2, Reflect.fields(tween.getValues()).length);
		Assert.equals(123.4, tween.getValues().abc123);
		Assert.equals(-567.89, tween.getValues().xyz456);
		Assert.isNull(tween.getValues().def789);
		Assert.equals(123.4, tween.getValue("abc123"));
		Assert.equals(-567.89, tween.getValue("xyz456"));
		Assert.isTrue(Math.isNaN(tween.getValue("def789")));
	}

	public function testGetValuesWithoutValues():Void
	{
		var target:Any = {abc123: 123.4, xyz456: -567.89};
		tween = new GTween(target);
		Assert.notNull(tween.getValues());
		Assert.equals(0, Reflect.fields(tween.getValues()).length);
		Assert.isTrue(Math.isNaN(tween.getValue("abc123")));
		Assert.isTrue(Math.isNaN(tween.getValue("xyz456")));
		Assert.isTrue(Math.isNaN(tween.getValue("def789")));
		tween.position = 0.5;
		Assert.notNull(tween.getValues());
		Assert.equals(0, Reflect.fields(tween.getValues()).length);
		Assert.isTrue(Math.isNaN(tween.getValue("abc123")));
		Assert.isTrue(Math.isNaN(tween.getValue("xyz456")));
		Assert.isTrue(Math.isNaN(tween.getValue("def789")));
	}

	public function testGetValuesAndInitialValues():Void
	{
		var target:Any = {abc123: 123.4, xyz456: -567.89};
		var values:Any = {abc123: -43.21, xyz456: 56.789};
		tween = new GTween(target, 1, values);
		Assert.notNull(tween.getValues());
		Assert.equals(2, Reflect.fields(tween.getValues()).length);
		Assert.equals(-43.21, tween.getValues().abc123);
		Assert.equals(56.789, tween.getValues().xyz456);
		Assert.isNull(tween.getValues().def789);
		Assert.equals(-43.21, tween.getValue("abc123"));
		Assert.equals(56.789, tween.getValue("xyz456"));
		Assert.isTrue(Math.isNaN(tween.getValue("def789")));

		Assert.raises(() -> {
			tween.getInitValue("abc123");
		});
		Assert.raises(() -> {
			tween.getInitValue("xyz456");
		});
		Assert.raises(() -> {
			tween.getInitValue("def789");
		});

		tween.position = 0.5;

		Assert.equals(123.4, tween.getInitValue("abc123"));
		Assert.equals(-567.89, tween.getInitValue("xyz456"));
		Assert.isTrue(Math.isNaN(tween.getInitValue("def789")));
	}

	public function testGetInitialValuesWithoutValues():Void
	{
		var target:Any = {abc123: 123.4, xyz456: -567.89};
		tween = new GTween(target);

		Assert.raises(() -> {
			tween.getInitValue("abc123");
		});
		Assert.raises(() -> {
			tween.getInitValue("xyz456");
		});
		Assert.raises(() -> {
			tween.getInitValue("def789");
		});

		tween.position = 0.5;

		// if we didn't pass in values, there is nothing read from the target
		Assert.isTrue(Math.isNaN(tween.getInitValue("abc123")));
		Assert.isTrue(Math.isNaN(tween.getInitValue("xyz456")));
		Assert.isTrue(Math.isNaN(tween.getInitValue("def789")));
	}

	public function testRatioAndCalculatedPosition():Void
	{
		var target:Any = {abc123: 1.0};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 3.0, values);

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.position = 1.5;
		Assert.equals(0.5, tween.ratio);
		Assert.equals(1.5, tween.calculatedPosition);

		tween.position = 3.0;
		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);
	}

	public function testDelay():Void
	{
		var target:Any = {abc123: 1.0};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 3.0, values, {delay: 0.5});

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.init();

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.position = 1.25;

		Assert.equals(1.25 / 3.0, tween.ratio);
		Assert.equals(1.25, tween.calculatedPosition);

		tween.position = 3.0;
		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);
	}

	public function testRepeatCount():Void
	{
		var target:Any = {abc123: 1.0};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 3.0, values, {repeatCount: 2});

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.position = 1.25;

		Assert.equals(1.25 / 3.0, tween.ratio);
		Assert.equals(1.25, tween.calculatedPosition);

		tween.position = 3.0;

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.position = 4.75;

		Assert.equals(1.75 / 3.0, tween.ratio);
		Assert.equals(1.75, tween.calculatedPosition);

		tween.position = 6.0;

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);
	}

	public function testReflect():Void
	{
		var target:Any = {abc123: 1.0};
		var values:Any = {abc123: 2.0};
		tween = new GTween(target, 3.0, values, {repeatCount: 2, reflect: true});

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);

		tween.position = 1.25;

		Assert.equals(1.25 / 3.0, tween.ratio);
		Assert.equals(1.25, tween.calculatedPosition);

		tween.position = 3.0;

		Assert.equals(1.0, tween.ratio);
		Assert.equals(3.0, tween.calculatedPosition);

		tween.position = 4.75;

		Assert.equals(1.25 / 3.0, tween.ratio);
		Assert.equals(1.25, tween.calculatedPosition);

		tween.position = 6.0;

		Assert.equals(0.0, tween.ratio);
		Assert.equals(0.0, tween.calculatedPosition);
	}
}