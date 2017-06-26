//
//  ZZGameBoardScene.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/15/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

//TODO: seperate game logic from view and controller

#import "ZZGameBoardScene.h"
#import "Utilities.h"

typedef NS_ENUM(NSInteger, GameState){
    GAMESTATE_INIT,
    GAMESTATE_GENERATING_GUAIS,
	GAMESTATE_REMOVING_SHOOTED_GUAIS,
	GAMESTATE_DROPPING_DOWN_GUAIS,
	GAMESTATE_REMOVING_SAME_COLOR_ROW,
    GAMESTATE_GUAI_GENERATED
};

@interface ZZGameBoardScene()

@property(nonatomic) GameState gameState; //TODO: use it
@property(nonatomic) NSInteger remainingSteps;
@property SKNode *container;
@property CGFloat scale;
@property SKNode *turretBoard;
@property NSUInteger numRows, numColumns;
@property NSMutableArray<NSMutableArray<SKNode *> *> *guaiNodes;
@property NSMutableArray<SKSpriteNode *> *paoNodes;

@property SKNode *movingPao;
@property CGPoint movingPaoPosition0;
@property CGPoint touchedLocation;
@end


@implementation ZZGameBoardScene

-(instancetype)initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	return self;
}

-(void)didMoveToView:(SKView *)view
{
    //TODO: transition _gameState
    _container = [SKNode node];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    _container.position = CGPointMake(0, 0);
    [self addChild:_container];
	
	//add background nodes
    SKSpriteNode *backgroundTop = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_3.png"];
    SKSpriteNode *backgroundBottom = [SKSpriteNode spriteNodeWithImageNamed:@"BJ_4.png"];
    CGFloat bgHeight = backgroundTop.size.height + backgroundBottom.size.height;
    backgroundTop.anchorPoint = CGPointMake(0.5, 1.0);
    backgroundTop.position = CGPointMake(0, bgHeight/2);
    [_container addChild:backgroundTop];
    
    backgroundBottom.anchorPoint = CGPointMake(0.5, 0.0);
    backgroundBottom.position = CGPointMake(0, -bgHeight/2);
    [_container addChild:backgroundBottom];
	
	//container's scale
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
	const NSInteger REMAINING_STEPS = 25;
	[self setRemainingSteps:REMAINING_STEPS];
    
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

//change property @remainingStep:NSInteger
-(void)setRemainingSteps:(NSInteger)steps
{
	_remainingSteps = steps;
    SKLabelNode *remainingStepsLabel = (SKLabelNode *)[self childNodeWithName:@"//LABEL_REMAINING_STEPS"];
    remainingStepsLabel.text = [NSString stringWithFormat:@"%@", @(steps)];
	
	SKLabelNode *labelMinusOne = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
	labelMinusOne.text = @"-1";
	labelMinusOne.position = CGPointZero;
	labelMinusOne.fontSize = remainingStepsLabel.fontSize;
	labelMinusOne.fontColor = remainingStepsLabel.fontColor;
	[remainingStepsLabel addChild:labelMinusOne];
	[labelMinusOne runAction:[SKAction sequence:@[
												  [SKAction group:@[
																	[SKAction fadeOutWithDuration:0.4],
																	[SKAction moveByX:100 y:0 duration:0.4],
																	[SKAction scaleBy:0.8 duration:0.4],
																	]],
												  [SKAction removeFromParent]
												  ]]];
}

//Pao and Guai colors: 0-Red, 1-Blue, 2-Green
-(void)_generateTurret
{
    const CGFloat xPadding = 15.0;
    const CGFloat yPadding = 10.0;
    CGFloat x0 = 10.0;
    CGFloat y0 = 10.0;
	
	{//generate Paos[_numColumns]
		//assume that all cannon sprites have same size
		CGSize paoSpriteSize = [SKSpriteNode spriteNodeWithImageNamed:@"UI_Pao_Blue_1.png"].size;
		CGFloat xPao = x0 + paoSpriteSize.width/2; //anchorPoint=(0.5, 0.5)
		CGFloat yPao = y0 + paoSpriteSize.height/2;
		_paoNodes = [NSMutableArray arrayWithCapacity:_numColumns];
		NSArray<NSNumber *> *seq = randomSequence(_numColumns);
		for(int column=0; column<_numColumns; column++){
			//        NSInteger paoColor = arc4random_uniform(3);
			NSInteger paoColor = [seq[column] integerValue];
			NSInteger paoPower = 0;
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
	}
	{ //generate blank monster nodes to hold monster sprites later
		CGSize guaiSpriteSize = [SKSpriteNode spriteNodeWithImageNamed:@"1.png"].size; //all monsters have the same size
		CGSize guaiNodeSize = CGSizeMake(guaiSpriteSize.width+6, guaiSpriteSize.height+6);
		CGFloat yGuai = y0+guaiNodeSize.height/2;
		_guaiNodes = [NSMutableArray arrayWithCapacity:_numRows];
		//generate Guai[_numRows][_numColumns] nodes to container Guai sprite later
		for(int row=0; row<_numRows; row++){
			_guaiNodes[row] = [NSMutableArray arrayWithCapacity:_numColumns];
			CGFloat xGuai = x0+guaiNodeSize.width/2;
			for(int column=0; column<_numColumns; column++){
				SKShapeNode *guaiNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(guaiNodeSize.width, guaiNodeSize.height) cornerRadius:10];
				guaiNode.userData = [NSMutableDictionary dictionary]; //IMPORTANT
				guaiNode.position = CGPointMake(xGuai, yGuai);
				guaiNode.fillColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:0.2];
				guaiNode.strokeColor = [SKColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
				guaiNode.lineWidth = 2.0;
				[_turretBoard addChild:guaiNode];
				//            [[_guaiNodes objectAtIndex:row] objectAtIndex:column] = guaiNode;
				_guaiNodes[row][column] = guaiNode;
				
				//put a SKLabelNode on each Guai node
				SKLabelNode *guaiLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
				guaiLabel.name = @"GUAI_LABEL";
				const CGFloat fontSize = 24;
				guaiLabel.fontSize = fontSize;
				guaiLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
				guaiLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				guaiLabel.position = CGPointMake(guaiNodeSize.width/2-fontSize/2-2, guaiNodeSize.height/2-fontSize/2-2); //place at top-right corner of guaiNode
				[guaiNode addChild:guaiLabel];
				
				[self _setGuaiNode:guaiNode
							 count:1
						  animated:NO]; //must after guaiLabel added into guaiNode
				
				xGuai += guaiNodeSize.width+xPadding;
			}
			yGuai += guaiNodeSize.height+yPadding;
		}
	}
	
	[self _fillBlankGuaiNodesWithRandomGuaiSprites]; //Note: asynchronous operation may not finish before method returns
}

-(NSInteger)_cannonPower:(NSInteger)cannonIndex
{
	SKSpriteNode *paoSprite = (SKSpriteNode *)_paoNodes[cannonIndex];
	return [[paoSprite.userData objectForKey:@"power"] integerValue];
}

//parameter cannonIndex must be in range [0.._numColumns-1]
//cannonPower in range [0..4]
-(void)_changePao:(NSInteger)column power:(NSInteger)paoPower completion:(void(^)(NSInteger column))completionBlock
{
	SKSpriteNode *paoNode = (SKSpriteNode *)_paoNodes[column];
	NSInteger cannonColor = [[paoNode.userData objectForKey:@"color"] integerValue];
	NSArray<SKColor *> *paoColors = @[@"Red", @"Blue", @"Green"];
	NSString *cannonSpriteImageName = [NSString stringWithFormat:@"UI_Pao_%@_%@.png", paoColors[cannonColor], @(paoPower+1)];
	SKTexture *cannonSpriteTexture = [SKTexture textureWithImageNamed:cannonSpriteImageName];
	NSAssert(cannonSpriteTexture!=nil, @"Assertion failed: cannonSpriteTexture==nil! cannonSpriteImageName=%@", cannonSpriteImageName);
//	cannonSprite.texture = [SKTexture textureWithImageNamed:cannonSpriteImageName];
	[paoNode runAction:[SKAction sequence:@[
												 [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:0.5 duration:0.1],
												 [SKAction setTexture:cannonSpriteTexture],
												 [SKAction colorizeWithColorBlendFactor:0.0 duration:0.1],
												 ]]
			  completion:^{
				  if(completionBlock)
					  completionBlock(column);
			  }];
	[paoNode.userData setValue:@(paoPower) forKey:@"power"];
}


//TODO: consider move Guai counts from guai node to guai sprite
-(NSInteger)_guaiNodeCount:(SKNode *)guaiNode
{
	NSInteger count = [[guaiNode.userData objectForKey:@"count"] integerValue];
	return count;
}

-(void)_setGuaiNode:(SKNode *)guaiNode count:(NSInteger)count animated:(BOOL)animated
{
	NSNumber *count0 = [guaiNode.userData objectForKey:@"count"];
	[guaiNode.userData setObject:@(count) forKey:@"count"];
	
	if(count0==nil || [count0 integerValue] != count){ //count changed
		SKLabelNode *guaiNodeLabel = (SKLabelNode *)[guaiNode childNodeWithName:@"GUAI_LABEL"];
		SKAction *changeTextAction = [SKAction runBlock:^{
//			guaiNodeLabel.text = [@(count==1 ? 0: count) description];
			guaiNodeLabel.text = count==0 ? @"" : [@(count) description];
			
		}];
		if(! animated){
			[guaiNodeLabel runAction:changeTextAction];
		}else{
			SKAction *scaleAction = [SKAction scaleBy:1.6 duration:0.2];
			[guaiNodeLabel runAction:[SKAction sequence:@[
														  scaleAction,
														  changeTextAction,
														  [SKAction waitForDuration:0.1],
														  [scaleAction reversedAction],
														  ]]];
		}
	}
}

//call this method when:
//1. the first time the scene is created
//2. one row of sprites with same color are merged
//3. some sprites on first row are exploded by cannons
-(void)_fillBlankGuaiNodesWithRandomGuaiSprites
{
	NSLog(@"--_fillBlankGuaiNodesWithRandomGuaiSprites!");
	self.gameState = GAMESTATE_GENERATING_GUAIS;
	for(NSUInteger column=0; column<_numColumns; column++){
		[self _generateRandomGuaisForColumn:column];
	}
}

-(void)_generateRandomGuaisForColumn:(NSUInteger)column;
{
	self.gameState = GAMESTATE_GENERATING_GUAIS;
	
	//search for the first "blank" Guai node in the column (from bottom row to top row)
	NSUInteger row=0;
	for(; row < _numRows; row++){
		SKNode *guaiNode = _guaiNodes[row][column];
		SKSpriteNode *guaiSprite = [guaiNode.userData objectForKey:@"GUAI_SPRITE"];
		if(guaiSprite == nil){ //"blank" Guai node
			break;
		}
	}
	
	if(row <= _numRows-1){ //there is a "blank" monster node, so generate monster sprite at [r][column]
		NSLog(@"    fill guaiNodes[%@][%@] with a randomly generate sprite...", @(row), @(column));
		SKNode *guaiNode = _guaiNodes[row][column];
		NSInteger guaiColor = arc4random_uniform(3); //random monster color
		NSArray<NSString *> *monsterSpriteImageNames = @[@"1.png", @"2.png", @"3.png"];
		SKSpriteNode *guaiSprite = [SKSpriteNode spriteNodeWithImageNamed:monsterSpriteImageNames[guaiColor]];
		//each monster has a "color" property in its .userData member
		guaiSprite.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"color": @(guaiColor)}];
		//            guaiSprite.position = CGPointZero;
		[_container addChild:guaiSprite];
		{
			const CGFloat yStart = [self convertPoint:CGPointMake(0, self.size.height/2) toNode:guaiSprite.parent].y; //self.anchorPoint=(0.5, 0.5)
			CGPoint guaiNodePosition = [guaiNode convertPoint:CGPointZero toNode:guaiSprite.parent];
			CGPoint positionFrom = CGPointMake(guaiNodePosition.x, yStart + [guaiSprite calculateAccumulatedFrame].size.height/2 );
			guaiSprite.position = positionFrom;
			CGPoint positionTo = CGPointMake(guaiNodePosition.x, guaiNodePosition.y);
			CGFloat duration = ({
				CGFloat distance = CGPoint_distance(positionFrom, positionTo);
				const CGFloat speed = 800.0;
				distance/speed;
			});
			SKAction *dropDownAction = [SKAction moveTo:positionTo
											   duration:duration];
			dropDownAction.timingMode = SKActionTimingEaseIn;
			[guaiSprite runAction:dropDownAction
					   completion:^(void){//guaiNodes[row][column] is filled with guaiSprite.
						   [guaiNode.userData setObject:guaiSprite
												 forKey:@"GUAI_SPRITE"]; //set data before Guai sprite really dropped down
						   [self _setGuaiNode:guaiNode
										count:1
									 animated:YES];

						   //recursively fill Guai sprites until row==numRows
						   [self _generateRandomGuaisForColumn:column];
					   }];
		}
	}else{ //row==numRows, means all blank Guai nodes filled with Guai sprites for this *column*
		[self guaiNodesDidFilledOnColumn:column];
	}
	
}

//guaiNodes[0..numRows-1][column] are filled with monster sprites
-(void)guaiNodesDidFilledOnColumn:(NSInteger)column
{
	NSLog(@"--guaiNodesDidFilledOnColumn:%@!", @(column));
	//test whether all columns of monster nodes are filled with monster sprites
	BOOL allColumnsFilledWithSprites = YES;
	for(NSInteger c=0; c<_numColumns; c++){
		SKNode *guaiNode = _guaiNodes[_numRows-1][c]; //top-most row
		if([guaiNode.userData objectForKey:@"GUAI_SPRITE"] == nil){ //there is still blank guaiNodes not filled
			allColumnsFilledWithSprites = NO;
			break;
		}
	}
	if( allColumnsFilledWithSprites ){ //the whole monster nodes are filled with monster sprites
		NSLog(@"--allColumnsFilledWithSprites!\n\n");
		
		//now remove rows with same color Guais
		BOOL removed = [self _removeGuaiRowsOfSameColor]; //Note: this may be an asynchronous operation
		if(! removed){
			[self allGuaiNodesDidFilled];
			NSLog(@"--allGuaiNodesDidFilled!");
		}
	}
}

-(void)allGuaiNodesDidFilled
{
	self.gameState = GAMESTATE_GUAI_GENERATED;
}

-(BOOL)_removeGuaiRowsOfSameColor
{
	NSLog(@"--_removeGuaiRowsOfSameColor...");
	
	BOOL anyRowRemoved = NO;
	for(NSInteger row=0; row<_numRows && !anyRowRemoved; row++){ //only remove one row of monsters with same color
		SKNode *guaiNode0 = _guaiNodes[row][0]; //guaiNodes[row][1..numColumns-1] are compared with guaiNodes[row][0]
		SKSpriteNode *guaiSprite0 = [guaiNode0.userData objectForKey:@"GUAI_SPRITE"];
		NSInteger guaiColor0 = [[guaiSprite0.userData objectForKey:@"color"] integerValue];
		//test whether whole row has same color Guais
		BOOL sameColor = YES;
		for(NSInteger c=1; c<_numColumns; c++){
			SKNode *guaiNode1 = _guaiNodes[row][c];
			SKSpriteNode *guaiSprite1 = [guaiNode1.userData objectForKey:@"GUAI_SPRITE"];
			NSInteger guaiColor1 = [[guaiSprite1.userData objectForKey:@"color"] integerValue];
			if(guaiColor0 != guaiColor1){
				sameColor =NO;
				break;
			}
		}
		if(sameColor){ //merge this *row* of same color sprites into right-most sprites
			self.gameState = GAMESTATE_REMOVING_SAME_COLOR_ROW;
			
			//keep last Guai sprite of this row
			//guaiNodes[row][0..numColumns-2] --merge--> guaiNodes[row][numColumns-1]
			NSInteger columnKeeping = arc4random_uniform((uint32_t)_numColumns);
			SKNode *guaiNodeKeeping = _guaiNodes[row][columnKeeping];
			SKSpriteNode *guaiSpriteKeeping =(SKSpriteNode *)[guaiNodeKeeping.userData objectForKey:@"GUAI_SPRITE"]; //keep this sprite on the _guaiNodes
			//remove all Guai sprites (0.._numColumns-2) but last one
			for(NSInteger column=0; column<_numColumns; column++){
				if(column == columnKeeping){ //skip column keepped
					continue;
				}
				
				SKNode *guaiNodeToRemove = _guaiNodes[row][column];
				SKNode *guaiSpriteToRemove = [guaiNodeToRemove.userData objectForKey:@"GUAI_SPRITE"];
				[guaiNodeToRemove.userData removeObjectForKey:@"GUAI_SPRITE"];
				
				SKAction *actionHighlighting = [SKAction sequence:@[ //hightlighting sprites that are to be removed
																  [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1.0 duration:0.4],
																  [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:0.0 duration:0.2],
																  ]];
				CGFloat duration = ({
					CGFloat distance = CGPoint_distance(guaiNodeToRemove.position, guaiNodeKeeping.position);
					const CGFloat speed = 400.0;
					distance/speed;
				});
				[guaiSpriteToRemove runAction:[SKAction sequence:@[
																   actionHighlighting,
																   [SKAction group:@[
																					 [SKAction moveTo:guaiSpriteKeeping.position duration:duration],
																					 [SKAction fadeOutWithDuration:duration],
																					 [SKAction scaleBy:0.5 duration:duration],
																					 ]
																	]]]
								   completion:^{
									   NSLog(@"--same color sprites removed for row=%@, now drop down...", @(row));
									   [SKAction removeFromParent]; //remove guaiSpriteToRemove ([row][0..numColumns-2]) from parent node
									   
									   NSInteger countRemoving = [self _guaiNodeCount:guaiNodeToRemove];
									   [self _setGuaiNode:guaiNodeToRemove //after Guai sprite is removed, the guaiNode's count reset to zero
													count:0
												 animated:NO];
									   
									   NSInteger countKeeping = [self _guaiNodeCount:guaiNodeKeeping];
									   [self _setGuaiNode:guaiNodeKeeping
													count:countKeeping + countRemoving
												 animated:YES];

									   
									   SKAction *actionScale = [SKAction scaleBy:1.1 duration:0.2];
									   [guaiSpriteKeeping runAction:[SKAction sequence:@[
																					   actionScale,
																					   [actionScale reversedAction]
																					   ]]
													   completion:^{
														   NSLog(@"==drop down beginning row=%@ onColumn=%@", @(row), @(column));
														   //drop down Guai sprites on column[column]
														   //guaiNodes[r][column] <--- guaiNodes[r+1][column], for r=row..numRows-2, for column=0.._numColumns-2
														   [self _dropDownBeginingAtRow:row onColumn:column];
													   }];
									   
								   }];
				
			}

			anyRowRemoved = YES;
			break; //no more row processed
		}
	}
	
	if( anyRowRemoved ){
		//fill all blank Guai nodes with Guai sprites
//		[self _fillBlankGuaiNodesWithRandomGuaiSprites]; //moved into -__dropDownBeginingAtRow:onColumn: for each column

	}
	return anyRowRemoved;
}

//r: drop down guais[r+1..numRows-1] --> [guais[r..numRows-2]
-(void)_dropDownBeginingAtRow:(NSInteger)r onColumn:(NSInteger)column
{
	NSLog(@"\t__dropDownBeginingAtRow:%@ onColumn:%@...", @(r), @(column));
	self.gameState = GAMESTATE_DROPPING_DOWN_GUAIS;
	if(r==_numRows-1){ //top-most row reached, remove [numRows-1][column] Guai sprites
		SKNode *guaiNodeAtTopMostRow = _guaiNodes[_numRows-1][column];
//		SKSpriteNode *guaiSprite = (SKSpriteNode *)[guaiNodeAtTopMostRow.userData objectForKey:@"GUAI_SPRITE"];
//		[guaiSprite removeFromParent]; //Note: don't remove guaiSprite, it's already dropped down to row below
		[guaiNodeAtTopMostRow.userData removeObjectForKey:@"GUAI_SPRITE"];
		[self _setGuaiNode:guaiNodeAtTopMostRow
					 count:0
				  animated:NO];
		
		NSLog(@"--columnDidDroppedDown! column=%@, now generate random Guais for this column...\n\n", @(column));
		[self _generateRandomGuaisForColumn:column];
		return ;
	}
	
	//else: r<=numRows-2
	SKNode *guaiNodeFrom = _guaiNodes[r+1][column];
	SKNode *guaiNodeTo = _guaiNodes[r][column];
	SKSpriteNode *guaiSpriteFrom = [guaiNodeFrom.userData objectForKey:@"GUAI_SPRITE"];
	NSInteger count1 = [self _guaiNodeCount:guaiNodeFrom];
	
	[guaiNodeTo.userData setObject:guaiSpriteFrom forKey:@"GUAI_SPRITE"];
	CGPoint position0 = [guaiNodeTo convertPoint:CGPointZero toNode:guaiSpriteFrom.parent];
	NSLog(@"--drop down row:%@-->%@ onColumn:%@", @(r+1), @(r), @(column));
	CGFloat duration = ({
		CGFloat distance = CGPoint_distance(guaiNodeFrom.position, guaiNodeTo.position);
		const CGFloat speed = 800.0;
		distance/speed;
	});
	[guaiSpriteFrom runAction:[SKAction moveTo:position0
									  duration:duration]
				   completion:^{ //dropped down: _guaiNodes[r+1][column]-->_guaiNodes[r][column]
					   [self _setGuaiNode:guaiNodeTo
									count:count1
								 animated:NO];
					   
					   //recursive drop down next row
					   [self _dropDownBeginingAtRow:r+1 onColumn:column];
				   }
	 ];
}


//Pao and Guai colors: 0-Red, 1-Blue, 2-Green
-(void)_firePaos
{
	NSLog(@"--firePaos!");
	NSInteger remainingSteps0 = [self remainingSteps];
	[self setRemainingSteps:remainingSteps0-1];
	
	//fire paoNode[0.._numColumns]
    for(NSUInteger column=0; column<_numColumns; column++) { //fire paoNode[0..numColumns-1]
        SKSpriteNode *paoNode = _paoNodes[column];
        CGSize paoSize = [paoNode calculateAccumulatedFrame].size;
		const NSInteger row = 0; //bottom-most row
		SKNode *guaiNode = _guaiNodes[row][column];
        SKSpriteNode *guaiSpriteAttacked = (SKSpriteNode *)[guaiNode.userData objectForKey:@"GUAI_SPRITE"];
        NSAssert(guaiSpriteAttacked!=nil, @"Assertion Failed: there is no \"Guai\" at position[0][%@]", @(column));
        CGPoint p0 = [paoNode convertPoint:CGPointMake(0, paoSize.width/2) toNode:_container];
        CGPoint p1 = ({
            CGSize guaiSize = [guaiSpriteAttacked calculateAccumulatedFrame].size;
            [guaiSpriteAttacked convertPoint:CGPointMake(0, -guaiSize.height/2) toNode:_container];
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
                completion:^{ //bullet shooted from Pao sprite collides with Guai sprite
                    [bulllet runAction:[SKAction sequence:@[//bullet disappear
                                                            [SKAction fadeOutWithDuration:0.05],
                                                            [SKAction removeFromParent],
                                                            ]]];
                    NSInteger guaiColor = [[guaiSpriteAttacked.userData objectForKey:@"color"] integerValue];
					
					NSInteger paoPower = [self _cannonPower:column];
					const NSInteger MAX_CANNON_POWER = 5-1;
					if(paoPower == MAX_CANNON_POWER){ //destroy the whole column of Guai sprites even Pao and Guai has no same color
						//TODO: destroy whole column
						[self _shootColumnWithLaserGun:column];
						
						[self _drainPaoPower:column fromPower:MAX_CANNON_POWER-1 toPower:0];
					}else if(paoColor == guaiColor){ //shoot Guai sprite with same color
						self.gameState = GAMESTATE_REMOVING_SHOOTED_GUAIS;
                        //remove this guai and generate new one
//						SKNode *guaiNode = _guaiNodes[0][column];
						
						[guaiNode.userData removeObjectForKey:@"GUAI_SPRITE"]; //removed shooted Guai sprites from guai nodes (if with same color)
						
						//TODO: repeat guaiNode's "count" times when a guaiNode's sprite is shooted
						[self _guaiShootedAtRow:row column:column guaiColor:guaiColor count:[self _guaiNodeCount:guaiNode]]; //explosion effect
						[guaiSpriteAttacked runAction:[SKAction sequence:@[ //remove attacked Guai node
																	   [SKAction group:@[
																						 [SKAction fadeOutWithDuration:0.4],
																						 [SKAction moveByX:0 y:20 duration:0.4],
																						 ]],
																	   [SKAction removeFromParent],
																	   ]]
									   completion:^{ //guaiSpriteNode is removed from guaiNode parent
										   [self _changePao:column
													  power:paoPower+1
												 completion:nil]; //Pao's power up!
										   if(paoPower==MAX_CANNON_POWER-1){
											   SKSpriteNode *paoGlowingSprite = [SKSpriteNode node];
											   paoGlowingSprite.name = @"PAO_GLOWING_SPRITE";
											   paoGlowingSprite.position = CGPointZero;
											   //Note: add glowing sprite behind the Pao sprite, or else -touchesBegan:withEvent: will not hit-test the Pao sprite but the glowing sprite
											   [paoNode addChild:paoGlowingSprite];
											   
											   const NSInteger numPaoGlowingAnimationTextures = 7;
											   NSMutableArray<SKTexture *> *paoGlowingAnimationTextures = [NSMutableArray arrayWithCapacity:numPaoGlowingAnimationTextures];
											   for(int k=0; k<numPaoGlowingAnimationTextures; k++){
												   NSString *textureName = [NSString stringWithFormat:@"DH_PT_%@.png", @(k+1)];
												   SKTexture *paoGlowingTexture = [SKTexture textureWithImageNamed:textureName];
												   [paoGlowingAnimationTextures addObject:paoGlowingTexture];
											   }
											   SKAction *actionPaoGlowing = [SKAction animateWithTextures:paoGlowingAnimationTextures timePerFrame:1.0/20 resize:YES restore:NO];
											   [paoGlowingSprite runAction:[SKAction repeatActionForever:actionPaoGlowing]];
										   }

										   [self _dropDownBeginingAtRow:0 onColumn:column];
										   
									   }];
					}else{ //Pao's power is not MAX_CANNON_POWER and Pao's color is different from Guai's color
						
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

-(void)_drainPaoPower:(NSInteger)column fromPower:(NSInteger)power toPower:(NSInteger)paoPowerTo
{
	if(power != paoPowerTo){
		[self _changePao:column
				   power:power
			  completion:^(NSInteger column){
				  [self _drainPaoPower:column fromPower:power-1 toPower:paoPowerTo];
			  }];
	}
}
-(void)_shootColumnWithLaserGun:(NSInteger)column
{
	self.gameState = GAMESTATE_REMOVING_SHOOTED_GUAIS;
	SKSpriteNode *paoNode = _paoNodes[column];
	{//shoot laser
		SKSpriteNode *laserSprite = [SKSpriteNode node];
		laserSprite.anchorPoint = CGPointMake(0.5, 0);
		laserSprite.position = [paoNode convertPoint:CGPointMake(0, 0) toNode:_container];
		SKNode *topMostGuaiNode = _guaiNodes[_numRows-1][column];
		const CGFloat laserHeight = CGPoint_distance(topMostGuaiNode.position, paoNode.position) + [topMostGuaiNode calculateAccumulatedFrame].size.height/2;
		const CGFloat laserWidth = paoNode.size.width*1.5;
		laserSprite.size = CGSizeMake(laserWidth, laserHeight);
		const NSInteger numLaserAnimationTextures = 14;
		NSMutableArray<SKTexture *> *laserAnimationTextures = [NSMutableArray arrayWithCapacity:numLaserAnimationTextures];
		for(int k=0; k<numLaserAnimationTextures; k++){
			NSString *textureName = [NSString stringWithFormat:@"DH_JG_%@.png", @(k+1)];
			SKTexture *laserTexture = [SKTexture textureWithImageNamed:textureName];
			[laserAnimationTextures addObject:laserTexture];
		}
		
		SKAction *actionShootingLaser = [SKAction animateWithTextures:laserAnimationTextures
														 timePerFrame:1.0/20
															   resize:NO
															  restore:NO];
		[_container addChild:laserSprite];
		[laserSprite runAction:actionShootingLaser
					completion:^{
						[laserSprite removeFromParent];
						
						SKSpriteNode *paoGlowingSprite = (SKSpriteNode *)[paoNode childNodeWithName:@"PAO_GLOWING_SPRITE"];
						[paoGlowingSprite removeFromParent];
					}];
	}
	
	//remove all Guai sprites of the column, starting from row 0, recursively
	[self _laserShootBeginningAtRow:0 onColumn:column];
	
}

-(void)_laserShootBeginningAtRow:(NSInteger)r onColumn:(NSInteger)column
{
	if(r > _numRows-1){ //all sprite of this column destroyed
		[self _generateRandomGuaisForColumn:column];
	}else{
		SKNode *guaiNode = _guaiNodes[r][column];
		SKSpriteNode *guaiSprite = [guaiNode.userData objectForKey:@"GUAI_SPRITE"];
		NSInteger guaiSpriteColor = [[guaiSprite.userData objectForKey:@"color"] integerValue];
		NSInteger guaiCount = [[guaiNode.userData objectForKey:@"count"] integerValue];
		[self _guaiShootedAtRow:r column:column guaiColor:guaiSpriteColor count:guaiCount];
		
		[guaiNode.userData removeObjectForKey:@"GUAI_SPRITE"];
		[guaiSprite runAction:[SKAction fadeOutWithDuration:0.1]
				   completion:^{
					   [guaiSprite removeFromParent];
					   [self _laserShootBeginningAtRow:r+1 onColumn:column]; //forward to next row
				   }];
	}
}

-(void)_guaiShootedAtRow:(NSInteger)row column:(NSInteger)column guaiColor:(NSInteger)guaiSpriteColor count:(NSInteger)guaiCount
{
	SKNode *guaiNode = _guaiNodes[row][column];
	CGSize guaiNodeSize = [guaiNode calculateAccumulatedFrame].size;
	CGPoint position = [guaiNode convertPoint:CGPointZero toNode:_container];
	SKEmitterNode *emitter = [SKEmitterNode node];
	emitter.position = position;
	[_container addChild:emitter];
	
	NSArray<NSString *> *guaiMind = @[@"UI_Mind_Guai_2.png", @"UI_Mind_Guai_1.png", @"UI_Mind_Guai_3.png"];
	SKTexture *guaiTexture = [SKTexture textureWithImageNamed:guaiMind[guaiSpriteColor]];
	emitter.particleTexture = guaiTexture;
	emitter.particleSize = CGSizeMake(guaiTexture.size.width*0.7, guaiTexture.size.height*0.7);
	emitter.numParticlesToEmit = guaiCount*10;
	emitter.particleBirthRate = emitter.numParticlesToEmit/0.1;
	emitter.particleSpeed = 500.0;
	const CGFloat distance = MAX(guaiNodeSize.width, guaiNodeSize.height)*2.0;
	emitter.particleLifetime = distance/emitter.particleSpeed; //t=s/v
	emitter.particleAlphaSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[@(1.0), @(0.5), @(0.0)]
																				 times:@[@(0.0), @(0.7), @(1.0)]];
	emitter.particleScaleSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[@(0.5), @(1.0), @(0.0)]
																				 times:@[@(0.0), @(0.3), @(1.0)]];
	emitter.emissionAngle = M_PI_2;
	emitter.emissionAngleRange = 2*M_PI;
	emitter.particlePositionRange = CGVectorMake(guaiNodeSize.width, guaiNodeSize.height);
	[emitter runAction:[SKAction sequence:@[
											[SKAction waitForDuration:emitter.numParticlesToEmit/emitter.particleBirthRate+emitter.particleLifetime],
											[SKAction removeFromParent]
											]]];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
	if([node.name isEqualToString:@"BUTTON_PAUSE"]){ //DEBUG
		return;
	}
	
	if(self.gameState != GAMESTATE_GUAI_GENERATED){//user interaction enabled only when .gameState==GAUI_GENERATED
		return ;
	}
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *nodeTouched = [self nodeAtPoint:location];
	if([nodeTouched.name isEqualToString:@"PAO_SPRITE"]){
		//FIXME: converting position coordinate
		SKSpriteNode *paoNode = (SKSpriteNode *)nodeTouched;
		_movingPao = paoNode;
		_movingPaoPosition0 = paoNode.position;
		_touchedLocation = location;
	}else if([nodeTouched.name isEqualToString:@"PAO_GLOWING_SPRITE"]){
		SKSpriteNode *paoNode = (SKSpriteNode *)nodeTouched.parent;
		NSAssert([paoNode.name isEqualToString:@"PAO_SPRITE"], @"Assertion failed in touchesBegan:withEvent:! glowingNode's parent is not Pao node");
		_movingPao = paoNode;
		_movingPaoPosition0 = paoNode.position;
		_touchedLocation = location;
	}
	
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	if(self.gameState != GAMESTATE_GUAI_GENERATED){
		return ;
	}
	
	if(_movingPao != nil){
		UITouch *touch = [touches anyObject];
		CGPoint location = [touch locationInNode:self];
		CGFloat dx = location.x - _touchedLocation.x;
		CGFloat dy = location.y - _touchedLocation.y;
		_movingPao.position = CGPointMake(_movingPaoPosition0.x+dx, _movingPaoPosition0.y+dy);
		
		//TODO: make the sprite-to-swap half transparent
	}
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	if(self.gameState != GAMESTATE_GUAI_GENERATED){
		return ;
	}
	
	if(_movingPao != nil){
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
		BOOL paoSwapped = NO;
		const CGFloat movingSpeed = 600;
		for(NSInteger i=0; i<_numColumns; i++){
			CGPoint p0 = _movingPao.position;
			SKNode *paoNodeToSwap = _paoNodes[i];
			if(i != index){
				CGRect frameToSwap = [paoNodeToSwap calculateAccumulatedFrame];
				if(CGRectContainsPoint(frameToSwap, p0)){ //_movingPao intersects with another cannon sprite
					CGFloat duration1 = CGPoint_distance(_movingPao.position, paoNodeToSwap.position)/movingSpeed;
					CGFloat duration2 = CGPoint_distance(_movingPaoPosition0, paoNodeToSwap.position)/movingSpeed;
					[_movingPao runAction:[SKAction moveTo:paoNodeToSwap.position duration:duration1]];
					[paoNodeToSwap runAction:[SKAction moveTo:_movingPaoPosition0 duration:duration2]
					 completion:^{
						 [self _firePaos];
					 }];
					
					//swap papNodes[i]<-->paoNodes[j]
					
					SKSpriteNode *t = _paoNodes[i];
					_paoNodes[i] = _paoNodes[index];
					_paoNodes[index] = t;
					paoSwapped = YES;
				}
			}
		}
		if(! paoSwapped){
//			_movingPao.position = _movingPaoPosition0;
			[_movingPao runAction:[SKAction moveTo:_movingPaoPosition0 duration:(CGPoint_distance(_movingPao.position, _movingPaoPosition0)/movingSpeed)] //move back to original position
					   completion:^{
						   [self _firePaos];
					   }];
		}
		_movingPao = nil;
	}else{
		SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
		if([node.name isEqualToString:@"BUTTON_PAUSE"]){ //DEBUG
			return;
		}
		
		[self _firePaos];
	}
	
}

-(void)setGameState:(GameState)gameState
{
	_gameState = gameState;
	
	NSArray<NSString *> *stateNames = @[
										@"GAMESTATE_INIT",
										@"GAMESTATE_GENERATING_GUAIS",
										@"GAMESTATE_REMOVING_SHOOTED_GUAIS",
										@"GAMESTATE_DROPPING_DOWN_GUAIS",
										@"GAMESTATE_REMOVING_SAME_COLOR_ROW",
										@"GAMESTATE_GUAI_GENERATED",
										];
	NSLog(@"--setGameState:%@", stateNames[gameState]);
}
//DEBUG ONLY
-(void)__debugPrintPaoSprites
{
	NSMutableString *colors = [NSMutableString string];
	for(NSInteger c=0; c<_numColumns; c++){
		NSInteger paoColor = [[_paoNodes[c].userData objectForKey:@"color"] integerValue];
		[colors appendFormat:@"\t%@", @[@"R", @"B", @"G"][paoColor]];
	}
	NSLog(@"--Pao Colors: \n%@", colors);
}
-(void)__debugGuaiSprites
{
	NSMutableString *colors = [NSMutableString string];;
	for(NSInteger r=_numRows-1; r>=0; r--){
		for(NSInteger c=0; c<_numColumns; c++){
			SKSpriteNode *guaiSprite = (SKSpriteNode *)[_guaiNodes[r][c].userData objectForKey:@"GUAI_SPRITE"];
			NSInteger guaiColor = [[guaiSprite.userData objectForKey:@"color"] integerValue];
			[colors appendFormat:@"\t%@", @[@"R", @"B", @"G"][guaiColor]];
		}
		[colors appendString:@"\n"];
	}
	
	NSLog(@"--Guai Colors: \n%@", colors);
}
@end
