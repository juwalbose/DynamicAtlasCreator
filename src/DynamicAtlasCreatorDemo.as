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
 */

package
{
	import com.csharks.topdownlevel.MainLevel
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	[SWF(backgroundColor = "#004400", frameRate = "30", width "100%", height = "100%")]
	
	
	/**
	 * Dependencies are AS3 signals by Rob Penner, Tweenlite by Greensock, Starling 1.3+ by Daniel Sperl, RectanglePacker by Ville Koskeal 
	 */
	public class DynamicAtlasCreatorDemo extends Sprite
	{
		private var starling:Starling;
		private var viewPort:Rectangle;
		
		public function DynamicAtlasCreatorDemo()
		{
			if (stage) init();
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		public function init(e:flash.events.Event = null):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//add resize event to track stage size change & dispatch new texture creation
			stage.addEventListener(flash.events.Event.RESIZE,onResize);
			
			Starling.multitouchEnabled = false; // useful on mobile devices
			Starling.handleLostContext = true; 
			
			
			starling = new Starling(MainLevel, stage,null,null,"auto","baseline");//for 4096 support use BASELINE_EXTENDED
			starling.showStats = false;
			starling.simulateMultitouch  = false;
			starling.enableErrorChecking = Capabilities.isDebugger;
			starling.antiAliasing=0;
			
			starling.start();
			
			// this event is dispatched when stage3D is set up
			starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			
		}
		private function onRootCreated(event:starling.events.Event, game:MainLevel):void
		{
			onResize();//call explicitly as this initialise creation of initial textures
		}
		private function onResize(e:flash.events.Event=null):void
		{
			starling.stage.stageWidth=stage.stageWidth;
			starling.stage.stageHeight=stage.stageHeight;
			
			viewPort = starling.viewPort;
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			
			try
			{
				starling.viewPort = viewPort;
				//need to process only the final resize values, resizing gets dispatched a lot in between start & end
				TweenLite.killDelayedCallsTo(scaleLevel);
				TweenLite.delayedCall(0.5,scaleLevel);//just giving it a delayed call as resizing may be a continuous thing
			}
			catch(error:Error) {trace("error");}
			
		}
		private function scaleLevel():void{//only the final resize values reach here as other tweens get killed when new values come
			trace("resize", stage.stageWidth,stage.stageHeight,stage.fullScreenWidth,stage.fullScreenHeight);
			//scale the main class. scale ratio is founf in main class
			(Starling.current.root as MainLevel).rescaleAndRedraw(stage.stageWidth,stage.stageHeight);
		}
	}
}