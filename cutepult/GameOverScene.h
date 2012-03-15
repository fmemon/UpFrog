//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"
#import <UIKit/UIKit.h>

@interface GameOverScene : CCLayer <UITextFieldDelegate, UIAlertViewDelegate>
{
	CCLabelTTF *winner1;
    CCLabelTTF *winner2;
    CCLabelTTF *winner3;
	CCLabelTTF *HS1;
    CCLabelTTF *HS2;
    CCLabelTTF *HS3;
    int newHS;
    int H1;
    int H2;
    int H3;
    NSString* W1;
    NSString* W2;
    NSString* W3;
    
    NSString *newWinner;
    
    CCLabelTTF* tapLabel;
    CCLabelTTF* newHSlabel;
    UITextField* myTextField;
    
    BOOL muted;

}

+(id) scene;
- (void)saveData;
- (void)restoreData;
- (void)testScore;
- (void)printScores;
-(void)setLabels;

@end
