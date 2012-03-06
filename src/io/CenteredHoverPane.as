package io
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class CenteredHoverPane extends Sprite
	{
		private var backGround:Sprite = new Sprite;
		private var stageRef:Stage;
		
		protected var headStyle:TextFormat = new TextFormat("BBAlpha Sans", 40, 0xcccccc, false, false, false, "", "", TextFormatAlign.LEFT);
		protected var bodyStyle:TextFormat = new TextFormat("BBAlpha Sans", 25, 0xeeeeee, false, false, false, "", "", TextFormatAlign.LEFT);
		public function CenteredHoverPane(x:int, y:int, alpha:Number, stageRef:Stage)
		{
			super();
			this.stageRef = stageRef;
			this.x = stageRef.stageWidth / 2;
			this.y = stageRef.stageHeight / 2;
			backGround.graphics.beginFill(0x000000, alpha);
			backGround.graphics.drawRoundRect(-x / 2, -y / 2, x, y, 30, 30);
			addChild(backGround);
		}
	}
}