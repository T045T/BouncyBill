package io
{
	import caurina.transitions.Tweener;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import io.MovableButton;
	
	public class CentralRotaryDisplay extends Sprite
	{
		private var btns:Dictionary;
		private var position:int = 0; // from -5 to 6, like hour markers on a clock face
		private var mode:int = 0;
		private var posUpdateTimer:Timer = new Timer(33);
		private var moneyMultiplier:int = 1000;
		/*
		** 0 : Starting the App
		** 1 : Selecting bill amount
		** 2 : Tip prompt
		** 3 : Selecting tip amount
		** 4 : Pulling out nodes
		*/
		private var money:int = 0;
		private var outerRing:Sprite = new Sprite();
		private var outerRingBase:Sprite = new Sprite();
		private var stageRef:Stage;
		private var velocity:Number;
		private var loader:Loader = new Loader();
		private var dollars:TextField = new TextField();
		private var cents:TextField = new TextField();
		
		public function CentralRotaryDisplay(myButtons:Dictionary, stageRef:Stage)
		{
			super();
			
			btns = myButtons;
			this.stageRef = stageRef;
			
			initialize();
			
			dollars.autoSize = TextFieldAutoSize.RIGHT;
			dollars.selectable = false;
			dollars.textColor = 0xeeeeee;
			dollars.setTextFormat(new TextFormat("BBAlpha Sans", 62, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.RIGHT));
			cents.autoSize = TextFieldAutoSize.LEFT;
			cents.selectable = false;
			cents.textColor = 0xeeeeee;
			cents.setTextFormat(new TextFormat("BBAlpha Sans", 42, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.LEFT));
			
			dollars.x = (stageRef.stageWidth / 2 ) - (dollars.width + cents.width) / 2;
			dollars.y = (stageRef.stageHeight - dollars.height) / 2;
			cents.x = (stageRef.stageWidth / 2 ) + (dollars.width + cents.width) / 2 - cents.width;
			cents.y = (stageRef.stageHeight - dollars.height) / 2 + 5;
			setText();
			addChild(dollars);
			addChild(cents);
		}
		
		
		private function initialize():void
		{
			outerRing.x = stageRef.stageWidth / 2;
			outerRing.y = stageRef.stageHeight / 2;
			outerRingBase.x = outerRing.x;
			outerRingBase.y = outerRing.y;
			loader.load(new URLRequest("indents.png"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fillIndents);
		}
		private function fillIndents(event:Event):void
		{
			var indentFill:BitmapData = new BitmapData(loader.width, loader.height, true, 0x00FFFFFF);
			indentFill.draw(loader);
			var myMatrix:Matrix = new Matrix();
			myMatrix.translate(-150, -150);
			outerRing.graphics.beginBitmapFill(indentFill, myMatrix, false, true);
			outerRing.graphics.drawCircle(0,0,150);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fillIndents);
			loader.load(new URLRequest("newRing.png"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fillRing);
		}
		private function fillRing(event:Event):void
		{
			var myMatrix:Matrix = new Matrix();
			myMatrix.translate(-150, -150);
			var ringFill:BitmapData = new BitmapData(loader.width, loader.height, true, 0x00FFFFFF);
			ringFill.draw(loader);
			outerRingBase.graphics.beginBitmapFill(ringFill, myMatrix, false, true);
			outerRingBase.graphics.drawCircle(0,0,150);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fillRing);
			loader.load(new URLRequest("brushed_display.png"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fillCenter);
		}
		private function fillCenter(event:Event):void {
			var centerFill:BitmapData = new BitmapData(loader.width, loader.height, true, 0x00FFFFFF);
			centerFill.draw(loader);
			var myMatrix:Matrix = new Matrix();
			myMatrix.translate((stageRef.stageWidth / 2) - 105, (stageRef.stageHeight / 2) - 105);
			this.graphics.beginBitmapFill(centerFill, myMatrix, false, true);
			this.graphics.drawCircle(stageRef.stageWidth / 2, stageRef.stageHeight / 2, 105);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fillCenter);
		}
		
		public function changeMode(mode:int):int
		{
			switch (mode)
			{
				case 0:
					return 1;
					break;
				case 1:
					if (this.mode !=1)
					{
						outerRing.scaleX = 0.6;
						outerRing.scaleY = 0.6;
						outerRingBase.scaleX = 0.6;
						outerRingBase.scaleY = 0.6;
						parent.addChildAt(outerRing,2);
						parent.addChildAt(outerRingBase, 2);
						Tweener.addTween(outerRingBase, {scaleX:1, scaleY:1, time:0.9, transition:"easeOutElastic"});
						Tweener.addTween(outerRing, {scaleX:1, scaleY:1, rotation:0, time:0.9, transition:"easeOutElastic", onComplete:function():void{
							outerRing.addEventListener(MouseEvent.MOUSE_DOWN, startRingDrag);
							resetMoney();
							posUpdateTimer.addEventListener(TimerEvent.TIMER, rotListener);
							posUpdateTimer.start();
						}});
					}
					break;
				case 4:
					if (this.mode != 4 && this.mode != 0)
					{
						Tweener.addTween(outerRing, {scaleX:0.6, scaleY:0.6, time:0.9, transition:"easeInOutElastic",
							onComplete:function():void {
								outerRing.removeEventListener(MouseEvent.MOUSE_DOWN, startRingDrag);
								parent.removeChild(outerRing);
								posUpdateTimer.stop();
								posUpdateTimer.removeEventListener(TimerEvent.TIMER, rotListener);
								}});
						Tweener.addTween(outerRingBase, {scaleX:0.6, scaleY:0.6, time:0.9, transition:"easeInOutElastic",
							onComplete:function():void {
								parent.removeChild(outerRingBase);}});
						break;
					}
					else
					{
						return 1;
					}
				default:
					return 1;
					break;
				
			}
			this.mode = mode;
			return 0;
		}
		public function getMoney():int
		{
			return this.money;
		}
		public function resetMoney():void
		{
			this.money = 0;
			this.setText();
			setPos();
		}
		private var startRot:Number;
		private function startRingDrag(event:MouseEvent):void
		{
			if (event.target == outerRing)
			{
				Tweener.removeTweens(outerRing);
				Tweener.addTween(outerRing, {scaleX:1.2, scaleY:1.2, time:0.5, transition:"easeOutElastic"});
				Tweener.addTween(outerRingBase, {scaleX:1.2, scaleY:1.2, time:0.5, transition:"easeOutElastic"});
				var rotOffset:Number = Math.atan2((event.stageY - outerRing.y), (event.stageX - outerRing.x));
				startRot = outerRing.rotation - rotOffset * (180 / Math.PI);
				//startRot = outerRing.rotation;
				lastMouseAngle = rotOffset * 180 / Math.PI;
				position = outerRing.rotation / 30;
				stageRef.addEventListener(MouseEvent.MOUSE_MOVE, ringDrag);
				stageRef.addEventListener(MouseEvent.MOUSE_UP, releaseRing, true);

			}
		}
		//private var partRot:Number = 0;
		
		private var lastMouseAngle:Number = 0;
		private function ringDrag(event:MouseEvent):void
		{
			var mouseAngle:Number = Math.atan2((event.stageY - outerRing.y), (event.stageX - outerRing.x)) * 180 / Math.PI;
			outerRing.rotation = startRot + mouseAngle;
		}
		private var myTrans:Function = function(t:Number, b:Number, c:Number, d:Number, e:Number):Number {
			var ts:Number=(t/=d)*t;
			var tc:Number=ts*t;
			return b+c*(0.197499999999999*tc*ts + -1.4925*ts*ts + 1.395*tc + -1.1*ts + 2*t);
		}
		private var coasting:Boolean = false;
		private function releaseRing(event:MouseEvent):void
		{
			Tweener.addTween(outerRing, {scaleX:1, scaleY:1, time:0.7, transition:"easeOutElastic"});
			Tweener.addTween(outerRingBase, {scaleX:1, scaleY:1, time:0.7, transition:"easeOutElastic"});
			lastMouseAngle = Math.atan2((event.stageY - outerRing.y), (event.stageX - outerRing.x)) * 180 / Math.PI;
			stageRef.removeEventListener(MouseEvent.MOUSE_MOVE, ringDrag);
			var rotCalc:int = position * 30;
			var timeCalc:Number = 0.4;
			outerRing.rotation > 0 ? rotCalc = rotCalc: rotCalc == 180 ? rotCalc -= 360 : rotCalc = rotCalc;
			if (Math.abs(velocity) < 2.5)
			{
				
			}
			else
			{
				if (velocity > 30)
				{
					velocity -= (velocity - 30) / 5; 
				}
				else if (velocity < -30)
				{
					velocity -= (velocity + 30) / 5; 
				}
				rotCalc += int(velocity * 0.3) * 30;
				timeCalc += Math.abs(velocity) / 30;
			}
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, releaseRing, true);
			coasting = true;
			Tweener.addTween(outerRing, {rotation:rotCalc, time:timeCalc, transition:myTrans, onComplete:function():void {coasting == false}});
		}
		private function rotListener(event:TimerEvent):void
		{
			var tmpPosition:int = this.position;
			setPos();
			tmpPosition = position - tmpPosition;
			if (tmpPosition < -5)
			{
				tmpPosition += 12;
			}
			else if (tmpPosition > 6)
			{
				tmpPosition -=12;
			}
			if (tmpPosition != 0)
			{
				if (money + tmpPosition * moneyMultiplier < 0)
				{
					money = 0;
				}
				else if (money + tmpPosition * moneyMultiplier > 99999)
				{
					money = 99999
				}
				else
				{
					money += tmpPosition * moneyMultiplier;
				}
				this.setText();
			}
		}
		private var oldRot:Number = 0;
		private function setText():void
		{
			if (money > 9999)
			{
				dollars.text = String(money).substr(0, 3);
			}
			else if (money > 999)
			{
				dollars.text = String(money).substr(0, 2);
			}
			else if (money > 99)
			{
				dollars.text = String(money).substr(0, 1);
			}
			else
			{
				dollars.text = "0";
			}
			dollars.setTextFormat(new TextFormat("BBAlpha Sans", 62, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.RIGHT));
			if (money == 0)
			{
				cents.text = "00";
			}
			else if (money < 10)
			{
				cents.text = "0" + String(money);
			}
			else
			{
				cents.text = String(money).substr(-2, 2);
			}
			cents.setTextFormat(new TextFormat("BBAlpha Sans", 42, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.LEFT));
			
			dollars.x = (stageRef.stageWidth / 2 ) - (dollars.width + cents.width) / 2;
			dollars.y = (stageRef.stageHeight - dollars.height) / 2;
			cents.x = (stageRef.stageWidth / 2 ) + (dollars.width + cents.width) / 2 - cents.width;
			cents.y = (stageRef.stageHeight - dollars.height) / 2 + 5;
		}
		private function setPos():void
		{
			var i:Number = outerRing.rotation > 0 ? outerRing.rotation + 15 : outerRing.rotation - 15;
			var tempVel:Number = outerRing.rotation - oldRot;
			oldRot = outerRing.rotation;
			if (tempVel > 200)
			{
				tempVel -= 360;
			}
			else if (tempVel < -200)
			{
				tempVel += 360;
			}
			this.velocity = tempVel;
			if (Math.abs(velocity) < 4)
			{
				this.moneyMultiplier = 1;
			}
			else if (Math.abs(velocity) < 12)
			{
				this.moneyMultiplier = 10;
			}
			/*else if (Math.abs(velocity) < 19)
			{
				this.moneyMultiplier = 100;
			}*/
			else
			{
				this.moneyMultiplier = 100;
			}
			this.position = int((i) / 30);
			if (position == -6)
			{
				position = 6;
			}
		}
	}
}