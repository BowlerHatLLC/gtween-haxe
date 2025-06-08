/*
 * GTweener by Grant Skinner. Oct 19, 2009
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
 */

package com.gskinner.motion;
	
import com.gskinner.motion.plugins.IGTweenPlugin;
import com.gskinner.motion.GTween;

/**
	GTweener is an experimental class that provides a static interface and basic
	override management for GTween. It adds about 1kb to GTween. With GTweener, if you tween a value that is
	already being tweened, the new tween will override the old tween for only that
	value. The old tween will continue tweening other values uninterrupted.

	GTweener also serves as an interesting example for utilizing GTween's `"~~"` plugin
	registration feature, where a plugin can be registered to run for every tween.

	GTweener introduces a small amount overhead to GTween, which may have a limited impact
	on performance critical scenarios with large numbers (thousands) of tweens.
**/
class GTweener implements IGTweenPlugin {
	
// Protected Static Properties:
	private static var tweens:Map<{}, Array<GTween>> = [];
	private static var instance:GTweener;
	
// Initialization:
	private static function __init__():Void {
		// register to be called any time a tween inits or tweens:
		instance = new GTweener();
		GTween.installPlugin(instance, ["*"]);
	}

	@:dox(hide)
	@:noCompletion
	public function new() {
	}
	
	public function init(tween:GTween, name:String, value:Float):Float {
		// don't do anything.
		return value;
	}
	
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		// if the tween has just completed and it is currently being managed by GTweener
		// then remove it:
		if (end && tween.pluginData.GTweener) {
			remove(tween);
		}
		return value;
	}

// Public Static Methods:
	/**
		Tweens the target to the specified values.
	**/
	public static function to(target:Any=null, duration:Float=1, values:Any=null, props:Any=null, pluginData:Any=null):GTween {
		var tween:GTween = new GTween(target, duration, values, props, pluginData);
		add(tween);
		return tween;
	}
	
	/**
		Tweens the target from the specified values to its current values.
	**/
	public static function from(target:Any=null, duration:Float=1, values:Any=null, props:Any=null, pluginData:Any=null):GTween {
		var tween:GTween = to(target, duration, values, props, pluginData);
		tween.swapValues();
		return tween;
	}
	
	/**
		Adds a tween to be managed by GTweener.
	**/
	public static function add(tween:GTween):Void {
		var target:Any = tween.target;
		var list:Array<GTween> = tweens.get(target);
		if (list != null) {
			clearValues(target,tween.getValues());
		} else {
			list = [];
			tweens.set(target, list);
		}
		list.push(tween);
		tween.pluginData.GTweener = true;
	}
	
	/**
		Gets the tween that is actively tweening the specified property of the target, or null
		if none.
	**/
	public static function getTween(target:Any, name:String):GTween {
		var list:Array<GTween> = tweens.get(target);
		if (list == null) { return null; }
		var l:Int = list.length;
		for (i in 0...l) {
			var tween:GTween = list[i];
			if (!Math.isNaN(tween.getValue(name))) { return tween; }
		}
		return null;
	}
	
	/**
		Returns an array of all tweens that GTweener is managing for the specified target.
	**/
	public static function getTweens(target:Any):Array<GTween> {
		var tweens:Array<GTween> = tweens.get(target);
		if (tweens != null) {
			return tweens;
		}
		return [];
	}
	
	/**
		Pauses all tweens that GTweener is managing for the specified target.
	**/
	public static function pauseTweens(target:Any,paused:Bool=true):Void {
		var list:Array<GTween> = tweens.get(target);
		if (list == null) { return; }
		var l:Int = list.length;
		for (i in 0...l) {
			list[i].paused = paused;
		}
	}
	
	/**
		Resumes all tweens that GTweener is managing for the specified target.
	**/
	public static function resumeTweens(target:Any):Void {
		pauseTweens(target,false);
	}
	
	/**
		Removes a tween from being managed by GTweener.
	**/
	public static function remove(tween:GTween):Void {
		Reflect.deleteField(tween.pluginData, "GTweener");
		var list:Array<GTween> = tweens.get(tween.target);
		if (list == null) { return; }
		var l:Int = list.length;
		for (i in 0...l) {
			if (list[i] == tween) {
				list.splice(i,1);
				return;
			}
		}
	}
	
	/**
		Removes all tweens that GTweener is managing for the specified target.
	**/
	public static function removeTweens(target:Any):Void {
		pauseTweens(target);
		var list:Array<GTween> = tweens.get(target);
		if (list == null) { return; }
		var l:Int = list.length;
		for (i in 0...l) {
			Reflect.deleteField(list[i].pluginData, "GTweener");
		}
		tweens.remove(target);
	}
	
// Protected Static Methods:
	private static function clearValues(target:Any, values:Any):Void {
		for (n in Reflect.fields(values)) {
			var tween:GTween = getTween(target,n);
			if (tween != null) { tween.deleteValue(n); }
		}
	}
	
}