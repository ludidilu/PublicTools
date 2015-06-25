package userData
{
	public class UserData
	{
		public function sync(_data:Object):void{
			
			for(var str:String in _data){
				
				(this[str] as UserDataUnit).sync(_data[str]);
			}
		}
	}
}