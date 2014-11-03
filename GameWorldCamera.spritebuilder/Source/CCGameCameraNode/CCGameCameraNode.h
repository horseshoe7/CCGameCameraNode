//
//  CCGameCameraNode.h
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 01/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

/* 
 
 Basically there are two ways to use this node:
 
i) You can set its contentSize to CGSizeZero, and it's position to be at the center of your scene
    - then you can decide when it should receive its touch handling events (i.e so it won't interfere with other touch events on your scene)
 
ii) allow its contentSize to match your [CCDirector sharedDirector].viewSize 
    - then set anchorPoint to 0.5, 0.5, and position to be at the center of your scene
    - then it will use its own touch handlers
 
 Add a gameboard:
 
 - You initialize the camera with a gameboard (gameworld).  These represent the entire world coordinates of our scene.  This gameboard becomes a child of your camera, and gets added as a child node.  You no longer play with the position coordinate of your gameboard node, but rather tell the camera where you would like to view on the board
 

 */

#import "CCNode.h"

@interface CCGameCameraNode : CCNode

@property (nonatomic, assign) float zoomScale;
@property (nonatomic, assign) float maxZoom; // default is 2.65
@property (nonatomic, readonly) float minZoom;  // the furthest out it can go, so that world is visible

@property (nonatomic, readonly) CGPoint positionInScreenCoords;

@property (nonatomic, assign) CGPoint positionInWorldCoords;
@property (nonatomic, assign) CGRect visibleWorldRect;  // the part of the world node which is currently visible

- (instancetype)initWithWorld:(CCNode*)world;

#pragma mark - Actions

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point duration:(CCTime)duration;
- (CCActionInterval*)actionToMoveToZoom:(float)zoom duration:(CCTime)duration;
- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point zoom:(float)zoom duration:(CCTime)duration;
- (CCActionInterval*)actionToMoveToRect:(CGRect)rect duration:(CCTime)duration;

@end
