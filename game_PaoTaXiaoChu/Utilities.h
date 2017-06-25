//
//  Utilities.h
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/20/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//
#import <CoreFoundation/CoreFoundation.h>

#ifndef Utilities_h
#define Utilities_h

/*!
 * 返回两点之间的距离
 */
CGFloat CGPoint_distance(CGPoint p0, CGPoint p1);
/*!
 * 生成一个随机序列
 */
NSArray<NSNumber *> * randomSequence(NSInteger n);


#endif /* Utilities_h */
