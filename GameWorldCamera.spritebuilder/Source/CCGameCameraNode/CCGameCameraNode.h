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

#pragma mark - Properties
/**
 @abstract the current zoomScale of the camera.
 */
@property (nonatomic, assign) float zoomScale;

/**
 @abstract The Maximum the camera is allowed to move in.  Default is 2.65.
 */
@property (nonatomic, assign) float maxZoom;

/**
 @abstract The maximum the camera can zoom out and not expose any part outside of your `world` used to initialize this object.  Or, the furthest that the camera can zoom out and keep the world visible and nothing outside of the world.
 */
@property (nonatomic, readonly) float minZoom;

/**
 @abstract Where the camera is looking with respect to the screen.  (Explain this better.)  It basically takes positionInWorldCoords and converts it to the parent's coord space.
 */

@property (nonatomic, readonly) CGPoint positionInScreenCoords;

/**
 @abstract The position of your `world` (when initializing this node) that the camera should focus on.
 */
@property (nonatomic, assign) CGPoint positionInWorldCoords;

/**
 @abstract The part of the world which is currently visible.  In world coordinates.  Will change `positionInWorldCoords` and `zoomScale`.
 */
@property (nonatomic, assign) CGRect visibleWorldRect;

/**
 @abstract The class name that will be used by default when generating the movement action methods of this class.  Should be a subclass of `CCActionEase`.  Defaults to nil (i.e. linear camera movements)
 */
@property (nonatomic, strong) NSString *defaultEasingClassName;

@property (nonatomic, weak, readonly) CCNode *worldNode;
          

#pragma mark - Initialization Method

/**
 @abstract The required init... Method of this class.  You provide a "world node" that has a `contentSize` set.  TODO:  Add caveats here, such as physics pitfalls, and where the position of the node should be, etc.
 @param world The CCNode Object with `contentSize` set which defines the world boundaries.
 @return a new CCGameCameraNode object.
 */
- (instancetype)initWithWorld:(CCNode*)world;



#pragma mark - Actions

/**
 @abstract A factory method to create a camera movement action where you can move to a specific coordinate in your world coordinates (i.e. if you were at a zoomScale of 1), at the current zoom level over the given duration.  It will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param point a location in world coordinates you want to move to.
 @param duration the time this movement should take.
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */
- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                   duration:(CCTime)duration
                                 completion:(void(^)(CCGameCameraNode *camera))completion;


/**
 @abstract A factory method to create a camera movement action where you can move to a specific coordinate in your world coordinates (i.e. if you were at a zoomScale of 1), at the current zoom level over the given duration.  If you do not provide an argument for easingClass, it will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param point a location in world coordinates you want to move to.
 @param duration the time this movement should take.
 @param easingClass a Class object that will be used to perform the easing action.  Must be a subclass of CCActionEase
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */


- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                   duration:(CCTime)duration
                                     easing:(Class)easingClass
                                 completion:(void(^)(CCGameCameraNode *camera))completion;


/**
 @abstract A factory method to create a camera movement action where you can move to a specific zoom levelat the current world position over the given duration.  The world position will change if required to keep the camera inside the boundaries.  It will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param zoom the target zoom level to move to.  It will be clamped between maxZoom and minZoom
 @param duration the time this movement should take.
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */

- (CCActionInterval*)actionToMoveToZoom:(float)zoom
                               duration:(CCTime)duration
                             completion:(void(^)(CCGameCameraNode *camera))completion;


/**
 @abstract A factory method to create a camera movement action where you can move to a specific zoom levelat the current world position over the given duration.  The world position will change if required to keep the camera inside the boundaries.  If you do not provide an argument for easingClass, it will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param zoom the target zoom level to move to.  It will be clamped between maxZoom and minZoom
 @param duration the time this movement should take.
 @param easingClass a Class object that will be used to perform the easing action.  Must be a subclass of CCActionEase
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */
- (CCActionInterval*)actionToMoveToZoom:(float)zoom
                               duration:(CCTime)duration
                                 easing:(Class)easingClass
                             completion:(void(^)(CCGameCameraNode *camera))completion;


/**
 @abstract A factory method to create a camera movement action where you can move to a specific zoom level and board position (i.e. in world coordinates, i.e. unaffected by zoom) over the given duration.  The world position will change if required to keep the camera inside the boundaries.  It will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param point a location in world coordinates you want to move to.
 @param zoom the target zoom level to move to.  It will be clamped between maxZoom and minZoom
 @param duration the time this movement should take.
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */

- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                       zoom:(float)zoom
                                   duration:(CCTime)duration
                                 completion:(void(^)(CCGameCameraNode *camera))completion;

/**
 @abstract A factory method to create a camera movement action where you can move to a specific zoom level and board position (i.e. in world coordinates, i.e. unaffected by zoom) over the given duration.  The world position will change if required to keep the camera inside the boundaries.  If you do not provide an argument for easingClass (i.e. Nil), it will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param point a location in world coordinates you want to move to.
 @param zoom the target zoom level to move to.  It will be clamped between maxZoom and minZoom
 @param duration the time this movement should take.
 @param easingClass a Class object that will be used to perform the easing action.  Must be a subclass of CCActionEase
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */
- (CCActionInterval*)actionToMoveToPosition:(CGPoint)point
                                       zoom:(float)zoom
                                   duration:(CCTime)duration
                                     easing:(Class)easingClass
                                 completion:(void(^)(CCGameCameraNode *camera))completion;


/**
 @abstract A factory method to create a camera movement action where you can move to a area of your world over the given duration.  The rectangle will be modified if required to keep the camera inside the boundaries.  It will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param rect an area of the world you want to move to.  Think of it as the target `visibleWorldRect`
 @param duration the time this movement should take.
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */
- (CCActionInterval*)actionToMoveToRect:(CGRect)rect
                               duration:(CCTime)duration
                             completion:(void(^)(CCGameCameraNode *camera))completion;

/**
 @abstract A factory method to create a camera movement action where you can move to a area of your world over the given duration.  The rectangle will be modified if required to keep the camera inside the boundaries.  If you do not provide an argument for easingClass (i.e. Nil), it will use the default CCActionEase class you've configured for the class.  You can provide a completion block to be notified when the move action has completed.
 @param rect an area of the world you want to move to.  Think of it as the target `visibleWorldRect`
 @param duration the time this movement should take.
 @param easingClass a Class object that will be used to perform the easing action.  Must be a subclass of CCActionEase
 @param completion any code you may want executed upon completion of the movement.
 @return A CCActionIntervalInstance you should run on the CCGameCameraNode object.
 */
- (CCActionInterval*)actionToMoveToRect:(CGRect)rect
                               duration:(CCTime)duration
                                 easing:(Class)easingClass
                             completion:(void(^)(CCGameCameraNode *camera))completion;



@end
