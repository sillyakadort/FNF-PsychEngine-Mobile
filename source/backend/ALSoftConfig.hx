package backend;

import haxe.io.Path;

/*
A class that simply points OpenALSoft to a custom configuration file when the game starts up.
The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
*/
@:keep class ALSoftConfig
{
	#if desktop
	static function __init__():Void
	{
		var origin:String = #if (hl || mobile) Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#elseif android
		configPath = origin + 'alsoft.conf';
		var exists:Bool = FileSystem.exists(configPath);
		if (!exists) File.saveContent(configPath, openfl.Assets.getText('alsoft.conf'));
		exists = FileSystem.exists(configPath);
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		#if android
		if (exists)
		{
			lime.system.JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'nativeSetenv', '(Ljava/lang/String;Ljava/lang/String;)V')("ALSOFT_CONF", configPath);
		}
		else
		{
			trace("Couldn't configure ALSoft because the the config file doesn't exist on the current working directory.");
		}
		#else
		Sys.putEnv("ALSOFT_CONF", configPath);
		#end
	}
	#end
}
