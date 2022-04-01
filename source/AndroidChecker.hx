package;
#if android
#if android
import android.AndroidTools;
import android.Permissions;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;

class AndroidChecker
{
    #if android
    private static var aDir:String = null;
    private static var sPath:String = AndroidTools.getExternalStorageDirectory();  
    private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions();  
    #end

    static public function getPath():String
    {
    	#if android
        if (aDir != null && aDir.length > 0) 
        {
            return aDir;
        } 
        else 
        {
            aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/files/";         
        }
        return aDir;
        #else
        return "";
        #end
    }

    static public function doTheCheck()
    {
        #if android
        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
            }  
        }

        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                AndroidChecker.applicationAlert("Furret Engine", "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings" + "\n" + "Press OK To Close The App");
            } else {
                AndroidChecker.applicationAlert("Furret Engine", "The game can't run without storage permissions please grant them in app settings" + "\n" + "Press OK To Close The App");
            }
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file") + "/files")){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file") + "/files");
        }

        if (!FileSystem.exists(AndroidChecker.getPath() + "assets")){
            AndroidChecker.applicationAlert("Furret Engine", "Hello! It seems this is your first time using Furret Engine on Android. You have to copy assets/assets from apk to your internal storage app directory " + "( here " + AndroidChecker.getPath() + " )" + "\n" + "Press Ok To Close The App");
	    flash.system.System.exit(0);
        }
        #end
    }

    static public function gameCrashCheck(){
    	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    }
     
    static public function onCrash(e:UncaughtErrorEvent):Void {
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
	var dateNow:String = Date.now().toString();
	dateNow = StringTools.replace(dateNow, " ", "_");
	dateNow = StringTools.replace(dateNow, ":", "'");
	var path:String = "log/" + "crash_" + dateNow + ".txt";

	var errMsg:String = "";

	for (stackItem in callStack)
	{
		switch (stackItem)
		{
			case FilePos(s, file, line, column):
				errMsg += file + " (line " + line + ")\n";
			default:
				Sys.println(stackItem);
		}
	}

        errMsg += e.error;

        if (!FileSystem.exists(AndroidChecker.getPath() + "log")){
            FileSystem.createDirectory(AndroidChecker.getPath() + "log");
        }

        sys.io.File.saveContent(AndroidChecker.getPath() + path, errMsg + "\n");

	Sys.println(errMsg);
	Sys.println("Crash dump saved in " + Path.normalize(path));
	Sys.println("Making a simple alert ...");
		
	AndroidChecker.applicationAlert("Uncaught Error:", errMsg);
	flash.system.System.exit(0);
    }
	
    public static function applicationAlert(title:String, description:String){
        Application.current.window.alert(description, title);
    }

    static public function saveContent(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
        if (!FileSystem.exists(AndroidChecker.getPath() + "system-saves")){
            FileSystem.createDirectory(AndroidChecker.getPath() + "system-saves");
        }

        sys.io.File.saveContent(AndroidChecker.getPath() + "system-saves/" + fileName + fileExtension, fileData);
        AndroidChecker.applicationAlert("", "File Saved Successfully!");
    }
}
#end