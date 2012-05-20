package  
{
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.events.SampleDataEvent;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SoundSynth extends EventDispatcher
	{
		public static var midiNotes:Array = [
			8.18,
			8.66,
			9.18,
			9.72,
			10.3,
			10.91,
			11.56,
			12.25,
			12.98,
			13.75,
			14.57,
			15.43,
			16.35,
			17.32,
			18.35,
			19.45,
			20.6,
			21.83,
			23.12,
			24.5,
			25.96,
			27.5,
			29.14,
			30.87,
			32.7,
			34.65,
			36.71,
			38.89,
			41.2,
			43.65,
			46.25,
			49.0,
			51.91,
			55.0,
			58.27,
			61.74,
			65.41,
			69.3,
			73.42,
			77.78,
			82.41,
			87.31,
			92.5,
			98.0,
			103.83,
			110.0,
			116.54,
			123.47,
			130.81,
			138.59,
			146.83,
			155.56,
			164.81,
			174.61,
			185.0,
			196.0,
			207.65,
			220.0,
			233.08,
			246.94,
			261.63,
			277.18,
			293.66,
			311.13,
			329.63,
			349.23,
			369.99,
			392.0,
			415.3,
			440.0,
			466.16,
			493.88,
			523.25,
			554.37,
			587.33,
			622.25,
			659.26,
			698.46,
			739.99,
			783.99,
			830.61,
			880.0,
			932.33,
			987.77,
			1046.5,
			1108.73,
			1174.66,
			1244.51,
			1318.51,
			1396.91,
			1479.98,
			1567.98,
			1661.22,
			1760.0,
			1864.66,
			1975.53,
			2093.0,
			2217.46,
			2349.32,
			2489.02,
			2637.02,
			2793.83,
			2959.96,
			3135.96,
			3322.44,
			3520.0,
			3729.31,
			3951.07,
			4186.01,
			4434.92,
			4698.64,
			4978.03,
			5274.04,
			5587.65,
			5919.91,
			6271.93,
			6644.88,
			7040.0,
			7458.62,
			7902.13,
			8372.02,
			8869.84,
			9397.27,
			9956.06,
			10548.08,
			11175.3,
			11839.82,
			12543.85
		];
		
		private var sound:Sound = new Sound();
		
		private var modules:Array = new Array();
		
		private var totalProcessed:int = 0;
		private var totalTime:Number = 0.0;

		public function SoundSynth() 
		{
			var i:int = 0;
			for (i = 0; i < modules.length; ++i)
			{
				modules[i] = new SoundSynthModule();
			}
		}
		
		public function start():void
		{
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
		}
		
		public function stop():void
		{
			sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.close();
		}
		
		public function getSynth():SoundSynthModule
		{
			var synth:SoundSynthModule = new SoundSynthModule();
			modules.push(synth);
			return synth;
		}
		
		public function getTotalTime():Number
		{
			return totalTime;
		}
		
		private function onSampleData(event:SampleDataEvent):void
		{
			var i:int = 0;
			var outBuffer:Vector.<Number> = new Vector.<Number>(2048);
			super.dispatchEvent(new SoundSynthProcessEvent("PreProcess", outBuffer.length / 44100.0, event.position));
			
			for (i = 0; i < modules.length; ++i)
			{
				modules[i].process(outBuffer);
			}
			
			var newModules:Array = new Array;
			for (i = 0; i < modules.length; ++i)
			{
				var module:SoundSynthModule = modules[i];
				if (module.isActive())
				{
					newModules.push(module);
				}
			}
			modules = newModules;
			
			//trace(modules.length);
			
			for(i = 0; i < outBuffer.length; i++)
			{
				var sample:Number = outBuffer[i];
				event.data.writeFloat(sample); // left
				event.data.writeFloat(sample); // right
			}
			
			// advance total processed.
			totalProcessed += modules.length;
			totalTime = totalProcessed / 44100.0;
		}		
	}
}