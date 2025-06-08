/*
 * MatrixPlugin by Grant Skinner and Sebastian DeRossi. Nov 3, 2009
 * Visit www.gskinner.com/blog for documentation, updates and more free code.
 *
 * Adapted from Robert Penner's AS3 tweening equations.
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

package com.gskinner.motion.plugins;

#if (openfl || flash)
import com.gskinner.motion.GTween;

#if openfl
import openfl.display.DisplayObject;
import openfl.geom.Matrix;
#else
import flash.display.DisplayObject;
import flash.geom.Matrix;
#end
/**
	Plugin for GTween. Tweens the a, b, c, d, tx, and ty properties of
	the target's `transform.matrix` object.

	Supports the following `pluginData` properties:

	- MatrixEnabled: overrides the enabled property for the plugin on a per tween basis.
**/
class MatrixPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:MatrixPlugin;
	private static var tweenProperties:Array<String> = ['a', 'b', 'c', 'd', 'tx', 'ty'];
	
	/**
	* Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new MatrixPlugin();
		GTween.installPlugin(instance, tweenProperties, true);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		if (!((enabled && tween.pluginData.MatrixEnabled == null) || tween.pluginData.MatrixEnabled)) { return value; }
		
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		return Reflect.getProperty(tweenTarget.transform.matrix, name);
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		if (!((enabled && tween.pluginData.MatrixEnabled == null) || tween.pluginData.MatrixEnabled)) { return value; }
		
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var matrix:Matrix = tweenTarget.transform.matrix;
		Reflect.setProperty(matrix, name, value);
		tween.target.transform.matrix = matrix;
		
		// tell GTween not to use the default assignment behaviour:
		return Math.NaN;
	}
}
#end