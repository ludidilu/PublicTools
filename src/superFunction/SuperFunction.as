package superFunction
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class SuperFunction
	{
		private static var dic:Dictionary = new Dictionary;
		
		private var event:String;
		private var fun:Function;
		private var callBack:Function;
		
		public function SuperFunction(_event:String,_fun:Function,_callBack:Function){
			
			event = _event;
			fun = _fun;
			callBack = _callBack;
		}
		
		private static function createCallBack(_obj:*,_event:String,_fun:Function,_arg:Array):Function{
			
			var addEvent:Boolean = true;
			
			var callBack:Function = function(e:*):void{
				
				if(addEvent){
					
					_arg.unshift(e);
					
					addEvent = false;
					
				}else{
					
					_arg[0] = e;
				}
				
				_fun.apply(null,_arg);
			};
			
			
			if(!dic[_obj]){
				
				dic[_obj] = new Vector.<SuperFunction>;
			}
			
			dic[_obj].push(new SuperFunction(_event,_fun,callBack));
			
			return callBack;
		}
		
		public static function addEventListener(_obj:EventDispatcher,_event:String,_fun:Function,...arg):void{
			
			_obj.addEventListener(_event,createCallBack(_obj,_event,_fun,arg));
		}
		
		public static function removeAllEventListener(_obj:*):void{
			
			var vec:Vector.<SuperFunction> = dic[_obj];
			
			if(vec){
				
				for each(var unit:Object in vec){
					
					_obj.removeEventListener(unit.event,unit.callBack);
				}
				
				delete dic[_obj];
			}
		}
		
		public static function removeEventListener(_obj:*,_event:String,_fun:Function):void{
			
			var callBack:Function = getCallBack(_obj,_event,_fun);
			
			if(callBack != null){
				
				_obj.removeEventListener(_event,callBack);
			}
		}
		
		private static function getCallBack(_obj:*,_event:String,_fun:Function):Function{
			
			var vec:Vector.<SuperFunction> = dic[_obj];
			
			if(vec){
				
				for(var i:int  = 0 ; i < vec.length ; i++){
					
					if(vec[i].event == _event && vec[i].fun == _fun){
						
						var callBack:Function = vec[i].callBack;
						
						vec.splice(i,1);
						
						if(vec.length == 0){
							
							delete dic[_obj];
						}
						
						return callBack;
					}
				}
			}
			
			return null;
		}
	}
}