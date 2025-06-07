/**
* ColorAdjustPlugin by Grant Skinner. Nov 3, 2009
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
import openfl.filters.ColorMatrixFilter;
#else
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
#end
import com.gskinner.motion.GTween;
import com.gskinner.geom.ColorMatrix;
import com.gskinner.motion.plugins.IGTweenPlugin;

/**
	Plugin for GTween. Applies a color matrix filter to the target based on the "brightness", "contrast", "hue", and/or "saturation" tween values.

	If a color matrix filter does not already exist on the tween target, the plugin will create one.
	Note that this may conflict with other plugins that use filters. If you experience problems,
	try applying a color matrix filter to the target in advance to avoid this behaviour.

	Supports the following `pluginData` properties:

	- ColorAdjustEnabled: overrides the enabled property for the plugin on a per tween basis.
	- ColorAdjustData: Used internally.
**/
class ColorAdjustPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:ColorAdjustPlugin;
	private static var tweenProperties:Array<String> = ["brightness","contrast","hue","saturation"];
	
	/**
		Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new ColorAdjustPlugin();
		GTween.installPlugin(instance,tweenProperties);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		if (!((tween.pluginData.ColorAdjustEnabled == null && enabled) || tween.pluginData.ColorAdjustEnabled)) { return value; }
		
		if (tween.pluginData.ColorAdjustData == null) {
			// try to find an existing color matrix filter on the target:
			var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
			var f:Array<BitmapFilter> = tweenTarget.filters;
			for (i in 0...f.length) {
				if ((f[i] is ColorMatrixFilter)) {
					var cmF:ColorMatrixFilter = cast f[i];
					var o:Dynamic = {index:i,ratio:Math.NaN};
					
					// save off the initial matrix:
					o.initMatrix = cmF.matrix;
					
					// save off the target matrix:
					o.matrix = getMatrix(tween);
					
					// store in pluginData for this tween for retrieval later:
					tween.pluginData.ColorAdjustData = o;
				}
			}
		}
		
		// make up an initial value that will let us get a 0-1 ratio back later:
		return tween.getValue(name)-1;
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		// don't run if we're not enabled:
		if (!((tween.pluginData.ColorAdjustEnabled == null && enabled) || tween.pluginData.ColorAdjustEnabled)) { return value; }
		
		// grab the tween specific data from pluginData:
		var data:Dynamic = tween.pluginData.ColorAdjustData;
		if (data == null) { data = initTarget(tween); }
		
		// only run once per tween tick, regardless of how many properties we're dealing with
		// ex. don't run twice if both contrast and hue are specified, because we deal with them at the same time:
		if (ratio == data.ratio) { return Math.NaN; }
		data.ratio = ratio;
		
		// use the "magic" ratio we set up in init:
		ratio = value-initValue;
		
		// grab the filter:
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		var cmF:ColorMatrixFilter = Std.downcast(f[Std.int(data.index)], ColorMatrixFilter);
		if (cmF == null) { return value; }
		
		// grab our init and target color matrixes:
		var initMatrix:Array<Dynamic> = data.initMatrix;
		var targMatrix:Array<Float> = (data.matrix : ColorMatrix);
		
		// check if we're running backwards:
		if (rangeValue < 0) {
			// values were swapped.
			initMatrix = targMatrix;
			targMatrix = data.initMatrix;
			ratio *= -1;
		}
		
		// grab the current color matrix, and tween it's values:
		var matrix:Array<#if openfl Float #else Dynamic #end> = cmF.matrix;
		var l:Int = matrix.length;
		for (i in 0...l) {
			matrix[i] = initMatrix[i]+(targMatrix[i]-initMatrix[i])*ratio;
		}
		
		// set the matrix back to the filter, and set the filters on the target:
		cmF.matrix = matrix;
		tweenTarget.filters = f;
		
		// clean up if it's the end of the tween:
		if (end) {
			Reflect.deleteField(tween.pluginData, "ColorAdjustData");
		}
		
		// tell GTween not to use the default assignment behaviour:
		return Math.NaN;
	}
	
// Private methods:
	private function getMatrix(tween:GTween):ColorMatrix {
		var brightness:Float = fixValue(tween.getValue("brightness"));
		var contrast:Float = fixValue(tween.getValue("contrast"));
		var saturation:Float = fixValue(tween.getValue("saturation"));
		var hue:Float = fixValue(tween.getValue("hue"));
		var mtx:ColorMatrix = new ColorMatrix();
		mtx.adjustColor(brightness,contrast,saturation,hue);
		return mtx;
	}
	
	private function initTarget(tween:GTween):Dynamic {
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var f:Array<BitmapFilter> = tweenTarget.filters;
		var mtx:ColorMatrix = new ColorMatrix();
		f.push(new ColorMatrixFilter(mtx));
		tweenTarget.filters = f;
		var o:Dynamic = {index:f.length-1, ratio:Math.NaN};
		o.initMatrix = mtx;
		o.matrix = getMatrix(tween);
		tween.pluginData.ColorAdjustData = o;
		return o;
	}
	
	private function fixValue(value:Float):Float {
		return Math.isNaN(value) ? 0 : value;
	}
}
#end