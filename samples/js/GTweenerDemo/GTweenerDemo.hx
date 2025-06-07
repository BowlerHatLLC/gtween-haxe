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
import js.html.Element;
import js.html.MouseEvent;
import com.gskinner.motion.GTweener;

class GTweenerDemo {
	public static function main():Void {
		new GTweenerDemo();
	}
	
// Constants:
	
// Public Properties:
	
// Protected Properties:
	private var ball:Element;
	private var delegate:Dynamic;
	
// Initialization:
	public function new() {
		var document = Browser.window.document;

		ball = document.createElement("div");
		ball.style.position = "absolute";
		ball.style.background = "#000";
		ball.style.borderRadius = "50%";
		var radius = 40;
		ball.style.width = '${2*radius}px';
		ball.style.height = '${2*radius}px';
		var left = 130;
		var top = 80;
		ball.style.left = '${left}px';
		ball.style.top = '${top}px';
		document.body.appendChild(ball);

		delegate = {left: left, top: top};
		function onChange(tween:GTweener):Void {
			ball.style.left = delegate.left + "px";
			ball.style.top = delegate.top + "px";
		}

		GTweener.to(delegate, 2, {left:200, top:350}, {repeatCount:0, reflect:true, onChange:onChange});
		
		Browser.window.addEventListener("click",handleClick);
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:

	private function handleClick(evt:MouseEvent):Void {
		GTweener.to(delegate, 0.4, {left: evt.clientX});
	}
}