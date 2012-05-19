package  
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameButton extends Entity
	{
		[Embed(source = '../assets/button.png')] private const BUTTON:Class;
		[Embed(source = '../assets/button_on.png')] private const BUTTON_ON:Class;
		
		private var state:Boolean = false;
		
		public function GameButton(_x:int, _y:int) 
		{
			width = 64;
			height = 64;
			x = _x * width;
			y = _y * height;

			setupGraphic();
		}
		
		override public function update():void
		{
			
		}
		
		public function setState(_state:Boolean):void
		{
			if (state != _state)
			{
				state = _state;
				
				setupGraphic();
			}
		}
		
		private function setupGraphic():void
		{
			if (state)
			{	
				graphic = new Image(BUTTON_ON);
			}
			else
			{
				graphic = new Image(BUTTON);
			}
		}
	}

}