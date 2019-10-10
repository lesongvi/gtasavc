/*
	Default-Style radio stream system
	@Author: Bitrate
	http://forum.sa-mp.com/member.php?u=143266
*/

#include <a_samp>

#define MAX_LCSTATIONS 10

#define PRESSED(%0) \
        (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))



new Text:pRadioStation[MAX_PLAYERS] = {Text:INVALID_TEXT_DRAW, ...};
new HideTimer[MAX_PLAYERS];

forward UpdateStation(playerid, LCStationiD);
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
	if(newstate != PLAYER_STATE_DRIVER || newstate != PLAYER_STATE_PASSENGER && oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    StopAudioStreamForPlayer(playerid);
	}

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public UpdateStation(playerid, LCStationiD)
{
	if(LCStationiD == 0)
	{
	    KillTimer(HideTimer[playerid]);

	   	StopAudioStreamForPlayer(playerid);

	   	SetPVarInt(playerid, "LCStationiD", 0);

        TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Radio Off");
	   	GameTextForPlayer(playerid, "Radio Off", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 1)
	{
	    KillTimer(HideTimer[playerid]);

		PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/h8o2x8xf7wgayjw/%5BGTA%203%5D%20Chatterbox%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 1);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
   		TextDrawSetString(pRadioStation[playerid], "Chatterbox FM");
   		GameTextForPlayer(playerid, "Chatterbox FM", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 2)
	{
	    KillTimer(HideTimer[playerid]);

		PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/5zzucvhydaeu1f5/%5BGTA%203%5D%20Flashback%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 2);

	   	TextDrawSetString(pRadioStation[playerid], "Flashback FM");
	   	GameTextForPlayer(playerid, "Flashback FM", 5000, 6);
	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 3)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/6s3sf31s73fhdwt/%5BGTA%203%5D%20Game%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 3);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Game FM");
	   	GameTextForPlayer(playerid, "Game FM", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 4)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/ta5228iwhiy92t2/%5BGTA%203%5D%20K-Jah%20Radio.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 4);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "K-Jah Radio");
	   	GameTextForPlayer(playerid, "K-Jah Radio", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 5)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/9iz6wy32ewobo4u/%5BGTA%203%5D%20Lips%20106.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 5);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Lips 106");
	   	GameTextForPlayer(playerid, "Lips 106", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 6)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/3xn62208o8id4jt/%5BGTA%203%5D%20MSX%20101.1.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 6);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "MSX 101.1");
	   	GameTextForPlayer(playerid, "MSX 101.1", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 7)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/do4imivszqwneu7/%5BGTA%203%5D%20Head%20Radio.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 7);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Head Radio");
	   	GameTextForPlayer(playerid, "Head Radio", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	if(LCStationiD == 8)
	{
	    KillTimer(HideTimer[playerid]);

	   	PlayAudioStreamForPlayer(playerid, "https://www.dropbox.com/s/nb7vfnxt3naewx0/%5BGTA%203%5D%20Rise%20FM.mp3?raw=1");

	   	SetPVarInt(playerid, "LCStationiD", 8);

	   	TextDrawShowForPlayer(playerid, pRadioStation[playerid]);
	   	TextDrawSetString(pRadioStation[playerid], "Rise FM");
	   	GameTextForPlayer(playerid, "Rise FM", 5000, 6);

	   	HideTimer[playerid] = SetTimerEx("RadioText", 3000, false, "i", playerid);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
 		if(!IsPlayerInArea(playerid, 365.628173, -2906.053955, 2873.086914, 668.727539))
		{
			if(PRESSED(KEY_YES))
			{
		    	PlayerPlaySound(playerid,1083,0.0,0.0,0.0);
		    	if(GetPVarInt(playerid, "LCStationiD") >= MAX_LCSTATIONS) SetPVarInt(playerid, "LCStationiD", -1);

				UpdateStation(playerid, GetPVarInt(playerid, "LCStationiD") + 1);
			}
			else if(PRESSED(KEY_NO))
			{
		    	PlayerPlaySound(playerid,1084,0.0,0.0,0.0);
		    	if(GetPVarInt(playerid, "LCStationiD") <= 0) SetPVarInt(playerid, "LCStationiD", MAX_LCSTATIONS + 1);

		    	UpdateStation(playerid, GetPVarInt(playerid, "LCStationiD") - 1);
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
