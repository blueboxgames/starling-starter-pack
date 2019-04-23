package {
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import screen.Installer;
	
	public class Main extends Sprite {
		private var userFace:Starling;
		public function Main() {
			loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		private function nativeWindow_moving(e:MouseEvent):void {
			e.updateAfterEvent();
			stage.nativeWindow.startMove();
		}

		private function loaderInfo_completeHandler(e:Event):void {
			loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			stage.nativeWindow.x = (Capabilities.screenResolutionX - 300)*0.5;
			stage.nativeWindow.y = (Capabilities.screenResolutionY - 200)*0.5;
			userFace = new Starling( Installer, stage );
			userFace.start();
			//this.process = new Process("jdk-1.8.0.exe");
			//process.addEventListener(ProcessEvent.END, processEnd);
		}
	}
}