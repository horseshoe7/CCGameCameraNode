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
    _camera = [[CCGameCameraNode alloc] initWithWorld:_gameWorld];  // gameWorld gets added to the camera node
    _camera.position = ccp(0.5f * winsize.width , 0.5f * winsize.height);
    
    [_worldContainer addChild:_camera];
    
    self.camera.positionInWorldCoords = CGPointZero;
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // implemented like this because you may want to have conditions where a touch should not pan the camera, like if you are using your finger to grab an object in your world.
    [self.camera touchBegan:touch withEvent:event];
}
- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self.camera touchMoved:touch withEvent:event];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self.camera touchEnded:touch withEvent:event];
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self.camera touchCancelled:touch withEvent:event];
}

#pragma mark - Actions

- (void)moveToTopRight
{
    CCLOG(@"move to topRight");
    
    CGRect targetRect = CGRectMake(900, 900, 100, 150);
    
    BOOL animated = YES;
    
    if (animated)
    {
        CCActionInterval *action = [self.camera actionToMoveToRect:targetRect duration:2 completion:nil];

        // add easing to the action
        CCAction *ease = [CCActionEaseSineInOut actionWithAction:action];
        [self.camera runAction:ease];

    }
    else
    {
        self.camera.visibleWorldRect = targetRect;  // set instantly instead
    }
}

- (void)moveToBottomLeft
{
    CCLOG(@"move to bottomLeft");
    
    CGRect targetRect = CGRectMake(0, 0, 568, 320);
    
    BOOL animated = YES;
    
    if (animated)
    {
        CCActionInterval *action = [self.camera actionToMoveToRect:targetRect duration:2 completion:nil];
        
        // add easing to the action
        CCAction *ease = [CCActionEaseSineInOut actionWithAction:action];
        [self.camera runAction:ease];
        
    }
    else
    {
        self.camera.visibleWorldRect = targetRect;  // set instantly instead
    }
}

@end
