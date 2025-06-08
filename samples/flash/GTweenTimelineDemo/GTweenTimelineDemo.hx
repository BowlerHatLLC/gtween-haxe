import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import com.gskinner.motion.plugins.*;
import com.gskinner.motion.easing.*;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

class GTweenTimelineDemo extends MovieClip {

	public static function main():Void {
		flash.Lib.current.stage.addChild(new GTweenTimelineDemo());
	}
		
// Constants:
	
// Public Properties:
	
// Protected Properties:
	private var timeline:GTweenTimeline;

	private var pod:Sprite;
	private var title:TextField;
	private var buttons:Array<Sprite> = [];
	private var newsPanel:Sprite;
	private var tickerPanel:Sprite;
	private var news:TextField;
	private var ticker:TextField;
	private var spinner:Sprite;
	
// Initialization:
	public function new() {
		super();
		// install the motion blur plugin:
		MotionBlurPlugin.install();
		
		// exaggerate the motion blur effect:
		MotionBlurPlugin.strength = 2;

		createChildren();
			
		// create the timeline:
		timeline = new GTweenTimeline(null,0,null,{repeatCount:0,ease:Bounce.easeOut,reflect:true});
		
		// note that these tweens could easily be created in a single line, but are expanded
		// to show different approaches.
		var tween:GTween = new GTween(pod,1,{scaleX:0,scaleY:0},{ease:Circular.easeOut});
		tween.setValue("x", pod.y+pod.width/2);
		tween.setValue("y", pod.x+pod.height/2);
		// swap the values so it tweens from the specified location to it's current location:
		tween.swapValues();
		timeline.addTween(0,tween);
		
		// notice that this tween has the repeatCount set to 0, so it will repeat indefinitely:
		tween = new GTween(spinner,1,{rotation:-360},{repeatCount:0,reflect:false});
		timeline.addTween(1,tween);
		
		// likewise, tweens can be created and added to a timeline in a single line:
		tween = new GTween(spinner,2,{alpha:0},{swapValues:true});
		timeline.addTween(1,tween);
		
		tween = new GTween(title,0.6,{alpha:0},{ease:Circular.easeOut});
		tween.setValue("x", title.x+100);
		tween.swapValues();
		timeline.addTween(0.9,tween);
		
		tween = new GTween(newsPanel,0.5,{height:1,alpha:0},{ease:Circular.easeOut, swapValues:true});
		timeline.addTween(1.4,tween);
		
		tween = new GTween(tickerPanel,0.8,{width:1,alpha:0},{ease:Circular.easeOut, swapValues:true});
		timeline.addTween(1.6,tween);
		
		tween = new GTween(ticker,2,{alpha:0},{swapValues:true});
		timeline.addTween(2.2,tween);
		
		tween = new GTween(news,1,{alpha:0},{swapValues:true});
		timeline.addTween(4,tween);
		
		for (i in 0...6) {
			var btn = getChildByName("btn"+i);
			tween = new GTween(btn,0.4,{alpha:0,scaleY:4},{ease:Circular.easeOut});
			tween.setValue("y", btn.y-120);
			tween.swapValues();
			timeline.addTween(3.2-i*0.1,tween);
			
			// for these tweens, we will turn on motion blur. Motion blur is one of the few
			// plugins that defaults to enabled=false. We need to override that by setting
			// MotionBlurEnabled to true in the pluginData.
			tween = new GTween(getChildByName("label"+i),0.6,{alpha:0,x:100},{ease:Circular.easeOut,swapValues:true},{MotionBlurEnabled:true});
			timeline.addTween(3.6-i*0.1,tween);
		}
			
		// change the visibility of the page numbers using addCallback, and setPropertyValue:
		// we'll be a little tricky here, and have put show/hide actions back to back,
		// so that they show going forwards, and hide going backwards.
		for (i in 1...4) {
			var pageObj:TextField = cast(getChildByName("page"+i), TextField);
			timeline.addCallback(5.0+i*0.15,GTweenTimeline.setPropertyValue,[pageObj,"visible",true],GTweenTimeline.setPropertyValue,[pageObj,"visible",false]);
			// start out the page numbers with visible= false;
			pageObj.visible = false;
		}
			
		// calculate the timeline duration based on all the tweens and callbacks:
		timeline.calculateDuration();
		// add a little bit of extra time on the end, so there's time to see the last page number come in before it reflects:
		timeline.duration += 0.5;
	}
	
// Public getter / setters:
	
// Public Methods:
	
// Protected Methods:
	private function createChildren():Void {
		pod = new Sprite();
		pod.graphics.lineStyle(1.0, 0x6A6A6A);
		var matrix = new Matrix();
		matrix.createGradientBox(500, 350, 90 * Math.PI / 180);
		pod.graphics.beginGradientFill(LINEAR, [0x1D2727, 0x1E1E1E, 0x0D0D0D], [1.0, 1.0, 1.0], [0x00, 0x33, 0xff], matrix);
		pod.graphics.drawRoundRect(0, 0, 500, 350, 10);
		pod.graphics.endFill();
		pod.x = 25;
		pod.y = 25;
		addChild(pod);

		title = new TextField();
		title.autoSize = LEFT;
		title.defaultTextFormat = new TextFormat("_sans", 36, 0x00CCFF);
		title.text = "Breaking News";
		title.x = 36;
		title.y = 34;
		addChild(title);

		spinner = new Sprite();
		spinner.graphics.lineStyle(1, 0x666666);
		var numLines = 8;
		for (i in 0...numLines) {
			spinner.graphics.moveTo(0, 0);
			var p = Point.polar(10, i*2*Math.PI/(numLines-1));
			spinner.graphics.lineTo(p.x, p.y);
		}
		spinner.x = 500;
		spinner.y = 54;
		addChild(spinner);

		createButton("Top Stories", 35, 90);
		createButton("World", 35, 130);
		createButton("Politics", 35, 170);
		createButton("Crime", 35, 210);
		createButton("Entertainment", 35, 250);
		createButton("Tech", 35, 290);

		newsPanel = new Sprite();
		newsPanel.graphics.lineStyle(1.0, 0x373737);
		newsPanel.graphics.beginFill(0x1E1E1E);
		newsPanel.graphics.drawRoundRect(0, 0, 300, 238, 10);
		newsPanel.graphics.endFill();
		newsPanel.x = 215;
		newsPanel.y = 90;
		addChild(newsPanel);

		tickerPanel = new Sprite();
		tickerPanel.graphics.lineStyle(1.0, 0x373737);
		tickerPanel.graphics.beginFill(0x1E1E1E);
		tickerPanel.graphics.drawRoundRect(0, 0, 480, 30, 10);
		tickerPanel.graphics.endFill();
		tickerPanel.x = 35;
		tickerPanel.y = 334;
		addChild(tickerPanel);

		news = new TextField();
		news.defaultTextFormat = new TextFormat("_sans", 14, 0xCCCCCC);
		news.multiline = true;
		news.wordWrap = true;
		news.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
		news.x = 224;
		news.y = 97;
		news.width = 283;
		news.height = 230;
		addChild(news);

		ticker = new TextField();
		ticker.defaultTextFormat = new TextFormat("_sans", 12, 0x666666);
		ticker.text = "are your kids safe? story at 11 - local dog wins election, in hot water for biting sheriff";
		ticker.x = 42;
		ticker.y = 340;
		ticker.width = 467;
		ticker.height = 32;
		addChild(ticker);
		
		var pageX = 462.0;
		for (i in 1...4) {
			var page = new TextField();
			page.name = "page" + i;
			page.autoSize = LEFT;
			page.selectable = false;
			page.defaultTextFormat = new TextFormat("_sans", 18, 0x00CCFF);
			page.text = Std.string(i);
			page.x = pageX;
			page.y = 298;
			addChild(page);
			pageX += 15;
		}
	}

	private function createButton(text:String, x:Float, y:Float):Void {
		var button = new Sprite();
		button.name = "btn" + buttons.length;
		var matrix = new Matrix();
		matrix.createGradientBox(175, 35, 90 * Math.PI / 180);
		button.graphics.beginGradientFill(LINEAR, [0x293134, 0x0D0D0D, 0x151515], [1.0, 1.0, 1.0], [0x00, 0x33, 0xff], matrix);
		button.graphics.drawRoundRect(0, 0, 175, 35, 10);
		button.graphics.endFill();
		button.x = x;
		button.y = y;
		button.buttonMode = true;
		button.mouseChildren = false;
		addChild(button);

		var label = new TextField();
		label.name = "label" + buttons.length;
		label.autoSize = LEFT;
		label.defaultTextFormat = new TextFormat("_sans", 20, 0x999999);
		label.text = text;
		label.selectable = false;
		label.x = button.x + (button.width - label.width) / 2;
		label.y = button.y + (button.height - label.height) / 2;
		addChild(label);
		
		buttons.push(button);
	}
	
}
