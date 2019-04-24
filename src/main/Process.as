package main {
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import events.ProcessEvent;

	[Event(name="end", type="events.ProcessEvent")]
	public class Process extends EventDispatcher {
		public var name:String;
		private var file:File;
		private var instance:NativeProcess;
				
		public function Process(name:String, type="Execute", path="."){
			this.name = name;
			this.file = File.applicationDirectory.resolvePath(name);
			if (type == "Execute" ) {
				this.start();
			} else if ( type == "Unpack" ) {
				this.unpack();
			} else if ( type == "Command") {
				this.runCommand();
			}
		}

		private function start():void{
			this.instance = new NativeProcess();
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = this.file;
			this.instance.start(nativeProcessStartupInfo);
			this.instance.addEventListener(NativeProcessExitEvent.EXIT, process_exit);
		}

		private function runCommand():void{
			var cmdFile:File = new File("c:\\Windows\\System32\\cmd.exe");
			var processArgs:Vector.<String> = new Vector.<String>; 
			processArgs.push("/c");
        	processArgs.push(this.file.nativePath);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.arguments = processArgs;
			nativeProcessStartupInfo.executable = cmdFile;
			this.instance = new NativeProcess();
			//var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			this.instance.start(nativeProcessStartupInfo);
			this.instance.addEventListener(NativeProcessExitEvent.EXIT, process_exit);
		}

		private function process_exit(e:NativeProcessExitEvent):void {
			this.dispatchEvent(new ProcessEvent(ProcessEvent.END));
		}
		
		private function unpack():void {
			var sourceDir:File;
			var resultDir:File;
			if (this.name == "finalize" ) {
				sourceDir = File.applicationDirectory.resolvePath("starling-feathers");
				resultDir = new File("C:\\Program Files (x86)\\FlashDevelop\\Projects");
				if (resultDir.exists){
					resultDir = new File("C:\\Program Files (x86)\\FlashDevelop\\Projects\\191 ActionScript 3 - Starling + Feathers");
					trace(resultDir.nativePath);
					sourceDir.copyToAsync(resultDir, true);
				} else {
					resultDir = File.applicationStorageDirectory.resolvePath("191 ActionScript 3 - Starling + Feathers");
					sourceDir.copyToAsync(resultDir, true);
				}
			} else {
				sourceDir = File.applicationDirectory.resolvePath(this.name); 
				resultDir = File.applicationStorageDirectory.resolvePath(this.name);
				sourceDir.copyToAsync(resultDir, true);
			}
			}
			sourceDir.addEventListener(Event.COMPLETE, copy_end);
		}
		
		private function copy_end(e:Event):void {
			this.dispatchEvent(new ProcessEvent(ProcessEvent.END));
		}
	}
}