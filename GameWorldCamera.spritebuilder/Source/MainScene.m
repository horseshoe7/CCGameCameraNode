//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Stephen O'Connor. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play
{
    CCLOG(@"Play Button Pressed");
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end
