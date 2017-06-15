//
//  ZZMessageBoxNode.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZMessageBox.h"

@interface ZZMessageBox()
@property CGFloat scale;
@property SKSpriteNode *mind;
@end

@implementation ZZMessageBox

-(instancetype)initWithScale:(CGFloat)scale title:(NSString *)title
{
    self = [super init];
    self.userInteractionEnabled = YES;

//    scale = [UIScreen mainScreen].bounds.size.width/[UIImage imageNamed:@"UI_Mind.png"].size.width;
    self.scale = scale;
    
    SKSpriteNode *mind = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Mind.png"];
    self.mind = mind;
    mind.anchorPoint = CGPointMake(0.5, 0.5);
    mind.position = CGPointZero;
    mind.xScale = scale; mind.yScale = scale;
    [self addChild:mind];
    
    SKSpriteNode *buttonClose = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Close.png"];
    buttonClose.name = @"BUTTON_CLOSE";
    buttonClose.anchorPoint = CGPointMake(1.0, 1.0);
    buttonClose.position = CGPointMake(mind.size.width/2, mind.size.height/2);
    buttonClose.xScale = scale; buttonClose.yScale = scale;
    [self addChild:buttonClose];
    
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    titleNode.name = @"TITLE_NODE";
    titleNode.text = title;
    titleNode.position = CGPointMake(0, mind.size.height/2-60);
    [self addChild:titleNode];
    
    SKSpriteNode *buttonPlay = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Play.png"];
    buttonPlay.name = @"BUTTON_PLAY";
    buttonPlay.position = CGPointMake(0, -mind.size.height/2+40);
    buttonPlay.xScale = scale; buttonPlay.yScale = scale;
    [self addChild:buttonPlay];
    
    return self;
}

-(void)showIn:(SKScene *)scene
{
    self.position = CGPointMake(scene.size.width/2, scene.size.height/2);
    [scene addChild:self];
    
    [self runAction:[SKAction sequence:@[
                                               [SKAction scaleTo:0.0 duration:0.0],
                                               [SKAction scaleTo:1.2 duration:0.2],
                                               [SKAction scaleTo:1.0 duration:0.1]
                                               ]]];
    
    if(self.dataSource){
        CGSize size = self.mind.size;
        const CGFloat yPadding = 0.0;
        NSInteger numOfSections = [self.dataSource numberOfSectionsInMessageBox:self];
        const CGFloat xMargin = 15.0;
        CGFloat x = -size.width/numOfSections+xMargin;
        for(NSInteger section=0; section<numOfSections; section++, x+=size.width/numOfSections+xMargin){
            CGFloat y = size.height/2 - 100;
            if([self.dataSource respondsToSelector:@selector(messageBox:titleForHeaderInSection:)]){
                NSString *titleForSection = [self.dataSource messageBox:self titleForHeaderInSection:section];
                SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                titleLabel.text = titleForSection;
                titleLabel.fontSize = 22;
                titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
                titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                titleLabel.position = CGPointMake(x+10.0, y);
                titleLabel.fontColor = [SKColor blackColor];
                [self addChild:titleLabel];
                
                y -= titleLabel.calculateAccumulatedFrame.size.height + yPadding+3.0;
            }
            
            CGFloat waitTime = 0.3;
            NSUInteger numberOfRows = [self.dataSource messageBox:self numberOfRowsInSection:section];
            for(NSInteger row=0; row<numberOfRows; row++, waitTime+=0.3){
                CGFloat rowHeight = 0.0;
                CGFloat imageWidth = 0.0;
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
                if([self.dataSource respondsToSelector:@selector(messageBox:imageForRowAtIndexPath:)]){
                    UIImage *image = [self.dataSource messageBox:self imageForRowAtIndexPath:path];
                    SKSpriteNode *imageNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
                    imageNode.xScale = self.scale; imageNode.yScale = self.scale;
                    imageNode.anchorPoint = CGPointMake(0, 0.5);
                    imageNode.position = CGPointMake(x, y);
                    [self addChild:imageNode];
                    [imageNode runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0],
                                                              [SKAction waitForDuration:waitTime],
                                                              [SKAction fadeInWithDuration:0.3],
                                                              ]]];
                    imageWidth = imageNode.size.width;
                    if(image.size.height*self.scale > rowHeight){
                        rowHeight = image.size.height*self.scale;
                    }
                }
                if([self.dataSource respondsToSelector:@selector(messagebox:textForRowAtIndexPath:)]){
                    NSString *text = [self.dataSource messagebox:self textForRowAtIndexPath:path];
                    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                    labelNode.text = text;
                    const CGFloat margin = 2.0;
                    labelNode.position = CGPointMake(x+imageWidth+margin, y);
                    labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
                    labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                    labelNode.fontSize = 20;
                    labelNode.fontColor = [SKColor blueColor];
                    [self addChild:labelNode];
                    [labelNode runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0],
                                                              [SKAction waitForDuration:waitTime],
                                                              [SKAction fadeInWithDuration:0.3],
                                                              ]]];
                    
                    CGFloat textHeight = [labelNode calculateAccumulatedFrame].size.height;
                    if(rowHeight < textHeight){
                        rowHeight = textHeight;
                    }
                }
                
                y -= rowHeight + yPadding;
            }
        }
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if([node.name isEqualToString:@"BUTTON_CLOSE"]){
        [self runAction:[SKAction sequence:@[
                                             [SKAction scaleTo:0.0 duration:0.2],
                                             [SKAction removeFromParent]
                                             ]]];
        if(self.delegate && [self.delegate respondsToSelector:@selector(messageBox:didDissmissWithButtonIndex:)]){
            [self.delegate messageBox:self didDissmissWithButtonIndex:0];
        }
    }else if([node.name isEqualToString:@"BUTTON_PLAY"]){
        [self runAction:[SKAction sequence:@[
                                             [SKAction scaleTo:0.0 duration:0.2],
                                             [SKAction removeFromParent]
                                             ]]];
        if(self.delegate && [self.delegate respondsToSelector:@selector(messageBox:clickedButtonAtIndex:)]){
            [self.delegate messageBox:self clickedButtonAtIndex:0];
        }
    }
}
@end
