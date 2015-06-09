package csv
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import connect.Csv_connect;
	
	import loader.SuperFileLoader;

	public class Csv
	{
		private static var loadNum:int;
		
		private static const VECTOR_NAME1:String = "Vector.<";
		private static const VECTOR_NAME2:String = ">";
		private static const clsDic:Object = {str:"String",int:"int",boo:"Boolean"};
		
		private static var dic:Dictionary;
		
		public var id:int;
		
		public function Csv()
		{
		}
		
		public static function init(_rootPath:String,_nameVec:Vector.<String>,_classVec:Vector.<Class>,_callBack:Function = null):void{
			
			dic = new Dictionary;
			
			loadNum = _nameVec.length + 1;
			
			loadCsv(_rootPath,Csv_connect.NAME,Csv_connect,_callBack);
			
			for(var i:int = 0 ; i < _nameVec.length ; i++){
				
				loadCsv(_rootPath,_nameVec[i],_classVec[i],_callBack);
			}
		}

		private static function getCsv(_callBack:Function):void{
			
			loadNum--;
			
			if(loadNum == 0){
				
				if(_callBack != null){
					
					_callBack();
				}
			}
		}
		
		private static function loadCsv(_rootPath:String,_name:String,_class:Class,_callBack:Function = null):void{
			
			SuperFileLoader.load(_rootPath + _name + ".csv",SuperFileLoader.TYPE_TEXT,getCsvData,_name,_class,_callBack);
		}
		
		private static function getCsvData(_str:String,_name:String,_cls:Class,_callBack:Function):void{
			
			var unit:CsvUnit = new CsvUnit;
			
			unit.dic = new Dictionary;
			
			var nameVec:Array;
			var typeVec:Array;
			
			var strVec:Array = _str.split("\r\n");
			
			var index:int;
			
			for each(var tmpStr:String in strVec){
				
				if(tmpStr == "" || tmpStr.indexOf("//") != -1){
					
					continue;
				}
				
				if(index == 0){
					
					nameVec = tmpStr.split(",");
					
				}else if(index == 1){
					
					typeVec = tmpStr.split(",");
					
				}else{
					
					var tmpStr2:Array = tmpStr.split(",");
					
					var o:Object = new _cls;
					
					for(var i:int = 0 ; i < nameVec.length ; i++){
						
						if(!o.hasOwnProperty(nameVec[i])){
							
							continue;
						}
						
						if(i >= tmpStr2.length){
							
							var ss:String = "";
							
						}else{
							
							ss = tmpStr2[i];
						}
						
						var strLength:int = typeVec[i].length;
						
						var type:String = typeVec[i].slice(0,3);
						
						var times:int = (strLength - 3) * 0.5;
						
						o[nameVec[i]] = split(ss,times,type);
					}
					
					unit.dic[o.id] = o;
				}
				
				index++;
			}
			
			unit.length = index - 2;
			
			dic[_name] = unit;
			
			getCsv(_callBack);
		}
		
		private static function split(_str:String,_times:int,_type:String):Object{
			
			if(_str == "null"){
				
				return null;
			}
			
			if(_times == 0){
				
				switch(_type){
					
					case "int":
						
						return int(_str);
						
					case "str":
						
						return _str;
						
					default:
						
						if(_str == "false"){
							
							return false;
							
						}else{
							
							return true;
						}
				}
			}
			
			if(_str != ""){
				
				var splitStr:String = "";
				
				for(var i:int = 0 ; i < _times ; i++){
					
					splitStr = splitStr + "$";
				}
				
				var arr:Array = _str.split(splitStr);
				
			}else{
				
				arr = new Array;
			}
			
			var tmpStr:String = clsDic[_type];
			
			for(i = 0 ; i < _times ; i++){
				
				tmpStr = VECTOR_NAME1 + tmpStr + VECTOR_NAME2;
			}
			
			var cls:Class = Class(getDefinitionByName(tmpStr));
			
			var objVec:Object = new cls;
			
			for(i = 0 ; i < arr.length ; i++){
				
				objVec[i] = split(arr[i],_times - 1,_type);
			}
			
			return objVec;
		}
		
		public static function getDic(_name:String):Dictionary{
			
			return dic[_name].dic;
		}
		
		public static function getData(_name:String,_id:int):Object{
			
			return dic[_name].dic[_id];
		}
		
		public static function getLength(_name:String):int{
			
			return dic[_name].length;
		}
	}
}