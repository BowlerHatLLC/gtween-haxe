/*
InterruptDemo for GTween by Grant Skinner, gskinner.com/blog/

This example demonstrates three concepts:
1) Dynamically creating tweens.
2) Reusing tweens.
3) Interrupting tweens.

Test movie, then click around the stage quickly. Note that you can interrupt
the tween while it is running, and it will attempt to recover appropriately.
*/

import com.gskinner.motion.GTween;
import com.gskinner.motion.easing.*;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class GTweenInterrupt extends Sprite {

// Constants:
	
// Public Properties:
	
// Protected Properties:
	private var tweens:Array<GTween> = [];
	
// Initialization:
	public function new() {
		super();

		// draw a bunch of circles, and set up tweens for them:
		for (i in 0...25) {
			// draw the circle, and put it on stage:
			var circle:Shape = new Shape();
			circle.graphics.lineStyle(15,0x113355,1-i*0.02);
			circle.graphics.drawCircle(0,0,(i+1)*4);
			circle.x = Math.random()*550;
			circle.y = Math.random()*400;
			circle.blendMode = ADD;
			addChild(circle);
			
			// set up a tween for each circle (initially tweening to the center):
			var circleTween:GTween = new GTween(circle,0.5+i*0.04,{x:275,y:200},{ease:Bounce.easeOut});
			tweens.push(circleTween);
		}
		
		stage.addEventListener(MouseEvent.CLICK,handleClick);
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:

	private function handleClick(evt:MouseEvent):Void {
		// update each tween with the new end property values.
		// note that I didn't create a new tween object, but reused the existing one instead.
		for (i in 0...tweens.length) {
			tweens[i].setValues({x:mouseX,y:mouseY});
		}
	}
}