package userData
{
	import flash.utils.getQualifiedClassName;

	public class UserDataUnit
	{
		public function sync(_data:Object):void{
			
			for(var str:String in _data){
				
				this[str] = getData(this[str],_data[str]);
			}
		}
		
		private function getData(_att:*,value:*):*{
			
			var type:String = getQualifiedClassName(_att);
			
			switch (type)
			{
				case "int":
					
					return int(value);
					
				case "Number":
					
					return Number(value);
					
				case "uint" :
					
					return uint(value);
					
				case "String":
					
					return value;
					
				case "Boolean":
					
					return value == "true" || value == "1";
					
				case "__AS3__.vec::Vector.<int>":
					
					return Vector.<int>(value);
					
				case "__AS3__.vec::Vector.<Number>":
					
					return Vector.<Number>(value);
					
				case "__AS3__.vec::Vector.<String>":
					
					return Vector.<String>(value);
					
				case "__AS3__.vec::Vector.<Boolean>":
					
					return Vector.<Boolean>(value);
					
				default :
					
					return value;
			}
		}
	}
}