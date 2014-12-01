//
//  CCActionTweenRect.h
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCActionInterval.h"

@interface CCActionTweenRect : CCActionInterval
{
    NSString		*_key;
    CGRect			_from, _to;
    CGRect			_delta;
}

/**
 *  Creates an initializes a tween action.
 *
 *  @param aDuration Action duration.
 *  @param key       Property key with a CGRect value to modify.
 *  @param from      Value to tween from.
 *  @param to        Value to tween to.
 *
 *  @return New tween action.
 */
+ (id)actionWithDuration:(CCTime)aDuration key:(NSString *)key fromRect:(CGRect)from toRect:(CGRect)to;

/**
 *  Initializes an initializes a tween action.
 *
 *  @param aDuration Action duration.
 *  @param key       Property key with a CGRect value to modify.
 *  @param from      Value to tween from.
 *  @param to        Value to tween to.
 *
 *  @return New tween action.
 */
- (id)initWithDuration:(CCTime)aDuration key:(NSString *)key fromRect:(CGRect)from toRect:(CGRect)to;

@end