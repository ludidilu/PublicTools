package loader
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class SuperURLLoader extends URLLoader
	{
		private static const dic:Dictionary = new Dictionary;
		private static const waittingDic:Array = new Array;
		
		private var index:int;
		private var urlRequest:URLRequest;
//		private var dataFormat:String;
		private var callBack:Function;
		private var arg:Array;
		
		public function SuperURLLoader(_index:int)
		{
			super();
			
			index = _index;
			urlRequest = new URLRequest;
		}
		
		public static function init(_loaderNum:int):void{
			
			for(var i:int = 0 ; i < _loaderNum ; i++){
				
				dic[i] = new SuperURLLoader(i);
				
				(dic[i] as SuperURLLoader).addEventListener(Event.COMPLETE,loadOK);
				(dic[i] as SuperURLLoader).addEventListener(IOErrorEvent.IO_ERROR,loadFail);
				(dic[i] as SuperURLLoader).addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadFail);
			}
		}
		
		public static function load(_url:String,_dataFormat:String = URLLoaderDataFormat.TEXT,_callBack:Function = null,...arg):void{
			
			for each(var superURLLoader:SuperURLLoader in dic){
				
				superURLLoader.urlRequest.url = _url;
				superURLLoader.dataFormat = _dataFormat;
				superURLLoader.callBack = _callBack;
				superURLLoader.arg = arg;
				
				superURLLoader.load(superURLLoader.urlRequest);
				
				delete dic[superURLLoader.index];
				
				return;
			}
			
			var obj:Object = new Object;
			
			obj.url = _url;
			obj.dataFormat = _dataFormat;
			obj.callBack = _callBack;
			obj.arg = arg;
			
			waittingDic.push(obj);
		}
		
		private static function loadOK(e:Event):void{
			
			var superURLLoader:SuperURLLoader = e.target as SuperURLLoader;
			
			superURLLoader.arg.unshift(e);
			
			superURLLoader.callBack.apply(null,superURLLoader.arg);
			
			continueLoad(superURLLoader);
		}
		
		private static function continueLoad(_superURLLoader:SuperURLLoader):void{
			
			if(waittingDic.length > 0){
				
				var obj:Object = waittingDic.shift();
				
				_superURLLoader.urlRequest.url = obj.url;
				_superURLLoader.dataFormat = obj.dataFormat;
				_superURLLoader.callBack = obj.callBack;
				_superURLLoader.arg = obj.arg;
				
				_superURLLoader.load(_superURLLoader.urlRequest);
				
			}else{
				
				_superURLLoader.callBack = null;
				_superURLLoader.arg = null;
				
				dic[_superURLLoader.index] = _superURLLoader;
			}
		}
		
		private static function loadFail(e:Event):void{
			
			var superURLLoader:SuperURLLoader = e.target as SuperURLLoader;
			
			trace("loadFail url=",superURLLoader.urlRequest.url);
			
			throw new Error("loadFail url=" + superURLLoader.urlRequest.url);
			
			continueLoad(superURLLoader);
		}
	}
}