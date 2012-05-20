package  
{
	import flash.geom.Point;
	import flash.ui.KeyboardType;
	import flash.utils.Dictionary;
		
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
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
		public var advanceTime:Number = 8.0 * (2048.0 / 44100.0);
		public var timer:Number = 0.0;
		public var viewZ:int = 0;
		public var dirtyRendering:Boolean = true;
		public var dirtySound:Boolean = true;
		public var level:int = 0;
		
		public var scaleNotes:Array = [ 0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24 ];
		
		public function GameWorld(_level:int) 
		{
			var i:int;
			var j:int;
			
			// Create game state.
			var totalStates:int = 8 * 8 * 8;
			for (i = 0; i < totalStates; ++i)
			{
				gameStateArray.push(false);
			}

			// Setup level.
			level = _level;
			
			var timeInc:int = (level / 2);
			advanceTime = (8.0 - timeInc) * (2048.0 / 44100.0)
			
			//
			var levelColor:int = 0xff00ff00;
			switch(level % 4)
			{
			case 0:
				{
					levelColor = 0xff0000ff;
					toggle(1, 1, 1);
					toggle(6, 1, 3);
					toggle(1, 6, 5);
					toggle(6, 6, 7);
				}
				break;
			case 1:
				{
					levelColor = 0xff00ff00;
					toggle(0, 0, 0);
					toggle(7, 7, 2);
					toggle(0, 7, 4);
					toggle(7, 0, 6);
				}
				break;
			case 2:
				{
					levelColor = 0xffff0000;
					toggle(1, 1, 0);
					toggle(2, 2, 1);
					toggle(3, 3, 2);
					toggle(4, 4, 3);
					toggle(6, 6, 4);
					toggle(5, 5, 5);
					toggle(4, 4, 6);
					toggle(3, 3, 7);
				}
				break;
			case 3:
				{
					levelColor = 0xff00ffff;
					toggle(1, 1, 1);
					toggle(6, 1, 3);
					toggle(1, 6, 5);
					toggle(6, 6, 7);
					toggle(1, 1, 0);
					toggle(2, 2, 1);
					toggle(3, 3, 2);
					toggle(4, 4, 3);
					toggle(6, 6, 4);
					toggle(5, 5, 5);
					toggle(4, 4, 6);
					toggle(3, 3, 7);
				}
				break;
			}
			
			// Create ALL the buttons.
			for (j = 0; j < 8; ++j)
			{
				for (i = 0; i < 8; ++i)
				{
					var button:GameButton = new GameButton(i, j, levelColor);
					buttonArray.push(button);
					add(button);
				}
			}
		}
			
		override public function begin():void
		{
			synth.addEventListener("PreProcess", onSynthPreProcess);			
			synth.start();
		}
		
		override public function end():void
		{
			synth.stop();
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
			
			// Reset level.
			if (Input.check(Key.R))
			{
				FP.world.removeAll();
				FP.world = new GameWorld(level);
			}
			
			// Update rendering.
			if (dirtyRendering)
			{
				updateButtons();
			}
		}
		
		override public function render():void
		{
			super.render();
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
				var noteArray:Array = new Array();
				for (var k in notesOn)
				{
					noteArray.push(k);
				}
				
				noteArray.sort();
				
				
				// 
				var lastNote:int = 0;
				for ( var idx:int = 0; idx < noteArray.length; ++idx)
				{
					var note:int = noteArray[idx];
					
					var min:int = notesMin[note];
					var max:int = notesMax[note];
					
					var lpCoef:Number = 200.0 * max + 50.0;
					var lpRes:Number = (1.0 * (1.0-min))/9.0;
					
					// Play note.
					if (note - lastNote > 2)
					{
						var module:SoundSynthModule = synth.getSynth();		
						module.setEnv(0.01, 0.02, 0.05, 0.08);
						module.setGain(0.08);
						module.setLowPassFilter(2600.0, max / 8.0);
						module.setBlend(min / 8.0);
						module.setPitch(SoundSynth.midiNotes[note] + 4.0, SoundSynth.midiNotes[note] - 4.0);
						
						module = synth.getSynth();		
						module.setEnv(0.01, 0.02, 0.05, 0.08);
						module.setGain(0.08);
						module.setLowPassFilter(2600.0, max / 8.0);
						module.setBlend(min / 8.0);
						module.setPitch(SoundSynth.midiNotes[note] - 4.0, SoundSynth.midiNotes[note] + 4.0);
						
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
			var z:int = 0;
			var hasNote:Boolean = false;
			
			for (x = 0; x < 8; ++x)
			{
				for (y = 0; y < 8; ++y)
				{
					var state:Boolean = getState(x, y, viewZ);
					var button:GameButton = getButton(x, y);
					
					button.setState(state);
					
					for (z = 0; z < 8; ++z)
					{
						state = getState(x, y, z);
						hasNote = hasNote || state;
					}
				}
			}
			
			// Check level state.
			if (hasNote == false && viewZ == 0)
			{
				FP.world = new GameWorld(level + 1);
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