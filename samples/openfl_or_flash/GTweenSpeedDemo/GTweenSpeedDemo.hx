
import com.gskinner.motion.GTween;

import flash.display.MovieClip;
import flash.display.Shape;

class GTweenSpeedDemo extends MovieClip {

	public static function main():Void {
		flash.Lib.current.stage.addChild(new GTweenSpeedDemo());
	}
		
// Constants:
	
// Public Properties:
	
// Protected Properties:
	
// Initialization:
	public function new() {
		super();

		for (i in 0...5000) {
			var thing:Shape = new Shape();
			thing.graphics.beginFill(0xffffff);
			thing.graphics.drawRect(0, 0, 1, 1);
			thing.graphics.endFill();
			thing.x = thing.y = 300;
			addChild(thing);
			var tween:GTween = new GTween(thing,0.5,{x:Math.random()*600,y:Math.random()*600},{delay:Math.random(),onComplete:onComplete});
		}

		#if openfl
		var fps = new openfl.display.FPS();
		fps.defaultTextFormat = new openfl.text.TextFormat("_sans", 12, 0xffffff);
		addChild(fps);
		#end
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
		private function onComplete(tween:GTween):Void {
			var targ:Shape = cast(tween.target, Shape);
			targ.x = targ.y = 300;
			var tween:GTween = new GTween(targ,0.5,{x:Math.random()*600,y:Math.random()*600},{delay:Math.random(),onComplete:onComplete});
		}
	
}
