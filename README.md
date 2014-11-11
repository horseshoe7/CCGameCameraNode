CCGameCameraNode
================

An attempt at a way to pan around your game world, which also allows zooming.  For Cocos2D and SpriteBuilder 3.1

# Installation Instructions

* Download and install SpriteBuilder from the Mac App Store.
* Open the Project in SpriteBuilder and build / export it.
* Open it in Xcode

# What is this?

Sometimes you may have a game world that needs to do more than a CCFollowNode action can offer.  Why?  Because often you would like have zooming on your map.  This CCGameCameraNode attempts to be a sort of "view manager" for your game world.

# What Does the Project Currently Do?

It loads a test scene and allows you to pan and pinch the screen to adjust the zoom.  There are two buttons to show off the camera animation feature of the camera.  T-R for top right, B-L for bottom left.  Have a look at these action handlers for an example of how to best use it.

# Features

* Adjust camera position and zoom.  Convenience method allows you to zoom to a specific rectangle on your board
* Use CCActions on the camera.

# Notes

If you are using a CCPhysicsNode in your scene, make sure it is a child of the node you provide to the camera, otherwise asserts will fire when you try to zoom with the camera.

# Future Work

* Allow for rotation

# Known Issues

* I'm still familiarizing myself with Cocos2D and contentSizeType and so on.  This worked fine on iPhone, but I had troubles with world boundaries for some reason on iPad.  If someone knows the answer given this project, please let me know!!

# What this isn't for

Endless scrollers.  Not really in scope. Look somewhere else if that's what you're working on.

# Legal

Do whatever you want with it, just keep your lawyers away from me.  :D  I think that's called MIT.  I'm too busy being creative.
