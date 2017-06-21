//
//  Utilities.m
//  game_PaoTaXiaoChu
//
//  Created by zhaoxiaojian on 6/20/17.
//  Copyright © 2017 Zhao Xiaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Utilities.h"

CGFloat CGPoint_distance(CGPoint p0, CGPoint p1)
{
    return sqrt((p0.x-p1.x)*(p0.x-p1.x) + (p0.y-p1.y)*(p0.y-p1.y));
}
