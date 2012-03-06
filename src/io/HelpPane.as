package io
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class HelpPane extends CenteredHoverPane
	{
		private var bgLoader:Loader = new Loader();
		private var bg:Sprite = new Sprite();
		private var step1_head:TextField = new TextField();
		private var step1_body:TextField = new TextField();
		private var step2_head:TextField = new TextField();
		private var step2_body:TextField = new TextField();
		private var exitHelp:TextField = new TextField();
		
		public function HelpPane(stageRef:Stage)
		{
			super(900, 700, 0.75, stageRef);
			bg.x = -450;
			bg.y = -130;
			bgLoader.load(new URLRequest("helpPane.png"));
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
		}
		private function init(event:Event):void
		{
			var bgFill:BitmapData = new BitmapData(bgLoader.width, bgLoader.height, true, 0x00FFFFFF);
			bgFill.draw(bgLoader);
			var myMatrix:Matrix = new Matrix();
			//myMatrix.translate(-450, -150);
			bg.graphics.beginBitmapFill(bgFill, myMatrix, false, true);
			bg.graphics.drawRect(0, 0, 900, 500);
			addChild(bg);
			
			step1_head.autoSize = TextFieldAutoSize.LEFT;
			step1_head.x = -400;
			step1_head.y = -150;
			step1_head.text = "Step 1:";
			step1_head.setTextFormat(headStyle);
			addChild(step1_head);
			
			step1_body.autoSize = TextFieldAutoSize.LEFT;
			step1_body.x = -400;
			step1_body.y = -90;
			step1_body.text = "Turn the ring to adjust\n"
				+ "the amount of money on\n"
				+ "the bill, then tap the\n"
				+ "center to start splitting!";
			step1_body.setTextFormat(bodyStyle);
			addChild(step1_body);
			
			step2_head.autoSize = TextFieldAutoSize.LEFT;
			step2_head.x = 45;
			step2_head.y = -150;
			step2_head.text = "Step 2:";
			step2_head.setTextFormat(headStyle);
			addChild(step2_head);
			
			step2_body.autoSize = TextFieldAutoSize.LEFT;
			step2_body.x = 45;
			step2_body.y = -90;
			step2_body.text = "Everyone who wants to\n"
				+ "pay can pull out a node\n"
				+ "from the center...\n"
				+ "BouncyBill will do the math!";
			step2_body.setTextFormat(bodyStyle);
			addChild(step2_body);
			
			exitHelp.autoSize = TextFieldAutoSize.CENTER;
			exitHelp.y = 315;
			exitHelp.x = 0;
			exitHelp.text = "Tap anywhere to continue.";
			exitHelp.setTextFormat(new TextFormat("BBAlpha Sans", 18, 0x888888, false, false, false, "", "", TextFormatAlign.CENTER));
			addChild(exitHelp);
			
			
			bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, init);
		}
	}
}