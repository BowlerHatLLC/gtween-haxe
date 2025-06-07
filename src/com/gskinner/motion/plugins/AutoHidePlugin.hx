/**
* AutoHidePlugin by Grant Skinner. Nov 3, 2009
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
import com.gskinner.motion.plugins.IGTweenPlugin;
#if openfl
import openfl.display.DisplayObject;
#else
import flash.display.DisplayObject;
#end

/**
* Plugin for GTween. Sets the visible of the target to false if its alpha is 0 or less.
* <p>
* Supports the following <code>pluginData</code> properties:</p><ul>
* <li> AutoHideEnabled: overrides the enabled property for the plugin on a per tween basis.</li>
* </ul>
**/
class AutoHidePlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:AutoHidePlugin;
	private static var tweenProperties:Array<String> = ["alpha"];
	
	/**
		Installs this plugin for use with all GTween instances.
	**/
	public static function install():Void {
		if (instance != null) { return; }
		instance = new AutoHidePlugin();
		GTween.installPlugin(instance,tweenProperties);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		return value;
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		// only change the visibility if the plugin is enabled:
		if (((tween.pluginData.AutoHideEnabled == null && enabled) || tween.pluginData.AutoHideEnabled)) {
			var tweenTarget:DisplayObject = cast(tween.target, DisplayObject);
			if (tweenTarget.visible != (value > 0)) { tweenTarget.visible = (value > 0); }
		}
		return value;
	}
	
}
#end