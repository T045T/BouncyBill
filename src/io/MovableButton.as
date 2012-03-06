package io
{
	import caurina.transitions.Tweener;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/*
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	*/
	public class MovableButton extends Sprite
	{
		private var id:int;
		private var money:int;
		private var stageRef:Stage;
		private var dollars:TextField = new TextField();
		private var cents:TextField = new TextField();
		private var originX:int;
		private var originY:int;
		private var radius:int = 70;
		private var movementVector:Array; // 0 : velocity | 1: angle
		private var wasClicked:Boolean = false;
		private var bgLoader:Loader = new Loader();
		
		public function MovableButton(x:Number, y:Number, id:int, stageRef:Stage, money:int)
		{
			super();
			this.x = x;
			this.y = y;
			this.originX = x;
			this.originY = y;
			this.id = id;
			this.wasClicked = true;
			this.stageRef = stageRef;
			bgLoader.load(new URLRequest("nodeBG.png"));
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
			dollars.autoSize = TextFieldAutoSize.RIGHT;
			dollars.selectable = false;
			dollars.textColor = 0xeeeeee;
			cents.autoSize = TextFieldAutoSize.LEFT;
			cents.selectable = false;
			cents.textColor = 0xeeeeee;
			this.money = money;
			setText();
		}
		public function getMoney():int
		{
			return this.money;
		}
		public function setMoney(money:int):void
		{
			this.money = money;
			setText();
		}
		private function init(event:Event):void
		{
			var bgFill:BitmapData = new BitmapData(bgLoader.width, bgLoader.height, true, 0x00FFFFFF);
			bgFill.draw(bgLoader);
			var myMatrix:Matrix = new Matrix();
			myMatrix.translate(-70, -70);
			this.graphics.beginBitmapFill(bgFill, myMatrix, false, true);
			this.graphics.drawCircle(0, 0, 70);
			addChild(dollars);
			addChild(cents);
			
			addEventListener(MouseEvent.MOUSE_DOWN, nodeDown);
			stageRef.addEventListener(Event.ENTER_FRAME, nodeDrag);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, this.nodeRelease, true, 3);
			bgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, init);
		}
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
			
			dollars.setTextFormat(new TextFormat("BBAlpha Sans", 40, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.RIGHT));
			cents.setTextFormat(new TextFormat("BBAlpha Sans", 28, 0xDDDDDD, false, false, false, "", "", TextFormatAlign.LEFT));
			dollars.x = - (dollars.width + cents.width) / 2;
			dollars.y = - dollars.height / 2;
			cents.x = (dollars.width + cents.width) / 2 - cents.width;
			cents.y = - dollars.height / 2 + 3;
			Tweener.addTween(this, {scaleX:1.1, scaleY:1.1, time:0.05, transition:"easeOutBack", onComplete:function():void {
				Tweener.addTween(this, {scaleX:1, scaleY:1, time:0.1, transition:"easeOutElastic"})}
			});
		}
		public function getID():int
		{
			return this.id;
		}
		public function nodeDown(event:MouseEvent):void
		{
			this.wasClicked = true;
			Tweener.removeTweens(this);
			stageRef.addEventListener(Event.ENTER_FRAME, nodeDrag, false, 0, true);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, this.nodeRelease, true, 3);
		}
		public function nodeDrag(event:Event):void
		{
			var speed:Number = 4;
			var oldLoc:Array = [x, y];
			x -= (x - stageRef.mouseX) / speed;	//easing
			y -= (y - stageRef.mouseY) / speed; 	//easing
			movementVector = [this.getDistance(oldLoc[0], oldLoc[1]), Math.atan2(y - oldLoc[1], x - oldLoc[0])];
		}
		public function nodeRelease(event:MouseEvent):void
		{
			if (this.wasClicked)
			{
				var inertiaFactor:Number = 3
				var xDest:Number = this.x + Math.cos(movementVector[1]) * movementVector[0] * inertiaFactor;
				var yDest:Number = this.y + Math.sin(movementVector[1]) * movementVector[0] * inertiaFactor;
				var duration:Number = 0.2;
				
				if (xDest + this.radius * this.scaleX > stageRef.stageWidth)
				{
					xDest = stageRef.stageWidth - (this.radius * this.scaleX);
				}
				else if (xDest - this.radius * this.scaleX < 0)
				{
					xDest = this.radius * this.scaleX;
				}
				if (yDest + this.radius * this.scaleY > stageRef.stageHeight)
				{
					yDest = stageRef.stageHeight - this.radius * this.scaleY;
				}
				else if (yDest - this.radius * this.scaleY < 0)
				{
					yDest = this.radius * this.scaleY;
				}
				
				duration = movementVector[0] * inertiaFactor / 300;
				duration < 0.2 ? duration = 0.2: duration = duration;
				Tweener.addTween(this, {x:xDest, y:yDest, time:duration, transition:"easeOutBack"});
				stageRef.removeEventListener(Event.ENTER_FRAME, nodeDrag);
				stageRef.removeEventListener(MouseEvent.MOUSE_UP, this.nodeRelease);
				this.wasClicked = false;
			}
		}
		public function fadeRemove(xDest:Number, yDest:Number, fadeTime:Number):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, nodeDown);
			var distance:Number = this.getDistance(xDest, yDest);
			distance = distance / Math.max(stageRef.stageHeight, stageRef.stageWidth);
			distance = Math.abs(distance)*1.5;
			Tweener.addTween(this, {x:xDest, y:yDest, scaleX:0.7, scaleY:0.7, time:distance,
				transition:"easeInQuad", onComplete:Sprite(parent).removeChild, onCompleteParams:[this]});
		}
		public function getDistance(x:Number, y:Number):Number
		{
			return Math.sqrt((x - this.x) * (x - this.x) + (y - this.y) * (y - this.y));
		}
		public function getOriginDistance():Number
		{
			return Math.sqrt((this.originX - this.x) * (this.originX - this.x) + (this.originY - this.y) * (this.originY - this.y));
		}
	}
}