package com.jack.physicsEngine.nape
{
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class RootForNape extends Sprite
	{
		private var space:Space;
		private var pivotJoint:PivotJoint;

		private var touch:Touch;
		private var numBoxes:int = 500;
		
		public function RootForNape()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			space = new Space(new Vec2(0, 0));
			
			setup();
			
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			stage.addEventListener(Event.ENTER_FRAME, loop);
		}		
		
		private function loop(e:Event):void
		{
			if(pivotJoint.active)
			{
				pivotJoint.anchor1.setxy(Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY);
			}
			
			space.step(1/60, 10, 10);
			
			var len:int = space.liveBodies.length;
			var body:Body;
			for (var i:int = 0; i < len; i++) 
			{
				body = space.liveBodies.at(i);
				if(body.userData && body.userData.graphicUpdate)
				{
					body.userData.graphicUpdate();
				}
			}
		}
		
		private function setup():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;
			
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(0, 0, w, 1)));
			border.shapes.add(new Polygon(Polygon.rect(0, h, w, 1)));
			border.shapes.add(new Polygon(Polygon.rect(0, 0, 1, h)));
			border.shapes.add(new Polygon(Polygon.rect(w, 0, 1, h)));
			border.space = space;
			
			var box:BoxForNape;
			var body:Body;
			for (var i:int = 0; i < numBoxes; i++) 
			{
				box = new BoxForNape();
				box.pivotX = box.width >> 1;
				box.pivotY = box.height >> 1;
				addChild(box);	
				
				body = new Body(BodyType.DYNAMIC);
				body.shapes.add(new Polygon(Polygon.box(box.width, box.height, true)));
				body.position.setxy(Math.random()*w, Math.random()*h);
				body.space = space;
				
				box.setBody(body);
				body.userData.graphic = box;
				body.userData.graphicUpdate = box.graphicUpdate;
			}
			
			pivotJoint = new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
			pivotJoint.space = space;
			pivotJoint.active = false;
			pivotJoint.stiff = false;
			pivotJoint.maxForce = 60000;
			pivotJoint.frequency = 4;
			//pivotJoint.frequency = 10;
			//pivotJoint.damping = 10;
			//pivotJoint.breakUnderForce = true;
		}
		
		private function onTouch(e:TouchEvent):void
		{
			touch = e.getTouch(stage);
			
			if(!touch)	return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				var mouseVec:Vec2 = Vec2.get(Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY);
				var bodies:BodyList = space.bodiesUnderPoint(mouseVec);
				var body:Body;
				
				for (var i:int = 0; i < bodies.length; i++) 
				{
					body = bodies.at(i);
					
					if(!body.isDynamic())
						continue;
					
					pivotJoint.body2 = body;
					pivotJoint.anchor2.set(body.worldPointToLocal(mouseVec, true));
					pivotJoint.active = true;
					
					break;
				}
				
				mouseVec.dispose();
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				pivotJoint.active = false;
			}
		}
		
	}
}