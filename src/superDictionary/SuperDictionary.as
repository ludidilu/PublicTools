package superDictionary
{
	import flash.utils.Dictionary;

	public class SuperDictionary
	{
		public var size:int = 0;
		
		private var dic:Dictionary;
		
		public function SuperDictionary(weakKeys:Boolean = false)
		{
			dic = new Dictionary(weakKeys);
		}
		
		public function put(_key:Object,_value:Object):void{
			
			if(dic[_key] == null){
				
				size++;
			}
			
			dic[_key] = _value;
		}
		
		public function del(_key:Object):void{
			
			if(dic[_key] != null){
				
				size--;
				
				delete dic[_key];
			}
		}
		
		public function get(_key:Object):Object{
			
			return dic[_key];
		}
	}
}