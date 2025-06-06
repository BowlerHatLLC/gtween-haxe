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
import js.html.MouseEvent;
import com.gskinner.motion.GTween;
import com.gskinner.motion.easing.*;

class GTweenInterrupt {
	public static function main():Void {
		new GTweenInterrupt();
	}
	
// Constants:
	
// Public Properties:
	
// Protected Properties:
	private var tweens:Array<GTween> = [];
	
// Initialization:
	public function new() {
		var document = Browser.window.document;

		// draw a bunch of circles, and set up tweens for them:
		for (i in 0...25) {
			var left = Math.random()*550;
			var top = Math.random()*400;

			// draw the circle, and put it on stage:
			var circle = document.createElement("div");
			circle.style.position = "absolute";
			circle.style.border = "solid 15px #113355";
			circle.style.borderRadius = "50%";
			circle.style.opacity = Std.string(1-i*0.02);
			circle.style.mixBlendMode = "screen";
			var radius = (i+1)*4;
			circle.style.width = '${2*radius}px';
			circle.style.height = '${2*radius}px';
			circle.style.marginLeft = '-${radius}px';
			circle.style.marginTop = '-${radius}px';
			circle.style.left = left + "px";
			circle.style.top = top + "px";
			document.body.appendChild(circle);
			
			// set up a tween for each circle (initially tweening to the center):
			var delegate = {left: left, top: top, circle: circle};
			function onChange(tween:GTween):Void {
				var delegate = tween.target;
				delegate.circle.style.left = delegate.left + "px";
				delegate.circle.style.top = delegate.top + "px";
			}
			var circleTween:GTween = new GTween(delegate,0.5+i*0.04,{left:275,top:200},{ease:Bounce.easeOut,onChange:onChange});
			tweens.push(circleTween);
		}
		
		Browser.window.addEventListener("click",handleClick);
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:

	private function handleClick(evt:MouseEvent):Void {
		// update each tween with the new end property values.
		// note that I didn't create a new tween object, but reused the existing one instead.
		for (i in 0...tweens.length) {
			tweens[i].setValues({left:evt.clientX,top:evt.clientY});
		}
	}
}