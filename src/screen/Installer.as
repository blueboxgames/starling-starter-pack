package screen {
	
	import feathers.controls.Button;
	import feathers.controls.Panel;
	import feathers.controls.Screen;
	import flash.desktop.NativeProcess;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import main.Process;
	import events.ProcessEvent;
	import starling.display.Sprite;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.controls.TextInput;
	import feathers.controls.Check;
	import flash.desktop.NativeApplication;
	import feathers.themes.MetalWorksMobileTheme;
	import starling.events.Event;

	
	public class Installer extends Sprite {
		private var process:Process;
		private var log:Label;
		private var launchMenu:Screen; 
		private var pathF:TextInput;
		private var launchButton:Button;
		private var installingMenu:Screen;
		private var jdkInstallCheck:Check;
		private var fdInstallCheck:Check;
		private var airInstallCheck:Check;
		private var finInstallCheck:Check;
		public function Installer() {
			new MetalWorksMobileTheme;
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, showLaunchMenu);
		}
		
		private function showLaunchMenu():void {
			// Create Rocket Launch Icon.
			// Create feathers button and make screen go top.
			// Wait for input ->
			this.launchButton = new Button();
			this.launchMenu = new Screen();
			var launchLabel:Label = new Label();
			launchLabel.text = "Welcome to blue box installer";
			launchButton.label = "Continue";
			launchLabel.validate();
			launchButton.validate();
			launchLabel.x = Math.floor( ( 300 - launchLabel.width ) / 2 );
			launchLabel.y = 20;
			launchButton.x = Math.floor( ( 300 - launchButton.width ) / 2 );
			launchButton.y = 20 + launchLabel.height + 30;
			launchMenu.addChild(launchButton);
			launchMenu.addChild(launchLabel);
			this.addChild(launchMenu);
			var sdkPath:String = File.applicationStorageDirectory.resolvePath("airsdk-32").nativePath;
			editSDKSettings();
			this.launchButton.addEventListener(starling.events.Event.TRIGGERED, showInstallingProcess);
			return;
		}
		
		private function showInstallingProcess():void {
			this.launchMenu.move(0, -(this.stage.stageHeight));
			this.installingMenu = new Screen();
			this.installingMenu.x = 10;
			this.jdkInstallCheck = new Check();
			this.jdkInstallCheck.label = "Instaling JDK";
			this.jdkInstallCheck.isEnabled = false;
			this.jdkInstallCheck.validate();
			this.fdInstallCheck = new Check();
			this.fdInstallCheck.label = "Installing FlashDevelop";
			this.fdInstallCheck.isEnabled = false;
			this.fdInstallCheck.y = this.jdkInstallCheck.height + 1;
			this.fdInstallCheck.validate();
			
			this.airInstallCheck = new Check();
			this.airInstallCheck.label = "Copying AIR SDK";
			this.airInstallCheck.isEnabled = false;
			this.airInstallCheck.y = this.jdkInstallCheck.height + fdInstallCheck.y + 1;
			this.airInstallCheck.validate();
			
			this.finInstallCheck = new Check();
			this.finInstallCheck.label = "Finalize";
			this.finInstallCheck.isEnabled = false;
			this.finInstallCheck.y = this.jdkInstallCheck.height + airInstallCheck.y + 1;
			this.finInstallCheck.validate();
			
			installingMenu.addChild(jdkInstallCheck);
			installingMenu.addChild(fdInstallCheck);
			installingMenu.addChild(airInstallCheck);
			installingMenu.addChild(finInstallCheck);
			this.addChild(installingMenu);
			//if ( NativeProcess.isSupported ) {
				this.process = new Process("jdk-1.8.0.exe", "Execute");
				//this.process = new Process("javaset", "Command");
				//this.process = new Process("finalize", "Unpack");
				this.process.addEventListener(ProcessEvent.END, processEnd);
				trace(this.process.name);
			//}
		}
		
		private function processEnd(e:ProcessEvent):void {
			this.process.removeEventListener(ProcessEvent.END, processEnd);
			switch(this.process.name){
				case "jdk-1.8.0.exe":
					this.jdkInstallCheck.isSelected = true;
					this.process = new Process("javaset", "Command");
					this.process.addEventListener(ProcessEvent.END, processEnd);
					//this.log.text = "Installing Flash Develop...";
					break;
				case "javaset.bat":
					this.process = new Process("flashdevelop-5.3.3.exe", "Execute");
					this.process.addEventListener(ProcessEvent.END, processEnd);
				case "flashdevelop-5.3.3.exe":
					this.process = new Process("fdcopy.bat", "Command");
					this.process.addEventListener(ProcessEvent.END, processEnd);
					break;
				case "fdcopy.bat":
					this.fdInstallCheck.isSelected = true;
					this.process = new Process("airsdk-32", "Unpack");
					this.process.addEventListener(ProcessEvent.END, processEnd);
					break;
				case "airsdk-32":
					this.airInstallCheck.isSelected = true;
					this.process = new Process("finalize", "Unpack");
					this.process.addEventListener(ProcessEvent.END, processEnd);
					break;
				case "finalize":
					this.finInstallCheck.isSelected = true;
					var finishButton:Button = new Button();
					finishButton.label = "Done!";
					finishButton.validate();
					finishButton.y = finishButton.height + finInstallCheck.y + 5;
					finishButton.x = Math.floor( ( 300 - finishButton.width ) / 2 );
					this.installingMenu.addChild(finishButton);
					finishButton.addEventListener(starling.events.Event.TRIGGERED, exit_Main);
					break;
				default:
					NativeApplication.nativeApplication.exit( 1 );
					break;
			}
		}
		
		private function editSDKSettings(destination:String = "C:\\SDK\\aaar-32"):void {
			var fileStream:FileStream = new FileStream();
			var settingsPath:String = File.applicationDirectory.resolvePath("Settings.fdb").nativePath;
			var sourceSettingsFile:File = new File(settingsPath);
			sourceSettingsFile.addEventListener(Event.COMPLETE, sourceSettingsFile_completeHadler); 
			sourceSettingsFile.load();
			function sourceSettingsFile_completeHadler() : void
			{
				sourceSettingsFile.removeEventListener(Event.COMPLETE, sourceSettingsFile_completeHadler);
				var seperatorPosition:int = getSeperatorPosition(sourceSettingsFile.data, 233);
				
				var byteArray:ByteArray = new ByteArray();
				for ( var i:int = 0; i < seperatorPosition ;  i ++)
					byteArray.writeByte(sourceSettingsFile.data[i]);
				
				for ( i = 0; i < destination.length ;  i ++)
					byteArray.writeByte(destination.charCodeAt(i));
					
				for ( i = seperatorPosition + 1; i < sourceSettingsFile.data.length ;  i ++)
					byteArray.writeByte(sourceSettingsFile.data[i]);
					
				//byteArray.writeBytes(sourceSettingsFile.data);
				//byteArray.po sition = 0;
				var destinationFile:File = File.desktopDirectory.resolvePath("Settings.fdb");
				destinationFile.save(byteArray, destinationFile.name);
				trace(byteArray.toString())
				
			}
			//SSFS.addEventListener(flash.events.Event.COMPLETE, writeToPosition);
			/*var byteArray:ByteArray = new ByteArray();
			trace(byteArray.toString());
			fileStream.open(sourceSettingsFile, FileMode.UPDATE);
			fileStream.position = 934;
			fileStream.readBytes(byteArray);
			byteArray.toString().split(934);
			trace(byteArray.toString());
			fileStream.writeUTFBytes(destination);
			fileStream.close();*/
			//SDK_SETTINGS_FILE = new File(pathToFile);
			//SSFS.open(SDK_SETTINGS_FILE, FileMode.UPDATE);
			//SSFS.writeBytes(Data);
			//SSFS.close();
		}
		
		private function getSeperatorPosition(data:ByteArray, number:Number):int 
		{
			for ( var i:int = 0; i < data.length; i++)
				if( data[i] == 233 )
					return i;
			return -1;
		}
		
	
		
		private function exit_Main(e:*):void {
			NativeApplication.nativeApplication.exit( 1 );
		}
		
	}

}