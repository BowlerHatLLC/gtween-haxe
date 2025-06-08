/*
 * ColorTransformPlugin by Grant Skinner. Nov 3, 2009
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
import openfl.geom.ColorTransform;
#else
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
#end

/**
	Plugin for GTween. Applies a color transform or tint to the target based on the
	"redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset",
	"greenOffset", "blueOffset", "alphaOffset", and/or "tint" tween values. The tint
	value is a 32 bit color, where the alpha channel represents the strength of the tint.
	For example 0x8000FF00 would apply a green tint at 50% (0x80) strength.

	Supports the following `pluginData` properties:

	- ColorTransformEnabled: overrides the enabled property for the plugin on a per tween basis.
**/
class ColorTransformPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:ColorTransformPlugin;
	private static var tweenProperties:Array<String> = ["redMultiplier","greenMultiplier","blueMultiplier","alphaMultiplier","redOffset","greenOffset","blueOffset","alphaOffset","tint"];
	
	/**
		Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new ColorTransformPlugin();
		GTween.installPlugin(instance,tweenProperties,true);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		if (!((enabled && tween.pluginData.ColorTransformEnabled == null) || tween.pluginData.ColorTransformEnabled)) { return value; }
		
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		if (name == "tint") {
			// try to calculate initial tint:
			var ct:ColorTransform = tweenTarget.transform.colorTransform;
			var a:Int = Std.int(Math.min(1,1-ct.redMultiplier));
			var r:Int = Std.int(Math.min(0xFF,ct.redOffset*a));
			var g:Int = Std.int(Math.min(0xFF,ct.greenOffset*a));
			var b:Int = Std.int(Math.min(0xFF,ct.blueOffset*a));
			var tint:Int = a*0xFF<<24 | r<<16 | g<<8 | b;
			return tint;
		} else {
			return Reflect.getProperty(tweenTarget.transform.colorTransform, name);
		}
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		if (!((tween.pluginData.ColorTransformEnabled == null && enabled) || tween.pluginData.ColorTransformEnabled)) { return value; }
		
		var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
		var ct:ColorTransform = tweenTarget.transform.colorTransform;
		if (name == "tint") {
			var aA:Int = Std.int(initValue)>>24&0xFF;
			var rA:Int = Std.int(initValue)>>16&0xFF;
			var gA:Int = Std.int(initValue)>>8&0xFF;
			var bA:Int = Std.int(initValue)&0xFF;
			var tint:Int = Std.int(initValue)+Std.int(rangeValue)>>0;
			var a:Int = aA+Std.int(ratio)*((tint>>24&0xFF)-aA);
			var r:Int = rA+Std.int(ratio)*((tint>>16&0xFF)-rA);
			var g:Int = gA+Std.int(ratio)*((tint>>8&0xFF)-gA);
			var b:Int = bA+Std.int(ratio)*((tint&0xFF)-bA);
			var mult:Float = 1-a/0xFF;
			tweenTarget.transform.colorTransform = new ColorTransform(mult,mult,mult,ct.alphaMultiplier,r,g,b,ct.alphaOffset);
		} else {
			Reflect.setProperty(ct, name, value);
			tweenTarget.transform.colorTransform = ct;
		}
		
		// tell GTween not to use the default assignment behaviour:
		return Math.NaN;
	}	
}
#end