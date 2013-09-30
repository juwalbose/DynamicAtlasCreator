/**
 * DynamicAtlasCreator v0.9
 *
 * Copyright 2013 Juwal Bose, Csharks Games. All rights reserved.
 *
 * Email: juwal@csharks.com
 * Blog: http://csharksgames.blogspot.com
 * Twitter: @juwalbose
 * 
 * This code is based on the Rectangle packing algorithm developed by Ville Koskela
 * More on this can be found at http://villekoskela.org/2012/08/12/rectangle-packing/
 *
 * You may redistribute, use and/or modify this source code freely
 * but this copyright statement must not be removed from the source files.
 *
 * The package structure of the source code must remain unchanged.
 * Mentioning the author in the binary distributions is highly appreciated.
 *
 * If you use this utility it would be nice to hear about it so feel free to drop
 * an email.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *
 *
 */

package com.csharks.juwalbose.utils
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;
	import org.villekoskela.utils.RectanglePacker;
	
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	/**
	 * Class helps create starling textures for any size based on a 2048 based texture atlas.
	 * The created textures are read from a single packed texture, there by enabling batching.
	 * Texture creation always maintains aspect ratio.
	 * @author juwalbose
	 * Dependencies: AS3 Signals, RectanglePacker
	 */
	public class DynamicAtlasCreator
	{
		private static var scaleRatio:Number=1;
		private static var gameAtlas:Dictionary=new Dictionary();
		private static const padding:int = 1;
		private static var mPacker:RectanglePacker;
		private static var sizeIterator:uint;
		private static var totalTextures:uint;
		private static var lookup:Dictionary=new Dictionary();
		private static var newSize:Point=new Point();
		
		private static var customAtlas:Texture;
		private static var assets:AssetManager;
		
		/**
		 * Enable for supporting 4096 textures, but not all devices support it
		 */
		private static var support4096Textures:Boolean=false;
		private static var maxAtlasSize:uint;
		
		/**
		 * This AS3 Signal is dispatched on completion of texture creation or failure. Add a listener to this.
		 */
		public static var creationComplete:Signal=new Signal();
		
		/**
		 * Starts the creation of the scaled textures, packs them into a single texture, creates textures out of it & 
		 * loads into a default starling AssetManager instance
		 * 
		 * @param sourceBitmapData : 2048 based texture atlas image
		 * @param atlasXml : 2048 based texture atlas xml
		 * @param scale : the ratio to scale to. cannot be above 1 (will be set to 1) eg, for 1024 based textures, scale will be 0.5
		 * @param assetManager : the Starling AssetManager instance onto which the created textures are stored
		 * 
		 * An AS3 signal, 'creationComplete' is dispatched when the conversion is complete.
		 */
		public static function createFrom(sourceBitmapData:BitmapData, atlasXml:XML, scale:Number, assetManager:AssetManager):void{
			gameAtlas=new Dictionary();
			lookup=new Dictionary();
			scaleRatio=scale;
			trace("creating dynamic scaled textures, scale:",scaleRatio);
			if(scaleRatio>1){
				scaleRatio=1;
			}
			assets=assetManager;
			totalTextures = atlasXml.SubTexture.length();   
			var name:String;  
			var x:int;  
			var y:int;  
			var width:int;  
			var height:int;  
			var frameX:int;
			var frameY:int;
			var frameWidth:int;
			var frameHeight:int;
			var bData:BitmapData;
			var pt:Point=new Point(0,0);
			var clipping:Rectangle=new Rectangle();
			
			for (var i:int = 0; i < totalTextures; i++) {  
				name = atlasXml.SubTexture[i].@name;  
				x = atlasXml.SubTexture[i].@x;  
				y = atlasXml.SubTexture[i].@y;  
				width = atlasXml.SubTexture[i].@width;  
				height = atlasXml.SubTexture[i].@height;  
				
				//create source rectangle for each individual texture  
				frameX=atlasXml.SubTexture[i].@frameX;
				frameY=atlasXml.SubTexture[i].@frameY;
				frameWidth=atlasXml.SubTexture[i].@frameWidth;
				frameHeight=atlasXml.SubTexture[i].@frameHeight;
				
				clipping = new Rectangle(x, y, width, height); 
				pt.x=pt.y=0;
				
				if(frameWidth!=0&&frameHeight!=0){
					bData=new BitmapData(frameWidth,frameHeight,true,0x000000);
					pt.x=-1*frameX;
					pt.y=-1*frameY;
				}else{
					bData=new BitmapData(clipping.width,clipping.height,true,0x000000);
				}
				bData.copyPixels(sourceBitmapData,clipping,pt);
				
				//add to dictionary  
				gameAtlas[name] =scaleBitmapData(bData);  
				
				bData.dispose();
				bData=null;
			} 
			/*
			System.disposeXML(atlasXml);
			atlasXml=null;
			sourceBitmapData.dispose();
			sourceBitmapData=null;
			*/
			if(support4096Textures){
				maxAtlasSize=9;
			}else{
				maxAtlasSize=7;
			}
			
			tryPacking();
		}
		
		
		private static function tryPacking():void{
			
			if (mPacker == null)
			{
				sizeIterator=1;
			}
			else
			{
				sizeIterator++;
			}
			newSize=findAtlasSize();
			mPacker=null;
			mPacker = new RectanglePacker(newSize.x, newSize.y, padding);
			trace("trying "+newSize);
			
			var rect:Rectangle;
			var rectIterator:uint=0;
			for(var j:String in gameAtlas){
				rect=(gameAtlas[j] as BitmapData).rect;
				mPacker.insertRectangle(rect.width, rect.height, rectIterator);
				lookup[rectIterator]=j;
				rectIterator++;
			}
			
			mPacker.packRectangles();
			
			trace(mPacker.rectangleCount," packed of ",totalTextures);
			if (mPacker.rectangleCount !=totalTextures)
			{
				if(sizeIterator<9){
					tryPacking();
				}else{
					trace("cannot pack into single 4096x4096 image");
					creationComplete.dispatch("failed");
				}
			}else{
				trace("packed into "+newSize.x+"x"+newSize.y);
				createAtlas();
			}
			
		}
		
		private static function createAtlas():void{
			var finalAtlas:BitmapData=new BitmapData(newSize.x,newSize.y,true,0x000000);
			
			var mat:Matrix=new Matrix();
			for (var j:int = 0; j < mPacker.rectangleCount; j++)
			{
				var rect:Rectangle = new Rectangle();
				rect = mPacker.getRectangle(j, rect).clone();
				var index:int = mPacker.getRectangleId(j);
				mat.tx=rect.x;
				mat.ty=rect.y;
				finalAtlas.draw(gameAtlas[lookup[index]],mat);
				(gameAtlas[lookup[index]] as BitmapData).dispose();
				gameAtlas[lookup[index]]=rect;
			}
			if(customAtlas){
				customAtlas.dispose();
			}
			customAtlas=Texture.fromBitmapData(finalAtlas,false);
			
			for (j = 0; j < totalTextures; j++)
			{
				
				assets.addTexture(lookup[j],Texture.fromTexture(customAtlas,gameAtlas[lookup[j]]));
			}
			
			finalAtlas.dispose();
			finalAtlas=null;
			
			for(var i:String in gameAtlas){
				gameAtlas[i]=null;
				lookup[i]=null;
			}
			gameAtlas=null;
			lookup=null;
			mPacker=null;
			
			System.pauseForGCIfCollectionImminent(0.8);
			System.gc();
			
			creationComplete.dispatch("success");
			
		}
		private static function findAtlasSize():Point{
			var tmp:Point=new Point();
			switch(sizeIterator){
				case 1:
					tmp.y=tmp.x=256;
					break;
				case 2:
					tmp.y=256
					tmp.x=512;
					break;
				case 3:
					tmp.y=tmp.x=512;
					break;
				case 4:
					tmp.y=512
					tmp.x=1024;
					break;
				case 5:
					tmp.y=tmp.x=1024;
					break;
				case 6:
					tmp.y=1024
					tmp.x=2048;
					break;
				case 7:
					tmp.y=tmp.x=2048;
					break;
				case 8:
					tmp.y=2048;
					tmp.x=4096;
					break;
				case 9:
					tmp.y=tmp.x=4096;
					break;
			}
			return tmp;
		}
		private static function scaleBitmapData(ARG_object:BitmapData):BitmapData {
			// create a BitmapData object the size of the crop
			//var bmpd:BitmapData = new BitmapData(ARG_object.width * ARG_scaleX, ARG_object.height * ARG_scaleY,true,0x000000);
			var bmpd:BitmapData = new BitmapData(ARG_object.width * scaleRatio, ARG_object.height * scaleRatio,true,0x000000);
			// create the matrix that will perform the scaling
			var scaleMatrix:Matrix = new Matrix();
			scaleMatrix.scale(scaleRatio, scaleRatio);
			// draw the object to the BitmapData, applying the matrix to scale
			bmpd.draw( ARG_object, scaleMatrix ,null,null,null,true);
			ARG_object.dispose();
			ARG_object=null;
			return bmpd;
		}
	}
}