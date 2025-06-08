/*
 * SoundTransformPlugin by Grant Skinner and Sebastian DeRossi. Nov 3, 2009
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
#if openfl
import openfl.media.SoundTransform;
#else
import flash.media.SoundTransform;
#end
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.IGTweenPlugin;

/**
	Plugin for GTween. Tweens the volume, pan, leftToLeft, leftToRight, rightToLeft, and rightToRight
	properties of the target's soundTransform object.

	Supports the following `pluginData` properties:

	- SoundTransformEnabled: overrides the enabled property for the plugin on a per tween basis.
**/
class SoundTransformPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:SoundTransformPlugin;
	private static var tweenProperties:Array<String> = ["leftToLeft", "leftToRight", "pan", "rightToLeft", "rightToRight", "volume"];
	
	/**
		Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new SoundTransformPlugin();
		GTween.installPlugin(instance, tweenProperties, true);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		if (!((enabled && tween.pluginData.SoundTransformEnabled == null) || tween.pluginData.SoundTransformEnabled)) { return value; }
		
		// it might be a SoundChannel, Sprite, NetStream, or a number of
		// different types without a common interface, so we can't cast
		// tween.target
		var soundTransform:SoundTransform = cast(Reflect.getProperty(tween.target, "soundTransform"), SoundTransform);
		return Reflect.getProperty(soundTransform, name);
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		if (!((enabled && tween.pluginData.SoundTransformEnabled == null) || tween.pluginData.SoundTransformEnabled)) { return value; }
		
		var soundTransform:SoundTransform = cast(Reflect.getProperty(tween.target, "soundTransform"), SoundTransform);
		Reflect.setProperty(soundTransform, name, value);
		Reflect.setProperty(tween.target, "soundTransform", soundTransform);
		
		// tell GTween not to use the default assignment behaviour:
		return Math.NaN;
	}
}
#end
