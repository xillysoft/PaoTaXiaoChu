//
//  ZZGameBoardScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/15/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZGameBoardScene.h"
#import "Utilities.h"

@interface ZZGameBoardScene()
@property SKNode *container;
@property CGFloat scale;
@property SKNode *turretBoard;
@property(nonatomic) NSInteger remainingSteps;
@property NSUInteger numRows, numColumns;
@property NSMutableArray<NSMutableArray<SKNode *> *> *guaiNodes;
@property NSMutableArray<SKNode *> *paoNodes;
@end


@implementation ZZGameBoardScene

-(void)didMoveToView:(SKView *)view
{
    _container = [SKNode node];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    _container.position = CGPointMake(0, 0);
    [self addChild:_container];
    
    SKSpriteNode *backgroundTop = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_3.png"];
    SKSpriteNode *backgroundBottom = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_4.png"];
    CGFloat bgHeight = backgroundTop.size.height + backgroundBottom.size.height;

    backgroundTop.anchorPoint = CGPointMake(0.5, 1.0);
    backgroundTop.position = CGPointMake(0, bgHeight/2);
    [_container addChild:backgroundTop];
    
    backgroundBottom.anchorPoint = CGPointMake(0.5, 0.0);
    backgroundBottom.position = CGPointMake(0, -bgHeight/2);
    [_container addChild:backgroundBottom];
    
    _scale = MAX(self.size.width / backgroundTop.size.width, self.size.height/(backgroundTop.size.height+backgroundBottom.size.height));
    _container.xScale = _scale; _container.yScale = _scale;
    
    SKSpriteNode *shangLan = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Game_ShangLan.png"];
    shangLan.anchorPoint = CGPointMake(0.5, 0.5);
    shangLan.position = CGPointMake(0, self.size.height/_scale/2-shangLan.size.height/2);
    [_container addChild:shangLan];
    SKLabelNode *remainingStepsLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    remainingStepsLabel.name = @"LABEL_REMAINING_STEPS";
    remainingStepsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    remainingStepsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    remainingStepsLabel.position = CGPointMake(0, 0);
    remainingStepsLabel.fontSize = 48;
    remainingStepsLabel.fontColor = [SKColor redColor];
    [shangLan addChild:remainingStepsLabel];
    self.remainingSteps = 25;
    
    SKSpriteNode *buyCoinsButton = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Buy.png"];
    buyCoinsButton.name = @"BUTTON_BUY_COINS";
    buyCoinsButton.position = CGPointMake(-100, shangLan.size.height/2-buyCoinsButton.size.height/2-10);
    [shangLan addChild:buyCoinsButton];
    
    SKSpriteNode *pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Pause.png"];
    pauseButton.name = @"BUTTON_PAUSE";
    pauseButton.position = CGPointMake(shangLan.size.width/2-pauseButton.size.width/2, shangLan.size.height/2-pauseButton.size.height/2-5);
    [shangLan addChild:pauseButton];
    
    _numRows = 4;
    _numColumns = 3;
    _turretBoard = [SKNode node];
    _turretBoard.position = CGPointMake(-self.size.width/_scale/2, -self.size.height/_scale/2); //left-bottom corner
    [_container addChild:_turretBoard];
    [self _generateTurret];
}

-(void)setRemainingSteps:(NSInteger)steps
{
    SKLabelNode *remainingStepsLabel = (SKLabelNode *)[self childNodeWithName:@"//LABEL_REMAINING_STEPS"];
    remainingStepsLabel.text = [NSString stringWithFormat:@"%@", @(steps)];
}

-(void)_generateTurret
{
    const CGFloat xPadding = 15.0;
    const CGFloat yPadding = 10.0;
    CGFloat x0 = 10.0;
    CGFloat y0 = 10.0;
    CGSize paoSpriteSize = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Pao_Blue_1.png"].size;
    CGFloat xPao = x0 + paoSpriteSize.width/2;
    CGFloat yPao = y0 + paoSpriteSize.height/2;
    _paoNodes = [NSMutableArray arrayWithCapacity:_numColumns];
    for(int column=0; column<_numColumns; column++){
        NSInteger paoColor = arc4random_uniform(3);
        NSInteger paoPower = arc4random_uniform(5);
        NSArray<SKColor *> *paoColors = @[@"Blue", @"Red", @"Green"];
        NSString *paoSpriteImageName = [NSString stringWithFormat:@"UI_Pao_%@_%@.png", paoColors[paoColor], @(paoPower+1)];
        SKSpriteNode *paoSprite = [SKSpriteNode spriteNodeWithImageNamed:paoSpriteImageName];
        paoSprite.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"color":@(paoColor)}];
//        paoSprite.size = paoSize;
        paoSprite.position = CGPointMake(xPao, yPao);
        [_turretBoard addChild:paoSprite];
        _paoNodes[column] = paoSprite;
        xPao += paoSpriteSize.width + xPadding;
    }
    const CGFloat paddingBetweenPaoAndGuai = 60;
    y0 += paoSpriteSize.height + paddingBetweenPaoAndGuai;
    
    CGSize guaiSpriteSize = [SKSpriteNode spriteNodeWithImageNamed:@"1.png"].size;
    CGSize guaiNodeSize = CGSizeMake(guaiSpriteSize.width+6, guaiSpriteSize.height+2);
    CGFloat yGuai = y0+guaiNodeSize.height/2;
    _guaiNodes = [NSMutableArray arrayWithCapacity:_numRows];
    for(int row=0; row<_numRows; row++){
        _guaiNodes[row] = [NSMutableArray arrayWithCapacity:_numColumns];
        CGFloat xGuai = x0+guaiNodeSize.width/2;
        for(int column=0; column<_numColumns; column++){
            SKShapeNode *guaiNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(guaiNodeSize.width, guaiNodeSize.height) cornerRadius:10];
            guaiNode.position = CGPointMake(xGuai, yGuai);
            guaiNode.fillColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:0.2];
            guaiNode.strokeColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
            guaiNode.lineWidth = 2.0;
            [_turretBoard addChild:guaiNode];
//            [[_guaiNodes objectAtIndex:row] objectAtIndex:column] = guaiNode;
            _guaiNodes[row][column] = guaiNode;
            
            SKLabelNode *guaiLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
            guaiLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            guaiLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
            guaiLabel.position = CGPointMake(guaiNodeSize.width/2-2, guaiNodeSize.height/2-2);
            guaiLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(4)];
            guaiLabel.fontSize = 24;
            [guaiNode addChild:guaiLabel];
            
            xGuai += guaiNodeSize.width+xPadding;
        }
        yGuai += guaiNodeSize.height+yPadding;
    }
    
    [self _generateRandomGuaisAtRow:0];
}

-(void)_generateRandomGuaisAtRow:(NSUInteger)row
{
    if(row < _numRows){
        NSMutableArray<SKNode *> *guaiSpritesRow = [NSMutableArray arrayWithCapacity:_numColumns];
        for(NSUInteger column=0; column<_numColumns; column++){
//            SKNode *guaiNode = _guaiNodes[row][column];
            NSInteger guaiColor = arc4random_uniform(3);
            SKSpriteNode *guaiSprite = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@.png", @(guaiColor+1)]];
            guaiSprite.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"color": @(guaiColor)}];
            //            guaiSprite.size = guaiSpriteSize;
//            guaiSprite.position = CGPointZero;
            guaiSprite.hidden = YES;
            [_container addChild:guaiSprite];
            guaiSpritesRow[column] = guaiSprite;
        }
        const CGFloat yStart = [self convertPoint:CGPointMake(0, self.size.height/2) toNode:_container].y;
        for(NSUInteger column=0; column<_numColumns; column++){
            SKNode *guaiSprite = guaiSpritesRow[column];
            SKNode *guaiNode = _guaiNodes[row][column];
            CGPoint guaiPosition = [guaiNode convertPoint:CGPointZero toNode:_container];
            CGFloat x = guaiPosition.x;
            CGPoint positionFrom = CGPointMake(x, yStart + [guaiSprite calculateAccumulatedFrame].size.height/2 );
            CGPoint positionTo = CGPointMake(x, guaiPosition.y);
            CGFloat duration = ({
                CGFloat distance = CGPoint_distance(positionFrom, positionTo);
                const CGFloat speed = 800.0;
                distance/speed;
            });
            guaiSprite.position = positionFrom;
            SKAction *dropDownAction = [SKAction moveTo:positionTo duration:duration];
            dropDownAction.timingMode = SKActionTimingEaseIn;
            guaiSprite.hidden = NO;
            [guaiSprite runAction:dropDownAction completion:^{
                [self _generateRandomGuaisAtRow:row+1];
            }];
        }
    }

}

-(void)_fireTurret
{
    for(NSUInteger column=0; column<_numColumns; column++) {
        SKNode *paoNode = _paoNodes[column];
        CGSize paoSize = [paoNode calculateAccumulatedFrame].size;
        CGPoint p0 = [paoNode convertPoint:CGPointMake(0, paoSize.width/2) toNode:_container];
        SKNode *guaiNode = _guaiNodes[0][column];
        CGPoint p1 = ({
            CGSize guaiSize = [guaiNode calculateAccumulatedFrame].size;
            [guaiNode convertPoint:CGPointMake(0, -guaiSize.height/2) toNode:_container];
        });
        
        NSInteger paoColor = [[paoNode.userData objectForKey:@"color"] integerValue];
        SKSpriteNode *bulllet = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"UI_Mind_Guai_%@.png", @(paoColor+1)]];
        p0 = CGPointMake(p0.x, p0.y+bulllet.size.height/2);
        p1 = CGPointMake(p1.x, p1.y-bulllet.size.height/2);
        bulllet.position = p0;
        [_container addChild:bulllet];
        CGFloat fireDuration = ({
            CGFloat distance = CGPoint_distance(p0, p1);
            const CGFloat speed = 1200;
            distance/speed;
        });
        [bulllet runAction:[SKAction group:@[
                                             [SKAction moveTo:p1 duration:fireDuration],
                                             [SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:0.2]],
                                             ]]];
        [paoNode runAction:[SKAction sequence:@[
                                                [SKAction moveByX:0 y:-15 duration:0.02],
                                                [SKAction waitForDuration:0.02],
                                                [SKAction moveByX:0 y:15 duration:0.5],
                                                ]]
                completion:^{
                    [bulllet runAction:[SKAction sequence:@[
                                                            [SKAction fadeOutWithDuration:0.05],
                                                            [SKAction removeFromParent],
                                                            ]]];
                    NSInteger guaiColor = [[guaiNode.userData objectForKey:@"color"] integerValue];
                    if(paoColor == guaiColor){
                        //TODO: remove this guai and drop new one down
                        
                    }
                }
         ];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self _fireTurret];
}
@end
