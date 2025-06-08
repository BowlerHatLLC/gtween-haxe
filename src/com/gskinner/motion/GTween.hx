/**
 * GTween v1 by Grant Skinner. Aug 15, 2008
 * GTween v2 by Grant Skinner. Oct 02, 2009
 * Visit www.gskinner.com/blog for documentation, updates and more free code.
 *
 *
 * Copyright (c) 2009 Grant Skinner
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

package com.gskinner.motion;

import com.gskinner.motion.plugins.IGTweenPlugin;
import haxe.Constraints.Function;
#if openfl
import openfl.display.Shape;
import openfl.events.EventDispatcher;
import openfl.events.Event;
import openfl.events.IEventDispatcher;
#elseif flash
import flash.display.Shape;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.IEventDispatcher;
#end
	
/**
	**GTween ©2008 Grant Skinner, gskinner.com. Visit www.gskinner.com/libraries/gtween/ for documentation, updates and more free code. Licensed under the MIT license - see the source file header for more information.**

	GTween is a light-weight instance oriented tween engine. This means that you instantiate tweens for specific purposes, and then reuse, update or discard them.
	This is different than centralized tween engines where you "register" tweens with a global object. This provides a more familiar and useful interface
	for object oriented programmers.

	In addition to a more traditional setValue/setValues tweening interface, GTween also provides a unique proxy interface to tween and access properties of target objects
	in a more dynamic fashion. This allows you to work with properties directly, and mostly ignore the details of the tween. The proxy "stands in"
	for your object when working with tweened properties. For example, you can modify end values (the value you are tweening to), in the middle of a tween.
	You can also access them dynamically, like so:

	```haxe
	mySpriteTween.proxy.rotation += 50;
	```

	Assuming no end value has been set for rotation previously, the above example will get the current rotation from the target, add 50 to it, set it as the end
	value for rotation, and start the tween. If the tween has already started, it will adjust for the new values. This is a hugely powerful feature that
	requires a bit of exploring to completely understand. See the documentation for the "proxy" property for more information.
	For a light-weight engine (~3.5kb), GTween boasts a number of advanced features:

	-  frame and time based durations/positions which can be set per tween
	-  works with any numeric properties on any object (not just display objects)
	-  simple sequenced tweens using .nextTween
	-  pause and resume individual tweens or all tweens
	-  jump directly to the end or beginning of a tween with .end() or .beginning()
	-  jump to any arbitrary point in the tween with .position
	-  complete, init, and change callbacks
	-  smart garbage collector interactions (prevents collection while active, allows collection if target is collected)
	-  uses any standard ActionScript tween functions
	-  easy to set up in a single line of code
	-  can repeat or reflect a tween a specified number of times
	-  deterministic, so setting a position on a tween will (almost) always result in predictable results
	-  very powerful sequencing capabilities in conjunction with GTweenTimeline
**/
class GTween #if (flash || openfl) extends EventDispatcher #end
{
	
	// Constants:
	
	// Static interface:
	/**
		Indicates the version number for this build. The numeric value will always
		increase with the version number for easy comparison (ex. GTween.version >= 2.12).
		Currently, it incorporates the major version as the integer value, and the two digit
		build number as the decimal value. For example, the fourth build of version 3 would
		have version=3.04.
	**/
	public static var version:Float = 2.01;
	
	#if (flash || openfl)
	/**
		Sets the default value of dispatchEvents for new instances.
	**/
	public static var defaultDispatchEvents:Bool = false;
	#end
	
	/**
		Specifies the default easing function to use with new tweens. Set to GTween.linearEase by default.
	**/
	public static var defaultEase:Function = linearEase;
	
	/**
		Setting this to true pauses all tween instances. This does not affect individual tweens' .paused property.
	**/
	public static var pauseAll:Bool = false;
	
	/**
		Sets the time scale for all tweens. For example to run all tweens at half speed,
		you can set timeScaleAll to 0.5. It is multiplied against each tweens timeScale.
		For example a tween with timeScale=2 will play back at normal speed if timeScaleAll is set to 0.5.
	**/
	public static var timeScaleAll:Float = 1;
	
	private static var hasStarPlugins:Bool = false;
	private static var plugins:Any;
	#if (flash || openfl)
	private static var shape:Shape;
	#else
	private static var addedTimerEvent:Bool = false;
	#if (!lime && !js)
	private static var timer:haxe.Timer;
	#end
	#end
	private static var time:Float;
	private static var tickList:Map<GTween, Bool>;
	private static var gcLockList:Map<GTween, Bool>;

	private static function __init__():Void {
		plugins = {};
		tickList = [];
		gcLockList = [];
	}
	
	/**
		Installs a plugin for the specified property. Plugins with high priority
		will always be called before other plugins for the same property. This method
		is primarily used by plugin developers. Plugins are normally installed by calling
		the install method on them, such as BlurPlugin.install().
		
		Plugins can register to be associated with a specific property name, or to be
		called for all tweens by registering for the "*" property name. The latter will be called after
		all properties are inited or tweened for a particular GTween instance.
		
		@param plugin The plugin object to register. The plugin should conform to the IGTweenPlugin interface.
		@param propertyNames An array of property names to operate on (ex. "rotation"), or "*" to register the plugin to be called for every GTween instance.
		@param highPriority If true, the plugin will be added to the start of the plugin list for the specified property name, if false it will be added to the end.
	**/
	public static function installPlugin(plugin:IGTweenPlugin, propertyNames:Array<String>, highPriority:Bool = false):Void
	{
		for (i in 0...propertyNames.length)
		{
			var propertyName:String = propertyNames[i];
			if (propertyName == "*")
			{
				hasStarPlugins = true;
			}
			if (Reflect.field(plugins, propertyName) == null)
			{
				Reflect.setField(plugins, propertyName, [plugin]);
				continue;
			}
			if (highPriority)
			{
				var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, propertyName);
				pluginArr.unshift(plugin);
			}
			else
			{
				var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, propertyName);
				pluginArr.push(plugin);
			}
		}
	}
	
	/**
		The default easing function used by GTween.
	**/
	public static function linearEase(a:Float, b:Float, c:Float, d:Float):Float
	{
		return a;
	}

	private static inline function getTimer():Float {
		#if openfl
		return openfl.Lib.getTimer();
		#elseif lime
		return lime.system.System.getTimer()
		#elseif flash
		return flash.Lib.getTimer();
		#elseif js
		return js.Lib.global.performance.now();
		#else
		return haxe.Timer.stamp() * 1000;
		#end
	}
	
	private static function staticTick(#if (flash || openfl) evt:Event #elseif lime deltaTime:Int #elseif js deltaTime:Float #end):Void
	{
		var t:Float = time;
		time = getTimer() / 1000;
		if (pauseAll)
		{
			return;
		}
		var dt:Float = (time - t) * timeScaleAll;
		for (tween in tickList.keys())
		{
			tween.position = tween._position + (tween.useFrames ? timeScaleAll : dt) * tween.timeScale;
		}

		#if (js && !openfl && !lime)
		if (js.Lib.typeof(js.Browser.window) == "undefined")
		{
			js.Lib.global.setImmediate(staticTick);
		}
		else
		{
			js.Browser.window.requestAnimationFrame(staticTick);
		}
		#end
	}
	
	// Public Properties:
	private var _delay:Float = 0;
	private var _values:Any;
	private var _paused:Bool = true;
	private var _position:Float = Math.NaN;
	private var _inited:Bool;
	private var _initValues:Any;
	private var _rangeValues:Any;
	
	// Protected Properties:
	/**
		Indicates whether the tween should automatically play when an end value is changed.
	**/
	public var autoPlay:Bool = true;
	
	/**
		Allows you to associate arbitrary data with your tween. For example, you might use this to reference specific data when handling event callbacks from tweens.
	**/
	public var data:Dynamic;
	
	/**
		The length of the tween in frames or seconds (depending on the timingMode). Setting this will also update any child transitions that have synchDuration set to true.
	**/
	public var duration:Float;
	
	/**
		The easing function to use for calculating the tween. This can be any standard tween function, such as the tween functions in fl.motion.easing.* that come with Flash CS3.
		New tweens will have this set to `defaultTween`. Setting this to null will cause GTween to throw null reference errors.
	**/
	public var ease:Function;
	
	/**
		Specifies another GTween instance that will have `paused=false` set on it when this tween completes.
		This happens immediately before onComplete is called.
	**/
	public var nextTween:GTween;
	
	/**
		Stores data for plugins specific to this instance. Some plugins may allow you to set properties on this object that they use.
		Check the documentation for your plugin to see if any properties are supported.
		Most plugins also support a property on this object in the form PluginNameEnabled to enable or disable
		the plugin for this tween (ex. BlurEnabled for BlurPlugin). Many plugins will also store internal data in this object.
	**/
	public var pluginData:Dynamic;
	
	/**
		Indicates whether the tween should use the reflect mode when repeating. If reflect is set to true, then the tween will play backwards on every other repeat.
	**/
	public var reflect:Bool = false;
	
	/**
		The number of times this tween will run. If 1, the tween will only run once. If 2 or more, the tween will repeat that many times. If 0, the tween will repeat forever.
	**/
	public var repeatCount:Int = 1;
	
	/**
		The target object to tween. This can be any kind of object. You can retarget a tween at any time, but changing the target in mid-tween may result in unusual behaviour.
	**/
	public var target:Dynamic;
	
	/**
		If true, durations and positions can be set in frames. If false, they are specified in seconds.
	**/
	public var useFrames:Bool = false;
	
	/**
		Allows you to scale the passage of time for a tween. For example, a tween with a duration of 5 seconds, and a timeScale of 2 will complete in 2.5 seconds.
		With a timeScale of 0.5 the same tween would complete in 10 seconds.
	**/
	public var timeScale:Float = 1;
	
	/**
		The position of the tween at the previous change. This should not be set directly.
	**/
	public var positionOld:Float = Math.NaN;
	
	/**
		The eased ratio (generally between 0-1) of the tween at the current position. This should not be set directly.
	**/
	public var ratio:Float = Math.NaN;
	
	/**
		The eased ratio (generally between 0-1) of the tween at the previous position. This should not be set directly.
	**/
	public var ratioOld:Float = Math.NaN;
	
	/**
		The current calculated position of the tween.
		This is a deterministic value between 0 and duration calculated
		from the current position based on the duration, repeatCount, and reflect properties.
		This is always a value between 0 and duration, whereas `.position` can range
		between -delay and repeatCount*duration. This should not be set directly.
	**/
	public var calculatedPosition:Float = Math.NaN;
	
	/**
		The previous calculated position of the tween. See `.calculatedPosition` for more information.
		This should not be set directly.
	**/
	public var calculatedPositionOld:Float = Math.NaN;
	
	/**
		If true, events/callbacks will not be called. As well as allowing for more
		control over events, and providing flexibility for extension, this results
		in a slight performance increase, particularly if useCallbacks is false.
	**/
	public var suppressEvents:Bool = false;
	
	#if (flash || openfl)
	/**
		If true, it will dispatch init, change, and complete events in addition to calling the
		onInit, onChange, and onComplete callbacks. Callbacks provide significantly better
		performance, whereas events are more standardized and flexible (allowing multiple
		listeners, for example).
		
		By default this will use the value of defaultDispatchEvents.
	**/
	public var dispatchEvents:Bool;
	#end
	
	/**
		Callback for the complete event. Any function assigned to this callback
		will be called when the tween finishes with a single parameter containing
		a reference to the tween.
		
		Ex.
		
		```haxe
		myTween.onComplete = myFunction;
		function myFunction(tween:GTween):Void {
			trace("tween completed");
		}
		```
	**/
	public var onComplete:Function;
	
	/**
		Callback for the change event. Any function assigned to this callback
		will be called each frame while the tween is active with a single parameter containing
		a reference to the tween.
	**/
	public var onChange:Function;
	
	/**
		Callback for the init event. Any function assigned to this callback
		will be called when the tween inits with a single parameter containing
		a reference to the tween. Init is usually triggered when a tween finishes
		its delay period and becomes active, but it can also be triggered by other
		features that require the tween to read the initial values, like calling `.swapValues()`.
	**/
	public var onInit:Function;
	
	// Initialization:
	/**
		Constructs a new GTween instance.
		
		@param target The object whose properties will be tweened. Defaults to null.
		@param duration The length of the tween in frames or seconds depending on the timingMode. Defaults to 1.
		@param values An object containing end property values. For example, to tween to x=100, y=100, you could pass {x:100, y:100} as the values object.
		@param props An object containing properties to set on this tween. For example, you could pass {ease:myEase} to set the ease property of the new instance. It also supports a single special property "swapValues" that will cause `.swapValues` to be called after the values specified in the values parameter are set.
		@param pluginData An object containing data for installed plugins to use with this tween. See `.pluginData` for more information.
	**/
	public function new(target:Any = null, duration:Float = 1, values:Any = null, props:Any = null, pluginData:Any = null)
	{
		#if (flash || openfl)
		super();
		if (shape == null)
		{
			(shape = new Shape()).addEventListener(Event.ENTER_FRAME, staticTick);
			time = getTimer() / 1000;
		}
		#elseif lime
		if (!addedTimerEvent)
		{
			addedTimerEvent = true;
			Application.current.onUpdate.add(staticTick);
			time = getTimer() / 1000;
		}
		#elseif js
		if (!addedTimerEvent)
		{
			addedTimerEvent = true;
			if (js.Lib.typeof(js.Browser.window) == "undefined")
			{
				js.Lib.global.setImmediate(staticTick);
			}
			else
			{
				js.Browser.window.requestAnimationFrame(staticTick);
			}
			time = getTimer() / 1000;
		}
		#else
		if (!addedTimerEvent)
		{
			addedTimerEvent = true;
			timer = new haxe.Timer(Std.int(1000.0 / 30.0));
			timer.run = staticTick;
			time = getTimer() / 1000;
		}
		#end
		ease = defaultEase;
		#if (flash || openfl)
		dispatchEvents = defaultDispatchEvents;
		#end
		this.target = target;
		this.duration = duration;
		this.pluginData = copy(pluginData, {});
		var swap:Bool = false;
		if (props != null)
		{
			swap = Reflect.field(props, "swapValues");
			Reflect.deleteField(props, "swapValues");
		}
		copy(props, this);
		resetValues(values);
		if (swap)
		{
			swapValues();
		}
		if (this.duration == 0 && delay == 0 && autoPlay)
		{
			position = 0;
		}
	}
	
	// Public getter / setters:

	/**
		Plays or pauses a tween. You can still change the position value externally on a paused
		tween, but it will not be updated automatically. While paused is false, the tween is also prevented
		from being garbage collected while it is active.
		This is achieved in one of two ways:

		1. If the target object is an IEventDispatcher, then the tween will subscribe to a dummy event using a hard reference. This allows
		   the tween to be garbage collected if its target is also collected, and there are no other external references to it.
		2. If the target object is not an IEventDispatcher, then the tween is placed in a global list, to prevent collection until it is paused or completes.
		   Note that pausing all tweens via the GTween.pauseAll static property will not free the tweens for collection.
	**/
	@:flash.property
	public var paused(get, set):Bool;

	private function get_paused():Bool
	{
		return _paused;
	}
	
	private function set_paused(value:Bool):Bool
	{
		if (value == _paused)
		{
			return _paused;
		}
		_paused = value;
		if (Math.isNaN(_position) || (repeatCount != 0 && _position >= repeatCount * duration))
		{
			// reached the end, reset.
			_inited = false;
			calculatedPosition = calculatedPositionOld = ratio = ratioOld = positionOld = 0;
			_position = -delay;
		}
		if (_paused)
		{
			tickList.remove(this);
			#if (flash || openfl)
			if ((target is IEventDispatcher))
			{
				(cast target : IEventDispatcher).removeEventListener("_", invalidate);
			}
			#end
			gcLockList.remove(this);
		}
		else
		{
			tickList.set(this, true);
			#if (flash || openfl)
			// prevent garbage collection:
			if ((target is IEventDispatcher))
			{
				(cast target : IEventDispatcher).addEventListener("_", invalidate);
			}
			else
			{
				gcLockList.set(this, true);
			}
			#else
			gcLockList.set(this, true);
			#end
		}
		return _paused;
	}
	
	/**
		Gets and sets the position of the tween in frames or seconds (depending on `.useFrames`). This value will
		be constrained between -delay and repeatCount*duration. It will be resolved to a `calculatedPosition` before
		being applied.
		
		**Negative values**
		
		Values below 0 will always resolve to a calculatedPosition of 0. Negative values can be used to set up a delay on the tween, as the tween will have to count up to 0 before initing.
		
		**Positive values**

		Positive values are resolved based on the duration, repeatCount, and reflect properties.
	**/
	@:flash.property
	public var position(get, set):Float;

	private function get_position():Float
	{
		return _position;
	}
	
	private function set_position(value:Float):Float
	{
		positionOld = _position;
		ratioOld = ratio;
		calculatedPositionOld = calculatedPosition;
		
		var maxPosition:Float = repeatCount * duration;
		
		var end:Bool = (value >= maxPosition && repeatCount > 0);
		if (end)
		{
			if (calculatedPositionOld == maxPosition)
			{
				return _position;
			}
			_position = maxPosition;
			calculatedPosition = (reflect && (repeatCount & 1) == 0) ? 0 : duration;
		}
		else
		{
			_position = value;
			calculatedPosition = _position < 0 ? 0 : duration == 0 ? Math.NaN : _position % duration;
			if (reflect && (Std.int(_position / duration) & 1) != 0)
			{
				calculatedPosition = duration - calculatedPosition;
			}
		}
		
		ratio = (duration == 0 && _position >= 0) ? 1 : ease(calculatedPosition / duration, 0, 1, 1);
		if (target != null && (_position >= 0 || positionOld >= 0) && calculatedPosition != calculatedPositionOld)
		{
			if (!_inited)
			{
				init();
			}
			for (n in Reflect.fields(_values))
			{
				var initVal:Float = Reflect.field(_initValues, n);
				var rangeVal:Float = Reflect.field(_rangeValues, n);
				var val:Float = initVal + rangeVal * ratio;
				
				var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, n);
				if (pluginArr != null)
				{
					var l:Int = pluginArr.length;
					for (i in 0...l)
					{
						val = pluginArr[i].tween(this, n, val, initVal, rangeVal, ratio, end);
					}
					if (!Math.isNaN(val))
					{
						Reflect.setProperty(target, n, val);
					}
				}
				else
				{
					Reflect.setProperty(target, n, val);
				}
			}
		}
		
		if (hasStarPlugins)
		{
			var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, "*");
			var l:Int = pluginArr.length;
			for (i in 0...l)
			{
				pluginArr[i].tween(this, "*", Math.NaN, Math.NaN, Math.NaN, ratio, end);
			}
		}
		
		if (!suppressEvents)
		{
			#if (flash || openfl)
			if (dispatchEvents)
			{
				dispatchEvt("change");
			}
			#end
			if (onChange != null)
			{
				onChange(this);
			}
		}
		if (end)
		{
			paused = true;
			if (nextTween != null)
			{
				nextTween.paused = false;
			}
			if (!suppressEvents)
			{
				#if (flash || openfl)
				if (dispatchEvents)
				{
					dispatchEvt("complete");
				}
				#end
				if (onComplete != null)
				{
					onComplete(this);
				}
			}
		}
		return _position;
	}

	/**
		The length of the delay in frames or seconds (depending on `.useFrames`).
		The delay occurs before a tween reads initial values or starts playing.
	**/
	@:flash.property
	public var delay(get, set):Float;

	private function get_delay():Float
	{
		return _delay;
	}
	
	private function set_delay(value:Float):Float
	{
		if (_position <= 0)
		{
			_position = -value;
		}
		_delay = value;
		return _delay;
	}
	
	// Public Methods:
	/**
		Sets the numeric end value for a property on the target object that you would like to tween.
		For example, if you wanted to tween to a new x position, you could use: myGTween.setValue("x",400).
		
		@param name The name of the property to tween.
		@param value The numeric end value (the value to tween to).
	**/
	public function setValue(name:String, value:Float):Void
	{
		Reflect.setField(_values, name, value);
		invalidate();
	}
	
	/**
		Returns the end value for the specified property if one exists.
		
		@param name The name of the property to return a end value for.
	**/
	public function getValue(name:String):Float
	{
		if (_values == null)
		{
			return Math.NaN;
		}
		var value:Dynamic = Reflect.field(_values, name);
		if (!(value is Float))
		{
			return Math.NaN;
		}
		return value;
	}
	
	/**
		Removes a end value from the tween. This prevents the GTween instance from tweening the property.
		
		@param name The name of the end property to delete.
	**/
	public function deleteValue(name:String):Bool
	{
		Reflect.deleteField(_rangeValues, name);
		Reflect.deleteField(_initValues, name);
		return Reflect.deleteField(_values, name);
	}
	
	/**
		Shorthand method for making multiple setProperty calls quickly.
		This adds the specified properties to the values list. Passing a
		property with a value of null will delete that value from the list.
		
		**Example:** set x and y end values, delete rotation:

		```haxe
		myGTween.setProperties({x:200, y:400, rotation:null});
		```
		
		@param properties An object containing end property values.
	**/
	public function setValues(values:Dynamic):Void
	{
		copy(values, _values, true);
		invalidate();
	}
	
	/**
		Similar to `.setValues()`, but clears all previous end values
		before setting the new ones.
		
		@param properties An object containing end property values.
	**/
	public function resetValues(values:Dynamic = null):Void
	{
		_values = {};
		setValues(values);
	}
	
	/**
		Returns the hash table of all end properties and their values. This is a copy of the internal hash of values, so modifying
		the returned object will not affect the tween.
	**/
	public function getValues():Dynamic
	{
		return copy(_values, {});
	}
	
	/**
		Returns the initial value for the specified property.
		Note that the value will not be available until the tween inits.
	**/
	public function getInitValue(name:String):Float
	{
		if (_initValues == null)
		{
			throw "Not initialized";
		}
		var value:Dynamic = Reflect.field(_initValues, name);
		if (!(value is Float))
		{
			return Math.NaN;
		}
		return value;
	}
	
	/**
		Swaps the init and end values for the tween, effectively reversing it.
		This should generally only be called before the tween starts playing.
		This will force the tween to init if it hasn't already done so, which
		may result in an onInit call.
		It will also force a render (so the target immediately jumps to the new values
		immediately) which will result in the onChange callback being called.
		
		You can also use the special "swapValues" property on the props parameter of
		the GTween constructor to call swapValues() after the values are set.
		
		The following example would tween the target from 100,100 to its current position:

		```haxe
		new GTween(ball, 2, {x:100, y:100}, {swapValues:true});
		```
	**/
	public function swapValues():Void
	{
		if (!_inited)
		{
			init();
		}
		var o:Dynamic = _values;
		_values = _initValues;
		_initValues = o;
		for (n in Reflect.fields(_rangeValues))
		{
			Reflect.setField(_rangeValues, n, Reflect.field(_rangeValues, n) * -1);
		}
		if (_position < 0)
		{
			// render it at position 0:
			var pos:Float = positionOld;
			position = 0;
			_position = positionOld;
			positionOld = pos;
		}
		else
		{
			position = _position;
		}
	}
	
	/**
		Reads all of the initial values from target and calls the onInit callback.
		This is called automatically when a tween becomes active (finishes delaying)
		and when `.swapValues()` is called. It would rarely be used directly
		but is exposed for possible use by plugin developers or power users.
	**/
	public function init():Void
	{
		_inited = true;
		_initValues = {};
		_rangeValues = {};
		for (n in Reflect.fields(_values))
		{
			if (Reflect.field(plugins, n) != null)
			{
				var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, n);
				var l:Int = pluginArr.length;
				var value:Float = Math.NaN;
				if (Reflect.hasField(target, n))
				{
					value = Reflect.field(target, n);
				}
				else
				{
					// Reflect.hasField doesn't work to find getter functions on
					// some target, but Reflect.field() may still return a value
					var getter = Reflect.field(target, 'get_$n');
					if (getter != null && Reflect.isFunction(getter)) {
						value = Reflect.getProperty(target, n);
					}
				}
				for (i in 0...l)
				{
					value = pluginArr[i].init(this, n, value);
				}
				if (!Math.isNaN(value))
				{
					Reflect.setField(_initValues, n, value);
					Reflect.setField(_rangeValues, n, Reflect.field(_values, n) - value);
				}
			}
			else
			{
				var initValue:Float = Reflect.getProperty(target, n);
				Reflect.setField(_initValues, n, initValue);
				Reflect.setField(_rangeValues, n, Reflect.field(_values, n) - initValue);
			}
		}
		
		if (hasStarPlugins)
		{
			var pluginArr:Array<IGTweenPlugin> = Reflect.field(plugins, "*");
			var l:Int = pluginArr.length;
			for (i in 0...l)
			{
				pluginArr[i].init(this, "*", Math.NaN);
			}
		}
		
		if (!suppressEvents)
		{
			#if (flash || openfl)
			if (dispatchEvents)
			{
				dispatchEvt("init");
			}
			#end
			if (onInit != null)
			{
				onInit(this);
			}
		}
	}
	
	/**
		Jumps the tween to its beginning and pauses it. This is the same as setting `position=0` and `paused=true`.
	**/
	public function beginning():Void
	{
		position = 0;
		paused = true;
	}
	
	/**
		Jumps the tween to its end and pauses it. This is roughly the same as setting `position=repeatCount*duration`.
	**/
	public function end():Void
	{
		position = (repeatCount > 0) ? repeatCount * duration : duration;
	}
	
	// Protected Methods:

	private function invalidate(#if (flash || openfl) evt:Event = null #end):Void
	{
		_inited = false;
		if (_position > 0)
		{
			_position = 0;
		}
		if (autoPlay)
		{
			paused = false;
		}
	}
	
	private function copy(o1:Dynamic, o2:Dynamic, smart:Bool = false):Dynamic
	{
		for (n in Reflect.fields(o1))
		{
			if (smart && Reflect.field(o1, n) == null)
			{
				Reflect.deleteField(o2, n);
			}
			else
			{
				// we might be copying to a GTween instance, so be sure to use
				// setProperty instead of setField because GTween has a mix of
				// fields and properties
				Reflect.setProperty(o2, n, Reflect.field(o1, n));
			}
		}
		return o2;
	}
	
	#if (flash || openfl)
	private function dispatchEvt(name:String):Void
	{
		if (hasEventListener(name))
		{
			dispatchEvent(new Event(name));
		}
	}
	#end

}
