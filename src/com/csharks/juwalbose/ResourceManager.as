/**
 *
 * Copyright 2013 Juwal Bose, Csharks Games. All rights reserved.
 *
 * Email: juwal@csharks.com
 * Blog: http://csharksgames.blogspot.com
 * Twitter: @juwalbose
 
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
package com.csharks.juwalbose
{
	import com.csharks.juwalbose.utils.DynamicAtlasCreator;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import starling.utils.AssetManager;
	
	public class ResourceManager
	{
		public static var  assets:AssetManager=new AssetManager();
		public static var initialised:Boolean=false;
		private static var loader:Loader;
		
		//XML can also be loaded dynamically, but not much savings that way
		[Embed(source = "../../../../assets/assets.xml", mimeType = "application/octet-stream")]
		private static const XhdpiXml:Class;
		private static var data:XML;
		private static var XhdpiPng:Bitmap;
		public static var scaleRatio:Number=1;
		
		public static function initialise(_scaleRatio:Number):void{
			//scale ratio = new art size / original art size
		
			initialised=false;
			scaleRatio=_scaleRatio;
			//loading is much more efficient than embedding in terms of memory usage
			loadImage("media/assets.png");
		}
		
		private static function loadImage(fileName:String):void
		{
			loader = new Loader();
			var urlReq:URLRequest = new URLRequest(fileName);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
			loader.load(urlReq);
		}
		private static function creationComplete(result:String):void {  
			if(result=="success"){
				initialised=true;
			}
			DynamicAtlasCreator.creationComplete.remove(creationComplete);
			
			System.disposeXML(data);
			data=null;
			XhdpiPng.bitmapData.dispose();
			XhdpiPng=null;
		
		}
		
		
		private static function loaded(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaded);
			XhdpiPng=e.target.content as Bitmap;
			loader.unloadAndStop(true);
			loader=null;
			
			
			assets.verbose = false;//Capabilities.isDebugger;
			data=XML(new XhdpiXml());
			
			//listen to atlas creation process, we use AS3 signal here
			DynamicAtlasCreator.creationComplete.add(creationComplete);
			DynamicAtlasCreator.createFrom(XhdpiPng.bitmapData,data,scaleRatio,assets);
		}
	}
}