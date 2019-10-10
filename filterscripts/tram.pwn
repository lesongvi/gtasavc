// Entering tram as passenger v3.01 by BeckzyBoi. (27/04/2014). Requires SA-MP 0.3z R2-2 or later

#include <a_samp>
#include <ZCMD>

public OnFilterScriptInit()
{
	print("---------------------------------------");
	print("Loaded 'Entering tram as passenger'");
	print("v3.01 by BeckzyBoi. (27/04/2014)");
	print("---------------------------------------");
	return 1;
}

new sExplode[MAX_VEHICLES];
new tCount[MAX_VEHICLES];

#define S_EXPLODE_X 2.4015
#define S_EXPLODE_Y 29.2775
#define S_EXPLODE_Z 1199.593
#define S_EXPLODE_RANGE 13.4

forward Explodetram(vehicleid);

GetPlayertramID(playerid)
{
	return GetPlayerVirtualWorld(playerid) > cellmax-MAX_VEHICLES ? cellmax-GetPlayerVirtualWorld(playerid) : 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (ispassenger != 0 && GetVehicleModel(vehicleid) == 449)
	{
		SetPlayerVirtualWorld(playerid, cellmax-vehicleid);
		SetPlayerInterior(playerid, 1);
		SetPlayerPos(playerid,199.6787, 812.9191, 2503.7085);
		SetCameraBehindPlayer(playerid);
  		SetTimerEx("spawn",3000,0,"d",playerid);
		TogglePlayerControllable(playerid,false);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vehicleid = GetPlayertramID(playerid);
	if (newkeys == 16 && vehicleid != 0)
	{
		new Float:x, Float:y, Float:z, Float:a;
		GetVehiclePos(vehicleid, x, y, z);
		GetVehicleZAngle(vehicleid, a);
		x += (5.0*floatsin(-(a-45.0), degrees));
		y += (5.0*floatcos(-(a-45.0), degrees));
		SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(vehicleid));
		SetPlayerInterior(playerid, 0);
		SetPlayerPos(playerid, x, y, z+0.5);
		SetPlayerFacingAngle(playerid, a);
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if (GetVehicleModel(vehicleid) == 449)
	{
		for (new i = 0; i < MAX_PLAYERS; i++)
		{
			if (GetPlayertramID(i) == vehicleid)
			{
				SetPlayerHealth(i, 0.0);

			}
		}
		sExplode[vehicleid] = SetTimerEx("Explodetram", 700, 0, "d", vehicleid);
		tCount[vehicleid] = true;
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	tCount[vehicleid] = false;
	return 1;
}



public Explodetram(vehicleid)
{
	KillTimer(sExplode[vehicleid]);
	if (tCount[vehicleid])
	{
		for (new i = 0; i < MAX_PLAYERS; i++)
		{
			if (GetPlayertramID(i) == vehicleid)
			{

			}
		}
		sExplode[vehicleid] = SetTimerEx("Explodetram", random(1300) + 100, 0, "d", vehicleid);
	}
}

forward spawn(playerid);
public spawn(playerid)
{
	TogglePlayerControllable(playerid,true);
}

