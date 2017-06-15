//
//  ZZMessageBoxNode.h
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/13/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class ZZMessageBox;
@protocol ZZMessageBoxDelegate;
@protocol ZZMesageBoxDataSource;

//class ZZMessageBox
@interface ZZMessageBox : SKNode

@property(nonatomic, weak) id<ZZMesageBoxDataSource> dataSource;
@property(nonatomic, weak) id<ZZMessageBoxDelegate> delegate;

-(instancetype)initWithScale:(CGFloat)scale title:(NSString *)title;

-(void)showIn:(SKScene *)scene;

@end

//protocol ZZMessageBoxDelegate
@protocol ZZMessageBoxDelegate <NSObject>

@optional
-(void)messageBox:(ZZMessageBox *)messageBox clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)messageBox:(ZZMessageBox *)messageBox didDissmissWithButtonIndex:(NSInteger)buttonIndex;

@end


//protocol ZZMesageBoxDataSourceDelegate
@protocol ZZMesageBoxDataSource <NSObject>

@required
-(NSUInteger)numberOfSectionsInMessageBox:(ZZMessageBox *)messageBox;
-(NSUInteger)messageBox:(ZZMessageBox *)messageBox numberOfRowsInSection:(NSUInteger)section;

@optional
-(NSString *)messageBox:(ZZMessageBox *)messageBox titleForHeaderInSection:(NSUInteger)section;
-(UIImage *)messageBox:(ZZMessageBox *)messgeBox imageForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)messagebox:(ZZMessageBox *)messageBox textForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

