//
//  Gameplay.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 30/10/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "Gameplay.h"
#import "CCGameCameraNode.h"
#import "GameWorld.h"

@interface Gameplay()

@property (nonatomic, readonly) CCGameCameraNode *camera;

@end

@implementation Gameplay
{
    CCGameCameraNode *_camera;
    
    GameWorld *_gameWorld;
    
    CCNode *_hudContainer;
    CCNode *_worldContainer;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCLOG(@"Gameplay Loaded");
    
    _gameWorld = (GameWorld*)[CCBReader load:@"TestWorld"];
    
    CGSize winsize = [CCDirector sharedDirector].view.bounds.size;
    _camera = [[CCGameCameraNode alloc] initWithWorld:_gameWorld];
    _camera.position = ccp(0.5f * winsize.width , 0.5f * winsize.height);
    
    [_worldContainer addChild:_camera];
    
    self.camera.positionInWorldCoords = CGPointZero;
    
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // implemented like this because you may want to have conditions where a touch should not pan the camera, like if you are using your finger to grab an object in your world.
    [self.camera touchBegan:touch withEvent:event];
}
- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.camera touchMoved:touch withEvent:event];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.camera touchEnded:touch withEvent:event];
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.camera touchCancelled:touch withEvent:event];
}

#pragma mark - Actions

- (void)moveToTopRight
{
    CCLOG(@"move to topRight");
    
    CGRect targetRect = CGRectMake(900, 900, 100, 150);
    CCActionInterval *action = [self.camera actionToMoveToRect:targetRect duration:2];
    //self.camera.visibleWorldRect = targetRect;
    
//    CGPoint targetPos = ccp(900, 900);
//    CCActionInterval *action = [self.camera actionToMoveToPosition:targetPos duration:2];

    [self.camera runAction:action];
    
}

- (void)moveToBottomLeft
{
    CCLOG(@"move to bottomLeft");
    CGRect targetRect = CGRectMake(0, 0, 568, 320);
    CCActionInterval *action = [self.camera actionToMoveToRect:targetRect duration:2];
    //self.camera.visibleWorldRect = targetRect;

//    CGPoint targetPos = ccp(0, 0);
//    CCActionInterval *action = [self.camera actionToMoveToPosition:targetPos duration:2];

    [self.camera runAction:action];
}

@end
