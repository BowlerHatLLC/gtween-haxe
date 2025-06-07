/*
InterruptDemo for GTween by Grant Skinner, gskinner.com/blog/

This example demonstrates three concepts:
1) Dynamically creating tweens.
2) Reusing tweens.
3) Interrupting tweens.

Test movie, then click around the stage quickly. Note that you can interrupt
the tween while it is running, and it will attempt to recover appropriately.
*/

import js.Browser;
import com.gskinner.motion.GTween;

class GTweenSpeedDemo {
	public static function main():Void {
		new GTweenSpeedDemo();
	}
	
// Constants:
	
// Public Properties:
	
// Protected Properties:
	
// Initialization:
	public function new() {
		var document = Browser.window.document;

		for (i in 0...5000) {
			var left = 300;
			var top = 300;

			var thing = document.createElement("div");
			thing.style.position = "absolute";
			thing.style.background = "#fff";
			thing.style.width = '1px';
			thing.style.height = '1px';
			thing.style.left = left + "px";
			thing.style.top = top + "px";
			document.body.appendChild(thing);
			
			var delegate = {left: left, top: top, thing: thing};
			var tween:GTween = new GTween(delegate,0.5,{left:Math.random()*600,top:Math.random()*600},{delay:Math.random(),onChange:onChange,onComplete:onComplete});
		}
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
		private function onChange(tween:GTween):Void {
			var delegate = tween.target;
			delegate.thing.style.left = delegate.left + "px";
			delegate.thing.style.top = delegate.top + "px";
		}

		private function onComplete(tween:GTween):Void {
			var delegate:Dynamic = tween.target;
			delegate.left = 300;
			delegate.top = 300;
			var tween:GTween = new GTween(delegate,0.5,{left:Math.random()*600,top:Math.random()*600},{delay:Math.random(),onChange:onChange,onComplete:onComplete});
		}

}