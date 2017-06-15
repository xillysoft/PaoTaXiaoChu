//
//  ZZChooseStageScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZChooseLevelsScene.h"
#import "ZZWelcomeScene.h"
#import "ZZMessageBox.h"
#import "ZZGameBoardScene.h"

@interface ZZChooseLevelsScene () <ZZMessageBoxDelegate, ZZMesageBoxDataSource>
@property CGFloat scale;
@property SKEffectNode *effectSceneNode;
@property NSUInteger numDiamonds;
@property NSUInteger numStars;
@end


@implementation ZZChooseLevelsScene

//called by SKScene's -presentScene:
-(void)didMoveToView:(SKView *)view
{
    self.effectSceneNode = [SKEffectNode node];
    self.effectSceneNode.position = CGPointMake(0, 0);
    [self addChild:self.effectSceneNode];
    self.effectSceneNode.shouldEnableEffects = YES;
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_1.png"];
    self.scale = MIN(self.size.width/background.size.width, self.size.height/background.size.height);
    background.position = CGPointMake(self.size.width/2, self.size.height/2); //SKScene's anchorPoint=(0,0)
//    background.xScale = scale; background.yScale = scale;
    background.size = self.size;
    [self.effectSceneNode addChild:background];
    
    SKSpriteNode *levelTop = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Level_1.png"];
    levelTop.anchorPoint = CGPointMake(0.0, 1.0);
    levelTop.position = CGPointMake(0, self.size.height);
    levelTop.xScale = self.size.width/levelTop.size.width;
    levelTop.yScale = levelTop.xScale;
    [self.effectSceneNode addChild:levelTop];
    
    SKSpriteNode *buttonBack = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Back.png"];
    buttonBack.name = @"BUTTON_BACK";
    buttonBack.anchorPoint = CGPointMake(0.0, 0.0);
    buttonBack.position = CGPointMake(5, 5);
    buttonBack.xScale = self.scale; buttonBack.yScale = self.scale;
    [self.effectSceneNode addChild:buttonBack];
    
    {
        UIImage *levelImage = [UIImage imageNamed:@"UI_Level_JieSuo.png"];
        SKTexture *levelTexture = [SKTexture textureWithImage:levelImage];
        CGSize levelSize = CGSizeMake(levelTexture.size.width*self.scale, levelTexture.size.height*self.scale);
        const int rows = 5;
        const int columns = 4;
        CGFloat xPadding = (self.size.width - columns*levelSize.width) / (columns+1);
        CGFloat yPadding = 5.0;
        CGFloat y = self.size.height - (self.size.height - levelSize.height*rows-yPadding*(rows-1))/2 - levelSize.height/2;
        for(int r=0; r<5; r++, y-=yPadding+levelSize.height){
            CGFloat x = xPadding;
            for(int c=0; c<4; c++, x+=xPadding+levelSize.width){
                SKSpriteNode *level = [SKSpriteNode spriteNodeWithTexture:levelTexture];
                level.name = @"LEVEL";
                NSUInteger levelIndex = r*columns+c;
                level.userData = [NSMutableDictionary dictionary];
                [level.userData setObject:[NSNumber numberWithInteger:levelIndex] forKey:@"level"];
                level.anchorPoint = CGPointMake(0.5, 0.5);
                level.xScale = self.scale; level.yScale = self.scale;
                level.position = CGPointMake(x+levelSize.width/2, y);
                [self.effectSceneNode addChild:level];
                
                SKLabelNode *levelLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                levelLabel.text = [NSString stringWithFormat:@"%@", @(levelIndex+1)];
                levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
                levelLabel.position = CGPointMake(0, 0);
//                levelLabel.fontSize = 24;
                levelLabel.fontColor = [SKColor whiteColor];
                [level addChild:levelLabel];
            }
        }
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if([node.name isEqualToString:@"BUTTON_BACK"]){
        ZZWelcomeScene *welcomeScene = [[ZZWelcomeScene alloc] initWithSize:self.size];
        [self.view presentScene:welcomeScene
                     transition:[SKTransition moveInWithDirection:SKTransitionDirectionLeft duration:0.3]];
        
    }else if([node.name isEqualToString:@"LEVEL"]){
        NSUInteger level = [[node.userData objectForKey:@"level"] integerValue];
        [node runAction:[SKAction sequence:@[
                                             [SKAction moveByX:-3 y:0 duration:0.1],
                                             [SKAction moveByX:3 y:0 duration:0.1],
                                             [SKAction moveByX:-2 y:0 duration:0.1],
                                             [SKAction moveByX:2 y:0 duration:0.1]
                                             ]]];
        ZZMessageBox *messageBox = [[ZZMessageBox alloc] initWithScale:self.scale title:[NSString stringWithFormat:@"Level %@", @(level+1)]];
        messageBox.name = @"MIND";
        messageBox.delegate = self;
        messageBox.dataSource = self;
        [messageBox showIn:self];
        
        self.effectSceneNode.userInteractionEnabled = YES; //disable effectSceneNode from receiving touch events
        self.effectSceneNode.shouldRasterize = YES;
        self.effectSceneNode.filter = ({
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" withInputParameters:@{@"inputRadius": @(0)}];
            [filter setValue:@(20) forKey:@"inputRadius"];
            filter;
        });
    }
}

-(void)messageBox:(ZZMessageBox *)messageBox didDissmissWithButtonIndex:(NSInteger)buttonIndex
{
    self.effectSceneNode.userInteractionEnabled = NO; //re-enable effectSceneNode receiving touch events
    self.effectSceneNode.filter = nil;
}

-(void)messageBox:(ZZMessageBox *)messageBox clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.effectSceneNode.userInteractionEnabled = NO; //re-enable effectSceneNode receiving touch events
    self.effectSceneNode.filter = nil;
    
    ZZGameBoardScene *gameBoardScene = [[ZZGameBoardScene alloc] initWithSize:self.size];
    [self.view presentScene:gameBoardScene transition:[SKTransition revealWithDirection:SKTransitionDirectionUp duration:0.3]];
}

-(NSUInteger)numberOfSectionsInMessageBox:(ZZMessageBox *)messageBox
{
    return 2;
}

-(NSString *)messageBox:(ZZMessageBox *)messageBox titleForHeaderInSection:(NSUInteger)section
{
    NSArray<NSString *> *titles = @[@"Tasks", @"Bonus"];
    return titles[section];
}

-(NSUInteger)messageBox:(ZZMessageBox *)messageBox numberOfRowsInSection:(NSUInteger)section
{
    NSUInteger rows[] = {4, 3};
    return rows[section];
}

-(NSString *)messagebox:(ZZMessageBox *)messageBox textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        NSArray<NSString *> *texts = @[@"x5000", @"x5000", @"x5000", @"x5000"];
        return texts[indexPath.row];
    }else if(indexPath.section == 1){
        NSArray<NSString *> *texts = @[@"x0", @"x0", @"x0"];
        return texts[indexPath.row];
    }
    return  nil;
}

-(UIImage *)messageBox:(ZZMessageBox *)messgeBox imageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIImage imageNamed:@"UI_Game_Star.png"];
}
@end
