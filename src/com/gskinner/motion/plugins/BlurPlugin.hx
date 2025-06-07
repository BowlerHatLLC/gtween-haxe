/**
* BlurPlugin by Grant Skinner. Nov 3, 2009
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

package com.gskinner.motion.plugins;

#if (openfl || flash)
#if openfl
import openfl.display.DisplayObject;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
#else
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.IGTweenPlugin;
	
/**
	Plugin for GTween. Applies a blur filter to the target based on the "blur", "blurX", and/or "blurY" tween values.

	If a blur filter does not already exist on the tween target, the plugin will create one.
	Note that this may conflict with other plugins that use filters. If you experience problems,
	try applying a blur filter to the target in advance to avoid this behaviour.

	Supports the following `pluginData` properties:

	- BlurEnabled: overrides the enabled property for the plugin on a per tween basis.
	- BlurData: Used internally.
**/
class BlurPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:BlurPlugin;
	private static var tweenProperties:Array<String> = ["blurX","blurY","blur"];
	
	/**
	* Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new BlurPlugin();
		GTween.installPlugin(instance,tweenProperties);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		if (!((tween.pluginData.BlurEnabled == null && enabled) || tween.pluginData.BlurEnabled)) { return value; }
		
		// try to find a blur filter:
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		for (i in 0...f.length) {
			if ((f[i] is BlurFilter)) {
				// found one.
				var blurF:BlurFilter = cast f[i];
				
				// save off its index for future reference:
				tween.pluginData.BlurData = {index:i}
				
				// return our initial values from it:
				if (name == "blur") {
					return (blurF.blurX+blurF.blurY)/2;
				} else {
					return Reflect.getProperty(blurF, name);
				}
			}
		}
		// didn't find one, so our blur starts at 0:
		return 0;
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		// don't run if we're not enabled:
		if (!((tween.pluginData.BlurEnabled == null && enabled) || tween.pluginData.BlurEnabled)) { return value; }
		
		// grab the tween specific data from pluginData:
		var data:Dynamic = tween.pluginData.BlurData;
		if (data == null) { data = initTarget(tween); }
		
		// grab the filter:
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		var blurF:BlurFilter = Std.downcast(f[Std.int(data.index)], BlurFilter);
		if (blurF == null) { return value; }
		
		// update the filter and set it back to the target:
		if (name == "blur") { blurF.blurX = blurF.blurY = value; }
		else { Reflect.setProperty(blurF, name, value); }
		tweenTarget.filters = f;
		
		// clean up if it's the end of the tween:
		if (end) {
			Reflect.deleteField(tween.pluginData, "BlurData");
		}
		
		// tell GTween not to use the default assignment behaviour:
		return Math.NaN;
	}
	
// Private methods:
	private function initTarget(tween:GTween):Dynamic {
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		f.push(new BlurFilter(0,0,1));
		tweenTarget.filters = f;
		var o = {index:f.length-1};
		tween.pluginData.BlurData = o;
		return o;
	}
	
}
#end