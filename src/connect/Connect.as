package connect
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import csv.Csv;
	
	public class Connect
	{
		private static var sk:Socket;
		private static var ip:String;
		private static var port:int;
		private static var callBack:Function;
		
		private static var i:int,m:int,n:int;
		private static var length:int = -1;
		
		private static var getByteArray:ByteArray;
		private static var sendByteArray:ByteArray;

		private static var method:Function;
		private static var strLength:int;
		private static var times:int;
		
		private static const VECTOR_NAME1:String = "Vector.<";
		private static const VECTOR_NAME2:String = ">";
		
		private static const clsDic:Object = {str:"String",int:"int",boo:"Boolean"};
		
		private static var csv_connect:Dictionary;
		
		private static var sendCallBack:Function;
		private static var receiveCallBack:Function;
		
		private static var handler:Object;
		
		public function Connect()
		{
		}
		
		public static function init(_ip:String,_port:int,_handler:Object,_sendCallBack:Function,_receiveCallBack:Function,_callBack:Function = null):void{
			
			getByteArray = new ByteArray;
			sendByteArray = new ByteArray;
			
			ip = _ip;
			port = _port;
			
			handler = _handler;
			
			sendCallBack = _sendCallBack;
			receiveCallBack = _receiveCallBack;
			
			callBack = _callBack;
			
			sk = new Socket;
			
			sk.addEventListener(Event.CONNECT,connected);
			sk.addEventListener(Event.CLOSE,closed);
			sk.addEventListener(IOErrorEvent.IO_ERROR,error);
			
			csv_connect = Csv.getDic(Csv_connect.NAME);
			
			connect();
		}
		
		public static function connect():void{
			
			sk.connect(ip,port);
		}
		
		private static function connected(e:Event):void{
			
			trace("连接服务器成功");
			
			sk.addEventListener(ProgressEvent.SOCKET_DATA,getData);
			
			if(callBack != null){
				
				callBack();
				
				callBack = null;
			}
		}
		
		private static function getData(e:ProgressEvent):void{
			
//			trace("getData!!!!",sk.bytesAvailable,length);
			
			while((length == -1 && sk.bytesAvailable > 1) || (length != -1 && sk.bytesAvailable >= length)){
				
				if(length == -1){
				
					length = sk.readShort();
					
//					trace("准备收包  包长度:",length);
				}

				if(length <= sk.bytesAvailable){
					
					sk.readBytes(getByteArray,0,length);
					
					handleData(getByteArray);
					
					length = -1;
					
				}
//				else{
//					
//					trace("收到不完整包  长度:",sk.bytesAvailable);
//				}
			}
		}
		
		private static function handleData(_byteArray:ByteArray):void{
			
//			trace("getData:",_str);
			
			var id:int = _byteArray.readShort();
			
			var unit:Csv_connect = csv_connect[id];
			
			trace("收到服务器的包:",unit.methodName);
			
			if(unit.type == 1){
				
				if(receiveCallBack != null){
					
					receiveCallBack();
				}
			}
			
			var arr:Array = new Array;
			
			var length:int = _byteArray.readShort();
			
			method = handler[unit.methodName];
			
			for(i = 0 ; i < length ; i++){
				
				strLength = unit.arg[i].length;
				
				var str:String = unit.arg[i].slice(0,3);
				
				times = (strLength - 3) * 0.5;
				
				var dataLength:int = _byteArray.readShort();
				
				var data:String = _byteArray.readUTFBytes(dataLength);
				
				arr.push(split(data,times,str));
			}
			
			_byteArray.clear();
			
			method.apply(null,arr);
		}
		
		private static function closed(e:Event):void{
			
			trace("connection closed");
		}
		
		private static function error(e:IOErrorEvent):void{
			
			trace("connection error");
			
			throw new Error("connection error");
		}
		
		public static function sendData(_id:int,arg:Array):void{
			
			if(sendCallBack != null){
				
				sendCallBack();
			}
			
			var unit:Csv_connect = csv_connect[_id];
			
			sendByteArray.writeShort(0);
			
			sendByteArray.writeShort(_id);
			
			sendByteArray.writeShort(unit.arg.length);
			
			if(unit.arg.length > 0){
				
				for(i = 0 ; i < unit.arg.length ; i++){
					
					strLength = unit.arg[i].length;
					
					times = (strLength - 3) * 0.5;
					
					var str:String = concat(arg[i],times);
					
					sendByteArray.writeShort(str.length);
					
					sendByteArray.writeUTFBytes(str);
				}
			}
			
			sendByteArray.position = 0;
			
			sendByteArray.writeShort(sendByteArray.length - 2);
			
			sk.writeBytes(sendByteArray);
			
			sendByteArray.clear();
			
//			sk.writeUTFBytes(sendStr);
			
			sk.flush();
			
//			trace("发包:****",sendStr,"******");
		}
		
		public static function disconnect():void{
			
			sk.close();
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
			
			var index:int = _str.indexOf(":");
			
			var num:int = int(_str.slice(0,index));
			
			_str = _str.slice(index + 1);
			
			if(num != 0){
				
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
		
		private static function concat(_obj:Object,_times:int):String{
			
			if(_obj == null){
				
				return "null";
			}
			
			if(_times == 0){
				
				return String(_obj);
			}
			
			var str:String = _obj.length + ":";
			
			if(_obj.length == 0){
				
				return str;
			}
			
			var concatStr:String = "";
			
			for(var i:int = 0 ; i < _times ; i++){
				
				concatStr = concatStr + "$";
			}
			
			for(i = 0 ; i < _obj.length - 1; i++){
				
				str = str + concat(_obj[i],_times - 1) + concatStr;
			}
			
			str = str + concat(_obj[i],_times - 1);

			return str;
		}
	}
}