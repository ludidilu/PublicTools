package aStar
{
	import flash.utils.Dictionary;

	public class AStar
	{
		private static var unitDic:Dictionary = new Dictionary;
		private static var openUnit:AStarUnit;
		private static var openNum:int;
		private static var openDic:Dictionary = new Dictionary;
		private static var closeDic:Dictionary = new Dictionary;
		
		private static var bool:Boolean;
		private static var wallDic:Dictionary;
		
		private static var width:int;
		private static var height:int;
		
		public static function init(_width:int,_height:int,_wallDic:Dictionary):void{
			
			width = _width;
			height = _height;
			
			wallDic = _wallDic;
			
			for(var i:int = 0 ; i < height ; i++){
				
				for(var m:int = 0 ; m < width ; m++){
					
					var unit:AStarUnit = new AStarUnit;
					
					unit.pos = i * width + m;
					unit.x = m;
					unit.y = i;
					
					unitDic[unit.pos] = unit;
				}
			}
		}
		
		/**
		 * 返回的路径包括起点和终点 
		 * @param _start
		 * @param _end
		 * @param _resultVec
		 * @return 
		 * 
		 */		
		public static function getRoute(_start:int,_end:int,_resultVec:Vector.<int> = null):Vector.<int>{
			
			if(_start == _end){
				
				return null;
			}
			
			var unit:AStarUnit = unitDic[_start];
			
			unit.qian = 0;
			unit.hou = getHou(_start,_end);
			unit.all = unit.qian + unit.hou;
			
			unit.father = null;
			unit.preOne = null;
			unit.nextOne = null;
			
			openUnit = unit;
				
			openDic[_start] = unit;
			openNum++;
			
			while(true){
				
				unit = openUnit;
				
				if(unit.nextOne != null){
					
					unit.nextOne.preOne = null;
					openUnit = unit.nextOne;
					
				}else{
					
					openUnit = null;
				}
				
				delete openDic[unit.pos];
				openNum--;
				closeDic[unit.pos] = true;
				
				bool = addNextUnits(unit,_end);
				
				if(bool){
					
					if(_resultVec){
						
						var result:Vector.<int> = _resultVec;
						result.length = unit.qian + 2;
						
					}else{
						
						result = new Vector.<int>(unit.qian + 2);
					}
					
					result[unit.qian + 1] = _end;
					
					while(true){
						
						result[unit.qian] = unit.pos;
						
						unit = unit.father;
						
						if(unit == null){
							
							break;
						}
					}
					
					reset();
					
					return result;
					
				}else{
					
					if(openNum == 0){
						
						reset();
						
						return null;
					}
				}
			}
			
			return null;
		}
		
		private static function reset():void{
			
			openNum = 0;
			openDic = new Dictionary;
			closeDic = new Dictionary;
		}
		
		private static function addNextUnits(_unit:AStarUnit,_end:int):Boolean{
			
			if(_unit.x > 0){
				
				if(_end == _unit.pos - 1){
					
					return true;
				}
				
				addNextUnit(_unit,_unit.pos - 1,_end);
			}
			
			if(_unit.x < width - 1){
				
				if(_end == _unit.pos + 1){
					
					return true;
				}
				
				addNextUnit(_unit,_unit.pos + 1,_end);
			}
			
			if(_unit.y > 0){
				
				if(_end == _unit.pos - width){
					
					return true;
				}
				
				addNextUnit(_unit,_unit.pos - width,_end);
			}
			
			if(_unit.y < height - 1){
				
				if(_end == _unit.pos + width){
					
					return true;
				}
				
				addNextUnit(_unit,_unit.pos + width,_end);
			}
			
			return false;
		}
		
		private static function addNextUnit(_unit:AStarUnit,_pos:int,_end:int):void{
			
//			if(_pos in _wallDic || _pos in closeDic){
			
			if(wallDic[_pos] != null || closeDic[_pos] != null){
				
				return;
			}
			
			var unit:AStarUnit = openDic[_pos];
			
			if(unit != null){
				
				if(unit.qian > _unit.qian + 1){
					
					unit.father = _unit;
					
					unit.qian = _unit.qian + 1;
					
					unit.all = unit.qian + unit.hou;
					
					if(unit.preOne != null && unit.nextOne != null){
						
						unit.preOne.nextOne = unit.nextOne;
						unit.nextOne.preOne = unit.preOne;
						
					}else if(unit.preOne != null){
						
						unit.preOne.nextOne = null;
						
					}else if(unit.nextOne != null){
						
						openUnit = unit.nextOne;
						
						unit.nextOne.preOne = null;
						
					}else{
						
						return;
					}
					
					addUnit(unit);
				}
				
			}else{
				
				unit = unitDic[_pos];
				openDic[_pos] = unit;
				openNum++;
				
				unit.father = _unit;
				unit.qian = _unit.qian + 1;
				unit.hou = getHou(_pos,_end);
				
				unit.all = unit.qian + unit.hou;
				
				addUnit(unit);
			}
		}
		
		private static function addUnit(_unit:AStarUnit):void{
			
			if(openUnit == null){
				
				_unit.preOne = tmpUnit;
				_unit.nextOne = null;
				
				openUnit = _unit;
				
			}else{
			
				var tmpUnit:AStarUnit = openUnit;
				
				while(true){
					
					if(_unit.all <= tmpUnit.all){
						
						_unit.preOne = tmpUnit.preOne;
						_unit.nextOne = tmpUnit;
						
						if(tmpUnit.preOne){
							
							tmpUnit.preOne.nextOne = _unit;
							
						}else{
							
							openUnit = _unit;
						}
						
						tmpUnit.preOne = _unit;
						
						break;
						
					}else{
						
						if(tmpUnit.nextOne){
							
							tmpUnit = tmpUnit.nextOne;
							
						}else{
							
							tmpUnit.nextOne = _unit;
							
							_unit.preOne = tmpUnit;
							_unit.nextOne = null;
							
							break;
						}
					}
				}
			}
		}
		
		private static function getHou(_start:int,_end:int):int{
			
			return Math.abs(unitDic[_start].x - unitDic[_end].x) + Math.abs(unitDic[_start].y - unitDic[_end].y);
		}
	}
}