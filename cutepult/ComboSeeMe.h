//
//  ComboSeeMe.h
//  CompoundBody
//
//  Created by Saida Memon on 3/8/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "VRope.h"
#import "MusicHandler.h"

// ComboSeeMe
@interface ComboSeeMe : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
    b2RopeJointDef jd;
    b2Body *body;
    CCSprite *sprite;
    NSMutableArray* vRopes; //array to hold rope references
    b2Body* circle2;
    b2MouseJoint *mouseJoint;
    b2BodyDef bodyDef1;
    b2BodyDef bodyDef;
    CCSpriteBatchNode* ropeSpriteSheet; //sprite sheet for rope segment

//Call it Ball and Chain    
    
    
   //Breakout
    b2Fixture *_ballFixture;
    
    b2Body *_paddleBody;
    b2Fixture *_paddleFixture;
    b2Body * ballBody;
    
    b2CircleShape dynamicBox;
    b2FixtureDef fixtureDef;
    b2MouseJoint *_mouseJoint;


    //2 circles
    b2Body* anchorBody; //reference to anchor body

    MyContactListener *contactListener;
    
    b2Fixture *_bottomFixture;
    b2Fixture *_topFixture;
    b2Fixture *_leftFixture;
    b2Fixture *_rightFixture;
    
    NSArray *walls;
    BOOL shattered;
    CCSpriteBatchNode* spriteSheet;
    
    int score;
    int highscore;
    CCLabelTTF *highscoreLabel;
    CCLabelTTF *scoreLabel;
    
    BOOL muted;

    //score sprites
    CCSprite *score100;
    CCSprite *score200;
    CCSprite *score500;
    CCParticleExplosion *myEmitter;
    
    BOOL stopWater;

}

// returns a CCScene that contains the ComboSeeMe as the only child
+(CCScene *) scene;
- (CCAction*)createBlinkAnim:(BOOL)isTarget;
- (void)callEmitter:(b2Body*)bodyB;
- (void)updateScore;
- (void)saveData;
- (void)restoreData;
- (void)applyPush:(b2Body*)bodyB;
- (void)scored:(b2Body*)bodyB;
-(void)endGame:(b2Body*)bodyB;
- (void)gotoHS;

@end
