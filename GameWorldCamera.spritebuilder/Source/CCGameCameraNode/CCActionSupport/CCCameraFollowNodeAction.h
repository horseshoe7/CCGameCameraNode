//
//  CCCameraFollowNodeAction.h
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCAction.h"

/**
 *  Creates an action which follows a node.
 *
 *  Note:
 *  You add this action to a CCGameCameraNode object, and the node to be followed should
 *  have its position value in the coordinate space of the node you used as the world
 *  when instantiating the CCGameCameraNode
 *
 *
 *  Example:
 *  [self.camera runAction: [CCCameraFollowNodeAction actionWithTarget:hero]];
 */
@interface CCCameraFollowNodeAction : CCAction <NSCopying> {
    
    // Node to follow.  Should be a child of the world you are using for the camera
    CCNode	*_followedNode;
}

/// -----------------------------------------------------------------------
/// @name Creating a CCActionFollow Object
/// -----------------------------------------------------------------------

/**
 *  Creates a follow action with no boundaries.
 *
 *  @param followedNode Node to follow.
 *
 *  @return The follow action object.
 */
+ (id)actionWithTarget:(CCNode *)followedNode;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionFollow Object
/// -----------------------------------------------------------------------

/**
 *  Initalizes a follow action with no boundaries.
 *
 *  @param followedNode Node to follow.
 *
 *  @return An initialized follow action object.
 */
- (id)initWithTarget:(CCNode *)followedNode;

@end
