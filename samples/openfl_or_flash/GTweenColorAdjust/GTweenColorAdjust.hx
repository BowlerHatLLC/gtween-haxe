import flash.display.Bitmap;
import flash.display.BitmapData;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweener;
import com.gskinner.motion.plugins.ColorAdjustPlugin;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

class GTweenColorAdjust extends MovieClip {

	public static function main():Void {
		flash.Lib.current.stage.addChild(new GTweenColorAdjust());
	}
		
// Constants:
	
// Public Properties:
	
// Protected Properties:
	
// Initialization:
	public function new() {
		super();

		var image = new Bitmap(new EmbeddedBitmapData(0, 0));
		addChild(image);

		ColorAdjustPlugin.install();
		new GTween(image, 3, {saturation:-100, contrast:70}, {repeatCount:0, reflect:true});
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	
}

@:bitmap("bitmap.png")
private class EmbeddedBitmapData extends BitmapData {}