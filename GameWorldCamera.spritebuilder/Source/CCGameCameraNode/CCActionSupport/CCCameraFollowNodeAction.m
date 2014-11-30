//
//  CCCameraFollowNodeAction.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCCameraFollowNodeAction.h"

@implementation CCCameraFollowNodeAction

+ (id)actionWithTarget:(CCNode *) fNode
{
    return [[self alloc] initWithTarget:fNode];
}
- (id)initWithTarget:(CCNode *)fNode
{
    if( (self = [super init]) ) {
        
        _followedNode = fNode;
    }
    
    return self;
}
- (id)copyWithZone:(NSZone*)zone
{
    CCAction *copy = [[[self class] allocWithZone: zone] init];
    copy.tag = _tag;
    return copy;
}

- (void)step:(CCTime)dt
{
    [_target setValue:[NSValue valueWithCGPoint: _followedNode.position]
               forKey:@"positionInWorldCoords"];
}


- (BOOL)isDone
{
    return !_followedNode.runningInActiveScene;
}

- (void)stop
{
    _target = nil;
    [super stop];
}

@end
