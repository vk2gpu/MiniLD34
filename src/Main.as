package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Main extends Engine
	{
		
		public function Main():void 
		{
			super(64 * 8, 64 * 8, 60, false);
			
			FP.world = new GameWorld(0);
		}		
		
		override public function init():void
		{
			trace("FlashPunk has started successfully!");
		}
		
		
	}
	
}