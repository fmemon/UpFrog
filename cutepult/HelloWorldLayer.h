//
//  HelloWorldLayer.h
//  cutepult
//
//  Created by Saida Memon on 3/1/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "VRope.h"
#import "MusicHandler.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
    b2Fixture *armFixture;
    b2Body *armBody;
    b2RevoluteJoint *armJoint;
    b2MouseJoint *mouseJoint;
    b2Body *groundBody;
    
    NSMutableArray *bullets;
    int currentbullet;
    
    b2Body *bulletBody;
    b2WeldJoint *bulletJoint;
    
    BOOL releasingArm;
    
    NSMutableSet *targets;
    NSMutableSet *enemies;
    
    MyContactListener *contactListener;
    
	b2Body* anchorBody; //reference to anchor body
	CCSpriteBatchNode* ropeSpriteSheet; //sprite sheet for rope segment
	NSMutableArray* vRopes; //array to hold rope references
    
   // b2Body *squirrel;
	b2Body* ranchorBody; //reference to anchor body
}



// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
