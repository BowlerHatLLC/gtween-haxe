/**
* MotionBlurPlugin by Grant Skinner. Nov 3, 2009
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
import com.gskinner.motion.GTween;
#if openfl
import openfl.display.DisplayObject;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
#else
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
#end
import com.gskinner.motion.plugins.IGTweenPlugin;

/**
	Plugin for GTween. Automatically applies a motion blur effect when x and y are tweened. This plugin
	will create a new blur filter on the target, and remove it based on a saved index when the tween ends.
	This can potentially cause problems with other filters that create or remove filters.

	**Note:** Because it works on the common x,y properties, and has a reasonably high CPU cost,
	this plugin is disabled for all tweens by default (ie. its enabled property is set to false).
	Set `pluginData.MotionBlurEnabled` to true on the tweens you want to enable it for,
	or set `MotionBlurPlugin.enabled` to true to enable it by default for all tweens.

	Supports the following `pluginData` properties:

	- MotionBlurEnabled: overrides the enabled property for the plugin on a per tween basis.
	- MotionBlurData: Used internally.
**/
class MotionBlurPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool = false;
	
	/**
		Specifies the strength to use when calculating the blur. A higher value will result in more blurring.
	**/
	public static var strength:Float = 0.6;
	
	private static var instance:MotionBlurPlugin;
	
	/**
		Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new MotionBlurPlugin();
		GTween.installPlugin(instance,["x","y"]);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		return value;
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		if (!((enabled && tween.pluginData.MotionBlurEnabled == null) || tween.pluginData.MotionBlurEnabled)) { return value; }
		
		var data:Any = Reflect.field(tween.pluginData, "MotionBlurData");
		if (data == null) { data = initTarget(tween); }
		
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		var dataIndex:Int = Reflect.field(data, "index");
		var blurF:BlurFilter = Std.downcast(f[dataIndex], BlurFilter);
		if (blurF == null) { return value; }
		if (end) {
			f.splice(dataIndex,1);
			Reflect.deleteField(tween.pluginData, "MotionBlurData");
		} else {
			var blur:Float = Math.abs((tween.ratioOld-ratio)*rangeValue*strength);
			if (name == "x") { blurF.blurX = blur; }
			else { blurF.blurY = blur; }
		}
		tweenTarget.filters = f;
		
		// tell GTween to tween x/y with the default value:
		return value;
	}
	
// Private methods:
	/** @private **/
	private function initTarget(tween:GTween):Any {
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		f.push(new BlurFilter(0,0,1));
		tweenTarget.filters = f;
		var result = {index:f.length-1};
		Reflect.setField(tween.pluginData, "MotionBlurData", result);
		return result;
	}
	
}
#end