import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweener;
import com.gskinner.motion.plugins.ColorAdjustPlugin;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class GTweenColorAdjust extends Sprite {

// Constants:
	
// Public Properties:
	
// Protected Properties:
	
// Initialization:
	public function new() {
		super();

		var image = new Bitmap(Assets.getBitmapData("assets/bitmap.png"));
		addChild(image);

		ColorAdjustPlugin.install();
		new GTween(image, 3, {saturation:-100, contrast:70}, {repeatCount:0, reflect:true});
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	
}
