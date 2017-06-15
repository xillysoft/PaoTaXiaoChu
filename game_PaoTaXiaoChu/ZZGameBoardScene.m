//
//  ZZGameBoardScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/15/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZGameBoardScene.h"

@implementation ZZGameBoardScene

-(void)didMoveToView:(SKView *)view
{
    SKNode *node = [SKNode node];
    
    SKSpriteNode *backgroundTop = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_3.png"];
    SKSpriteNode *backgroundBottom = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_4.png"];
    CGFloat height = backgroundTop.size.height+backgroundBottom.size.height;

    backgroundTop.anchorPoint = CGPointMake(0.5, 1.0);
    backgroundTop.position = CGPointMake(0, height/2);
    [node addChild:backgroundTop];
    
    backgroundBottom.anchorPoint = CGPointMake(0.5, 0.0);
    backgroundBottom.position = CGPointMake(0, -height/2);
    [node addChild:backgroundBottom];
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    node.position = CGPointMake(0, 0);
    CGFloat scale = MAX(self.size.width / backgroundTop.size.width, self.size.height/(backgroundTop.size.height+backgroundBottom.size.height));
    node.xScale = scale; node.yScale = scale;
    [self addChild:node];
    
}



@end
