package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	 /**
	 * ...
	 * @author ...
	 */
	public class SoundSynthModule extends EventDispatcher
	{
		private var position:int = 0;
		
		// Env.
		private var envA:Number = 0.0;
		private var envD:Number = 0.0;
		private var envS:Number = 0.0;
		private var envR:Number = 0.0;
		private var envAEnd:Number = 0.0;
		private var envDEnd:Number = 0.0;
		private var envSEnd:Number = 0.0;
		private var envREnd:Number = 0.0;
		
		// Filter.
		private var filterInCoef:Vector.<Number> = new Vector.<Number>(3);
		private var filterOutCoef:Vector.<Number> = new Vector.<Number>(2);
		private var filterInBuf:Vector.<Number> = new Vector.<Number>(3);
		private var filterOutBuf:Vector.<Number> = new Vector.<Number>(2);
		
		
		// Synth.
		private var cursor:Number = 0.0;
		private var cycle:Number = 0.0;
		private var startCycle:Number = 0.0;
		private var endCycle:Number = 0.0;
		private var timer:Number = 0.0;
		private var totalTime:Number = 0.0;
		private var gain:Number = 0.2;
		
		

		
		
		public function SoundSynthModule() 
		{
			setEnv(0.1, 0.1, 0.1, 0.1);
			resetFilter();
		}
		
		public function setEnv(_a:Number, _d:Number, _s:Number, _r:Number):void
		{
			envA = _a * 44100.0;
			envD = _d * 44100.0;
			envS = _s * 44100.0;
			envR = _r * 44100.0;
			envAEnd = envA;
			envDEnd = envA + envD;
			envSEnd = envA + envD + envS;
			envREnd = envA + envD + envS + envR;
			totalTime = envA + envD + envS + envR;
		}
		
		public function setPitch(_start:Number, _end:Number):void
		{
			var doublePi:Number = Math.PI * 2.0;
			
			startCycle = doublePi / (44100.0 / _start);
			endCycle = doublePi / (44100.0 / _end);
			cycle = 0.0;
			cursor = 0.0;
		}
		
		public function lerp(a:Number, b:Number, t:Number):Number
		{
			return a + ( b - a ) * t;
		}
		
		public function smoothstep(t:Number):Number
		{
			return t * t * (3 - 2 * t);
		}
		
		public function getEnv():Number
		{
			var env:Number = 0.0;

			if( cursor < envAEnd )
			{
				env = lerp( 0.0, 1.0, smoothstep(( cursor ) / envA) );
			}
			else if( cursor < envDEnd )
			{
				env = lerp( 1.0, 0.5, smoothstep(( cursor - envAEnd ) / envD) );
			}
			else if( cursor < envSEnd )
			{
				env = 0.5;
			}
			else if( cursor < envREnd )
			{
				env = lerp( 0.5, 0.0, smoothstep(( cursor - envSEnd ) / envR) );
			}
			else
			{
				env = 0.0;
			}
			
			return env;
		}
		
		public function setGain(_gain:Number):void
		{
			gain = _gain;
		}
		
		public function getFilter(inData:Number):Number
		{
			var newSample:Number = filterInCoef[0] * inData +
								   filterInCoef[1] * filterInBuf[0] +
								   filterInCoef[2] * filterInBuf[1] -
								   filterOutCoef[0] * filterOutBuf[0] -
								   filterOutCoef[1] * filterOutBuf[1];
			filterInBuf[1] = filterInBuf[0];
			filterInBuf[0] = inData;
			
			filterOutBuf[1] = filterOutBuf[0];
			filterOutBuf[0] = newSample;
			
			return newSample;
		}
		
		public function setLowPassFilter(coef:Number, res:Number):void
		{
			var initCoef:Number = 1.0 / (Math.tan(Math.PI * coef / 44100.0));
			var initCoefPw2:Number = initCoef * initCoef;
			var resonance = ((Math.sqrt(2.0) - 0.1) * (1.0 - res)) + 0.1;
			
			filterInCoef[0] = 1.0 / (1.0 + (resonance * initCoef) + initCoefPw2);
			filterInCoef[1] = 2.0 * filterInCoef[0];
			filterInCoef[2] = filterInCoef[0];
			filterOutCoef[0] = 2.0 * filterInCoef[0] * (1.0 - initCoefPw2);
			filterOutCoef[1] = filterInCoef[0] * (1.0 - resonance * initCoef + initCoefPw2);
		}
		
		public function resetFilter()
		{
			filterInBuf[0] = 0.0;
			filterInBuf[1] = 0.0;
			filterOutBuf[0] = 0.0;
			filterOutBuf[1] = 0.0;

			filterInCoef[0] = 1.0;
			filterInCoef[1] = 0.0;
			filterInCoef[2] = 0.0;
			filterOutCoef[0] = 1.0;
			filterOutCoef[1] = 0.0;
		}
		
		public function sampleCursor():Number
		{
			var val:Number = timer;
			return val;
		}
		
		public function synthSine():Number
		{
			var doublePi:Number = Math.PI * 2.0;
			var val:Number = Math.sin(sampleCursor());
			return val;
		}
		
		public function synthPulse():Number
		{
			var doublePi:Number = Math.PI * 2.0;
			var val:Number = Math.sin(sampleCursor());
			return val * val * val * val;
		}
		
		public function synthSawtooth():Number
		{
			var phase = sampleCursor();
			var val:Number = phase < Math.PI ? ( phase / Math.PI ) : ( ( phase - Math.PI ) / Math.PI ) - 1.0;
			return val;
		}
		
		public function synthSquare():Number
		{
			var phase = sampleCursor();
			var val:Number = phase < Math.PI ? -1.0 : 1.0;
			return val;
		}

		public function process(outBuffer:Vector.<Number>):void
		{
			var i:int = 0;
			for (i = 0; i < outBuffer.length; ++i)
			{
				outBuffer[i] += getFilter(synthSquare() * getEnv()) * gain;
				
				// Advance timer.
				var doublePi:Number = Math.PI * 2.0;
				var lerpVal:Number = cursor / totalTime;
				cycle = lerp(startCycle, endCycle, lerpVal);
				timer += cycle;
				if (timer > doublePi)
					timer -= doublePi;

				
				cursor += 1.0;
			}
		}	
		
		public function isActive():Boolean
		{
			return cursor < totalTime;
		}
	}

}