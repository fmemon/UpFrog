//
//  ComboSeeMe.mm
//  CompoundBody
//
//  Created by Saida Memon on 3/8/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "ComboSeeMe.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};



/** Convert the given position into the box2d world. */
static inline float ptm(float d)
{
    return d / PTM_RATIO;
}

/** Convert the given position into the cocos2d world. */
static inline float mtp(float d)
{
    return d * PTM_RATIO;
}

// ComboSeeMe implementation
@implementation ComboSeeMe

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ComboSeeMe *layer = [ComboSeeMe node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(id)init

{
    
    if( (self=[super init])) { 
        
        // enable touches
        //self.isTouchEnabled = YES; 
        
        // enable accelerometer        
        self.isAccelerometerEnabled = YES; 
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
                
        // Define the gravity vector.
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f); 
                
        // This will speed up the physics simulation
        bool doSleep = true; 
        
        // Construct a world object, which will hold and simulate the rigid bodies.
        world = new b2World(gravity, doSleep); 
        world->SetContinuousPhysics(true); 
        
        stopWater = TRUE;
        muted = FALSE;

        
        b2Body* ground = NULL;
        b2BodyDef bd;
        ground = world->CreateBody(&bd);
        
        bodyDef.type=b2_dynamicBody;
        b2Vec2 initVel;
        b2EdgeShape edge;      
        b2CircleShape circleShape;
        b2FixtureDef fd;
        b2RevoluteJointDef revJointDef;
        b2DistanceJointDef jointDef;
        b2Vec2 pos;
        
        //Box
        b2BodyDef groundBodyDef;
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        edge.Set(b2Vec2(0.000000f, 0.000000f), b2Vec2(15.000000f, 0.000000f)); //bottom wall
        _bottomFixture = groundBody->CreateFixture(&edge,0);
        edge.Set(b2Vec2(15.000000f, 0.000000f), b2Vec2(15.000000f, 10.000000f)); //right wall
        _rightFixture = groundBody->CreateFixture(&edge,0);
        edge.Set(b2Vec2(15.000000f, 10.000000f), b2Vec2(0.000000f, 10.000000f)); //top wall
        _topFixture = groundBody->CreateFixture(&edge,0);
        edge.Set(b2Vec2(0.000000f, 10.000000f), b2Vec2(0.000000f, 0.000000f)); //;left wall
        _leftFixture = groundBody->CreateFixture(&edge,0);
              
        walls = [[NSArray alloc] initWithObjects:   [NSValue valueWithPointer:_bottomFixture], 
                                                    [NSValue valueWithPointer:_topFixture], 
                                                    [NSValue valueWithPointer:_leftFixture],
                                                    [NSValue valueWithPointer:_rightFixture], nil];

        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"froggie.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"froggie.png"];
        [self addChild:spriteSheet];
        sprite = [CCSprite spriteWithSpriteFrameName:@"froggie1.png"];     
        [self addChild:sprite z:1 tag:88];
        [sprite runAction:[self createBlinkAnim:YES]];

        //add the score sprites
        score100 = [CCSprite spriteWithSpriteFrameName:@"score100.png"];     
        score200 = [CCSprite spriteWithSpriteFrameName:@"score200.png"];     
        score500 = [CCSprite spriteWithSpriteFrameName:@"score500.png"];     
        score100.position = ccp(screenSize.width/2, 30.0f);
        score200.position = ccp(screenSize.width/2, 30.0f);
        score500.position = ccp(screenSize.width/2, 30.0f);
        [score100 setOpacity:0];
        [score200 setOpacity:0];
        [score500 setOpacity:0];
        [self addChild:score100 z:11 tag:100];
        [self addChild:score200 z:11 tag:200];
        [self addChild:score500 z:11 tag:500];
        
        CCSprite *sprite2 = [CCSprite spriteWithFile:@"u13BMine.png"];
        sprite2.anchorPoint = CGPointZero;
        [self addChild:sprite2 z:-11];
        
        //Circles
        //circle2
        bodyDef.userData = sprite;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(0.468085f, 9.574468f);
        bodyDef.angle = 0.000000f;
        circle2 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        circle2->SetLinearVelocity(initVel);
        circle2->SetAngularVelocity(0.000000f);
        circleShape.m_radius = 0.406489f;
        fd.shape = &circleShape;
        fd.density = 1.0f;
        fd.friction = 1.0f;
        fd.restitution = 0.9f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        _ballFixture = circle2->CreateFixture(&fd);

        // +++ Add rope spritesheet to layer
        ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"newrope.png" ];
        [self addChild:ropeSpriteSheet];
    
        
        //paddle code
        // Create paddle and add it to the layer
        //CCSprite *paddle = [CCSprite spriteWithFile:@"newPaddle.png"];
        CCSprite *paddle = [CCSprite spriteWithSpriteFrameName:@"newPaddle.png"];
        paddle.position = ccp(screenSize.width/2, 50/PTM_RATIO);
        [self addChild:paddle z:1 tag:11];
         
       //static body 4
        b2PolygonShape shape;
        bodyDef1.type = b2_staticBody;
        bodyDef1.userData = paddle;
        bodyDef1.position.Set(screenSize.width/2/PTM_RATIO, 50/PTM_RATIO);
        b2Body* staticBody4 = world->CreateBody(&bodyDef1);
        shape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, paddle.contentSize.height/PTM_RATIO/2);
        fd.shape = &shape;
        staticBody4->CreateFixture(&fd);
        

        
         // +++ Init array that will hold references to all our ropes
         vRopes = [[NSMutableArray alloc] init];
        
        // +++ Create box2d joint
        rjd.bodyA=staticBody4; //define bodies
        rjd.bodyB=circle2;
        rjd.localAnchorA = b2Vec2(0,0); //define anchors
        rjd.localAnchorB = b2Vec2(0,0);
        rjd.maxLength= (circle2->GetPosition() - staticBody4->GetPosition()).Length(); //define max length of joint = current distance between bodies
        rjd.collideConnected = true;
        world->CreateJoint(&rjd); //create joint
        VRope *newRope = [[VRope alloc] init:staticBody4 body2:circle2 spriteSheet:ropeSpriteSheet];
        [vRopes addObject:newRope];
        
        [self schedule: @selector(tick:)]; 
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        // Create contact listener
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        // Preload effect
        [MusicHandler preload];

        //initialize the score
        score  = 0;
        highscore = 0;
                
 
        highscoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HighScore: %i",highscore] fontName:@"Arial" fontSize:24];
        highscoreLabel.color = ccc3(26, 46, 149);
        highscoreLabel.position = ccp(340.0f, 300.0f);
        [self addChild:highscoreLabel z:10];
        
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"       Score: %i",score] fontName:@"Arial" fontSize:24];
        scoreLabel.position = ccp(340.0f, 280.0f);
        scoreLabel.color = ccc3(26, 46, 149);
        [self addChild:scoreLabel z:10];
        
        [self restoreData];
        // Enable touches        
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        //Pause Toggle can not sure frame cache for sprites!!!!!
		/*
         CCMenuItemSprite *playItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseON.png"]
         selectedSprite:[CCSprite spriteWithFile:@"newPauseONSelect.png"]];
         
         CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseOFF.png"]
         selectedSprite:[CCSprite spriteWithFile:@"newPauseOFFSelect.png"]];
         CCMenuItemToggle *pause;
         if (!muted)  {
         pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:playItem, pauseItem, nil];
         pause.position = ccp(screenSize.width*0.05, screenSize.height*0.95f);
         }
         else {
         pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:pauseItem, playItem, nil];
         pause.position = ccp(screenSize.width*0.05, screenSize.height*0.95f);
         }
         
         
         //Create Menu with the items created before
         CCMenu *menu = [CCMenu menuWithItems:pause, nil];
         menu.position = CGPointZero;
         [self addChild:menu z:11];
         */
    }
    return self; 
}

- (void)turnOnMusic {
    if ([[SimpleAudioEngine sharedEngine] mute]) {
        // This will unmute the sound
        muted = FALSE;
    }
    else {
        //This will mute the sound
        muted = TRUE;
    }
    [[SimpleAudioEngine sharedEngine] setMute:muted];    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:muted forKey:@"IsMuted"];
    [defaults synchronize];
}

- (void)updateScore {
    [scoreLabel setString:[NSString stringWithFormat:@"       Score: %i",score]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"score"];
    [defaults synchronize];

    
}
- (void)saveData {   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"newHS"];
    [defaults synchronize];
}

- (void)restoreData {
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:@"HS1"]) {
        highscore = [defaults integerForKey:@"HS1"];
        [highscoreLabel setString:[NSString stringWithFormat:@"HighScore: %i",highscore]];
    }
    
    if ([defaults boolForKey:@"IsMuted"]) {
        muted = [defaults boolForKey:@"IsMuted"];
    }
    
    //NSLog(@"Is muted value afterward %d", muted);
}

- (CCAction*)createBlinkAnim:(BOOL)isTarget {
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<5; i++) {
        //[walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"blinker%dsm.png", i]]];
        [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"froggie%d.png", i]]];
    }
    
    CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.2f];
    
    CCAnimate *blink = [CCAnimate actionWithDuration:0.4f animation:walkAnim restoreOriginalFrame:YES];
    
    CCAction *walkAction = [CCRepeatForever actionWithAction:
                            [CCSequence actions:
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*2.0f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*3.0f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*0.2f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*2.0f],
                             nil]
                            ];
    return walkAction;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	// +++ Update rope sprites
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] updateSprites];
	}
}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
            
            if (sprite.tag == 1) {
                static int maxSpeed = 10;
                
                b2Vec2 velocity = b->GetLinearVelocity();
                float32 speed = velocity.Length();
                
                if (speed > maxSpeed) {
                    b->SetLinearDamping(0.5);
                } else if (speed < maxSpeed) {
                    b->SetLinearDamping(0.0);
                }
                
            }
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}

	// +++ Update rope physics
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] update:dt];
	}
            
    // Loop through all of the box2d bodies that are currently colliding, that we have
    // gathered with our custom contact listener...
    std::vector<MyContact>::iterator pos;
    for(pos = contactListener->_contacts.begin(); pos != contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        // Get the box2d bodies for each object
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            // Is sprite A a cat and sprite B a car? 
            if (spriteA.tag == 88 && spriteB.tag == 11) {
                [self scored:bodyB];
            } 
            // Is sprite A a car and sprite B a cat?  
            else if (spriteA.tag == 11 && spriteB.tag == 88) {
                [self scored:bodyB];
            } 
        }  
        
        for (NSData *fixtureData in walls)
        {
            b2Fixture *fixture;
            fixture = (b2Fixture*)[fixtureData pointerValue];
                        
            if ((contact.fixtureA == fixture && contact.fixtureB == _ballFixture) ||
                (contact.fixtureA == _ballFixture && contact.fixtureB == fixture)) {
                // NSLog(@"Ball hit bottom!");
                
                if (contact.fixtureA == _bottomFixture  || contact.fixtureB == _bottomFixture) {
                    b2Body *bodyB = contact.fixtureB->GetBody();
                    [self endGame:bodyB];
                }
                else {
                }
            } 
        } 
    }
}

- (void)scored:(b2Body*)bodyB {
    [MusicHandler playBounce];
    [self callEmitter:bodyB];
    [self applyPush:bodyB];  
    [self updateScore];
}

- (void)endGame:(b2Body*)bodyB {
    if (stopWater) {[MusicHandler playWater];
    stopWater = FALSE;
    //[self callWaterEmitter:bodyB];
    [self callEmitter:bodyB];
    bodyB->SetLinearVelocity(b2Vec2(0,0));
    bodyB->SetAngularVelocity(0);
    
    [self saveData];
    [self performSelector:@selector(gotoHS) withObject:nil afterDelay:0.3];
    }
}

- (void)gotoHS {
    [[CCDirector sharedDirector] replaceScene:[GameOverScene node]];
}

- (void)applyPush:(b2Body*)bodyB  {
   // CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    float xStrength = abs(bodyB->GetPosition().x - 8) + 1;
    //NSLog(@"XSTRENGTH VALUE: %0.0f", xStrength);
    //NSLog(@"X value: %0.0f and screen %0.0f", bodyB->GetPosition().x, screenSize.width/2 );

    CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
    if (spriteB.tag == 88) {
        //b2Vec2 force = b2Vec2(0.2 + 1/xStrength/8, 0.2 + 1/xStrength/8);
        b2Vec2 force = b2Vec2(0.2 * xStrength, 0.2 * xStrength);
        bodyB->ApplyLinearImpulse(force, bodyB->GetPosition());

        if (xStrength >= 3.0f) {
            [score500 runAction:[CCFadeOut actionWithDuration:0.5f]];   //0 to 255 
            score +=500;
        } else if (xStrength >= 2.0f) {
            [score200 runAction:[CCFadeOut actionWithDuration:0.5f]];   //0 to 255 
            score +=200;
        } else if (xStrength >= 1.0f) {
            [score100 runAction:[CCFadeOut actionWithDuration:0.5f]];   //0 to 255 
            score +=100;
        } 
    }
}

-(void)callEmitter:(b2Body*)bodyB {    
    int xStrength = int(abs(bodyB->GetPosition().x - 8)) + 1;
    int numParticle = 30 +CCRANDOM_0_1()*200 * xStrength;
    myEmitter = [[CCParticleExplosion alloc] initWithTotalParticles:numParticle];
    myEmitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"goldstars1.png"];
    myEmitter.position = CGPointMake( mtp(bodyB->GetPosition().x) ,  mtp(bodyB->GetPosition().y));
    myEmitter.life =0.4f + CCRANDOM_0_1()*0.2 * xStrength;
    myEmitter.duration = 0.3f + CCRANDOM_0_1()*0.35 * xStrength;
    myEmitter.scale = 0.5f;
    //myEmitter.scale = 0.3 + CCRANDOM_0_1()*0.2 * xStrength;
    myEmitter.speed = 50.0f + CCRANDOM_0_1()*50.0f * xStrength;
    //For not showing color
    myEmitter.blendAdditive = YES;
    [self addChild:myEmitter z:11];
    myEmitter.autoRemoveOnFinish = YES;
    
    //NSLog(@" Y values %0.0f Xstrength  %d Speed value: %0.0f  numparticles %d  myemtterspped %f myemitetrscale %0.0f", bodyB->GetPosition().y,xStrength,speed, numParticle, myEmitter.speed, myEmitter.scale);
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}


/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mouseJoint == nil) return;

    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mouseJoint == nil) return;
    

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

*/

-(void)removeRopes {
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] removeSprites];
		[[vRopes objectAtIndex:i] release];
	}
	[vRopes removeAllObjects];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
//    To remove a rope you need to call the removeSprites method and then release:
    [self removeRopes]; //remove the sprites of this rope from the spritebatchnode
    [VRope release];
    
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    delete contactListener;
    
    [walls release];
    
    //IF you have particular spritesheets to be removed! Don't use these if you haven't any
    //[[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"froggie.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:@"froggie.png"];
    
    //Use these
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    
    //Use these
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCDirector sharedDirector] purgeCachedData];
    
    //Try out and use it. Not compulsory
    [self removeAllChildrenWithCleanup: YES];
    
    [myEmitter release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
