package com.jack.physicsEngine.box2d
{
	import Box2D.Dynamics.b2Body;
	
	import com.jack.physicsEngine.IPhysGraphicUpdate;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class BoxForBox2D extends Sprite implements IPhysGraphicUpdate
	{
		[Embed(source="../assets/box.png")]
		private static var BoxImage:Class;
		
		private static var boxTexture:Texture = Texture.fromBitmap(new BoxImage());
		
		private var _box2dBody:b2Body;
		
		public function BoxForBox2D()
		{
			super();
			
			addChild(new Image(boxTexture));
		}
		
		public function setBody(body:b2Body):void
		{
			_box2dBody = body;
		}
		
		public function graphicUpdate():void
		{
			if(_box2dBody)
			{
				this.x = _box2dBody.GetPosition().x*RootForBox2D.m_physFactor;
				this.y = _box2dBody.GetPosition().y*RootForBox2D.m_physFactor;
				this.rotation = _box2dBody.GetAngle();
			}
		}
	}
}