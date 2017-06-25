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

//返回两点之间的距离
CGFloat CGPoint_distance(CGPoint p0, CGPoint p1)
{
    return sqrt((p0.x-p1.x)*(p0.x-p1.x) + (p0.y-p1.y)*(p0.y-p1.y));
}


//生成随机序列
NSArray<NSNumber *> * randomSequence(NSInteger n)
{
	NSMutableArray<NSNumber *> *a = [NSMutableArray arrayWithCapacity:n];
	for(NSInteger i=0; i<n; i++){ //a=[0, 1, ..., n-1]
		a[i] = @(i);
	}
	NSMutableArray<NSNumber *> *b = [NSMutableArray arrayWithCapacity:n];
	for(NSInteger m=n-1; m>=0; m--){ //randomly choose one element from remaining m elements in a
		NSInteger k = arc4random_uniform((uint32_t)m);
		NSNumber *x = a[k];
		//		[b addObject:x];
		b[n-1-m] = x;
		[a removeObjectAtIndex:k];
	}
	return b;
}
