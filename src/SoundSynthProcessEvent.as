package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SoundSynthProcessEvent extends Event
	{
		public var period:Number = 0.0;
		public var position:Number = 0.0;
		
		public function SoundSynthProcessEvent(_type:String,_period:Number,_position:Number) 
		{
			super(_type)
			period = _period;
			position = _position;
		}
		
	}

}