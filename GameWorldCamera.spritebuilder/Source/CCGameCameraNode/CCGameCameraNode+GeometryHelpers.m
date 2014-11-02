//
//  CCGameCameraNode+GeometryHelpers.m
//  GameWorldCamera
//
//  Created by Stephen O'Connor on 02/11/14.
//  Copyright (c) 2014 Stephen O'Connor. All rights reserved.
//

#import "CCGameCameraNode+GeometryHelpers.h"

@interface CCGameCameraNode(Private)
- (float)_zoomForRect:(CGRect)rect;
@end


@implementation CCGameCameraNode (GeometryHelpers)

- (CGRect)boundsForFitObjects:(NSArray*)objects
{
    CGFloat highX, lowX, highY, lowY;
    int i = 0;
    
    // determine the bounding box of the objects
    for(CCNode *o in objects)
    {
        //NSLog(@"trackingObject is of type: %@", [o class]);
        // IF CCSprite
        CGRect bb = [o boundingBox];
        //NSLog(@"DISC POS X: %f \t Y: %f \t Width: %f \t Height: %f", bb.origin.x, bb.origin.y, bb.size.width, bb.size.height);
        if (i==0)
        {
            lowX = bb.origin.x;
            highX = lowX + bb.size.width;
            lowY = bb.origin.y;
            highY = lowY + bb.size.height;
        }
        else
        {
            lowX = bb.origin.x < lowX ? bb.origin.x : lowX;
            lowY = bb.origin.y < lowY ? bb.origin.y : lowY;
            highX = (bb.origin.x + bb.size.width) > highX ? (bb.origin.x + bb.size.width) : highX;
            highY = (bb.origin.y + bb.size.height) > highY ? (bb.origin.y + bb.size.height) : highY;
        }
        
        i+=1;
    }
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}

- (CGRect)boundsForFitObjects:(NSArray*)objects padding:(UIEdgeInsets)padding screenCoords:(BOOL)screen
{
    CGRect newBounds = [self boundsForFitObjects:objects]; // returns with origin at bottom left corner
    
    CGFloat factor = screen ? self.zoomScale : 1.0;  // factor involved in calculating the padding.
    
    newBounds.origin.x -= padding.left/factor;
    newBounds.origin.y -= padding.bottom/factor;
    newBounds.size.height += (padding.bottom + padding.top)/factor;
    newBounds.size.width += (padding.left + padding.right)/factor;
    
    return newBounds;
}


- (CGPoint)centerOfRect:(CGRect)bounds
{
    CGPoint pt;
    pt.x = CGRectGetMidX(bounds);
    pt.y = CGRectGetMidY(bounds);
    return pt;
}

- (float)zoomForRect:(CGRect)rect
{
    return [self _zoomForRect:rect];
}

- (float)zoomForHeight:(CGFloat)h
{
    return [CCDirector sharedDirector].viewSize.height/h;
}

- (float)zoomForWidth:(CGFloat)w
{
    return [CCDirector sharedDirector].viewSize.width/w;
}


@end
