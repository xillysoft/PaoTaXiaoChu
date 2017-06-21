//
//  ZZMessageBoxNode.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZMessageBox.h"

@interface ZZMessageBox()
@property SKSpriteNode *mind;
@end

@implementation ZZMessageBox

-(instancetype)init
{
    self = [super init];
    self.userInteractionEnabled = YES;

//    scale = [UIScreen mainScreen].bounds.size.width/[UIImage imageNamed:@"UI_Mind.png"].size.width;
    
    SKSpriteNode *mind = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Mind.png"];
    self.mind = mind;
    mind.anchorPoint = CGPointMake(0.5, 0.5);
    mind.position = CGPointZero;
    [self addChild:mind];
    
    SKSpriteNode *buttonClose = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Close.png"];
    buttonClose.name = @"BUTTON_CLOSE";
    buttonClose.anchorPoint = CGPointMake(1.0, 1.0);
    buttonClose.position = CGPointMake(mind.size.width/2, mind.size.height/2);
    [self addChild:buttonClose];
    
    SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    titleNode.name = @"TITLE_NODE";
//    titleNode.text = self.title;
    titleNode.position = CGPointMake(0, mind.size.height/2-80);
    [self addChild:titleNode];
    
    SKSpriteNode *buttonPlay = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Btn_Play.png"];
    buttonPlay.name = @"BUTTON_PLAY";
    buttonPlay.position = CGPointMake(0, -mind.size.height/2+40);
    [self addChild:buttonPlay];
    
    return self;
}

-(void)setTitle:(NSString *)title
{
    SKLabelNode *titleNode = (SKLabelNode *)[self childNodeWithName:@"TITLE_NODE"];
    titleNode.text = title;
}

-(void)showIn:(SKNode *)container position:(CGPoint)position
{
    SKScene *scene = [container scene];
    CGSize size0 = [scene size];
    CGPoint anchorPoint0 = scene.anchorPoint;
    CGPoint center0 = CGPointMake(-(anchorPoint0.x-0.5)*size0.width, -(anchorPoint0.y-0.5)*size0.height);
    CGPoint center1 = [scene convertPoint:center0 toNode:container];
    self.position = center1;
    [container addChild:self];
    
    //ensure that the size of mind does not exceed the scene's visible region
    CGFloat scale = ({
        CGFloat scale1 = ({
            CGFloat s = 1.0;
            for(SKNode *node = container; node!=scene; node = [node parent]){
                s *= node.xScale;
            }
            s;
        });
        CGSize size1 = [self calculateAccumulatedFrame].size;
        MIN(size0.width*0.75/(size1.width*scale1), size0.height*0.75/(size1.height*scale1));
    });
    self.xScale = scale; self.yScale = scale;
    
    [self runAction:[SKAction sequence:@[
                                         [SKAction scaleTo:0.0*scale duration:0.0],
                                         ({SKAction *s = [SKAction scaleTo:1.2*scale duration:0.4];
        s.timingMode = SKActionTimingEaseOut;
        s;
    }),
                                         [SKAction scaleTo:1.0*scale duration:0.1]
                                         ]]];
    
    if(self.dataSource){
        CGSize size = self.mind.size;
        const CGFloat yPadding = 5.0;
        NSInteger numOfSections = [self.dataSource numberOfSectionsInMessageBox:self];
        const CGFloat xMargin = 20.0;
        CGFloat x = -size.width/numOfSections+xMargin;
        for(NSInteger section=0; section<numOfSections; section++, x+=size.width/numOfSections+xMargin){
            CGFloat y = size.height/2 - 160;
            if([self.dataSource respondsToSelector:@selector(messageBox:titleForHeaderInSection:)]){
                NSString *titleForSection = [self.dataSource messageBox:self titleForHeaderInSection:section];
                SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                titleLabel.text = titleForSection;
                titleLabel.fontSize = 24;
                titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
                titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                titleLabel.position = CGPointMake(x+15.0, y);
                titleLabel.fontColor = [SKColor blackColor];
                [self addChild:titleLabel];
                
                y -= titleLabel.calculateAccumulatedFrame.size.height + yPadding+20.0;
            }
            
            CGFloat waitTime = 0.3;
            NSUInteger numberOfRows = [self.dataSource messageBox:self numberOfRowsInSection:section];
            for(NSInteger row=0; row<numberOfRows; row++, waitTime+=0.3){
                CGFloat rowHeight = 0.0;
                CGFloat imageWidth = 0.0;
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
                if([self.dataSource respondsToSelector:@selector(messageBox:imageForRowAtIndexPath:)]){
                    UIImage *image = [self.dataSource messageBox:self imageForRowAtIndexPath:path];
                    if(image){
                        SKSpriteNode *imageNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
                        imageNode.anchorPoint = CGPointMake(0.5, 0.5);
                        imageNode.position = CGPointMake(x+image.size.width/2, y);
                        [self addChild:imageNode];
                        [imageNode runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0],
                                                                  [SKAction waitForDuration:waitTime],
                                                                  [SKAction fadeInWithDuration:0.3],
                                                                  [SKAction scaleTo:1.2 duration:0.1],
                                                                  [SKAction scaleTo:1.0 duration:0.05],
                                                                  ]]];
                        imageWidth = imageNode.size.width;
                        if(image.size.height > rowHeight){
                            rowHeight = image.size.height;
                        }
                    }
                }
                if([self.dataSource respondsToSelector:@selector(messagebox:textForRowAtIndexPath:)]){
                    NSString *text = [self.dataSource messagebox:self textForRowAtIndexPath:path];
                    if(text){
                        SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
                        labelNode.text = text;
                        const CGFloat margin = 10.0;
                        labelNode.position = CGPointMake(x+imageWidth+margin, y);
                        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
                        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                        labelNode.fontSize = 22;
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
