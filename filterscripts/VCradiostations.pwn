/*
	Default-Style radio stream system
	@Author: Bitrate
	http://forum.sa-mp.com/member.php?u=143266
*/

#include <a_samp>

#define MAX_VCSTATIONS 10

#define PRESSED(%0) \
        (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))



new Text:pRadioStation[MAX_PLAYERS] = {Text:INVALID_TEXT_DRAW, ...};
new HideTimer[MAX_PLAYERS];

forward UpdateStation(playerid, VCStationiD);
forward RadioText(playerid);




public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Vehicle radio system by Bitrate.\n");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    pRadioStation[playerid] = TextDrawCreate(220, 25, "Radio off");

    TextDrawFont(pRadioStation[playerid], 2);

   	TextDrawUseBox(pRadioStation[playerid], 0);

	TextDrawLetterSize(pRadioStation[playerid], 0.7, 1.3);

	TextDrawFont(pRadioStation[playerid], 2);

	TextDrawSetShadow(pRadioStation[playerid],0);

    TextDrawSetOutline(pRadioStation[playerid],1);

    TextDrawColor(pRadioStation[playerid],0x946110FF);

	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
	    SendClientMessage(playerid, 0xFF0000FF, "To select the next radio press ~k~~CONVERSATION_YES~ and to select the prior radio press ~k~~CONVERSATION_NO~");
	}
	else if(newstate != PLAYER_STATE_DRIVER || newstate != PLAYER_STATE_PASSENGER && oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    StopAudioStreamForPlayer(playerid);
	}

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public UpdateStation(playerid, VCStationiD)
{
	if(VCStationiD == 0)
	{
	    KillTimer(HideTimer[playerid]);

	   	StopAudioStreamForPlayer(playerid);

	   	SetPVarInt(playerid, "VCStationiD", 0);

        TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Radio Off");
	   	GameTextForPlayer(playerid, "Radio Off", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 1)
	{
	    KillTimer(HideTimer[playerid]);

		PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/xutdt7wc4pgebre/%5BGTA%20VC%5D%20Emotion%20103.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 1);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
   		TextDrawSetString(pRadioStation[playerid], "Emotion 103");
   		GameTextForPlayer(playerid, "Emotion 103", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 2)
	{
	    KillTimer(HideTimer[playerid]);

		PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/e8huvqf7w90cete/%5BGTA%20VC%5D%20Espantoso.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 2);

	   	TextDrawSetString(pRadioStation[playerid], "Espantoso");
	   	GameTextForPlayer(playerid, "Espantoso", 5000, 6);
	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 3)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/yhweh2pq5g0jo0n/%5BGTA%20VC%5D%20Fever%20105.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 3);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Fever 105");
	   	GameTextForPlayer(playerid, "Fever 105", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 4)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/vbn39n5jhdjpofk/%5BGTA%20VC%5D%20Flash%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 4);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Flash FM");
	   	GameTextForPlayer(playerid, "Flash FM", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 5)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/w2c2u819yp0ptwa/%5BGTA%20VC%5D%20K-CHAT.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 5);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "K-CHAT");
	   	GameTextForPlayer(playerid, "K-CHAT", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}


	if(VCStationiD == 6)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/lk8j7dh9nth58dw/%5BGTA%20VC%5D%20V%20Rock.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 6);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "V Rock");
	   	GameTextForPlayer(playerid, "V Rock", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 7)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/pzoj7j30oynejpc/%5BGTA%20VC%5D%20VCPR.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 7);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "VCPR");
	   	GameTextForPlayer(playerid, "VCPR", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 8)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/httu2jfmy8oc0un/%5BGTA%20VC%5D%20Wave%20103.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 8);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Wave 103");
	   	GameTextForPlayer(playerid, "Wave 103", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(VCStationiD == 9)
	{
	    KillTimer(HideTimer[playerid]);

		PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/8jpei3ythfn1o38/%5BGTA%20VC%5D%20Wildstyle%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "VCStationiD", 9);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
   		TextDrawSetString(pRadioStation[playerid], "Wildstyle FM");
   		GameTextForPlayer(playerid, "Wildstyle FM", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
 		if(IsPlayerInArea(playerid, 365.628173, -2906.053955, 2873.086914, 668.727539))
		{
			if(PRESSED(KEY_YES))
			{
		    	PlayerPlaySound(playerid,1083,0.0,0.0,0.0);
		    	if(GetPVarInt(playerid, "VCStationiD") >= MAX_VCSTATIONS) SetPVarInt(playerid, "VCStationiD", -1);

				UpdateStation(playerid, GetPVarInt(playerid, "VCStationiD") + 1);
			}
			else if(PRESSED(KEY_NO))
			{
		    	PlayerPlaySound(playerid,1084,0.0,0.0,0.0);
		    	if(GetPVarInt(playerid, "VCStationiD") <= 0) SetPVarInt(playerid, "VCStationiD", MAX_VCSTATIONS + 1);

		    	UpdateStation(playerid, GetPVarInt(playerid, "VCStationiD") - 1);
			}
		}
	}

	return 1;
}


IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
    new Float:X, Float:Y, Float:Z;
    GetPlayerPos(playerid, X, Y, Z);
    return (X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) ? 1 : 0;
}

public RadioText(playerid)
{
    TextDrawHideForPlayer(playerid, pRadioStation[playerid]);
}
