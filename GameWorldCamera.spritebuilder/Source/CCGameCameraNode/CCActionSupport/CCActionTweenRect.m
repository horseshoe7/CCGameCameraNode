//
//  CCActionTweenRect.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCActionTweenRect.h"

CGSize ccP2S(CGPoint p)
{
    return CGSizeMake(p.x, p.y);
}

CGPoint ccS2P(CGSize s)
{
    return CGPointMake(s.width, s.height);
}

@implementation CCActionTweenRect
{
    CGRect _updateRect;
}

+ (id)actionWithDuration:(CCTime)aDuration key:(NSString *)aKey fromRect:(CGRect)aFrom toRect:(CGRect)aTo {
    
    return [[[self class] alloc] initWithDuration:aDuration key:aKey fromRect:aFrom toRect:aTo];
}

- (id)initWithDuration:(CCTime)aDuration key:(NSString *)key fromRect:(CGRect)from toRect:(CGRect)to {
    
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
    _delta.origin = ccpSub(_to.origin, _from.origin);
    CGPoint pointSize = ccpSub(ccp(_to.size.width, _to.size.height), ccp(_from.size.width, _from.size.height));
    _delta.size = ccP2S(pointSize);
}

- (void)update:(CCTime) dt
{
    // (to - delta)*(1-dt)
    _updateRect.origin = ccpAdd(_from.origin, ccpMult(_delta.origin, dt));
    
    // (to - delta)*(1 - dt)
    _updateRect.size = ccP2S(ccpAdd(ccS2P(_from.size),
                                    ccpMult(ccS2P(_delta.size), dt)));
    
    [_target setValue:[NSValue valueWithCGRect:_updateRect] forKey:_key];
}

- (CCActionInterval *)reverse
{
    return [[self class] actionWithDuration:_duration key:_key fromRect:_to toRect:_from];
}
@end
