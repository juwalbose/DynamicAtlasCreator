/**
 * 
 * Copyright 2013 Juwal Bose, Csharks Games. All rights reserved.
 *
 * Email: juwal@csharks.com
 * Blog: http://csharksgames.blogspot.com
 * Twitter: @juwalbose
 * 
 * You may redistribute, use and/or modify this source code freely
 * but this copyright statement must not be removed from the source files.
 * 
 * You may NOT use the art files provided along with this for any commercial purposes without 
 * written consent from Csharks Games & Solutions Pvt Ltd
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
**/
package com.csharks.topdownlevel
{
	import com.csharks.juwalbose.ResourceManager;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.RenderTexture;
	import starling.textures.TextureSmoothing;
	import starling.utils.AssetManager;
	
	public class MainLevel extends DisplayObjectContainer
	{
		//to centralise our level on screen
		private var borderOffsetOriginal:Point=new Point(124,168);// our level occuppies 1800 x 1200 which is 248 x 336 less than 2048 x 1536
		private var borderOffset:Point=new Point(0,0);
		//original art tile width for 2048 retina ipad
		private var tileWidth:uint=120;
		//level coulms, rows
		private var visibileTiles:Point=new Point(15,10);
		//our art is based for this screen size, ipad retina
		private var viewPortOriginal:Rectangle=new Rectangle(0,0,2048,1536);
		//the area our level covers on screen, visible tiles X tile width
		private var levelSpan:Rectangle=new Rectangle(0,0,1800,1200);
		//new scale after resizing
		private var newScale:Point=new Point(2048,1536);
		//level size conversion ratio, 1800 for 2048
		private var conversionRatio:Number=1800/2048;
		private var rTex:RenderTexture;
		private var rTexImage:Image;
		
		private var pt:Point=new Point();
		private var img:Image;
		private var mat:Matrix=new Matrix();
		
		//tile level data
		private var levelData:Array=
			[["14","21","21","21","21","21","21","13","21","21","21","21","21","21","17"],
				["18","12","7","2","2","8","2","3","2","5","2","2","7","13","20"],
				["18","3","3","2","2","2","2","2","2","2","2","2","3","2","20"],
				["18","3","3","2","2","2","9","2","2","2","3","2","3","3","20"],
				["18","5","2","2","5","2","2","2","4","2","2","2","2","5","20"],
				["10","2","2","2","2","3","2","2","2","2","2","2","7","2","12"],
				["18","2","8","2","2","2","2","3","2","5","2","2","2","5","20"],
				["18","2","2","2","4","2","2","2","2","2","4","2","2","2","20"],
				["18","11","2","3","2","2","2","3","2","2","2","2","2","10","20"],
				["15","19","19","19","19","19","19","13","19","19","19","19","19","19","16"]];
		//ref to AssetManager instance
		private var assetsManager:AssetManager;
		
		public function MainLevel()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			conversionRatio=levelSpan.width/viewPortOriginal.width;
			newScale.x=stage.stageWidth;
			newScale.y=stage.stageHeight;
			
			rTex=new RenderTexture(newScale.x,newScale.y);
			rTexImage= new Image(rTex);
			
			assetsManager=ResourceManager.assets;
			
		}
		private function paddedName(id:String):String{//returns zero padded name
			var offset:uint=10000;
			offset+=int(id);
			var str:String="tiles";
			str+=offset.toString().substr(1,4);
			return str;
		}
		private function createLevel():void{
			//add the render texture to screen
			rTex=new RenderTexture(newScale.x,newScale.y);
			rTexImage= new Image(rTex);
			rTexImage.blendMode=BlendMode.NONE;
			rTexImage.touchable=false;
			rTexImage.smoothing=TextureSmoothing.NONE;
			
			addChild(rTexImage);
			
			renderLevel();
		}
		
		private function renderLevel():void{
			//draw render texture with tiles as per level data
			rTex.clear();
			rTex.drawBundled(function():void
			{
				for(var i:int=0;i<levelData.length;i++){//i is for rows
					for(var j:int=0;j<levelData[0].length;j++){//j is for columns
						img=new Image(assetsManager.getTexture(paddedName(levelData[i][j])));
						img.x=(j*tileWidth)+borderOffset.x;//offset to centralise
						img.y=(i*tileWidth)+borderOffset.y;
						rTex.draw(img);
					}
				}
			
			});
			
		}
		public function rescaleAndRedraw(newWidth:Number,newHeight:Number):void{
			if(assetsManager){//remove old textures
				assetsManager.purge();
			}
			newScale.x=newWidth;
			newScale.y=newHeight;
			trace("scaling", newWidth,newHeight);
			
			//new tile size based on width
			tileWidth=0+((newWidth*conversionRatio)/visibileTiles.x);
			
			if(tileWidth*visibileTiles.y>newScale.y){
				//if new tile size makes items go out of screen in Y, then find based on height
				tileWidth=0+((newHeight*conversionRatio)/visibileTiles.y);
			}
			
			if(rTexImage){//clean up
				if(rTexImage.parent){
					removeChild(rTexImage);
				}
				
				rTexImage.dispose();
				rTexImage=null;
				rTex.clear();
				rTex.dispose();
				rTex=null;
				
				//new offsets
				borderOffset.x=(borderOffsetOriginal.x/viewPortOriginal.width)*newScale.x;
				borderOffset.y=(borderOffsetOriginal.y/viewPortOriginal.height)*newScale.y;
				
				trace("tw",tileWidth,borderOffset);
				
				//Initialise new Textures
				ResourceManager.initialise(tileWidth/120);
				
				addEventListener(Event.ENTER_FRAME,waitForReload);
			}
			
		}
		private function waitForReload(e:Event):void{//wait till resource manager is initialised
			if(ResourceManager.initialised){
				removeEventListener(Event.ENTER_FRAME,waitForReload);
				assetsManager=ResourceManager.assets;
				createLevel();
			}
		}
	}
}
