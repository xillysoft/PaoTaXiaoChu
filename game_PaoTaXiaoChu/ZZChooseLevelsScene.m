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
@property SKNode *container;
@property CGFloat scale;
@property SKEffectNode *effectSceneNode;
@property NSUInteger numDiamonds;
@property NSUInteger numStars;
@end


@implementation ZZChooseLevelsScene

//called by SKScene's -presentScene:
-(void)didMoveToView:(SKView *)view
{
    _container = [SKNode node];
    self.anchorPoint = CGPointMake(0.0, 1.0);
    _container.position = CGPointMake(0, 0);
    [self addChild:_container];
    
    self.effectSceneNode = [SKEffectNode node];
    self.effectSceneNode.position = CGPointMake(0, 0);
    [_container addChild:self.effectSceneNode];
    self.effectSceneNode.shouldEnableEffects = YES;
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_1.png"];
    self.scale = MAX(self.size.width/background.size.width, self.size.height/background.size.height);
    _container.xScale = self.scale; _container.yScale = self.scale;
    CGSize size0 = self.size;
    CGSize size1 = CGSizeMake(size0.width/self.scale, size0.height/self.scale);
    
    
    background.anchorPoint = CGPointMake(0.0, 1.0);
    background.position = CGPointMake(0, 0);
    [self.effectSceneNode addChild:background];
    
    SKSpriteNode *levelTop = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Level_1.png"];
    levelTop.anchorPoint = CGPointMake(0.0, 1.0);
    levelTop.position = CGPointMake(0, 0);
    [self.effectSceneNode addChild:levelTop];
    
    SKSpriteNode *buttonBack = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Back.png"];
    buttonBack.name = @"BUTTON_BACK";
    buttonBack.anchorPoint = CGPointMake(0.5, 0.5);
    buttonBack.position = CGPointMake(buttonBack.size.width/2+20, -self.size.height/self.scale+buttonBack.size.height/2+10);
    [self.effectSceneNode addChild:buttonBack];
    
    { //level nodes
        UIImage *levelImage = [UIImage imageNamed:@"UI_Level_JieSuo.png"]; //解锁
        SKTexture *levelTexture = [SKTexture textureWithImage:levelImage];
        
        int rows, columns;
        if(size0.width < size0.height){ //portrait
            rows = 5;
            columns = 4;
        }else{ //landscape
            rows = 4;
            columns = 5;
        }
        CGFloat yPadding = 10.0;
        CGFloat levelTextureScale = ({
            ((size1.height-levelTop.size.height-buttonBack.size.height-20)-yPadding*(rows-1)) / rows / levelTexture.size.height;
        });
        //scale level sprite to match the height of blank region of background
        CGSize levelSize = CGSizeMake(levelTexture.size.width*levelTextureScale, levelTexture.size.height*levelTextureScale);
        CGFloat xPadding = (self.size.width/self.scale - columns*levelSize.width) / (columns+1);
//        CGFloat y = -(size1.height - levelSize.height*rows-yPadding*(rows-1))/2 + levelSize.height/2;
        CGFloat y = -levelTop.size.height-levelTexture.size.height*levelTextureScale/2;
        for(int r=0; r<rows; r++, y-=yPadding+levelSize.height){
            CGFloat x = xPadding;
            for(int c=0; c<columns; c++, x+=xPadding+levelSize.width){
                SKSpriteNode *levelSprite = [SKSpriteNode spriteNodeWithTexture:levelTexture];
                levelSprite.size = levelSize;
                levelSprite.name = @"LEVEL";
                NSUInteger levelIndex = r*columns+c;
                levelSprite.userData = [NSMutableDictionary dictionary];
                [levelSprite.userData setObject:[NSNumber numberWithInteger:levelIndex] forKey:@"level"];
                levelSprite.anchorPoint = CGPointMake(0.5, 0.5);
                levelSprite.position = CGPointMake(x+levelSize.width/2, y);
                [self.effectSceneNode addChild:levelSprite];
                
                SKLabelNode *levelLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                levelLabel.text = [NSString stringWithFormat:@"%@", @(levelIndex+1)];
                levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
                levelLabel.position = CGPointMake(0, 0);
                levelLabel.fontSize = levelSize.height/2;
                levelLabel.fontColor = [SKColor whiteColor];
                [levelSprite addChild:levelLabel];
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
        [node runAction:[SKAction sequence:({
            NSMutableArray<SKAction *> *actions = [NSMutableArray array];
            CGFloat t = 0.03;
            for(CGFloat d=8; d>0; d-=2){
                [actions addObject:[SKAction moveByX:-d y:0 duration:t]];
                [actions addObject:[SKAction moveByX:2*d y:0 duration:2*t]];
                [actions addObject:[SKAction moveByX:-d y:0 duration:t]];
            }
            actions;
        })
                         ]
             completion:^{
                 self.effectSceneNode.userInteractionEnabled = YES; //disable effectSceneNode from receiving touch events
                 self.effectSceneNode.shouldRasterize = YES;
                 self.effectSceneNode.filter = ({
                     CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                             withInputParameters:@{@"inputRadius": @(0)}];
                     [filter setValue:@(20) forKey:@"inputRadius"];
                     filter;
                 });

                 ZZMessageBox *messageBox = [[ZZMessageBox alloc] init];
                 messageBox.name = @"MIND";
                 messageBox.title = [NSString stringWithFormat:@"Level %@", @(level+1)];
                 messageBox.delegate = self;
                 messageBox.dataSource = self;
                 CGSize size1 = CGSizeMake(self.size.width/self.scale, self.size.height/self.scale);
                 CGPoint center = CGPointMake(size1.width/2, -size1.height/2);
                 [messageBox showIn:_container position:center];
                 
             }];
    }
}

#pragma mark - ZZMessageBoxDelegate
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
    [self.view presentScene:gameBoardScene
                 transition:[SKTransition revealWithDirection:SKTransitionDirectionUp duration:0.5]];
}
#pragma mark -

#pragma mark - ZZMesageBoxDataSource
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
    NSUInteger rows[] = {2, 3};
    return rows[section];
}

-(NSString *)messagebox:(ZZMessageBox *)messageBox textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        NSArray<NSString *> *texts = @[@"x10", @"x20"];
        return texts[indexPath.row];
    }else if(indexPath.section == 1){
        NSArray<NSString *> *texts = @[@"x0", @"x0", @"x0"];
        return texts[indexPath.row];
    }
    return  nil;
}
-(UIImage *)messageBox:(ZZMessageBox *)messgeBox imageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<NSArray<NSString *> *> *imageNames = @[
                                                   @[@"UI_Mind_Guai_2.png", @"UI_Mind_Guai_3.png"],
                                                   @[@"UI_Mind_DaoJu_1.png", @"UI_Mind_DaoJu_2.png", @"UI_Mind_DaoJu_3.png"],
                                                   ];
    return [UIImage imageNamed:imageNames[indexPath.section][indexPath.row]];
}
#pragma mark -

@end
