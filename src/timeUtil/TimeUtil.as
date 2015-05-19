package timeUtil
{
	import flash.utils.getTimer;

	public class TimeUtil
	{
		public static var speed:Number = 1;
		
		private static var lastTickTime:int;
		
		private static var nowTickTime:int;
		
		private static var lastTime:int;
		
		private static var nowTime:int;
		
		public static function gameNowTime():int{
			
			return nowTime;
		}
		
		public static function updateFrame():void{
			
			nowTickTime = getTimer();
			
			nowTime = lastTime + (nowTickTime - lastTickTime) * speed;
			
			lastTickTime = nowTickTime;
			
			lastTime = nowTime;
		}
	}
}