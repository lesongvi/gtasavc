/*
	SA:MP Audio Multi Stream v.1.2
	Copyright © 2011 Atrox

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

public OnPlayerConnect(playerid)
{
    SetPVarInt(playerid, "duration", 0);
    SetPVarString(playerid, "url", "");
    SetPVarFloat(playerid, "posX", 0.0);
    SetPVarFloat(playerid, "posY", 0.0);
    SetPVarFloat(playerid, "posZ", 0.0);
    SetPVarFloat(playerid, "distance", 50.0);
    SetPVarInt(playerid, "usepos", 0);
    return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect AudioMS_OnPlayerConnect

forward AudioMS_OnPlayerConnect(playerid);

stock StopAudioStreamForPlayerEx(playerid)
{
    SetPVarInt(playerid, "duration", 0);
    SetPVarString(playerid, "url", "");
    SetPVarFloat(playerid, "posX", 0.0);
    SetPVarFloat(playerid, "posY", 0.0);
    SetPVarFloat(playerid, "posZ", 0.0);
    SetPVarFloat(playerid, "distance", 50.0);
    SetPVarInt(playerid, "usepos", 0);
    
    StopAudioStreamForPlayer(playerid);
}
stock PlayAudioStreamForPlayerEx(playerid, url[], duration, Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, usepos = 0)
{
	if(GetPVarInt(playerid, "duration") == 0)
	{
	    PlayAudioStreamForPlayer(playerid, url, posX, posY, posZ, distance, usepos);
	    SetPVarInt(playerid, "duration", duration);
	    SetPVarString(playerid, "url", url);
	    SetPVarFloat(playerid, "posX", posX);
	    SetPVarFloat(playerid, "posY", posY);
	    SetPVarFloat(playerid, "posZ", posZ);
	    SetPVarFloat(playerid, "distance", distance);
	    SetPVarInt(playerid, "usepos", usepos);
        if(duration != -1)
        {
	    	SetTimerEx("StopAudio", duration, 0, "d", playerid);
		}
 	}
 	else if(GetPVarInt(playerid, "duration") == -1)
 	{
 	    StopAudioStreamForPlayer(playerid);
        PlayAudioStreamForPlayer(playerid, url, posX, posY, posZ, distance, usepos);
        if(duration != -1)
        {
    		new tmp[256];
    		GetPVarString(playerid, "url", tmp, 256);
        	SetTimerEx("SetNextStream", duration, 0, "dsdffffd", playerid, tmp, GetPVarInt(playerid, "duration"), GetPVarFloat(playerid, "posX"), GetPVarFloat(playerid, "posY"), GetPVarFloat(playerid, "posZ"), GetPVarFloat(playerid, "distance"), GetPVarInt(playerid, "usepos"));
		}
	}
 	else
 	{
 	    StopAudioStreamForPlayer(playerid);
        PlayAudioStreamForPlayer(playerid, url, posX, posY, posZ, distance, usepos);

        if(duration != -1)
        {
    		new tmp[256];
    		GetPVarString(playerid, "url", tmp, 256);
        	SetTimerEx("SetNextStream", duration, 0, "dsdffffd", playerid, tmp, GetPVarInt(playerid, "duration"), GetPVarFloat(playerid, "posX"), GetPVarFloat(playerid, "posY"), GetPVarFloat(playerid, "posZ"), GetPVarFloat(playerid, "distance"), GetPVarInt(playerid, "usepos"));
		}
  	}
}
forward StopAudio(playerid);
public StopAudio(playerid)
{
	StopAudioStreamForPlayerEx(playerid);
}
forward SetNextStream(playerid,url[], duration, Float:posX, Float:posY, Float:posZ, Float:distance, usepos);
public SetNextStream(playerid,url[], duration, Float:posX, Float:posY, Float:posZ, Float:distance, usepos)
{
    StopAudioStreamForPlayer(playerid);
    new tmp[256];
    format(tmp, 256, url);
    PlayAudioStreamForPlayer(playerid, tmp, Float:posX, Float:posY, Float:posZ, Float:distance, usepos);
    
    SetPVarInt(playerid, "duration", duration);
    SetPVarString(playerid, "url", tmp);
    SetPVarFloat(playerid, "posX", posX);
    SetPVarFloat(playerid, "posY", posY);
    SetPVarFloat(playerid, "posZ", posZ);
    SetPVarFloat(playerid, "distance", distance);
    SetPVarInt(playerid, "usepos", usepos);
    if(duration != -1)
    {
	   SetTimerEx("StopAudio", duration, 0, "d", playerid);
	}
	return 1;
}