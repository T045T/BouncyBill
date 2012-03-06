package io
{
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class AboutPane extends CenteredHoverPane
	{
		private var aboutHeader1:TextField = new TextField();
		private var aboutHeader2:TextField = new TextField();
		private var aboutBody1:TextField = new TextField();
		private var aboutBody2:TextField = new TextField();
		
		public function AboutPane(stageRef:Stage)
		{
			super(450, 300, 0.75, stageRef);
			aboutHeader1.autoSize = TextFieldAutoSize.LEFT;
			aboutHeader1.x = -200;
			aboutHeader1.y = -30;
			aboutHeader1.text = "BouncyBill";
			aboutHeader1.setTextFormat(this.headStyle);
			addChild(aboutHeader1);
			aboutBody1.autoSize = TextFieldAutoSize.LEFT;
			aboutBody1.x = -200;
			aboutBody1.y = 30;
			aboutBody1.text = "Version 1.0\n"
				+ "Copyright 2011, Nils Berg";
			aboutBody1.setTextFormat(this.bodyStyle);
			addChild(aboutBody1);
		}
	}
}