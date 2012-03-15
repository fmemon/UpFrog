//
//  ThrowRope.mm
//  cutepult
//
//  Created by Saida Memon on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>

// Import the interfaces
#import "ThrowRope.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define FLOOR_HEIGTH    62.0f

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

@interface ThrowRope()

-(void) addLevelBoundaries;
-(void) addNewSpriteWithCoords:(CGPoint)p;


@end

// HelloWorldLayer implementation
@implementation ThrowRope

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ThrowRope *layer = [ThrowRope node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
        
        
        /* Box2D Initialization */
        
        //Set gravity
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        
        //Initialize world
        bool doSleep = YES;
        world = new b2World(gravity, doSleep);
        world->SetContinuousPhysics(YES);
        
        //Initialize debug drawing
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        world->SetDebugDraw(m_debugDraw);
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        m_debugDraw->SetFlags(flags);	
        
        //Create level boundaries
        [self addLevelBoundaries];
        
        //Add batch node for block creation
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
        [self addChild:batch z:0 tag:0];
        
        //Add a new block
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        [self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
        
        //Schedule step method
        [self schedule:@selector(step:)];
    }
	return self;
}

/* Adds a polygonal box around the screen */
-(void) addLevelBoundaries {
/*	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0);
	b2Body *body = world->CreateBody(&groundBodyDef);
    
	b2PolygonShape groundBox;		
    
	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
	body->CreateFixture(&groundBox,0);
    
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
	body->CreateFixture(&groundBox,0);
    
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
	body->CreateFixture(&groundBox,0);
    
	groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
	body->CreateFixture(&groundBox,0);
   */ 
}

/* Adds a textured block */
-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:0];
    
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	//Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	//Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}

/* Draw debug data */
-(void) draw
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

/* Update graphical positions using physical positions */
-(void) step: (ccTime) dt
{	
	int32 velocityIterations = 8;
	int32 positionIterations = 3;
	
	world->Step(dt, velocityIterations, positionIterations);
	
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			CCSprite *obj = (CCSprite*)b->GetUserData();
			obj.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			obj.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

/* Tap to add a block */
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		[self addNewSpriteWithCoords: location];
	}
}

@end

