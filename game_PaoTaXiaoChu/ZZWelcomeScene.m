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
@property CGFloat scale;
@property BOOL musicOn;
@property BOOL soundOn;
@end


@implementation ZZWelcomeScene

-(void)didMoveToView:(SKView *)view
{
    self.musicOn = YES;
    self.soundOn = YES;
    
    CGSize size = self.size;
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_0.png"];
    self.scale = MAX(self.size.width/background.size.width, self.size.height/background.size.height);
    background.xScale = self.scale; background.yScale = self.scale;
    background.position = CGPointMake(size.width/2, size.height/2);
    [self addChild:background];
    
    SKSpriteNode *buttonStart = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Start.png"];
    buttonStart.name = @"BUTTON_START";
    buttonStart.xScale = self.scale; buttonStart.yScale = self.scale;
    buttonStart.position = CGPointMake(size.width/2, size.height*0.4);
    [self addChild:buttonStart];
    
    SKSpriteNode *buttonMusic = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Music_1.png"];
    buttonMusic.name = @"BUTTON_MUSIC";
    buttonMusic.anchorPoint = CGPointMake(0.5, 0.5);
    buttonMusic.xScale = self.scale; buttonMusic.yScale = self.scale;
    buttonMusic.position = CGPointMake(10+buttonMusic.size.width/2, 5+buttonMusic.size.height/2);
    [self addChild:buttonMusic];
    
    SKSpriteNode *buttonSound = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Sound.png"];
    buttonSound.name = @"BUTTON_SOUND";
    buttonSound.anchorPoint = CGPointMake(0.5, 0.5);
    buttonSound.xScale = self.scale; buttonSound.yScale = self.scale;
    buttonSound.position = CGPointMake(buttonMusic.position.x+buttonMusic.size.width/2+10+buttonSound.size.width/2, buttonMusic.position.y);
    [self addChild:buttonSound];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if([node.name isEqualToString:@"BUTTON_START"]){
        [node runAction:[SKAction scaleTo:1.2*self.scale duration:0.1]
             completion:^{
                 ZZChooseLevelsScene *scene = [[ZZChooseLevelsScene alloc] initWithSize:self.size];
                 [self.view presentScene:scene transition:[SKTransition flipVerticalWithDuration:0.3]];
             }];
    }else if([node.name isEqualToString:@"BUTTON_MUSIC"]){
        self.musicOn = !self.musicOn;
        [[NSUserDefaults standardUserDefaults] setBool:self.musicOn forKey:@"SETTING_MUSIC_ON"];
        SKTexture *texture = [SKTexture textureWithImageNamed: self.musicOn ? @"UI_Btn_Music_1.png" : @"UI_Btn_Music_2.png"];
        [node runAction:[SKAction sequence:@[
                                             [SKAction scaleTo:0.8*self.scale duration:0.06],
                                             [SKAction setTexture:texture],
                                             [SKAction scaleTo:1.0*self.scale duration:0.06],
                                             ]]];
    }else if([node.name isEqualToString:@"BUTTON_SOUND"]){
        SKTexture *texture = [SKTexture textureWithImageNamed: self.soundOn ? @"UI_Btn_Sound.png" : @"UI_Btn_Sound_2.png"];
        [[NSUserDefaults standardUserDefaults] setBool:self.soundOn forKey:@"SETTING_SOUND_ON"];
        [node runAction:[SKAction sequence:@[
                                             [SKAction scaleTo:0.8*self.scale duration:0.06],
                                             [SKAction setTexture:texture],
                                             [SKAction scaleTo:1.0*self.scale duration:0.06],
                                             ]]];
        
        self.soundOn = !self.soundOn;
    }
}

@end
