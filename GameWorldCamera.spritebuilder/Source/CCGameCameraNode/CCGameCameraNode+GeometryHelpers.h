//
//  CCGameCameraNode+GeometryHelpers.h
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCGameCameraNode.h"

@interface CCGameCameraNode (GeometryHelpers)

- (CGRect)boundsForFitObjects:(NSArray*)objects;
- (CGRect)boundsForFitObjects:(NSArray*)objects padding:(UIEdgeInsets)padding screenCoords:(BOOL)screen;
- (CGPoint)centerOfRect:(CGRect)bounds;  // useful for setting camera position based on a rectangle.
- (float)zoomForRect:(CGRect)rect;  // given a rectangle argument, what zoomlevel would it have
- (float)zoomForHeight:(CGFloat)h;
- (float)zoomForWidth:(CGFloat)w;

@end
