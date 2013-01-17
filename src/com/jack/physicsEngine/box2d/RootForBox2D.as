package com.jack.physicsEngine.box2d
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class RootForBox2D extends Sprite
	{
		private var world:b2World;
		private var mouseJoint:b2MouseJoint;
		private var touch:Touch;
		
		public static const m_physFactor:Number = 30;
		private var numBoxes:int = 500;
		private var helperVec:b2Vec2;
		
		public function RootForBox2D()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			world = new b2World(new b2Vec2(0, 0), true);
			
			setup();
			
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			stage.addEventListener(Event.ENTER_FRAME, loop);
		}		
		
		private function loop(e:Event):void
		{
			if(mouseJoint)
			{
				helperVec.x = Starling.current.nativeStage.mouseX/m_physFactor;
				helperVec.y = Starling.current.nativeStage.mouseY/m_physFactor;
				mouseJoint.SetTarget(helperVec);
			}
			
			world.Step(1/60, 5, 5);
			world.ClearForces();
			
			var body:b2Body = world.GetBodyList();
			
			while(body)
			{
				if(body.GetUserData() && Object(body.GetUserData()).graphicUpdate)
				{
					Object(body.GetUserData()).graphicUpdate();
				}
				
				body = body.GetNext();
			}
		}
		
		private function setup():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;
	
			createBox(w/2, 0, w, 1, true);
			createBox(w, h/2, 1, h, true);
			createBox(w/2, h, w, 1, true);
			createBox(0, h/2, 1, h, true);
			
			var box:BoxForBox2D;
			var body:b2Body;
			for (var i:int = 0; i < numBoxes; i++) 
			{
				box = new BoxForBox2D();
				box.pivotX = box.width >> 1;
				box.pivotY = box.height >> 1;
				addChild(box);	
				
				createBox(Math.random()*w, Math.random()*h, box.width, box.height, false, box);
			}
			
			helperVec = new b2Vec2();
		}
		
		private function createBox(x:Number, y:Number, w:Number, h:Number, isStatic:Boolean, userData:DisplayObject=null):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = isStatic ? b2Body.b2_staticBody : b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/m_physFactor, y/m_physFactor);
			
			var body:b2Body = world.CreateBody(bodyDef);
			
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsBox(w/m_physFactor/2, h/m_physFactor/2);
			
			var fixture:b2FixtureDef = new b2FixtureDef();
			fixture.shape = shape;
			fixture.density = 1;
			fixture.friction = 0.3;
			
			body.CreateFixture(fixture);
			
			if(userData)
			{
				body.SetUserData(userData);
				if(userData["setBody"])
				{
					userData["setBody"](body);
				}
			}
			
			return body;
		}
		
		private function onTouch(e:TouchEvent):void
		{
			touch = e.getTouch(stage);
			
			if(!touch)	return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				//var bodies:BodyList = world.QueryPoint(
				var body:b2Body = getBodyAtMouse();
				
				if(body)
				{
					if(!mouseJoint)
					{
						var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
						mouseJointDef.bodyA = world.GetGroundBody();
						mouseJointDef.bodyB = body;
						mouseJointDef.target.Set(Starling.current.nativeStage.mouseX/m_physFactor, Starling.current.nativeStage.mouseY/m_physFactor);
						mouseJointDef.maxForce = 300*body.GetMass();
						mouseJointDef.collideConnected = true;
						
						mouseJoint = world.CreateJoint(mouseJointDef) as b2MouseJoint;
						body.SetAwake(true);
					}
				}
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				if(mouseJoint)
				{
					world.DestroyJoint(mouseJoint);
					mouseJoint = null;
				}
			}
		}
		
		private function getBodyAtMouse():b2Body
		{
			var mouseVec:b2Vec2 = new b2Vec2(Starling.current.nativeStage.mouseX/m_physFactor, Starling.current.nativeStage.mouseY/m_physFactor);
			var body:b2Body;
			
			function queryPointCallBack(fixture:b2Fixture):Boolean
			{
				if(!fixture)	return true;
				
				body = fixture.GetBody();
				
				if(body.GetType() == b2Body.b2_staticBody)
					return true
				
				return false;
			}
			
			world.QueryPoint(queryPointCallBack, mouseVec);
			
			return body;
		}
		
	}
}