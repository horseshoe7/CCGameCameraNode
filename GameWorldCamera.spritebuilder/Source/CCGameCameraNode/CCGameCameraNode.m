//
//  CCGameCameraNode.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 01/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCGameCameraNode.h"

@interface CCGameCameraNode()
{
    CGSize _winSize;
    CGPoint _farCorner;  // fixed
    
    CGPoint _halfWindowSize;
    
    // user interaction
    CGPoint _lastLocation;
    float _lastScale;
    
    // State Variables
    CGPoint _camPos;
    float _zoomLevel;
    
    // Modifiers added independently of camPos or zoomLevel
    float _zoomVariance;
    CGPoint _positionVariance;
    
    // clamps
    float _minZoom, _maxZoom;
    
    // derived properties cache
    CGRect _viewBox;
}

@property (nonatomic, weak) CCNode *worldNode;

@end

@implementation CCGameCameraNode

- (instancetype)initWithGameboard:(CCNode*)gameboard
{
    self = [super init];
    if (self) {
        
        [self addChild:gameboard];
        gameboard.anchorPoint = CGPointZero;
        _camPos = ccp(0.5f * gameboard.contentSize.width, 0.5f * gameboard.contentSize.height);
        _worldNode = gameboard;
        
        _winSize = [CCDirector sharedDirector].view.bounds.size;
        _halfWindowSize = ccp(_winSize.width * 0.5f, _winSize.height * 0.5f);
        
        _farCorner = ccp(MAX(0, gameboard.contentSize.width),
                         MAX(0, gameboard.contentSize.height));
        
        
        _zoomLevel = 1.0;  // 100%, default value
        _zoomVariance = 0.0;
        _positionVariance = CGPointZero;
        _minZoom = MAX(_winSize.width/gameboard.contentSize.width, _winSize.height/gameboard.contentSize.height); //0.2345; // 320.0/1365.0  iPhone width/Board_Bar01 width.  Gets reset with setBounds.
        _maxZoom = 2.65;  // experimentally determined.
        _viewBox = CGRectZero; // 100% box.
        
        UIPinchGestureRecognizer *pinchzoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
        [[CCDirector sharedDirector].view addGestureRecognizer:pinchzoom];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}



#pragma mark - User Interaction Handlers

- (void)pinchZoom:(UIPinchGestureRecognizer*)pinch
{
    NSLog(@"Pinching!");
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        _lastScale = pinch.scale;
    }
    else if (pinch.state == UIGestureRecognizerStateChanged)
    {
        [self stopAllActions];
        
        
        CGFloat deltaZoom = [self deltaZoomForDeltaScale: pinch.scale - _lastScale];
        
        [self panZoomBy:deltaZoom];
        
        _lastScale = pinch.scale;
    }
}

- (CGFloat)deltaZoomForDeltaScale:(CGFloat)scaleDiff
{
    return 0.20 * scaleDiff;
}


- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    
    if (!self.isUserInteractionEnabled) {
        return;
    }
    _lastLocation = [touch locationInWorld];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    if (!self.isUserInteractionEnabled) {
        return;
    }
    
    CGPoint location = [touch locationInWorld];
    CGPoint difference = ccpSub(location, _lastLocation);
    
    [self panCameraInWorldBy:difference];
    
    _lastLocation = location;
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    if (!self.isUserInteractionEnabled) {
        return;
    }
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    if (!self.isUserInteractionEnabled) {
        return;
    }
}

#pragma Pan and Zoom via UI

- (void)panZoomBy:(CGFloat)deltaZoom
{
    _zoomLevel += deltaZoom;
    
    [self setZoom:_zoomLevel];
    
    [self clampPositionOrZoom];
}

- (void)panCameraInWorldBy:(CGPoint)deltaPos
{
    CGPoint diff = ccpMult(deltaPos, 1.0/_zoomLevel);  // deltaPos is in screen coords.  have to convert that to a board distance.
    
    CGPoint newPt = ccpSub(_camPos, diff);
    
    [self setCameraToBoardPos:newPt];  // doing it this way ensures the values are clamped appropriately.
}


#pragma mark step:/update: Methods

/* step or update methods in CCAction subclasses */
- (void)setCameraToBoardPos:(CGPoint)pos boundsTest:(BOOL)test;
{
    // Clamps the position from being able to view outside of the world.
    _camPos = pos;
    
    if(test){
        [self clampPositionOrZoom];   // basically you will always call this, unless you re-set the zoom and have already clamped.
    }
    
    [self recalculateViewBox];
    
}

- (void)setCameraToBoardPos:(CGPoint)pos
{
    [self setCameraToBoardPos:pos boundsTest: YES];
}

- (void)setZoom:(CGFloat)z
{
    // prevents from zooming out too much.  TODO - I assume I won't need a check in the y direction, but maybe?
    _zoomLevel = z; // _zoomVar is local variance.  Slight changes in camera zoom.
    [self clampPositionOrZoom];
    
    [self setCameraToBoardPos:_camPos boundsTest: NO];  // this should re-position the camera if zoomed out too far.  Will also re-calculate the viewBox.
}

#pragma mark - Update

- (void)update:(CCTime)time
{
    CCLOG(@"Move To Pos: (%.1f, %.1f) at zoom: %.3f", _camPos.x, _camPos.y, _zoomLevel);
    
    CGFloat scale = _zoomLevel;
    [self setScale:scale];
    
    self.worldNode.position = ccpNeg(_camPos);
}

#pragma mark - Helper Methods

// to be called any time a new position value is set.
- (void)clampPositionOrZoom
{
    _zoomLevel = _zoomLevel <= _minZoom ? _minZoom : _zoomLevel;  // prevents from zooming too far.
    
    // this works without zooming
    CGPoint bottomLeftEdge = ccpMult(_halfWindowSize, 1.f/_zoomLevel);
    CGPoint topRightEdge = ccpSub(_farCorner, ccpMult(_halfWindowSize, 1.f/_zoomLevel));
    
    if (topRightEdge.x < bottomLeftEdge.x) {
        topRightEdge.x = bottomLeftEdge.x;
    }
    if (topRightEdge.y < bottomLeftEdge.y) {
        topRightEdge.y = bottomLeftEdge.y;
    }
    
    _camPos = ccpClamp(_camPos, bottomLeftEdge, topRightEdge);
}

- (void)recalculateViewBox
{
    _viewBox.size.width = _winSize.width/_zoomLevel;
    _viewBox.size.height = _winSize.height/_zoomLevel;
    _viewBox.origin.x = _camPos.x - _viewBox.size.width/2;
    _viewBox.origin.y = _camPos.y - _viewBox.size.height/2;
}


@end
