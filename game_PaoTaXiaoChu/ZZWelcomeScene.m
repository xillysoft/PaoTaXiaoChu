//
//  ZZWelcomeScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZWelcomeScene.h"
#import "ZZChooseLevelsScene.h"

@interface ZZWelcomeScene ()
//@property CGFloat scale;
@property BOOL musicOn;
@property BOOL soundOn;
@end


@implementation ZZWelcomeScene

-(void)didMoveToView:(SKView *)view
{
    self.musicOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"SETTING_MUSIC_ON"];
    self.soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"SETTING_SOUND_ON"];
    SKNode *node = [SKNode node]; //container node
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_0.png"];
    //the scale between scene's real size and background picture's size
    CGFloat scale = MAX(self.size.width/background.size.width, self.size.height/background.size.height);

    background.anchorPoint = CGPointMake(0.5, 0.5);
    background.position = CGPointZero;
    [node addChild:background];
    
    SKSpriteNode *buttonStart = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Start.png"];
    buttonStart.name = @"BUTTON_START";
    buttonStart.position = CGPointMake(0, -50);
    [node addChild:buttonStart];
    
    SKSpriteNode *buttonMusic = [SKSpriteNode spriteNodeWithImageNamed:self.musicOn ? @"UI_Btn_Music_1.png" : @"UI_Btn_Music_2"];
    buttonMusic.name = @"BUTTON_MUSIC";
    buttonMusic.anchorPoint = CGPointMake(0.5, 0.5);
    //positioned at lower-left corner of the scene
    CGPoint position1 = CGPointMake(-self.size.width/scale/2+buttonMusic.size.width/2+50.0*scale, -self.size.height/scale/2+buttonMusic.size.height/2+30.0*scale);
    buttonMusic.position = position1;
    [node addChild:buttonMusic];
    
    SKSpriteNode *buttonSound = [SKSpriteNode spriteNodeWithImageNamed:self.soundOn ? @"UI_Btn_Sound.png" : @"UI_Btn_Sound_2.png"];
    buttonSound.name = @"BUTTON_SOUND";
    buttonSound.anchorPoint = CGPointMake(0.5, 0.5);
    buttonSound.position = CGPointMake(position1.x+buttonMusic.size.width/2+50+buttonSound.size.width/2, position1.y);
    [node addChild:buttonSound];
    
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    node.position = CGPointZero;
    [self addChild:node];
    node.xScale = scale; node.yScale = scale;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKNode *nodeTouched = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if([nodeTouched.name isEqualToString:@"BUTTON_START"]){
        SKAction *actionScale = [SKAction scaleBy:1.4 duration:0.1];
        [nodeTouched runAction:actionScale
             completion:^{
                 ZZChooseLevelsScene *scene = [[ZZChooseLevelsScene alloc] initWithSize:self.size];
                 [self.view presentScene:scene transition:[SKTransition flipVerticalWithDuration:0.3]];
                 [nodeTouched runAction:[actionScale reversedAction]];
             }];
    }else if([nodeTouched.name isEqualToString:@"BUTTON_MUSIC"]){
        self.musicOn = !self.musicOn;
        [[NSUserDefaults standardUserDefaults] setBool:self.musicOn forKey:@"SETTING_MUSIC_ON"];
        SKTexture *texture = [SKTexture textureWithImageNamed: self.musicOn ? @"UI_Btn_Music_1.png" : @"UI_Btn_Music_2.png"];
        SKAction *actionScale = [SKAction scaleBy:0.8 duration:0.06];
        [nodeTouched runAction:[SKAction sequence:@[
                                             actionScale,
                                             [SKAction setTexture:texture],
                                             [actionScale reversedAction],
                                             ]]];
    }else if([nodeTouched.name isEqualToString:@"BUTTON_SOUND"]){
        SKTexture *texture = [SKTexture textureWithImageNamed: self.soundOn ? @"UI_Btn_Sound.png" : @"UI_Btn_Sound_2.png"];
        [[NSUserDefaults standardUserDefaults] setBool:self.soundOn forKey:@"SETTING_SOUND_ON"];
        SKAction *actionScale = [SKAction scaleBy:0.8 duration:0.06];
        [nodeTouched runAction:[SKAction sequence:@[
                                                    actionScale,
                                                    [SKAction setTexture:texture],
                                                    [actionScale reversedAction],
                                                    ]]];
        
        self.soundOn = !self.soundOn;
    }
}

@end
