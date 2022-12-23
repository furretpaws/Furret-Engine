package;

import Sys.sleep;
#if sys
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public function new()
	{
		trace("Discord Client starting...");
		#if sys
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
			#if sys
			DiscordRpc.process();
			sleep(2);
			#end
			//trace("Discord Client Update");
		}

		#if sys
		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if sys
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if sys
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
		#if sys
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

		#if sys
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
