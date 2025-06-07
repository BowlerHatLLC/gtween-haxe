/**
* SnappingPlugin by Grant Skinner. Nov 3, 2009
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
	
import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.IGTweenPlugin;

/**
	Plugin for GTween. Snaps (rounds) values to whole numbers during a tween.

	Supports the following `pluginData` properties:

	- SnappingEnabled: overrides the enabled property for the plugin on a per tween basis.
**/
class SnappingPlugin implements IGTweenPlugin {
	
// Static interface:
	/**
		Specifies whether this plugin is enabled for all tweens by default.
	**/
	public static var enabled:Bool=true;
	
	private static var instance:SnappingPlugin;
	private static var tweenProperties:Array<String> = ["x","y"];
	
	/**
		Installs this plugin for use with all GTween instances.
	
		@param properties Specifies the properties to apply this plugin to. Defaults to x and y.
	**/
	public static function install(properties:Array<String>=null):Void {
		if (instance != null) { return; }
		instance = new SnappingPlugin();
		GTween.installPlugin(instance, properties != null ? properties : tweenProperties, true);
	}

	private function new() {}
	
// Public methods:
	@:dox(hide)
	public function init(tween:GTween, name:String, value:Float):Float {
		return value;
	}
	
	@:dox(hide)
	public function tween(tween:GTween, name:String, value:Float, initValue:Float, rangeValue:Float, ratio:Float, end:Bool):Float {
		if (!((enabled && tween.pluginData.SnappingEnabled == null) || tween.pluginData.SnappingEnabled)) { return value; }
		
		return Math.round(value);
	}
	
}