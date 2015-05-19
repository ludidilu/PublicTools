package loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class SuperLoader extends Loader
	{
		private static const dic:Dictionary = new Dictionary;
		private static const waittingDic:Array = new Array;
		
		private var index:int;
		private var urlRequest:URLRequest;
		private var callBack:Function;
		private var arg:Array;
		
		public function SuperLoader(_index:int)
		{
			super();
			
			index = _index;
			urlRequest = new URLRequest;
		}
		
		public static function init(_loaderNum:int):void{
			
			for(var i:int = 0 ; i < _loaderNum ; i++){
				
				dic[i] = new SuperLoader(i);
				
				(dic[i] as SuperLoader).contentLoaderInfo.addEventListener(Event.COMPLETE,loadOK);
				(dic[i] as SuperLoader).contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFail);
				(dic[i] as SuperLoader).contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadFail);
			}
		}
		
		public static function load(_url:String,_callBack:Function = null,...arg):void{
			
			for each(var superLoader:SuperLoader in dic){
				
				superLoader.urlRequest.url = _url;
				superLoader.callBack = _callBack;
				superLoader.arg = arg;
				
				superLoader.load(superLoader.urlRequest);
				
				delete dic[superLoader.index];
				
				return;
			}
			
			var obj:Object = new Object;
			
			obj.url = _url;
			obj.callBack = _callBack;
			obj.arg = arg;
			
			waittingDic.push(obj);
		}
		
		private static function loadOK(e:Event):void{
			
			var superLoader:SuperLoader = e.target.loader as  SuperLoader;
			
			superLoader.arg.unshift(e);
			
			superLoader.callBack.apply(null,superLoader.arg);
			
			continueLoad(superLoader);
		}
		
		private static function continueLoad(_superLoader:SuperLoader):void{
			
			if(waittingDic.length > 0){
				
				var obj:Object = waittingDic.shift();
				
				_superLoader.urlRequest.url = obj.url;
				_superLoader.callBack = obj.callBack;
				_superLoader.arg = obj.arg;
				
				_superLoader.load(_superLoader.urlRequest);
				
			}else{
				
				_superLoader.callBack = null;
				_superLoader.arg = null;
				
				dic[_superLoader.index] = _superLoader;
			}
		}
		
		private static function loadFail(e:Event):void{
			
			var superLoader:SuperLoader = e.target.loader as  SuperLoader;
			
			trace("loadFail url=",superLoader.urlRequest.url);
			
			continueLoad(superLoader);
		}
	}
}