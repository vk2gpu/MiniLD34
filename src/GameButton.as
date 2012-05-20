package  
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
		
	/**
	 * ...
	 * @author ...
	 */
	public class GameButton extends Entity
	{
		[Embed(source = '../assets/button.png')] private const BUTTON:Class;
		[Embed(source = '../assets/button_on.png')] private const BUTTON_ON:Class;
		[Embed(source = '../assets/flare.png')] private const FLARE:Class;
		
		private var state:Boolean = false;
		
		private var image:Image = new Image(BUTTON);
		private var flareImage:Image = new Image(FLARE);
		
		private var flareRotation:Number = 0.0;
		
		private var brightness:Number = 0.0;
		
		private var levelColor:int = 0xff00ff00;
		
		public function GameButton(_x:int, _y:int, _levelColor:int) 
		{
			width = 80;
			height = 80;
			x = (_x * 64) - 8;
			y = (_y * 64) - 8;
			levelColor = _levelColor;
		}
				
		override public function render():void
		{
			if (state)
			{
				brightness = 1.0;
			}
			image.tinting = 1.0;
			image.color = levelColor;// state ? 0xff0000ff : 0xffffffff;
			image.alpha = brightness;
			graphic = image;
						
			brightness = brightness * 0.9;

			super.render();

			var point:Point = new Point(x + 40, y + 40);
			flareImage.angle = flareRotation;
			flareImage.originX = 40.0;
			flareImage.originY = 40.0;
			flareImage.tinting = 1.0;
			flareImage.scale = brightness * 1.25;
			flareImage.alpha = brightness * 0.5;
			flareImage.color = levelColor;
			flareImage.render(FP.buffer, point, FP.point2);
			
			flareRotation -= 360.0 / FP.frameRate;
		}
		
		public function setState(_state:Boolean):void
		{
			if (state != _state)
			{
				state = _state;
				
				if (state)
				{
					flareRotation = 0.0;
				}
			}
		}
		
	}

}