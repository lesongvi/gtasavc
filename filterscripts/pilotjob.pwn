
#define FILTERSCRIPT

#include <a_samp>
#include <zcmd>

#define COLOR_GRAD2 0xBFC0C2FF

#define SCM SendClientMessage
#if defined FILTERSCRIPT

new DeliveryManJob[256];


public OnFilterScriptInit()
{

	return 1;
}

#endif

CMD:pilot(playerid, params[])
{
    if(!IsPlayerInRangeOfPoint(playerid, 50,440.4654,-2063.3464,10.2512))
	{
	    DisablePlayerCheckpoint(playerid);
	    SetPlayerCheckpoint(playerid,440.4654,-2063.3464,10.2512,4.0);
		SendClientMessage(playerid, COLOR_GRAD2, "You'll need to be in a Shamal and at Vice City Airport to do this job!");
		return 1;
	}
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 519)
	{
		DeliveryManJob[playerid] = 1;
		SetPlayerCheckpoint(playerid, -2637.9346,982.6188,11.9992, 10);
		SendClientMessage(playerid, COLOR_GRAD2, "Head to the Liberty City Airport");
		return 1;
	}
}

public OnPlayerConnect(playerid)
{
    DeliveryManJob[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    DeliveryManJob[playerid] = 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
    DeliveryManJob[playerid] = 0;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	DeliveryManJob[playerid] = 0;
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 519)
	{
	    if(DeliveryManJob[playerid] == 1)
	    {
	        GivePlayerCash(playerid, 50000);
	        SCM(playerid, -1, "You have recieved $50,000 after landing into Liberty City Airport.");
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
		if(DeliveryManJob[playerid] == 1)
		{
			DeliveryManJob[playerid] = 0;
   			DisablePlayerCheckpoint(playerid);
		}
}

stock GivePlayerCash(playerid, money)
{
	SetPVarInt(playerid, "Cash", GetPVarInt(playerid, "Cash")+money);
	GivePlayerMoney(playerid, money);
	return 1;
}
