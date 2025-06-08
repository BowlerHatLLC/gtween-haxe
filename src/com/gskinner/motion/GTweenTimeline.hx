/*
 * GTweenTimeline v1 by Grant Skinner. Jan 15, 2009
 * GTweenTimeline v2 by Grant Skinner. Oct 02, 2009
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
	
import haxe.Constraints.Function;
import com.gskinner.motion.GTween;

/**
	GTweenTimeline is a powerful sequencing engine for GTween. It allows you to build a virtual timeline
	with tweens, actions (callbacks), and labels. It supports all of the features of GTween, so you can repeat,
	reflect, and pause the timeline. You can even embed timelines within each other. GTweenTimeline adds about 1.2kb above GTween.</p>
**/
class GTweenTimeline extends GTween {
// static properties:
	/**
		Sets a property value on a specified target object. This is provided to make it easy to set properties
		in a GTweenTimeline using <code>addCallback</code>. For example, to set the <code>visible</code> property to true on a movieclip "foo"
		at 3 seconds into the timeline, you could use the following code:

		```haxe
		myTimeline.addCallback(3,GTweenTimeline.setPropertyValue,[foo,"visible",true]);
		```
		
		@param target The object to set the property value on.
		@param propertyName The name of the property to set.
		@param value The value to assign to the property.
	**/
	public static function setPropertyValue(target:Any,propertyName:String,value:Any):Void {
		Reflect.setProperty(target, propertyName, value);
	}
	
// public properties:
	/**
		If true, callbacks added with addCallback will not be called. This does not
		affect event callbacks like onChange, which can be disabled with suppressEvents.
		This can be handy for preventing large numbers of callbacks from being called when
		manually changing the position of a timeline (ex. calling `.end()`).
	**/
	public var suppressCallbacks:Bool = false;

// private properties:
	private var callbacks:Array<Callback>;
	private var labels:Map<String, Float>;
	private var tweens:Array<GTween>;
	private var tweenStartPositions:Array<Float>;
	
// construction:
	/**
		Constructs a new GTweenTimeline instance. Note that because GTweenTimeline
		extends GTween, it can be used to tween a target directly, in addition to
		using its timeline features (for example, to synch tweening an animation with
		a timeline sequence).
		
		@param target The object whose properties will be tweened. Defaults to null.
		@param duration The length of the tween in frames or seconds depending on the timingMode. Defaults to 10.
		@param values An object containing destination property values. For example, to tween to x=100, y=100, you could pass `{x:100, y:100}` as the props object.
		@param props An object containing properties to set on this tween. For example, you could pass {ease:myEase} to set the ease property of the new instance. It also supports a single special property "swapValues" that will cause `.swapValues` to be called after the values specified in the values parameter are set.
		@param pluginData An object containing data for installed plugins to use with this tween. See `.pluginData` for more information.
		@param tweens An array of alternating start positions and tween instances. For example, the following array would add 3 tweens starting at positions 2, 6, and 8: `[2, tween1, 6, tween2, 8, tween3]`
	**/
	public function new(target:Any=null, duration:Float=1, values:Any=null, props:Any=null, pluginData:Any=null, tweens:Array<Any>=null) {
		this.tweens = [];
		tweenStartPositions = [];
		callbacks = [];
		labels = [];
		addTweens(tweens);
		super(target, duration, values, props, pluginData);
		// unlike GTween, which waits for a setValue to start playing, GTweenTimeline starts immediately:
		if (autoPlay) { paused = false; }
	}
	
// public getter / setters:
	override public function set_position(value:Float):Float {
		// delay event callbacks until we're done:
		var tmpSuppressEvents:Bool = suppressEvents;
		suppressEvents = true;
		
		// run all the normal GTween logic:
		super.position = value;
		
		// update tweens:
		var repeatIndex:Float = Std.int(_position/duration);
		var rev:Bool = (reflect && repeatIndex%2>=1);
		var l:Int = tweens.length;
		if (rev) {
			for (i in 0...l) {
				tweens[i].position = calculatedPosition-tweenStartPositions[i];
			}
		} else {
			var i:Int = l-1;
			while (i>= 0) {
				tweens[i].position = calculatedPosition-tweenStartPositions[i];
				i--;
			}
		}
		if (!suppressCallbacks) { checkCallbacks(); }
		
		// handle events now that everything is complete:
		suppressEvents = tmpSuppressEvents;
		if (onChange != null && !suppressEvents) { onChange(this); }
		if (onComplete != null && !suppressEvents && value >= repeatCount*duration && repeatCount > 0) { onComplete(this); }
		return value;
	}
	
// public methods:
	/**
		Adds a tween to the timeline, which will start playing at the specified start position.
		The tween will play synchronized with the timeline, with all of its behaviours intact (ex. `repeat`, `reflect`)
		except for `delay` (which is accomplished with the `position` parameter instead).
		
		@param position The starting position for this tween in frames or seconds (as per the timing mode of this tween).
		@param tween The GTween instance to add. Note that this can be any subclass of GTween, including another GTweenTimeline.
	**/
	public function addTween(position:Float,tween:GTween):Void {
		if (tween == null || Math.isNaN(position)) { return; }
		tween.autoPlay = false;
		tween.paused = true;
		var index:Int = -1;
		while (++index < tweens.length && tweenStartPositions[index] < position) { }
		tweens.insert(index,tween);
		tweenStartPositions.insert(index,position);
		tween.position = calculatedPosition-position;
	}
	
	/**
		Shortcut method for adding a number of tweens at once.
	
		@param tweens An array of alternating positions and tween instances. For example, the following array would add 3 tweens starting at positions 2, 6, and 8: <code>[2, tween1, 6, tween2, 8, tween3]</code>
	**/
	public function addTweens(tweens:Array<Any>):Void {
		if (tweens == null) { return; }
		var i:Int = 0;
		while (i < tweens.length) {
			var position:Int = tweens[i];
			var tween:GTween = cast(tweens[i+1], GTween);
			addTween(position, tween);
			i+=2;
		}
	}
	
	/**
		Removes the specified tween. Note that this will remove all instances of the tween
		if has been added multiple times to the timeline.
	
		@param tween The GTween instance to remove.
	**/
	public function removeTween(tween:GTween):Void {
		var i:Int = tweens.length;
		while (i>=0) {
			if (tweens[i] == tween) {
				tweens.splice(i,1);
				tweenStartPositions.splice(i,1);
			}
			i--;
		}
	}
	
	/**
		Adds a label at the specified position. You can use `gotoAndPlay` or `gotoAndStop` to jump to labels.
	
		@param position The position to add the label at in frames or seconds (as per the timing mode of this tween).
		@param label The label to add.
	**/
	public function addLabel(position:Float,label:String):Void {
		labels.set(label, position);
	}
	
	/**
		Removes the specified label.
	
		@param label The label to remove.
	**/
	public function removeLabel(label:String):Void {
		labels.remove(label);
	}
	
	/**
		Adds a callback function at the specified position. When the timeline's playhead passes over or lands on the position while playing
		the callback will be called with the parameters specified. You can also optionally specify a callback and parameters to use
		if the timeline is playing in reverse (when reflected for example).
	
		You can add multiple callbacks at a specified position, however it is important to note that they will be played in the same order
		(most recently added first) playing both forwards and in reverse. You can enforce the order they are called in by offsetting the
		callbacks' positions by a tiny amount (ex. one at 2s, and one at 2.001s).
	
		Note that this can be used in conjunction with the static <code>setPropertyValue</code> method to easily set properties on objects in the timeline.
	
		@param labelOrPosition The position or label to add the callback at in frames or seconds (as per the timing mode of this tween).
		@param forwardCallback The function to call when playing forwards.
		@param forwardParameters Optional array of parameters to pass to the callback when it is called when playing forwards.
		@param reverseCallback The function to call when playing in reverse.
		@param reverseParameters Optional array of parameters to pass to the callback when it is called when playing in reverse.
	**/
	public function addCallback(labelOrPosition:Any, forwardCallback:Function, forwardParameters:Array<Any>=null, reverseCallback:Function=null, reverseParameters:Array<Any>=null):Void {
		var position:Float = resolveLabelOrPosition(labelOrPosition);
		if (Math.isNaN(position)) { return; }
		var callback:Callback = new Callback(position, forwardCallback, forwardParameters, reverseCallback, reverseParameters);
		var l:Int = callbacks.length;
		var i:Int = l-1;
		while (i>=0) {
			if (position > callbacks[i].position) { break; }
			i--;
		}
		callbacks.insert(i+1,callback);
	}
	
	
	/**
		Removes the callback(s) at the specified label or position.
	
		@param labelOrPosition The position of the callback(s) to remove in frames or seconds (as per the timing mode of this tween).
	**/
	public function removeCallback(labelOrPosition:Any):Void {
		var position:Float = resolveLabelOrPosition(labelOrPosition);
		if (Math.isNaN(position)) { return; }
		var l:Int = callbacks.length;
		for (i in 0...l) {
			if (position == callbacks[i].position) {
				callbacks.splice(i,1);
			}
		}
	}
	
	/**
		Jumps the timeline to the specified label or numeric position and plays it.
	
		@param labelOrPosition The label name or numeric position in frames or seconds (as per the timing mode of this tween) to jump to.
	**/
	public function gotoAndPlay(labelOrPosition:Any):Void {
		goto(labelOrPosition);
		paused = false;
	}
	
	/**
		Jumps the timeline to the specified label or numeric position and pauses it.
	
		@param labelOrPosition The label name or numeric position in frames or seconds (as per the timing mode of this tween) to jump to.
	**/
	public function gotoAndStop(labelOrPosition:Any):Void {
		goto(labelOrPosition);
		paused = true;
	}
	
	/**
		Jumps the timeline to the specified label or numeric position without affecting its paused state.
	
		@param labelOrPosition The label name or numeric position in frames or seconds (as per the timing mode of this tween) to jump to.
	**/
	public function goto(labelOrPosition:Any):Void {
		var pos:Float = resolveLabelOrPosition(labelOrPosition);
		if (!Math.isNaN(pos)) { position = pos; }
	}
	
	/**
		Returns the position for the specified label. If a numeric position is specified,
		it is returned unchanged.
	
		@param labelOrPosition The label name or numeric position in frames or seconds (as per the timing mode of this tween) to resolve.
	**/
	public function resolveLabelOrPosition(labelOrPosition:Any):Float {
		return (Math.isNaN(labelOrPosition)) ? labels.get(Std.string(labelOrPosition)) : labelOrPosition;
	}
	
	/**
		Calculates and sets the duration of the timeline based on the tweens and callbacks that have been added to it.
	**/
	public function calculateDuration():Void {
		var d:Float = 0;
		if (callbacks.length > 0) {
			d = callbacks[callbacks.length-1].position;
		}
		for (i in 0...tweens.length) {
			if (tweens[i].duration+tweenStartPositions[i] > d) {
				d = tweens[i].duration+tweenStartPositions[i];
			}
		}
		duration = d;
	}
	
// protected methods:
	// checks for callbacks between the previous and current position (inclusive of current, exclusive of previous).
	private function checkCallbacks():Void {
		if (callbacks.length == 0) { return; }
		var repeatIndex:Int = Std.int(_position/duration);
		var previousRepeatIndex:Int = Std.int(positionOld/duration);
		
		if (repeatIndex == previousRepeatIndex || (repeatCount > 0 && _position >= duration*repeatCount)) {
			checkCallbackRange(calculatedPositionOld, calculatedPosition);
		} else {
			// GDS: this doesn't currently support multiple repeats in one tick (ie. more than a single repeat).
			var rev:Bool = (reflect && previousRepeatIndex%2>=1);
			checkCallbackRange(calculatedPositionOld, rev ? 0 : duration);
			rev = (reflect && repeatIndex%2>=1);
			checkCallbackRange(rev ? duration : 0, calculatedPosition, !reflect);
		}
	}
	
	// checks for callbacks between a contiguous start and end position (ie. not broken by repeats).
	private function checkCallbackRange(startPos:Float,endPos:Float,includeStart:Bool=false):Void {
		var sPos:Float = startPos;
		var ePos:Float = endPos;
		var i:Int = -1;
		var j:Int = callbacks.length;
		var k:Int = 1;
		if (startPos > endPos) {
			// running backwards, flip everything:
			sPos = endPos;
			ePos = startPos;
			i = j;
			j = k = -1;
		}
		while ((i+=k) != j) {
			var callback:Callback = callbacks[i];
			var pos:Float = callback.position;
			if ( (pos > sPos && pos < ePos) || (pos == endPos) || (includeStart && pos == startPos) ) {
				if (k == 1) {
					if (callback.forward != null) {
						Reflect.callMethod(this, callback.forward, callback.forwardParams);
					}
				} else {
					if (callback.reverse != null) {
						Reflect.callMethod(this, callback.reverse, callback.reverseParams);
					}
				}
			}
		}
	}
}

private class Callback {
	public var position:Float;
	public var forward:Function;
	public var reverse:Function;
	public var forwardParams:Array<Any>;
	public var reverseParams:Array<Any>;
	
	public function new(position:Float, forward:Function, forwardParams:Array<Any>, reverse:Function, reverseParams:Array<Any>) {
		this.position = position;
		this.forward = forward;
		this.reverse = reverse;
		this.forwardParams = forwardParams;
		this.reverseParams = reverseParams;
	}
	
}