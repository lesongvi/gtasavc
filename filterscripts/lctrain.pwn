//------------------------------------------------------------------------------
//NPC SCRIPT MADY BY FLAKE AND REDIRECT_LEFT V1CEC1TY
//
/*
there are < 40 > NPC's in total
one Command /party to join the NPC party in los santos

A special thanks to Redirect_left for helping with the 3DTextLabel's also to Madruga
for suplying the UFO and those NPC;s
Also helped V1ceC1ty for the dancing NPC's
This is Version 4.5
//------------------------------------------------------------------------------
//==============================================================================
*/
#include <a_samp>
#include <a_npc>

#define COLOR_GREEN 0x33AA33AA
//so Far there are 68 NPC's


new LCTrain;
new VCBus2;
new VCBus;
new Ashley_Smith;

public OnGameModeInit()
{
//--this lets the NPC's connect to your server
	ConnectNPC("LCTrain","LCTrain");
	ConnectNPC("VCBus2","VCBus2");
	ConnectNPC("VCBus","VCBus");
	ConnectNPC("adele","adele");
	ConnectNPC("Ashley_Smith","Ashley_Smith");
//---This makes the Npc's spawn--
	LCTrain = AddStaticVehicle(449,-438.5647,1334.9385,-20.7643,0.3326,1,1);
	VCBus2 = AddStaticVehicle(431,2161.1042,-2277.5354,4.8325,167.4838,3,3); //
	VCBus = AddStaticVehicle(431,556.9011,-1782.9924,9.1937,264.0602,0,0); //
//------------------------------------------------------------------------------

	print(" NPC mega pack.. Loaded!");
	print("  Made by Memoryz, flake and V1cec1ity"); //Please do not remove this, this is all I ask in return
	return 1;
}



public OnPlayerSpawn(playerid)
{
    SetTimer("subwaylocation", 1000, false);
    if(!IsPlayerNPC(playerid)) return 0;
   	new npcname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, npcname, sizeof(npcname));
	new playername[64];
	GetPlayerName(playerid,playername,64);
	if(!strcmp(playername,"LCTrain",true))
	{
	    SetSpawnInfo( playerid, 0, 255, -438.5647, 1334.9385, -20.7643, 269.15, 0, 0, 0, 0, 0, 0 );
		PutPlayerInVehicle(playerid, LCTrain, 0);
		ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	}
	
	
	if(!strcmp(playername,"VCBus2",true))
	{
	    SetSpawnInfo( playerid, 0, 60, -438.5647, 1334.9385, -20.7643, 269.15, 0, 0, 0, 0, 0, 0 );
		PutPlayerInVehicle(playerid, VCBus2, 0);
		ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	}
	if(!strcmp(playername,"VCBus",true))
	{
	    SetSpawnInfo( playerid, 0, 60, 556.9011, -1782.9924, 9.1937, 269.15, 0, 0, 0, 0, 0, 0 );
		PutPlayerInVehicle(playerid, VCBus, 0);
		ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	}
	if(!strcmp(playername,"Ashley_Smith",true))
 	{
        SetPlayerInterior(playerid, 2);
        ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
        SetPlayerPos(playerid, 1203.4518, 15.9752, 1000.9221);
        SetPlayerSkin(playerid, 246);
	}
	if(!strcmp(playername,"adele",true))
 	{
        ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
        SetPlayerSkin(playerid, 91);
	}
    return 1;
}



public OnPlayerStreamIn(playerid)
{
        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, sizeof(name));
		if(!strcmp(name,"Ashley_Smith",true))
        {
        	if(IsPlayerNPC(playerid))
        	{
        		ApplyAnimation(playerid, "DANCING", "DAN_Loop_A", 4.1, 1, 1, 1, 0, 0, 1);
				return 1;
			}
		}
}

public subwaylocation(playerid)
{
    new string[128];
	if(IsPlayerNPC(playerid))
 	{
  		new npcvehicle = GetPlayerVehicleID(playerid);
    	if(npcvehicle == LCTrain)
     	{
			if(IsPlayerInRangeOfPoint(playerid, 8.0, -438.5105, 1336.1230, -19.9323))
			{
				format(string, sizeof(string), "The train arrived at Red Light District.");
			}
			else if(IsPlayerInRangeOfPoint(playerid, 8.0, -1146.5492, 139.0824, -5.4091))
			{
				format(string, sizeof(string), "The train arrived at Torrington.");
			}
			else if(IsPlayerInRangeOfPoint(playerid, 8.0, -2090.3689, 1024.2916, -12.6546))
			{
				format(string, sizeof(string), "The train arrived at Francis International Airport.");
			}
			else if(IsPlayerInRangeOfPoint(playerid, 8.0, -1116.5187, 1627.9641, -10.8130))
			{
				format(string, sizeof(string), "The train arrived at Francis International Airport.");
			}
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerInRangeOfPoint(i, 8.0, 199.3313, 809.5787, 2503.7085))
 				{
 					SendClientMessage(i, -1, string);
 					SetTimer("subwaylocation", 40000, false);
    			}
  			}
		}
	}
	return 1;
}


////////////////////////////////////////////////////////////////////////////////
//End of the script
