import com.gskinner.motion.GTween;
import com.gskinner.motion.plugins.*;
import com.gskinner.motion.easing.*;

import openfl.display.Sprite;

class GTweenSimpleSequencing extends Sprite {

// Constants:
	
// Public Properties:
	public var ball:Sprite;
	
// Protected Properties:
	
// Initialization:
	public function new() {
		super();

		ball = new Sprite();
		ball.graphics.beginFill(0xff0000);
		ball.graphics.drawCircle(0, 0, 50);
		ball.graphics.endFill();
		ball.x = 50;
		ball.y = 50;
		addChild(ball);

		MotionBlurPlugin.install();

		// MotionBlurPlugin is the only plugin that has enabled set to false by default.
		// Instead of setting MotionBlurEnabled on pluginData for all of the tweens
		// you could enable it by default for all tweens with:
		// MotionBlurPlugin.enabled = true;
		
		var tween4:GTween = new GTween(ball,0.4, {y:50}, {autoPlay:false,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
		var tween3:GTween = new GTween(ball,0.4, {x:50}, {autoPlay:false,nextTween:tween4,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
		var tween2:GTween = new GTween(ball,0.4, {y:350}, {autoPlay:false,nextTween:tween3,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
		var tween1:GTween = new GTween(ball,0.5, {x:500}, {nextTween:tween2,delay:0.5,ease:Sine.easeInOut}, {MotionBlurEnabled:true});
		tween4.nextTween = tween1;
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	
}
