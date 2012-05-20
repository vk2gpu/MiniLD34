package  
{
	import flash.geom.Point;
	import flash.ui.KeyboardType;
	import flash.utils.Dictionary;
		
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameWorld extends World
	{
		public var buttonArray:Array = new Array();
		public var gameStateArray:Array = new Array();
		public var synth:SoundSynth = new SoundSynth();
		
		public var deltaTime:Number = 1.0 / 60.0;
		public var advanceTime:Number = 4.0 * (2048.0 / 44100.0);
		public var timer:Number = 0.0;
		public var viewZ:int = 0;
		public var dirtyRendering:Boolean = true;
		public var dirtySound:Boolean = true;
		
		public var scaleNotes:Array = [ 0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24 ];
		
		public function GameWorld() 
		{
			var i:int;
			var j:int;
			
			// Create ALL the buttons.
			for (j = 0; j < 8; ++j)
			{
				for (i = 0; i < 8; ++i)
				{
					var button:GameButton = new GameButton(i, j);
					buttonArray.push(button);
					add(button);
				}
			}
			
			// Create game state.
			var totalStates:int = 8 * 8 * 8;
			for (i = 0; i < totalStates; ++i)
			{
				gameStateArray.push(false);
			}
			
			// Setup test puzzle.
			/*
			setState(0, 0, 0, true);
			setState(0, 7, 0, true);
			setState(7, 7, 0, true);
			setState(7, 0, 0, true);
			setState(0, 0, 7, true);
			setState(0, 7, 7, true);
			setState(7, 7, 7, true);
			setState(7, 0, 7, true);
			setState(7, 0, 7, true);
			*/
			//toggle(0, 0, 0);
			
			synth.addEventListener("PreProcess", onSynthPreProcess);
			
			synth.start();
		}
		
		override public function update():void
		{		
			// Handle input.
			if (Input.mousePressed)
			{
				if (Input.mouseX < 512 && Input.mouseY < 512)
				{
					var x:int = Input.mouseX / 64;
					var y:int = Input.mouseY / 64;
			
					toggle(x, y, viewZ);
					dirtyRendering = true;
				}
			}
			
			// Update rendering.
			if (dirtyRendering)
			{
				updateButtons();
			}
		}
		
		public function onSynthPreProcess(_event:SoundSynthProcessEvent):void
		{
			// Advance z.
			timer += _event.period;
			if (timer > advanceTime)
			{
				timer -= advanceTime;
				viewZ = (viewZ + 1) % 8;
				dirtyRendering = true;
				dirtySound = true;
			}
			
			if (dirtySound)
			{
				var x:int = 0;
				var y:int = 0;
				
				dirtySound = false;
				
				var notesOn:Dictionary = new Dictionary;
				var notesMin:Dictionary = new Dictionary;
				var notesMax:Dictionary = new Dictionary;
				
				// Gather notes to play.
				for (x = 0; x < 8; ++x)
				{
					var y0:int = -1;
					var y1:int = -1;
					var noteCount:int = 0;
					for (y = 0; y < 8; ++y)
					{
						var state:Boolean = getState(x, y, viewZ);
						var button:GameButton = getButton(x, y);
						
						// If on begin a chord.
						if (state)
						{
							noteCount++;
							var note:int = scaleNotes[y + (noteCount * 3)] + 60;
							
							notesOn[note] = true;
							
							if (notesMin[note] == null)
							{
								notesMin[note] = x;
							}
							else
							{
								notesMin[note] = Math.min(notesMin[note], x);
							}
							
							if (notesMax[note] == null)
							{
								notesMax[note] = x;
							}
							else
							{
								notesMax[note] = Math.max(notesMax[note], x);
							}
}
						// If not, end the chord.
						else
						{
							noteCount = 0;
						}
					}
				}
				
				// 
				var lastNote:int = 0;
				for (var k in notesOn)
				{
					var value:Boolean = notesOn[k];
					var note:int = k;
					
					var min:int = notesMin[k];
					var max:int = notesMax[k];
					
					var lpCoef:Number = 200.0 * max + 50.0;
					var lpRes:Number = (1.0 * (1.0-min))/9.0;
					
					// Play note.
					if (note - lastNote > 2)
					{
						var module:SoundSynthModule = synth.getSynth();		
						module.setEnv(0.01, 0.02, 0.05, 0.08);
						module.setGain(0.08);
						module.setLowPassFilter(1600.0, 0.1);
						module.setPitch(SoundSynth.midiNotes[note], SoundSynth.midiNotes[note]);
						lastNote = note;
					}
				}
				
				if (viewZ % 2 == 0)
				{
					/*
					var module:SoundSynthModule = synth.getSynth();		
					module.setEnv(0.01, 0.01, 0.01, 0.1);
					module.setGain(0.2);
					module.setLowPassFilter(400.0, 0.4);
					module.setPitch(80.0, 10.0);
					*/
				}
			}
		}
		
		public function updateButtons():void
		{
			var x:int = 0;
			var y:int = 0;
			
			for (x = 0; x < 8; ++x)
			{
				for (y = 0; y < 8; ++y)
				{
					var state:Boolean = getState(x, y, viewZ);
					var button:GameButton = getButton(x, y);
					
					button.setState(state);
				}
			}
		}
		
		public function getButton(_x:int, _y:int):GameButton
		{
			var index:int = _x + (_y * 8);
			
			return buttonArray[index];
		}
		
		public function getState(_x:int, _y:int, _z:int):Boolean
		{
			if (_x < 0 ) _x += 8;
			if (_y < 0 ) _y += 8;
			if (_z < 0 ) _z += 8;
			if (_x >= 8 ) _x -= 8;
			if (_y >= 8 ) _y -= 8;
			if (_z >= 8 ) _z -= 8;
			var index:int = _x + (_y + _z * 8) * 8;
			return gameStateArray[index];
		}

		public function setState(_x:int, _y:int, _z:int, _state:Boolean):void
		{
			if (_x < 0 ) _x += 8;
			if (_y < 0 ) _y += 8;
			if (_z < 0 ) _z += 8;
			if (_x >= 8 ) _x -= 8;
			if (_y >= 8 ) _y -= 8;
			if (_z >= 8 ) _z -= 8;
			var index:int = _x + (_y + _z * 8) * 8;
			gameStateArray[index] = _state;
		}
		
		public function toggle(_x:int, _y:int, _z:int):void
		{
			setState(_x, _y, _z, !getState(_x, _y, _z));
			
			setState(_x-1, _y, _z, !getState(_x-1, _y, _z));
			setState(_x+1, _y, _z, !getState(_x+1, _y, _z));
			setState(_x, _y-1, _z, !getState(_x, _y-1, _z));
			setState(_x, _y+1, _z, !getState(_x, _y+1, _z));
			setState(_x, _y, _z-1, !getState(_x, _y, _z-1));
			setState(_x, _y, _z+1, !getState(_x, _y, _z+1));
			
		}
	}

}