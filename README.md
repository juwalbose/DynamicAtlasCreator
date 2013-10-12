DynamicAtlasCreator
===================

Helps create Starling Texture Atlas dynamically from a single super atlas (2048, ipad retina screen width based)

With AIR we are able to deploy to many screen sizes but we will need art for many different resolutions to support as
many devices as possible. Here is a class which creates the needed art from a single super texture. Super texture
can be created for the highest resolution to be supported, at this point this can be iPad retina, 2048 x 1536. A
texture atlas for this resolution needs to be provided & the DynamicAtlasCreator will dynamically create the needed
scaled down textures at runtime. It scales down individual textures & packs them into a new TextureAtlas using Ville 
Koskela's Rectangle Packing algorithm.

https://github.com/villekoskelaorg/RectanglePacking

Other dependencies are Starling, AS3 Signals, TweenLite (can be removed by using Juggler instead)

Usage

DynamicAtlasCreator.creationComplete.add(creationComplete);//AS3 Signal will be dispatched 

DynamicAtlasCreator.createFrom(bitmapData,xml,scale,assets);

Where
bitmapData > the super texture atlas image BitmapData

xml > super atlas XML

scale > the ratio to scale down to. eg, for 1024 x 768 this can be 0.5

assets > default Starling AssetManager class which will be populated with new textures

The AIR version at https://github.com/juwalbose/DynamicAtlasCeatorAirDemo saves the created DynamicAtlas to 
ApplicationStorageDirectory for reuse after the first run. Web version ignores the texture 'frame' feature as we are
adding textures to the asset manager. AIR version supports texture frame as we are dealing with a tangible texture
atlas & not independent textures. Can be altered to support 'frame' if needed which will optimise the atlas.

Thank you Ville Koskela & Daniel Sperl for all the support.
