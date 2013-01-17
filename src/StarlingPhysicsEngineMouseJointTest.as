package
{
	import com.jack.physicsEngine.box2d.RootForBox2D;
	import com.jack.physicsEngine.nape.RootForNape;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#33333333")]
	public class StarlingPhysicsEngineMouseJointTest extends Sprite
	{
		public function StarlingPhysicsEngineMouseJointTest()
		{
			super();
			
			if(stage)
				init(null);
			else 
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
			Starling.handleLostContext = !iOS;
			Starling.multitouchEnabled = true;
			
			var viewPort:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			
			// change RootForNape to RootForBox2D if you want test performance on Box2D
			var m_starling:Starling = new Starling(RootForBox2D, stage, viewPort);
			m_starling.showStats = true;
			m_starling.start();
		}
	}
}