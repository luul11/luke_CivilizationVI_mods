--Sends LUA Event message broadcast stating this mod is enabled.

function BroadcastModInUse()
	LuaEvents.FF16_PolicyChangeReminder();
end

function Initialize()
	print("FinalFreak16: Loading Mod - Policy Change Reminder.")
	Events.LoadGameViewStateDone.Add( BroadcastModInUse );
end

Initialize();