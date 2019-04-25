package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.system.Capabilities;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.display.StageAlign;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.filesystem.File;
	
	import starling.core.Starling;
	import screen.Installer;
	
	public class Main extends Sprite {
		private var userFace:Starling;
		public function Main() {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		private function loaderInfo_completeHandler(e:Event):void {
			loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			stage.nativeWindow.x = (Capabilities.screenResolutionX - 300)*0.5;
			stage.nativeWindow.y = (Capabilities.screenResolutionY - 200)*0.5;
			userFace = new Starling( Installer, stage , new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE );
			userFace.addEventListener("rootCreated", this.starling_rootCreatedHandler);
			var username:String = File.userDirectory.name;
			trace(username);
			userFace.start();
		}
		
		protected function starling_rootCreatedHandler(event:Object):void {
			this.userFace.removeEventListener("rootCreated",	this.starling_rootCreatedHandler);
			this.stage.addEventListener(Event.DEACTIVATE, 		this.stage_deactivateHandler, false, 0, true);
		}

		protected function stage_deactivateHandler(event:Event):void {
			if( true ) {
				this.userFace.stop(true);
				this.stage.frameRate = 0;
			}
			this.stage.addEventListener(Event.ACTIVATE, this.stage_activateHandler, false, 0, true);
		}
		protected function stage_activateHandler(event:Event):void {
			this.stage.removeEventListener(Event.ACTIVATE, this.stage_activateHandler);
			this.stage.frameRate = 60;
			this.userFace.start();
		}
	}
}