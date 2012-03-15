//NOTE: We've added b2RopeJoint to our Box2D distribution here.
//When I finally upgrade all the recipes to the latest version of Cocos2d, Box2D should have b2RopeJoint.
//If not I'll have to add it back.


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

@interface ThrowRope  : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
	bool onRope;
	b2Body* anchorBody;
	CCSpriteBatchNode* ropeSpriteSheet;
	NSMutableArray* vRopes;
	float ropeUseTimer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
//-(void) step:(ccTime)delta;
//-(void) addRopeAnchor;
//-(void) useRope;
//-(void) releaseRope;
+(CCScene *) scene;

@end

