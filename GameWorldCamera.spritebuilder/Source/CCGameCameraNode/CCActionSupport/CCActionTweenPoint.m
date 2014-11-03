//
//  CCActionTweenPoint.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCActionTweenPoint.h"

@implementation CCActionTweenPoint
{
    CGPoint _updatePoint;
}

+ (id)actionWithDuration:(CCTime)aDuration key:(NSString *)aKey fromPoint:(CGPoint)aFrom toPoint:(CGPoint)aTo {
    
    return [[[self class] alloc] initWithDuration:aDuration key:aKey fromPoint:aFrom toPoint:aTo];
}

- (id)initWithDuration:(CCTime)aDuration key:(NSString *)key fromPoint:(CGPoint)from toPoint:(CGPoint)to {
    
    if ((self = [super initWithDuration:aDuration])) {
        
        _key	= [key copy];
        _to		= to;
        _from	= from;
        
        
    }
    
    return self;
}


- (void)startWithTarget:aTarget
{
    [super startWithTarget:aTarget];
    _delta = ccpSub(_to, _from);
}

- (void)update:(CCTime) dt
{
    //_updatePoint = ccpMult(ccpSub(_to, _delta), (1 - dt));
    
    _updatePoint = ccpAdd(_from, ccpMult(_delta, dt));
    
    [_target setValue:[NSValue valueWithCGPoint:_updatePoint] forKey:_key];
}

- (CCActionInterval *)reverse
{
    return [[self class] actionWithDuration:_duration key:_key fromPoint:_to toPoint:_from];
}


@end
