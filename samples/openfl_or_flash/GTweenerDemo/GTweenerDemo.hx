import flash.events.Event;
import com.gskinner.motion.GTweener;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;

class GTweenerDemo extends MovieClip {

	public static function main():Void {
		flash.Lib.current.stage.addChild(new GTweenerDemo());
	}
		
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

		addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	private function handleAddedToStage(evt:Event):Void {
		stage.addEventListener(MouseEvent.CLICK, handleClick);
	}

	private function handleClick(evt:MouseEvent):Void {
		GTweener.to(ball, 0.4, {x: mouseX});
	}
	
}
