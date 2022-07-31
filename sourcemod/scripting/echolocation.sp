#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Moonly Days"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "[TF2] Echo Location",
	author = PLUGIN_AUTHOR,
	description = "You can see sounds",
	version = PLUGIN_VERSION,
	url = "https://github.com/MoonlyDays"
};

public OnPluginStart()
{
     AddNormalSoundHook(OnSound);
     
     HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	TF2_AddCondition(client, TFCond_StealthedUserBuffFade, TFCondDuration_Infinite, client);
	return Plugin_Continue;
}

public Action OnSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (!IsClient(entity))
		return Plugin_Continue;
		
	bool isDucked = GetEntProp(entity, Prop_Send, "m_bDucked") > 0;
	if (isDucked && StrContains(sample, "footstep", false) != -1)
		return Plugin_Handled;
	
	float flTime = GetEstimatedSoundTime(sample);
	SetEntPropFloat(entity, Prop_Send, "m_flInvisChangeCompleteTime", GetGameTime() + flTime);
	return Plugin_Continue;
}

public float GetEstimatedSoundTime(char sample[PLATFORM_MAX_PATH])
{
	if (StrContains(sample, "vo/") != -1)
		return 2.0;
		
	if (StrContains(sample, "footsteps/") != -1)
		return 0.5;
		
	return 1.0;
}

public bool IsClient( int client )
{
	if (client <= 0)
		return false;
		
	if (client > MaxClients)
		return false;
		
	return IsClientInGame(client);
}