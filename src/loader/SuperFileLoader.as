package loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import superFunction.SuperFunction;

	public class SuperFileLoader
	{
		public static const TYPE_BYTEARRAY:int = 0;
		public static const TYPE_TEXT:int = 1;
		public static const TYPE_PICTURE:int = 2;
		
		public function SuperFileLoader()
		{
		}
		
		public static function load(_path:String,_type:int,_callBack:Function,..._arg):void{
			
			var file:File = new File(_path);
			
			var fs:FileStream = new FileStream;
			
			SuperFunction.addEventListener(fs,Event.COMPLETE,loadOK,_type,_callBack,_arg);
			
			fs.openAsync(file,FileMode.READ);
		}
		
		private static function loadOK(e:Event,_type:int,_callBack:Function,_arg:Array):void{
			
			var fs:FileStream = e.target as FileStream;
			
			SuperFunction.removeAllEventListener(fs);
			
			switch(_type){
				
				case TYPE_BYTEARRAY:
					
					var byteArray:ByteArray = new ByteArray;
					
					fs.readBytes(byteArray);
					
					_arg.unshift(byteArray);
					
					_callBack.apply(null,_arg);
					
					break;
				
				case TYPE_TEXT:
					
					var str:String = fs.readUTFBytes(fs.bytesAvailable);
					
					_arg.unshift(str);
					
					_callBack.apply(null,_arg);
					
					break;
				
				default:
					
					byteArray = new ByteArray;
					
					fs.readBytes(byteArray);
					
					var tmpLoader:Loader = new Loader;
					
					SuperFunction.addEventListener(tmpLoader.contentLoaderInfo,Event.COMPLETE,pictureLoadOK,_callBack,_arg);
					
					tmpLoader.loadBytes(byteArray);
			}
		}
		
		private static function pictureLoadOK(e:Event,_callBack:Function,_arg:Array):void{
			
			SuperFunction.removeAllEventListener(e.target);
			
			_arg.unshift(e.target.loader.content.bitmapData);
			
			_callBack.apply(null,_arg);
		}
	}
}