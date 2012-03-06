/**
 * BouncyBill
 * A bill splitting app for the BlackBerry PlayBook
 *
 * @author Nils Berg
 * @version 1.0
 */

package
{
	import caurina.transitions.Tweener;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import io.*;
	
	import qnx.events.QNXApplicationEvent;
	import qnx.system.QNXApplication;
	
	[SWF(width="1024", height="600", backgroundColor="#000000", frameRate="30")]
	
	public class BouncyBill extends Sprite
	{
		private var btns:Dictionary = new Dictionary();
		private var count:int = 0;
		private var rot:CentralRotaryDisplay;
		private var lastPressed:MovableButton;
		private var bgLoader:Loader = new Loader;
		private var backGround:Sprite = new Sprite;
		private var lines:Sprite = new Sprite;
		private var centerDisc:Sprite = new Sprite;
		private var menuBar:MenuBar = new MenuBar;
		private var helpPane:HelpPane;
		private var aboutPane:AboutPane;

		public function BouncyBill()
		{
			super();
			// support autoOrients
			QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.SWIPE_DOWN, showMenu);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			this.helpPane = new HelpPane(stage);
			this.aboutPane = new AboutPane(stage);
			
			bgLoader.load(new URLRequest("background.png"));
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
			
			/*
			var but1:Sprite = new Sprite();
			but1.graphics.lineStyle(4);
			but1.graphics.beginFill(0x000000);
			but1.graphics.drawRect(10,10,60,40);
			but1.addEventListener(MouseEvent.MOUSE_DOWN, function(foo:Event):void {rot.removeEventListener(MouseEvent.MOUSE_DOWN, centerClick); cleanAndSwitch(1)});
			var but2:Sprite = new Sprite();
			but2.graphics.lineStyle(4);
			but2.graphics.beginFill(0x000000);
			but2.graphics.drawRect(80,10,60,40);
			but2.addEventListener(MouseEvent.MOUSE_DOWN, function(foo:Event):void {rot.changeMode(4); rot.addEventListener(MouseEvent.MOUSE_DOWN, centerClick)});
			addChild(but1);
			addChild(but2);
			*/
			//rot.addEventListener(MouseEvent.MOUSE_DOWN, centerClick);
			//rot.addEventListener(MouseEvent.MOUSE_UP, centerUp);
		}
		
		private function firstClick(event:MouseEvent):void
		{
			rot.changeMode(4);
			centerDisc.addEventListener(MouseEvent.MOUSE_DOWN, centerClick);
			centerDisc.addEventListener(MouseEvent.MOUSE_UP, centerUp);
		}
		private function showMenu(event:QNXApplicationEvent):void
		{
			menuBar.y = -50;
			addChild(menuBar);
			Tweener.addTween(menuBar, {y:0 , time:0.2, onComplete:function():void {
				menuBar.restart.addEventListener(MouseEvent.MOUSE_DOWN, reset);
				menuBar.help.addEventListener(MouseEvent.MOUSE_DOWN, showHelp);
				menuBar.about.addEventListener(MouseEvent.MOUSE_DOWN, showAbout);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, maybeHideMenu);
			}});
		}
		private function maybeHideMenu(event:MouseEvent):void
		{
			if (event.stageY > 55)
			{
				Tweener.addTween(menuBar, {y: -50, time:0.2, onComplete:function():void {
					menuBar.restart.removeEventListener(MouseEvent.MOUSE_DOWN, reset);
					menuBar.help.removeEventListener(MouseEvent.MOUSE_DOWN, showHelp);
					menuBar.about.removeEventListener(MouseEvent.MOUSE_DOWN, showAbout);
					parent.removeChild(menuBar);
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, maybeHideMenu);
				}});
			}
		}
		private function reset(event:MouseEvent):void
		{
			Tweener.addTween(menuBar, {y: -50, time:0.2, transition:"easeInCubic", onComplete:function():void {
				menuBar.restart.removeEventListener(MouseEvent.MOUSE_DOWN, reset);
				menuBar.help.removeEventListener(MouseEvent.MOUSE_DOWN, showHelp);
				menuBar.about.removeEventListener(MouseEvent.MOUSE_DOWN, showAbout);
				removeChild(menuBar);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, maybeHideMenu);
			}});
			rot.resetMoney();
			cleanAndSwitch(1);
			
			centerDisc.removeEventListener(MouseEvent.MOUSE_DOWN, centerClick);
			centerDisc.removeEventListener(MouseEvent.MOUSE_UP, centerUp);
			centerDisc.addEventListener(MouseEvent.MOUSE_DOWN, firstClick);

		}
		private function showHelp(event:MouseEvent):void
		{
			helpPane.y = -350;
			addChild(helpPane);
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, maybeHideMenu);
			Tweener.addTween(helpPane, {y:200, time:1.4, transition:"easeOutBounce", onComplete:function():void {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, hideHelp)}});
		}
		private function hideHelp(event:MouseEvent):void
		{
			Tweener.addTween(helpPane, {y:-350, time:0.8, transition:"easeInCubic", onComplete:function():void {
				removeChild(helpPane)}});
			Tweener.addTween(menuBar, {y: -50, time:0.2, transition:"easeInCubic", onComplete:function():void {
				menuBar.restart.removeEventListener(MouseEvent.MOUSE_DOWN, reset);
				menuBar.help.removeEventListener(MouseEvent.MOUSE_DOWN, showHelp);
				menuBar.about.removeEventListener(MouseEvent.MOUSE_DOWN, showAbout);
				removeChild(menuBar);
			}});
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, hideHelp);
		}
		private function showAbout(event:MouseEvent):void
		{
			aboutPane.y = -150;
			addChild(aboutPane);
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, maybeHideMenu);
			Tweener.addTween(aboutPane, {y:100, time:1, transition:"easeOutBounce", onComplete:function():void {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, hideAbout)}});
		}
		private function hideAbout(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, hideAbout);
			Tweener.addTween(aboutPane, {y:-150, time:0.6, transition:"easeInCubic", onComplete:function():void {
				removeChild(aboutPane)}});
			Tweener.addTween(menuBar, {y: -50, time:0.2, transition:"easeInCubic", onComplete:function():void {
				menuBar.restart.removeEventListener(MouseEvent.MOUSE_DOWN, reset);
				menuBar.help.removeEventListener(MouseEvent.MOUSE_DOWN, showHelp);
				menuBar.about.removeEventListener(MouseEvent.MOUSE_DOWN, showAbout);
				removeChild(menuBar);
			}});
		}
		private function drawNodeLines(event:Event):void
		{
			lines.graphics.clear();
			lines.graphics.lineStyle(4, 0x000000);
			for each (var btn:MovableButton in btns)
			{
				lines.graphics.moveTo(stage.stageWidth / 2, stage.stageHeight / 2);
				lines.graphics.lineTo(btn.x, btn.y);
			}
		}
		private function init(event:Event):void
		{
			var bgFill:BitmapData = new BitmapData(bgLoader.width, bgLoader.height, true, 0x00FFFFFF);
			bgFill.draw(bgLoader);
			var myMatrix:Matrix = new Matrix();
			//myMatrix.translate(-150, -150);
			backGround.graphics.beginBitmapFill(bgFill, myMatrix, false, true);
			backGround.graphics.drawRect(0,0, 1024, 600);
			addChildAt(backGround, 0);
			lines.graphics.lineStyle(4, 0x000000);
			addChildAt(lines, 1);
			rot = new CentralRotaryDisplay(btns, stage);
			addChildAt(rot, 2);
			centerDisc.graphics.beginFill(0x000000, 0.0001);
			centerDisc.graphics.drawCircle(stage.stageWidth / 2, stage.stageHeight / 2, 105);
			addChild(centerDisc);
			
			rot.changeMode(1);
			centerDisc.addEventListener(MouseEvent.MOUSE_DOWN, firstClick);
			stage.addEventListener(Event.ENTER_FRAME, drawNodeLines);
			bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, init);
		}
		public function centerClick(event:MouseEvent):void
		{
			centerDisc.addEventListener(MouseEvent.MOUSE_OUT, createBtn);
		}
		public function centerUp(event:MouseEvent):void
		{
			centerDisc.removeEventListener(MouseEvent.MOUSE_OUT, createBtn);
			centerDisc.removeEventListener(MouseEvent.MOUSE_OVER, falseAlarm);
		}
		public function createBtn(event:MouseEvent):void
		{
			btns[count] = new MovableButton(stage.stageWidth / 2, stage.stageHeight / 2, count, stage, (rot.getMoney() / (this.countButtons() + 1)));
			var tmpBtn:MovableButton = btns[count];
			addChildAt(tmpBtn, 2);
			updateButtons();
			Tweener.addTween(tmpBtn, {scaleX:1, scaleY:1, x:event.stageX, y:event.stageY, time:0.15, transition:"easeInQuad"});
			stage.addEventListener(MouseEvent.MOUSE_UP, centerUp);
			tmpBtn.addEventListener(MouseEvent.MOUSE_DOWN, prepareRemoval);
			lastPressed = btns[count];
			count++;
			centerDisc.removeEventListener(MouseEvent.MOUSE_OUT, createBtn);
			centerDisc.addEventListener(MouseEvent.MOUSE_OVER, falseAlarm, false, 2);
		}
		private function updateButtons():void
		{
			for each (var btn:MovableButton in btns)
			{
				btn.setMoney(rot.getMoney() / this.countButtons());
			}
			var modulo:int = rot.getMoney() % this.countButtons();
			while (modulo > 0)
			{
				for each (var btn2:MovableButton in btns)
				{
					if (modulo > 0)
					{
						modulo --
							btn2.setMoney(btn2.getMoney() + 1);
					}
				}
			}
		}
		private function countButtons():Number
		{
			var output:Number = 0;
			for each (var btn:MovableButton in btns)
			{
				output++;
			}
			return output;
		}
		public function prepareRemoval(event:MouseEvent):void
		{
			var foo:MovableButton;
			if (event.target is MovableButton)
			{
				foo = event.target as MovableButton;
			}
			else {
				foo = event.target.parent as MovableButton;
			}
			lastPressed = foo;
			centerDisc.addEventListener(MouseEvent.MOUSE_OVER, falseAlarm, false, 2);
		}
		public function falseAlarm(event:MouseEvent):void
		{
			btns[lastPressed.getID()].fadeRemove(stage.stageWidth / 2, stage.stageHeight / 2, 0.2);
			delete btns[lastPressed.getID()];
			updateButtons();
			centerDisc.removeEventListener(MouseEvent.MOUSE_OVER, falseAlarm);
			centerDisc.addEventListener(MouseEvent.MOUSE_OUT, createBtn);
		}
		public function cleanAndSwitch(mode:int):void
		{
			var max:MovableButton; 
			var tmp:MovableButton;
			for(var index:String in btns)
			{
				if(btns[index] != null)
				{
					if(tmp == null)
					{
						tmp = btns[index];
						max = tmp;
					}
					{
						if (btns[index].getOriginDistance() > max.getOriginDistance())
						{
							max = btns[index];
						}
					}
					btns[index].fadeRemove(stage.stageWidth / 2, stage.stageHeight / 2, 0.4);
					delete btns[index];
				}
			}
			if(max != null)
			{
				setTimeout(rot.changeMode, max.getOriginDistance() / Math.max(stage.stageHeight, stage.stageWidth) * 1500, mode);
			}
			else
			{
				rot.changeMode(mode);
			}
		}
	}
}