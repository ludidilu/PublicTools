package debug
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class CatchError
	{
		private static var sp:Sprite;
		private static var tf:TextField;
		private static var container:Sprite;
		
		public function CatchError()
		{
		}
		
		public static function init(_sp:Sprite):void{
			
			sp = _sp;
			
			sp.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,catchError);
			
			tf = new TextField;
			var textFormat:TextFormat = new TextFormat;
			textFormat.size = 40;
			
			tf.defaultTextFormat = textFormat;
			
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0xFF0000);
			shape.graphics.drawRect(0,0,sp.stage.stageWidth,sp.stage.stageHeight);
			
			container = new Sprite;
			container.addChild(shape);
			
			container.addChild(tf);
		}
		
		private static function catchError(e:UncaughtErrorEvent):void{
			
			trace("get Error");
			
			tf.text = e.error.message;
			
			sp.addChild(container);
		}
		
		public static function test(_str:String):void{
			
			tf.text = _str;
			
			sp.addChild(container);
		}
	}
}