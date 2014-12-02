//
//  CCGameCameraNode.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 01/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCGameCameraNode.h"
#import "CCGameCameraNode+GeometryHelpers.h"
#import "CCActionTweenPoint.h"
#import "CCActionTweenRect.h"

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
    float _zoomScale;
    
    // Modifiers added independently of camPos or zoomLevel.  Not used currently, but can be used to add 'drunk cameraman'
    float _zoomVariance;
    CGPoint _positionVariance;
    
    // clamps
    float _minZoom, _maxZoom;
    
    // derived properties cache
    CGRect _viewBox;
    
    
}

@property (nonatomic, weak, readwrite) CCNode *worldNode;
@property (nonatomic, assign) BOOL parallaxMode;  // yes if your world contains parallax, NO if you want to (one day) allow rotate

@end

@implementation CCGameCameraNode

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - pos:%@\t worldRect:%@",
            [super description],
            NSStringFromCGPoint(self.positionInWorldCoords),
            NSStringFromCGRect(self.visibleWorldRect)];
                                                                      
}

- (instancetype)initWithWorld:(CCNode*)gameboard
{
    self = [super init];
    if (self) {
        
        self.name = @"Camera";
        
        [self addChild:gameboard];
        gameboard.anchorPoint = CGPointZero;
        _camPos = ccp(0.5f * gameboard.contentSize.width, 0.5f * gameboard.contentSize.height);
        _worldNode = gameboard;
        
        _winSize = [CCDirector sharedDirector].view.bounds.size;
        _halfWindowSize = ccp(_winSize.width * 0.5f, _winSize.height * 0.5f);
        
        _farCorner = ccp(MAX(0, gameboard.contentSize.width),
                         MAX(0, gameboard.contentSize.height));
        
        
        _zoomScale = 1.0;  // 100%, default value
        _zoomVariance = 0.0;
        _positionVariance = CGPointZero;
        _minZoom = MAX(_winSize.width/gameboard.contentSize.width, _winSize.height/gameboard.contentSize.height);
        _maxZoom = 2.65;
        _viewBox = CGRectZero; // 100% box.
        
        self.parallaxMode = YES;
        
        
        UIPinchGestureRecognizer *pinchzoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
        [[CCDirector sharedDirector].view addGestureRecognizer:pinchzoom];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - Accessors

- (void)setMaxZoom:(float)maxZoom
{
    if (maxZoom != _maxZoom) {
        [self willChangeValueForKey:@"maxZoom"];
        _maxZoom = MAX(maxZoom, _minZoom);
        [self didChangeValueForKey:@"maxZoom"];
    }
}

- (void)setParallaxMode:(BOOL)parallax
{
    if (parallax != _parallaxMode) {
        _parallaxMode = parallax;
        
        if (parallax) {
            self.worldNode.anchorPoint = CGPointZero;
        }
        else
        {
            self.worldNode.position = CGPointZero;
        }
    }
}

- (CGPoint)positionInScreenCoords
{
    return [self.worldNode convertToWorldSpace:_camPos];
}

- (CGPoint)positionInWorldCoords
{
    return _camPos;
}

- (void)setPositionInWorldCoords:(CGPoint)positionInWorldCoords
{
    // Clamps the position from being able to view outside of the world.
    [self setPosition:positionInWorldCoords andZoom:_zoomScale];
}

- (float)zoomScale
{
    return _zoomScale;
}

- (void)setZoomScale:(float)z
{
    [self setPosition:_camPos andZoom:z];
}

- (CGRect)visibleWorldRect
{
    return _viewBox;
}

- (void)setVisibleWorldRect:(CGRect)visibleWorldRect
{
    float targetZoom = [self _zoomForRect:visibleWorldRect];
    CGPoint targetPos;
    targetPos.x = CGRectGetMidX(visibleWorldRect);
    targetPos.y = CGRectGetMidY(visibleWorldRect);
    
    [self setPosition:targetPos andZoom:targetZoom];  // will clamp and recalculate as necessary
}

#pragma mark - Helper Methods

- (void)clampPosition:(CGPoint*)positionPtr andZoom:(float*)zoomPtr
{
    if (positionPtr == NULL || zoomPtr == NULL) {
        return;
    }
    
    CGPoint position = *positionPtr;
    float zoom = *zoomPtr;
    
    float newZoom = MAX(zoom, _minZoom);  // prevents from zooming too far.
    *zoomPtr = newZoom;
    
    CGPoint bottomLeftEdge = ccpMult(_halfWindowSize, 1.f/newZoom);
    CGPoint topRightEdge = ccpSub(_farCorner, ccpMult(_halfWindowSize, 1.f/newZoom));
    
    if (topRightEdge.x < bottomLeftEdge.x) {
        topRightEdge.x = bottomLeftEdge.x;
    }
    if (topRightEdge.y < bottomLeftEdge.y) {
        topRightEdge.y = bottomLeftEdge.y;
    }
    
    CGPoint newPos = ccpClamp(position, bottomLeftEdge, topRightEdge);
    *positionPtr = newPos;
}

// to be called any time a new position value is set.
- (void)setPosition:(CGPoint)position andZoom:(float)zoom
{
    BOOL recalculateViewBox = NO;
    
    CGPoint newPos = position;
    float newZoom = zoom;
    
    [self clampPosition:&newPos andZoom:&newZoom];
    
    if (newZoom != _zoomScale) {
        [self willChangeValueForKey:@"zoomScale"];
        _zoomScale = newZoom;
        recalculateViewBox = YES;
        [self didChangeValueForKey:@"zoomScale"];
    }
    
    if (CGPointEqualToPoint(_camPos, newPos) == NO) {
        [self willChangeValueForKey:@"positionInWorldCoords"];
        _camPos = newPos;
        recalculateViewBox = YES;
        [self didChangeValueForKey:@"positionInWorldCoords"];
    }
    
    if (recalculateViewBox) {
        [self recalculateViewBox];
    }
}

- (void)recalculateViewBox
{
    [self willChangeValueForKey:@"visibleWorldRect"];
    _viewBox.size.width = _winSize.width/_zoomScale;
    _viewBox.size.height = _winSize.height/_zoomScale;
    _viewBox.origin.x = _camPos.x - _viewBox.size.width/2;
    _viewBox.origin.y = _camPos.y - _viewBox.size.height/2;
    [self didChangeValueForKey:@"visibleWorldRect"];
}

- (float)_zoomForRect:(CGRect)rect
{
    CGFloat newZoom;
    
    CGFloat winSizeAR = _winSize.width / _winSize.height;
    CGFloat rectAR = rect.size.width / rect.size.height;
    
    // we know that screen coords correspond to camera zoom = 100%, that's why the math below should work.
    if(rectAR > winSizeAR){
        // then have to fit width
        newZoom = _winSize.width/rect.size.width;
    }
    else{
        // fit height
        newZoom = _winSize.height/rect.size.height;
    }
    
    return newZoom;
}


#pragma mark - User Interaction Handlers

- (void)pinchZoom:(UIPinchGestureRecognizer*)pinch
{
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


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    
    if (!self.isUserInteractionEnabled) {
        return;
    }
    _lastLocation = [touch locationInWorld];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
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

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    if (!self.isUserInteractionEnabled) {
        return;
    }
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (event.allTouches.count > 1) {
        return;  // probably a pinch gesture, handled elsewhere!
    }
    if (!self.isUserInteractionEnabled) {
        return;
    }
}

#pragma mark - Pan and Zoom via UI

- (void)panZoomBy:(CGFloat)deltaZoom
{
    [self setZoomScale: self.zoomScale + deltaZoom];
}

- (void)panCameraInWorldBy:(CGPoint)deltaPos
{
    CGPoint diff = ccpMult(deltaPos, 1.0/_zoomScale);  // deltaPos is in screen coords.  have to convert that to a board distance.
    
    CGPoint newPt = ccpSub(_camPos, diff);
    
    [self setPositionInWorldCoords:newPt]; 
}


#pragma mark - Update

- (void)update:(CCTime)time
{
    //CCLOG(@"Move To Pos: (%.1f, %.1f) at zoom: %.3f", _camPos.x, _camPos.y, _zoomScale);
    
    CGFloat scale = _zoomScale;
    [self setScale:scale];
    
    if (_parallaxMode)
    {
        self.worldNode.position = ccpNeg(_camPos);
    }
    else
    {
        self.worldNode.anchorPoint = ccp(_camPos.x / _farCorner.x, _camPos.y / _farCorner.y);
    }
    
}

#pragma mark -
#pragma mark - Actions

- (void)stopAllUnwantedActions
{
    [self stopAllActions];
}

#pragma mark - Helper Methods

- (CCActionInterval*)easedActionUsingClass:(Class)easingClass action:(CCActionInterval*)action
{
    if (easingClass != Nil) {
        NSAssert([easingClass isSubclassOfClass:[CCActionEase class]], @"You can only ease with known subclasses of CCActionEase");
        
        return [easingClass actionWithAction:action];
    }

    if (!self.defaultEasingClassName) {
        return action;
    }
    
    Class defaultEasingClass = NSClassFromString(self.defaultEasingClassName);
    NSAssert([defaultEasingClass isSubclassOfClass:[CCActionEase class]], @"You can only ease with known subclasses of CCActionEase");
    
    return [defaultEasingClass actionWithAction:action];
        
}

- (CCActionInterval*)addCallbackIfNecessaryWithAction:(CCActionInterval*)easedAction
                                           completion:(void(^)(CCGameCameraNode *camera))completion
{
    if (!completion) {
        return easedAction;
    }
    __weak CCGameCameraNode *weakself = self;
    CCActionCallBlock *callback = [CCActionCallBlock actionWithBlock:^{
        completion(weakself);
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionOne:easedAction two:callback];
    
    return sequence;
}

#pragma mark - Action Factory Methods

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point duration:(CCTime)duration
{
    return [self actionToMoveToPosition:point duration:duration completion:nil];
}

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                   duration:(CCTime)duration
                                 completion:(void(^)(CCGameCameraNode *camera))completion
{
    return [self actionToMoveToPosition:point duration:duration easing:Nil completion:completion];
}

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                   duration:(CCTime)duration
                                     easing:(__unsafe_unretained Class)easingClass
                                 completion:(void(^)(CCGameCameraNode *camera))completion
{
    CGPoint newPos = point;
    float newZoom = self.zoomScale;
    
    [self clampPosition:&newPos andZoom:&newZoom];
    
    CCActionTweenPoint *movePosition = [CCActionTweenPoint actionWithDuration:duration
                                                                          key:@"positionInWorldCoords"
                                                                    fromPoint:self.positionInWorldCoords
                                                                      toPoint:newPos];
    
    CCActionInterval *easedAction = [self easedActionUsingClass:easingClass action:movePosition];
    
    return [self addCallbackIfNecessaryWithAction:easedAction completion:completion];
}

- (CCActionInterval*)actionToMoveToZoom:(float)zoom duration:(CCTime)duration
{
    return [self actionToMoveToZoom:zoom duration:duration completion:nil];
}

- (CCActionInterval*)actionToMoveToZoom:(float)zoom
                               duration:(CCTime)duration
                             completion:(void(^)(CCGameCameraNode *camera))completion
{
    return [self actionToMoveToZoom:zoom duration:duration easing:Nil completion:completion];
}

- (CCActionInterval*)actionToMoveToZoom:(float)zoom
                               duration:(CCTime)duration
                                 easing:(__unsafe_unretained Class)easingClass
                             completion:(void(^)(CCGameCameraNode *camera))completion
{
    CCActionTween *moveZoom = [CCActionTween actionWithDuration:duration
                                                            key:@"zoomScale"
                                                           from:self.zoomScale
                                                             to:zoom];
    
    CCActionInterval *easedAction = [self easedActionUsingClass:easingClass action:moveZoom];
    
    return [self addCallbackIfNecessaryWithAction:easedAction completion:completion];
}

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                       zoom:(float)zoom
                                   duration:(CCTime)duration
{
    return [self actionToMoveToPosition:point zoom:zoom duration:duration completion:nil];
}

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                       zoom:(float)zoom
                                   duration:(CCTime)duration
                                 completion:(void (^)(CCGameCameraNode *))completion
{
    return [self actionToMoveToPosition:point zoom:zoom duration:duration easing:Nil completion:completion];
}

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                       zoom:(float)zoom
                                   duration:(CCTime)duration
                                     easing:(__unsafe_unretained Class)easingClass
                                 completion:(void (^)(CCGameCameraNode *))completion
{
    // figure out what rect would be
    CGPoint newPos = point;
    float newZoom = zoom;
    
    [self clampPosition:&newPos andZoom:&newZoom];
    
    CGRect targetRect;
    targetRect.size.width = _winSize.width/newZoom;
    targetRect.size.height = _winSize.height/newZoom;
    targetRect.origin.x = newPos.x - targetRect.size.width/2;
    targetRect.origin.y = newPos.y - targetRect.size.height/2;
    
    CCActionTweenRect *moveRect = [CCActionTweenRect actionWithDuration:duration
                                                                    key:@"visibleWorldRect"
                                                               fromRect:self.visibleWorldRect
                                                                 toRect:targetRect];
    
    CCActionInterval *easedAction = [self easedActionUsingClass:easingClass action:moveRect];
    
    return [self addCallbackIfNecessaryWithAction:easedAction completion:completion];
}

- (CCActionInterval*)actionToMoveToRect:(CGRect)targetRect duration:(CCTime)duration
{
    return [self actionToMoveToRect:targetRect duration:duration completion:nil];
}

- (CCActionInterval*)actionToMoveToRect:(CGRect)targetRect
                               duration:(CCTime)duration
                             completion:(void (^)(CCGameCameraNode *))completion
{
    return [self actionToMoveToRect:targetRect duration:duration easing:Nil completion:completion];
}

- (CCActionInterval*)actionToMoveToRect:(CGRect)targetRect
                               duration:(CCTime)duration
                                 easing:(__unsafe_unretained Class)easingClass
                             completion:(void (^)(CCGameCameraNode *))completion
{
    CGPoint newPos = [self centerOfRect:targetRect];
    float newZoom = [self zoomForRect:targetRect];
    
    [self clampPosition:&newPos andZoom:&newZoom];
    
    targetRect.size.width = _winSize.width/newZoom;
    targetRect.size.height = _winSize.height/newZoom;
    targetRect.origin.x = newPos.x - targetRect.size.width/2;
    targetRect.origin.y = newPos.y - targetRect.size.height/2;
    
    CCActionTweenRect *moveRect = [CCActionTweenRect actionWithDuration:duration
                                                                    key:@"visibleWorldRect"
                                                               fromRect:self.visibleWorldRect
                                                                 toRect:targetRect];

    CCActionInterval *easedAction = [self easedActionUsingClass:easingClass action:moveRect];
    
    return [self addCallbackIfNecessaryWithAction:easedAction completion:completion];
}


@end
