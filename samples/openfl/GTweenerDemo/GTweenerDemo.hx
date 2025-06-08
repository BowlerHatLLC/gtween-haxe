import com.gskinner.motion.GTweener;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class GTweenerDemo extends Sprite {

// Constants:
	
// Public Properties:
	public var ball:Sprite;
	
// Protected Properties:
	
// Initialization:
	public function new() {
		super();

		ball = new Sprite();
		ball.graphics.beginFill(0x000000);
		ball.graphics.drawCircle(40, 40, 40);
		ball.graphics.endFill();
		ball.x = 130;
		ball.y = 80;
		addChild(ball);

		GTweener.to(ball, 2, {x:200, y:350}, {repeatCount:0, reflect:true});

		stage.addEventListener(MouseEvent.CLICK, handleClick);
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:

	private function handleClick(evt:MouseEvent):Void {
		GTweener.to(ball, 0.4, {x: mouseX});
	}
}
