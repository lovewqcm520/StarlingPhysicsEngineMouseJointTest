package com.jack.physicsEngine.nape
{
	import nape.phys.Body;
	
	import com.jack.physicsEngine.IPhysGraphicUpdate;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class BoxForNape extends Sprite implements IPhysGraphicUpdate
	{
		[Embed(source="../assets/box.png")]
		private static var BoxImage:Class;
		
		private static var boxTexture:Texture = Texture.fromBitmap(new BoxImage());
		
		private var _napeBody:Body;
		
		public function BoxForNape()
		{
			super();
			
			addChild(new Image(boxTexture));
		}
		
		public function setBody(body:Body):void
		{
			_napeBody = body;
		}
		
		public function graphicUpdate():void
		{
			if(_napeBody)
			{
				this.x = _napeBody.position.x;
				this.y = _napeBody.position.y;
				this.rotation = _napeBody.rotation;
			}
		}
	}
}