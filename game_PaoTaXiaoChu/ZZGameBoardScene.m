//
//  ZZGameBoardScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/15/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import "ZZGameBoardScene.h"
#import "Utilities.h"

typedef NS_ENUM(NSInteger, GameState){
    GAMESTATE_INIT,
    GAMESTATE_GENERATING_GUAIS,
    GAMESTATE_GUAI_GENERATED
};

@interface ZZGameBoardScene()
@property GameState gameState;
@property SKNode *container;
@property CGFloat scale;
@property SKNode *turretBoard;
@property(nonatomic) NSInteger remainingSteps;
@property NSUInteger numRows, numColumns;
@property NSMutableArray<NSMutableArray<SKNode *> *> *guaiNodes;
@property NSMutableArray<SKNode *> *paoNodes;

@property SKNode *movingPao;
@property CGPoint movingPaoPosition0;
@property CGPoint touchedLocation;
@end


@implementation ZZGameBoardScene

-(void)didMoveToView:(SKView *)view
{
    //TODO: transition _gameState
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

-(NSArray<NSNumber *> *)_randomSequence:(NSInteger)n
{
	NSMutableArray<NSNumber *> *a = [NSMutableArray arrayWithCapacity:n];
	for(NSInteger i=0; i<n; i++){ //a=[0, 1, ..., n-1]
		a[i] = @(i);
	}
	NSMutableArray<NSNumber *> *b = [NSMutableArray arrayWithCapacity:n];
	for(NSInteger m=n-1; m>=0; m--){ //randomly choose one element from remaining m elements in a
		NSInteger k = arc4random_uniform(m);
		NSNumber *x = a[k];
		//		[b addObject:x];
		b[n-1-m] = x;
		[a removeObjectAtIndex:k];
	}
	return b;
}

//Pao and Guai colors: 0-Red, 1-Blue, 2-Green
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
	//generate Paos[_numColumns]
	NSArray<NSNumber *> *randomSequence = [self _randomSequence:_numColumns];
    for(int column=0; column<_numColumns; column++){
//        NSInteger paoColor = arc4random_uniform(3);
		NSInteger paoColor = [randomSequence[column] integerValue];
        NSInteger paoPower = arc4random_uniform(5);
        NSArray<SKColor *> *paoColors = @[@"Red", @"Blue", @"Green"];
        NSString *paoSpriteImageName = [NSString stringWithFormat:@"UI_Pao_%@_%@.png", paoColors[paoColor], @(paoPower+1)];
        SKSpriteNode *paoSprite = [SKSpriteNode spriteNodeWithImageNamed:paoSpriteImageName];
		paoSprite.name = @"PAO_SPRITE";
        paoSprite.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"color":@(paoColor), @"power": @(paoPower)}];
//        paoSprite.size = paoSize;
        paoSprite.position = CGPointMake(xPao, yPao);
        [_turretBoard addChild:paoSprite];
        _paoNodes[column] = paoSprite;
        xPao += paoSpriteSize.width + xPadding;
    }
    const CGFloat paddingBetweenPaoAndGuai = 100;
    y0 += paoSpriteSize.height + paddingBetweenPaoAndGuai;
    
    CGSize guaiSpriteSize = [SKSpriteNode spriteNodeWithImageNamed:@"1.png"].size;
    CGSize guaiNodeSize = CGSizeMake(guaiSpriteSize.width+6, guaiSpriteSize.height+2);
    CGFloat yGuai = y0+guaiNodeSize.height/2;
    _guaiNodes = [NSMutableArray arrayWithCapacity:_numRows];
	//generate Guai[_numRows][_numColumns] nodes to container Guai sprite later
    for(int row=0; row<_numRows; row++){
        _guaiNodes[row] = [NSMutableArray arrayWithCapacity:_numColumns];
        CGFloat xGuai = x0+guaiNodeSize.width/2;
        for(int column=0; column<_numColumns; column++){
            SKShapeNode *guaiNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(guaiNodeSize.width, guaiNodeSize.height) cornerRadius:10];
			guaiNode.userData = [NSMutableDictionary dictionary];
            guaiNode.position = CGPointMake(xGuai, yGuai);
            guaiNode.fillColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:0.2];
            guaiNode.strokeColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
            guaiNode.lineWidth = 2.0;
            [_turretBoard addChild:guaiNode];
//            [[_guaiNodes objectAtIndex:row] objectAtIndex:column] = guaiNode;
            _guaiNodes[row][column] = guaiNode;
            
            SKLabelNode *guaiLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
			guaiLabel.name = @"GUAI_LABEL";
			const CGFloat fontSize = 24;
			guaiLabel.fontSize = fontSize;
            guaiLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            guaiLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            guaiLabel.position = CGPointMake(guaiNodeSize.width/2-fontSize/2-2, guaiNodeSize.height/2-fontSize/2-2); //place at top-right corner of guaiNode
            [guaiNode addChild:guaiLabel];
			
			[self _setGuaiNode:guaiNode count:0]; //must after guaiLabel added into guaiNode
			
            xGuai += guaiNodeSize.width+xPadding;
        }
        yGuai += guaiNodeSize.height+yPadding;
    }
	
	[self _fillBlankGuaiNodesWithRandomGuaiSprites];
}

//this method will be called:
//1. the first time the scene is created
//2. one row of sprites with same color are merged
//3. some sprites are exploded by Paos
-(void)_fillBlankGuaiNodesWithRandomGuaiSprites
{
	for(NSUInteger column=0; column<_numColumns; column++){
		[self _generateRandomGuaisForColumn:column];
	}
}

-(void)_generateRandomGuaisForColumn:(NSUInteger)column;
{
	//search for the first "blank" Guai node in the column (from bottom row to top row)
	NSUInteger row=0;
	for(; row < _numRows; row++){
		SKNode *guaiNode = _guaiNodes[row][column];
		SKSpriteNode *guaiSprite = [guaiNode.userData objectForKey:@"GUAI_SPRITE"];
		if(guaiSprite == nil){ //"blank" Guai node
			break;
		}
	}
	if(row <= _numRows-1){ //there is a "blank" Guai node, so generate Guai sprite at [r][column]
		SKNode *guaiNode = _guaiNodes[row][column];
		NSInteger guaiColor = arc4random_uniform(3);
		SKSpriteNode *guaiSprite = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@.png", @(guaiColor+1)]];
		
		guaiSprite.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"color": @(guaiColor)}];
		//            guaiSprite.position = CGPointZero;
		[_container addChild:guaiSprite];
		
		{
			const CGFloat yStart = [self convertPoint:CGPointMake(0, self.size.height/2) toNode:_container].y;
			CGPoint guaiPosition = [guaiNode convertPoint:CGPointZero toNode:_container];
			CGPoint positionFrom = CGPointMake(guaiPosition.x, yStart + [guaiSprite calculateAccumulatedFrame].size.height/2 );
			CGPoint positionTo = CGPointMake(guaiPosition.x, guaiPosition.y);
			CGFloat duration = ({
				CGFloat distance = CGPoint_distance(positionFrom, positionTo);
				const CGFloat speed = 800.0;
				distance/speed;
			});
			guaiSprite.position = positionFrom;
			SKAction *dropDownAction = [SKAction moveTo:positionTo
											   duration:duration];
			dropDownAction.timingMode = SKActionTimingEaseIn;
			[guaiSprite runAction:dropDownAction
					   completion:^{//guaiNodes[row][column] is filled with guaiSprite.
						   if(! guaiNode.userData)
							   guaiNode.userData = [NSMutableDictionary dictionary];
						   [guaiNode.userData setObject:guaiSprite forKey:@"GUAI_SPRITE"];
						   
						   //TODO: after all column of row or entire Guai nodes board is filled, check same color and call -_removeGuaiRowsOfSameColor
						   [self _generateRandomGuaisForColumn:column]; //recursively fill Guai sprites
					   }];
		}
	}else{ //row==_numRows, means all blank Guai nodes filled with Guai sprites for this *column*
		BOOL flag = YES;
		for(NSInteger c=0; c<_numColumns; c++){
			SKNode *guaiNode = _guaiNodes[_numRows-1][c];
			if([guaiNode.userData objectForKey:@"GUAI_SPRITE"] == nil){ //there is still blank guaiNodes not filled
				flag = NO;
			}
		}
		if( flag ){ //all columns of guaiNodes filled
			[self _removeGuaiRowsOfSameColor];
		}
	}
	
}

-(NSInteger)_guaiNodeCount:(SKNode *)guaiNode
{
	NSInteger count = [[guaiNode.userData objectForKey:@"count"] integerValue];
	return count;
}

-(void)_setGuaiNode:(SKNode *)guaiNode count:(NSInteger)count
{
	NSNumber *count0 = [guaiNode.userData objectForKey:@"count"];
	[guaiNode.userData setObject:@(count) forKey:@"count"];
	
	if(count0==nil || [count0 integerValue] != count){ //count changed
		SKLabelNode *guaiNodeLabel = (SKLabelNode *)[guaiNode childNodeWithName:@"GUAI_LABEL"];
		if(count0==nil){
			guaiNodeLabel.text = [@(count) description];
		}else{
			SKAction *scaleAction = [SKAction scaleBy:1.5 duration:0.2];
			SKAction *changeTextAction = [SKAction runBlock:^{
				guaiNodeLabel.text = [@(count) description];
				
			}];
			[guaiNodeLabel runAction:[SKAction sequence:@[
														  scaleAction,
														  changeTextAction,
														  [SKAction waitForDuration:0.1],
														  [scaleAction reversedAction],
														  ]]];
		}
	}
}

-(void)_removeGuaiRowsOfSameColor
{
	BOOL rowRemoved = NO;
	for(NSInteger row=0; row<_numRows && !rowRemoved; row++){
		SKNode *guaiNode0 = _guaiNodes[row][0];
		SKSpriteNode *guaiSprite0 = [guaiNode0.userData objectForKey:@"GUAI_SPRITE"];
		NSInteger guaiColor0 = [[guaiSprite0.userData objectForKey:@"color"] integerValue];
		BOOL rowSameColor = YES;
		for(NSInteger c=1; c<_numColumns; c++){
			SKNode *guaiNode1 = _guaiNodes[row][c];
			SKSpriteNode *guaiSprite1 = [guaiNode1.userData objectForKey:@"GUAI_SPRITE"];
			NSInteger guaiColor1 = [[guaiSprite1.userData objectForKey:@"color"] integerValue];
			if(guaiColor0 != guaiColor1){
				rowSameColor =NO;
				break;
			}
		}
		if(rowSameColor){ //merge this row of same color sprites into right-most sprites
			//keep last Guai sprite of this row
			SKNode *guaiNode = _guaiNodes[row][_numColumns-1];
			NSInteger count = [self _guaiNodeCount:guaiNode];
			count += _numColumns;
			[self _setGuaiNode:guaiNode count:count];
			//remove all Guai sprites (0.._numColumns-2) but last one
			for(NSInteger c=0; c<_numColumns-1; c++){
				SKNode *guaiNode = _guaiNodes[row][c];
				SKNode *guaiSprite = [_guaiNodes[row][c].userData objectForKey:@"GUAI_SPRITE"];
				[guaiSprite runAction:[SKAction sequence:@[
														   [SKAction fadeOutWithDuration:0.2],
														   [SKAction removeFromParent]
														   ]]];
				[guaiNode.userData removeObjectForKey:@"GUAI_SPRITE"];
				
				[self _setGuaiNode:guaiNode count:0];
			}
			//drop down Guai sprites
			//guaiNodes[r][0.._numColumns-2] <--- guaiNodes[r+1][0.._numColumns-2], r=row..numRows-2
			for(NSInteger r=row; r<=_numRows-2; r++){
				for(NSInteger c=0; c<_numColumns-1; c++){
					SKNode *guaiNode0 = _guaiNodes[r][c];
					SKNode *guaiNode1 = _guaiNodes[r+1][c];
					SKSpriteNode *guaiSprite1 = [guaiNode1.userData objectForKey:@"GUAI_SPRITE"];
					NSInteger count1 = [self _guaiNodeCount:guaiNode1];
					[guaiNode0.userData setObject:guaiSprite1 forKey:@"GUAI_SPRITE"];
					[guaiSprite1 runAction:[SKAction moveTo:[guaiNode0 convertPoint:CGPointZero toNode:guaiSprite1.parent]
												   duration:0.2]];
					[self _setGuaiNode:guaiNode0 count:count1];

				}
			}
			//remove [numRows-1][0..numColumns-2] Guai sprites
			for(NSInteger c=0; c<_numColumns-1; c++){
				SKNode *guaiNode = _guaiNodes[_numRows-1][c];
				[guaiNode.userData removeObjectForKey:@"GUAI_SPRITE"];
				[self _setGuaiNode:guaiNode0 count:0];

			}
			
			rowRemoved = YES;
			break; //no more row processed
		}
	}
	
	if( rowRemoved ){
		//fill all blank Guai nodes with Guai sprites
		[self _fillBlankGuaiNodesWithRandomGuaiSprites];
	}
}

//Pao and Guai colors: 0-Red, 1-Blue, 2-Green
-(void)_firePaos
{
	//fire paoNode[0.._numColumns]
    for(NSUInteger column=0; column<_numColumns; column++) { //fire paoNode[0..numColumns-1]
        SKNode *paoNode = _paoNodes[column];
        CGSize paoSize = [paoNode calculateAccumulatedFrame].size;
		SKNode *guaiNode = _guaiNodes[0][column];
        SKSpriteNode *guaiSpriteNode = (SKSpriteNode *)[guaiNode.userData objectForKey:@"GUAI_SPRITE"];
        NSAssert(guaiSpriteNode!=nil, @"Assertion Failed: there is no \"Guai\" at position[0][%@]", @(column));
        CGPoint p0 = [paoNode convertPoint:CGPointMake(0, paoSize.width/2) toNode:_container];
        CGPoint p1 = ({
            CGSize guaiSize = [guaiSpriteNode calculateAccumulatedFrame].size;
            [guaiSpriteNode convertPoint:CGPointMake(0, -guaiSize.height/2) toNode:_container];
        });
        
        NSInteger paoColor = [[paoNode.userData objectForKey:@"color"] integerValue];
		NSArray<NSString *> *guaiMind = @[@"UI_Mind_Guai_2.png", @"UI_Mind_Guai_1.png", @"UI_Mind_Guai_3.png"];
        SKSpriteNode *bulllet = [SKSpriteNode spriteNodeWithImageNamed:guaiMind[paoColor]];
        p0 = CGPointMake(p0.x, p0.y+bulllet.size.height/2);
        //        p1 = CGPointMake(p1.x, p1.y);
        p1 = CGPointMake(p1.x, p1.y-bulllet.size.height/2);
        bulllet.position = p0;
        [_container addChild:bulllet];
        CGFloat fireDuration = ({
            CGFloat distance = CGPoint_distance(p0, p1);
            const CGFloat speed = 1000;
            distance/speed;
        });
//        [bulllet runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:0.3]]];
        [bulllet runAction:[SKAction moveTo:p1 duration:fireDuration]
                completion:^{
                    [bulllet runAction:[SKAction sequence:@[
                                                            [SKAction fadeOutWithDuration:0.05],
                                                            [SKAction removeFromParent],
                                                            ]]];
                    NSAssert(guaiSpriteNode.userData!=nil, @"guaiNode.userData==nil!");
                    NSAssert([guaiSpriteNode.userData objectForKey:@"color"]!=nil, @"[guaiNode.userData object[color]!=nil");
                    NSInteger guaiColor = [[guaiSpriteNode.userData objectForKey:@"color"] integerValue];
                    if(paoColor == guaiColor){
                        //remove this guai and generate new one
//						SKNode *guaiNode = _guaiNodes[0][column];
						[guaiNode.userData removeObjectForKey:@"GUAI_SPRITE"];
						[guaiSpriteNode runAction:[SKAction sequence:@[
																	   [SKAction group:@[
																						 [SKAction fadeOutWithDuration:0.2],
																						 [SKAction moveByX:0 y:20 duration:0.2],
																						 ]],
																	   [SKAction removeFromParent],
																	   ]]
									   completion:^{ //guaiSpriteNode is removed from guaiNode parent
										   //drop upper sprites (guaiNodes[1..numRows][column]-->guaiNodes[0..numRows-1][column]) down
										   for(NSUInteger r=1; r<_numRows; r++){
											   SKSpriteNode *guaiSprite1 = (SKSpriteNode *)[_guaiNodes[r][column].userData objectForKey:@"GUAI_SPRITE"];
											   CGPoint p1 = [_guaiNodes[r-1][column] convertPoint:CGPointZero toNode:_container];
											   [guaiSprite1 runAction:[SKAction moveTo:p1 duration:0.1]];
											   [_guaiNodes[r-1][column].userData setObject:guaiSprite1 forKey:@"GUAI_SPRITE"];
										   }
										   //remove top-most guaiNodes[numRows-1][column]
										   [_guaiNodes[_numRows-1][column].userData removeObjectForKey:@"GUAI_SPRITE"];
										   [self _fillBlankGuaiNodesWithRandomGuaiSprites];
										   
									   }];
                    }
                }
         ];
		
        SKAction *actionVibratePao = [SKAction sequence:@[
														  [SKAction moveByX:0 y:-30 duration:0.05],
														  [SKAction moveByX:0 y:40 duration:0.05],
														  [SKAction moveByX:0 y:-15 duration:0.10],
														  [SKAction moveByX:0 y:5 duration:0.15],
														  ]];
        [paoNode runAction:actionVibratePao];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *nodeTouched = [self nodeAtPoint:location];
	if([nodeTouched.name isEqualToString:@"PAO_SPRITE"]){
		//FIXME: converting position coordinate
		SKSpriteNode *paoNode = (SKSpriteNode *)nodeTouched;
		_movingPao = paoNode;
		_movingPaoPosition0 = paoNode.position;
		_touchedLocation = location;
		paoNode.color = [SKColor lightGrayColor];
		[paoNode runAction:[SKAction repeatActionForever:[SKAction sequence:@[
																			  [SKAction colorizeWithColorBlendFactor:0.5 duration:0.4],
																			  [SKAction colorizeWithColorBlendFactor:0.0 duration:0.4],
																			  ]]]
		 withKey:@"CHANGE_PAO_SPRITE_COLOR"];
	}
	
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	if(_movingPao != nil){
		UITouch *touch = [touches anyObject];
		CGPoint location = [touch locationInNode:self];
		CGFloat dx = location.x - _touchedLocation.x;
		CGFloat dy = location.y - _touchedLocation.y;
		_movingPao.position = CGPointMake(_movingPaoPosition0.x+dx, _movingPaoPosition0.y+dy);
	}
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	if(_movingPao != nil){
		UITouch *touch = [touches anyObject];
		SKNode *nodeTouched = [self nodeAtPoint:[touch locationInNode:self]];
		if([nodeTouched.name isEqualToString:@"PAO_SPRITE"]){
			[_movingPao removeActionForKey:@"CHANGE_PAO_SPRITE_COLOR"];
			
		}
		NSInteger index = ({
			NSInteger j = -1;
			for(int k=0; k<_numColumns; k++){
				if(_paoNodes[k] ==_movingPao){
					j = k;
					break;
				}
			}
			j;
		});
		BOOL swaped = NO;
		for(NSInteger i=0; i<_numColumns; i++){
			CGPoint p0 = _movingPao.position;
			SKNode *paoNode1 = _paoNodes[i];
			if(i != index){
				CGRect frame1 = [paoNode1 calculateAccumulatedFrame];
				if(CGRectContainsPoint(frame1, p0)){
					CGFloat duration = 0.2;
					[_movingPao runAction:[SKAction moveTo:paoNode1.position duration:duration]];
					[paoNode1 runAction:[SKAction moveTo:_movingPaoPosition0 duration:duration]
					 completion:^{
						 [self _firePaos];
					 }];
					
					//swap papNodes[i]<-->paoNodes[j]
					
					SKNode *t = _paoNodes[i];
					_paoNodes[i] = _paoNodes[index];
					_paoNodes[index] = t;
					swaped = YES;
				}
			}
		}
		if(! swaped){
//			_movingPao.position = _movingPaoPosition0;
			[_movingPao runAction:[SKAction moveTo:_movingPaoPosition0 duration:0.2]];
			[self _firePaos];
		}
		_movingPao = nil;
	}else{
		[self _firePaos];
	}
	
}
@end
