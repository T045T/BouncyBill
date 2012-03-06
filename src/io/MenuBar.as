package io
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import qnx.ui.buttons.LabelButton;
	import qnx.ui.skins.SkinStates;
	import qnx.ui.skins.buttons.TransparentButtonSkin;
	
	public class MenuBar extends Sprite
	{
		public var restart:LabelButton = new LabelButton();
		public var about:LabelButton = new LabelButton();
		public var help:LabelButton = new LabelButton();
		private var banner:LabelButton = new LabelButton();
		private var filler:LabelButton = new LabelButton();
		private var bgLoader:Loader = new Loader();
		private var buttonsUpFormat:TextFormat = new TextFormat("BBAlpha Sans", 22, 0x888888, false, false, false, "", "", TextFormatAlign.CENTER);
		private var buttonsDownFormat:TextFormat = new TextFormat("BBAlpha Sans", 22, 0x333333, false, false, false, "", "", TextFormatAlign.CENTER);
		
		
		public function MenuBar()
		{
			super();
			banner.setSkin(TransparentButtonSkin);
			banner.setTextFormatForState(new TextFormat("BBAlpha Sans", 37, 0x888888, false, false, false, "", "", TextFormatAlign.LEFT), SkinStates.UP);
			banner.setTextFormatForState(new TextFormat("BBAlpha Sans", 37, 0x888888, false, false, false, "", "", TextFormatAlign.LEFT), SkinStates.DOWN);
			
			restart.setSkin(TransparentButtonSkin);
			restart.setTextFormatForState(buttonsUpFormat, SkinStates.UP);
			restart.setTextFormatForState(buttonsDownFormat, SkinStates.DOWN)
				
			about.setSkin(TransparentButtonSkin);
			about.setTextFormatForState(buttonsUpFormat, SkinStates.UP);
			about.setTextFormatForState(buttonsDownFormat, SkinStates.DOWN)
				
			help.setSkin(TransparentButtonSkin);
			help.setTextFormatForState(buttonsUpFormat, SkinStates.UP);
			help.setTextFormatForState(buttonsDownFormat, SkinStates.DOWN)
			
			filler.setSkin(TransparentButtonSkin);
			filler.setTextFormatForState(buttonsUpFormat, SkinStates.UP);
			filler.setTextFormatForState(buttonsDownFormat, SkinStates.DOWN)
			
			bgLoader.load(new URLRequest("menuBar.png"));
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgInit);
			banner.setSize(400, 50);
			banner.label = "BouncyBill";
			restart.x = 400;
			restart.setSize(150, 50);
			restart.label = "Start Over";
			help.x = 550;
			help.setSize(150, 50);
			help.label = "Help";
			about.x = 700;
			about.setSize(150, 50);
			about.label = "About"
			filler.x = 850;
			filler.setSize(174, 50);
			filler.label = "";
			addChild(banner);
			addChild(restart);
			addChild(help);
			addChild(about);
			addChild(filler);
			
		}
		private function bgInit(event:Event):void
		{
			var bgFill:BitmapData = new BitmapData(bgLoader.width, bgLoader.height, true, 0x00FFFFFF);
			bgFill.draw(bgLoader);
			var myMatrix:Matrix = new Matrix();
			//myMatrix.translate(0, -70);
			this.graphics.beginBitmapFill(bgFill, myMatrix, false, true);
			this.graphics.drawRect(0, 0, 1024, 50);
			
			bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bgInit);
		}
	}
}