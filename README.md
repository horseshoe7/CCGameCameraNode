CCGameCameraNode
================

An attempt at a way to pan around your game world, which also allows zooming.  For Cocos2D and SpriteBuilder 3.1

# Installation Instructions

* Download and install SpriteBuilder from the Mac App Store.
* Open the Project in SpriteBuilder and build / export it.
* Open it in Xcode

# What is this?

Sometimes you may have a game world that needs to do more than a CCFollowNode action can offer.  Why?  Because often you would like have zooming on your map.  This CCGameCameraNode attempts to be a sort of "view manager" for your game world.

# What can it currently do?

It loads a test scene and allows you to pan and pinch the screen to adjust the zoom.  For now, that's it.

# Future Work

* An API that allows you to programmatically interact with the camera
* Adding actions

# What problem this won't yet solve

Parallax. Seeing as positioning the camera involves adjusting the anchor point on the world node, this could present a problem with parallax nodes because we never explicitly change a position value of a node.  Will look into this.

Endless scrollers.  Not really in scope. Look somewhere else if that's what you're working on.

# Legal

Do whatever you want with it, just keep your lawyers away from me.  :D  I think that's called MIT.  I'm too busy being creative.
