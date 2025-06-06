import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.*;
import com.gskinner.motion.easing.*;

import js.Browser;
import js.html.Document;
import js.html.Element;

class GTweenSimpleSequencing {

	public static function main():Void {
		new GTweenSimpleSequencing();
	}
		
// Constants:
	
// Public Properties:
	public var ball:Element;
	
// Protected Properties:
	
// Initialization:
	public function new() {
		var document = Browser.window.document;

		var radius = 50;

		ball = document.createElement("div");
		ball.style.position = "absolute";
		ball.style.background = "red";
		ball.style.width = '${radius*2}px';
		ball.style.height = '${radius*2}px';
		ball.style.marginLeft = '-${radius}px';
		ball.style.marginTop = '-${radius}px';
		ball.style.left = '${radius}px';
		ball.style.top = '${radius}px';
		ball.style.borderRadius = "50%";
		document.body.appendChild(ball);

		var delegate = {left: radius, top: radius};
		function onChange():Void {
			ball.style.left = delegate.left + "px";
			ball.style.top = delegate.top + "px";
		}
		
		var tween4:GTween = new GTween(delegate, 0.4, {top:50}, {autoPlay:false,delay:0.5,ease:Sine.easeInOut,onChange:onChange});
		var tween3:GTween = new GTween(delegate, 0.4, {left:50}, {autoPlay:false,nextTween:tween4,delay:0.5,ease:Sine.easeInOut,onChange:onChange});
		var tween2:GTween = new GTween(delegate, 0.4, {top:350}, {autoPlay:false,nextTween:tween3,delay:0.5,ease:Sine.easeInOut,onChange:onChange});
		var tween1:GTween = new GTween(delegate, 0.5, {left:500}, {nextTween:tween2,delay:0.5,ease:Sine.easeInOut,onChange:onChange});
		tween4.nextTween = tween1;
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	
}
