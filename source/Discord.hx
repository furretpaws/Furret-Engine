package;

import Sys.sleep;
#if (windows && cpp)
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public function new()
	{
		trace("Discord Client starting...");
		#if windows
		DiscordRpc.start({
			clientID: "1053457240901824543",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		#end
		trace("Discord Client started.");

		while (true)
		{
			#if windows
			DiscordRpc.process();
			sleep(2);
			#end
			//trace("Discord Client Update");
		}

		#if windows
		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if windows
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if windows
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Furret Engine " + MainMenuState.furretEngineVer
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if windows
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		#end
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		#if windows
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Furret Engine",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
		#end

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
