//////////////////////////////////////////////////////////////////////////////////////////
// 						                                                            	//
// 				               trablon's Muscle System(for RPG servers)          		//
//                             Coder: trablon(Onur AKAN) 		            			//
//                             				                        					//
// 					           															//
//   														  							//
//                                                       								//
//                                                                                    	//
/////////////////////////////////////////////////////////////////////////////////////////
/*

Player Variables for your gamemode:

GymDaily - integer
GymPoint - integer
MuscleLevel - integer
GymOneDay - integer

*/
// =========== [ include ] ============== //
#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI\y_ini>
// =========== [ define ] ============== //
#define FILTERSCRIPT
// =========== [ forward ] ============== //
forward GYM(playerid);
// =========== [ pragma ] ============== //
// =========== [ enum ] ============== //
enum PDATA
{
	GymPoint,
 	MuscleLevel
}
// =========== [ new ] ============== //
new pInfo[MAX_PLAYERS][PDATA];
new
	lsbarbell,
	sfbarbell,
	lvbarbell,
	lvbarbell2,
	IsEquipmentUsed[11],
	GymButton[MAX_PLAYERS],
	GymLoop[MAX_PLAYERS],
	GymPointvariable[MAX_PLAYERS],
	GymPointX[MAX_PLAYERS],
	GymTimer[MAX_PLAYERS],
	MyEquipment[MAX_PLAYERS],
	Float:Body[MAX_PLAYERS]
;
// ============================================================= //
#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
   	lsbarbell = CreateObject(1833, 774.4290, 1.883098, 1000.4883, 0, 270.0, 88.000,150); // Los Santos Gym's BarBell
	sfbarbell = CreateObject(1833, 765.8552, -48.8685, 1000.6409, 0, 89.50, 0.0000,150); // San Fierro Gym's BarBell.
	lvbarbell = CreateObject(1833, 765.3403, -59.1827, 1000.6379, 0, 89.50, 181.25,150); // Las Venturas Gym's BarBell
	lvbarbell2 = CreateObject(1833, 768.080, -59.0295, 1000.6379, 0, 90.0, 0, 150); // Las Venturas Gym's BarBell 2
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else
#endif

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	new Float:Health, Float:Armor;
	if(issuerid != INVALID_PLAYER_ID)
{
	if(GetPlayerWeapon(issuerid) == 0)
{
    new gympuan = pInfo[playerid][GymPoint];
	if(gympuan >= 10)
	{
		GetPlayerHealth(playerid,Health); GetPlayerArmour(playerid,Armor);
		SetPlayerHealth(playerid, Health-20);
	}
	if(gympuan >= 20)
	{
		GetPlayerHealth(playerid,Health); GetPlayerArmour(playerid,Armor);
		SetPlayerHealth(playerid, Health-40);
	}
}

}
	return 1;
}

public OnPlayerSpawn(playerid)
{

	return 1;
}
public OnPlayerConnect(playerid)
{
	GymButton[playerid] = 0; GymLoop[playerid] = 0; GymPointvariable[playerid] = 0; GymPointX[playerid] = 0;
	INI_ParseFile( user_ini_file( playerid ), "load_user_%s", .bExtra = true, .extra = playerid );
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(GymTimer[playerid]);
    new INI:File = INI_Open(user_ini_file(playerid));
    INI_SetTag(File, "GYM" );
    INI_WriteString(File,"Name",GetPlayerNamee(playerid));
	INI_WriteInt(File,"GymPoint",pInfo[playerid][GymPoint]);
	INI_WriteInt(File,"MuscleLevel",pInfo[playerid][MuscleLevel]);
    INI_Close(File);
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys == KEY_SECONDARY_ATTACK)
{
			if(Equipments(playerid) != 0)
{
		    if(MyEquipment[playerid] != 0)
{
			FinishGym(playerid);
			return 1;
}
			if(IsEquipmentUsed[Equipments(playerid)] == 1 && GymLoop[playerid] == 0)
{
			SendClientMessage(playerid,0xFF6347AA, "* This equipment is being used by another player.");
			return 1;
}
			if(GymLoop[playerid] != 0)
{
			FinishGym(playerid);
			return 1;
}
			MyEquipment[playerid] = Equipments(playerid);
			IsEquipmentUsed[MyEquipment[playerid]] = 1;
		    SendtoEquipment(playerid, MyEquipment[playerid], 1);
		    switch(MyEquipment[playerid])
			{
			    case 1 .. 3: { ApplyAnimation(playerid,"GYMNASIUM","gym_bike_geton",4.0,1,0,0,1,0,1); }
	            case 4 .. 6: { ApplyAnimation(playerid,"GYMNASIUM","gym_tread_geton",4.0,1,0,0,1,0,1); }
     			case 7 .. 10:{ ApplyAnimation(playerid,"benchpress","gym_bp_geton",4.0,1,0,0,1,0,1); }
			}
			GymButton[playerid] = random(4)+1;
			KillTimer(GymTimer[playerid]);
			GymTimer[playerid] = SetTimerEx("GYM", 2000, true, "i", playerid);
}
}
	return 1;
}

public GYM(playerid)
{
    if(GymLoop[playerid] > 30) { FinishGym(playerid); return 1; }
    new tus = random(4)+1; while(tus == GymButton[playerid]) { tus = random(4)+1; }
	SendtoEquipment(playerid, MyEquipment[playerid], 0);
	new Keys,ud,lr;
    GetPlayerKeys(playerid,Keys,ud,lr);
	switch(MyEquipment[playerid])
	{
    	case 7: { if(IsValidObject(lsbarbell)) { DestroyObject(lsbarbell); SetPlayerAttachedObject(playerid, 0, 1833, 6); } }
    	case 8: { if(IsValidObject(sfbarbell)) { DestroyObject(sfbarbell); SetPlayerAttachedObject(playerid, 0, 1833, 6); } }
    	case 9: { if(IsValidObject(lvbarbell)) { DestroyObject(lvbarbell); SetPlayerAttachedObject(playerid, 0, 1833, 6); } }
    	case 10:{ if(IsValidObject(lvbarbell2)){ DestroyObject(lvbarbell2); SetPlayerAttachedObject(playerid, 0, 1833, 6);} }
    }
	if((ud < 0 && GymButton[playerid] == 1 && lr == 0) || (ud > 0 && GymButton[playerid] == 2 && lr == 0) || (ud == 0 && GymButton[playerid] == 3 && lr < 0) || (ud == 0 && GymButton[playerid] == 4 && lr > 0))
	{
	    GymPointvariable[playerid] += 1; GymPointX[playerid] += 1;
	    switch(MyEquipment[playerid])
	    {
			case 1 .. 3: { if(GymPointX[playerid] < 10) { ApplyAnimation(playerid,"GYMNASIUM","gym_bike_slow",4.0,1,0,0,1,0,1); } else { ApplyAnimation(playerid,"GYMNASIUM","gym_bike_fast",4.0,1,0,0,1,0,1); } }
			case 4 .. 6: { if(GymPointX[playerid] < 10) { ApplyAnimation(playerid,"GYMNASIUM","gym_tread_sprint",4.0,1,0,0,1,0,1); } else { ApplyAnimation(playerid,"GYMNASIUM","gym_tread_sprint",4.0,1,0,0,1,0,1); } }
			case 7 .. 10:{ if(GymPointX[playerid] < 10) { ApplyAnimation(playerid,"benchpress","gym_bp_up_A",2.0,1,0,0,1,2000,1); } else { ApplyAnimation(playerid,"benchpress","gym_bp_up_smooth",4.0,1,0,0,1,2000,1); } }
	    }
	}
	else
	{
	    GymPointvariable[playerid] += 1; GymPointX[playerid] += 1;
	    switch(MyEquipment[playerid])
	    {
			case 1 .. 3: { ApplyAnimation(playerid,"GYMNASIUM","gym_bike_still",4.0,1,0,0,1,0,1); }
			case 4 .. 6: { ApplyAnimation(playerid,"GYMNASIUM","gym_tread_walk",4.0,1,0,0,1,0,1); }
			case 7 .. 10: { ApplyAnimation(playerid,"benchpress","gym_bp_up_B",2.0,1,0,0,1,2000,1);}
	    }
	}
	GymLoop[playerid] += 1; GymButton[playerid] = tus; return 1;
}
// ============================================================= //
//==================== [ zcmd ] =========================//
//==================== [ stock ] =========================//
stock FinishGym(playerid)
{
    new string[36];
    if(GymPointvariable[playerid] == 0) { format(string, sizeof(string), "Sorry, you could not get any point, you must work hard.", GymPointvariable[playerid]); }
    KillTimer(GymTimer[playerid]);
    switch(MyEquipment[playerid])
    {
		case 1 .. 3: { ApplyAnimation(playerid,"GYMNASIUM","gym_bike_getoff",4.0,0,0,0,0,0,0); }
		case 4 .. 6: { ApplyAnimation(playerid,"GYMNASIUM","gym_tread_getoff",4.0,0,0,0,0,0,0); }
		case 7 .. 10:
		{
			ApplyAnimation(playerid,"benchpress","gym_bp_getoff",4.0,0,0,0,0,0,0);
			RemovePlayerAttachedObject(playerid, 0); SetCameraBehindPlayer(playerid);
		}
	}
	switch(MyEquipment[playerid])
	{
		case 7:
{
		if(IsValidObject(lsbarbell))
{
		DestroyObject(lsbarbell);
}
		lsbarbell = CreateObject(1833, 774.4290, 1.883098, 1000.4883, 0, 270.0, 88.000,150);
}
		case 8:
{
		if(IsValidObject(sfbarbell))
{
		DestroyObject(sfbarbell);
}
		sfbarbell = CreateObject(1833, 765.8552, -48.8685, 1000.6409, 0, 89.50, 0.0000,150);
}
   		case 9:
{
		if(IsValidObject(lvbarbell))
{
		DestroyObject(lvbarbell);
}
		lvbarbell = CreateObject(1833, 765.3403, -59.1827, 1000.6379, 0, 89.50, 181.25,150);
}
   		case 10:
{
		if(IsValidObject(lvbarbell2))
{
		DestroyObject(lvbarbell2);
}
		lvbarbell2 = CreateObject(1833, 768.080, -59.0295, 1000.6379, 0, 90.0, 0, 150);
}
}

 	pInfo[playerid][GymPoint] = pInfo[playerid][GymPoint]+GymPointvariable[playerid];
    GymButton[playerid] = 0; GymLoop[playerid] = 0; GymPointvariable[playerid] = 0; GymPointX[playerid] = 0;
    IsEquipmentUsed[MyEquipment[playerid]] = 0; MyEquipment[playerid] = 0; return 1;
}


stock Equipments(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 772.5529, 9.423600, 1000.7247) && GetPlayerInterior(playerid) == 5) { return 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 769.6011, -47.9109, 1000.5859) && GetPlayerInterior(playerid) == 6) { return 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 775.0284, -68.6539, 1000.6563) && GetPlayerInterior(playerid) == 7) { return 3; }
 	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 773.4804, -2.36510, 1000.7247) && GetPlayerInterior(playerid) == 5) { return 4; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 759.5977, -47.8843, 1000.5859) && GetPlayerInterior(playerid) == 6) { return 5; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 758.3638, -65.3969, 1000.6563) && GetPlayerInterior(playerid) == 7) { return 6; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 773.8289, 1.403700, 1000.7247) && GetPlayerInterior(playerid) == 5) { return 7; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 766.2886, -48.1480, 1000.5859) && GetPlayerInterior(playerid) == 6) { return 8; }
	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 764.8702, -59.6601, 1000.6563) && GetPlayerInterior(playerid) == 7) { return 9; }
 	else if(IsPlayerInRangeOfPoint(playerid, 1.5, 768.5298, -59.6601, 1000.6563) && GetPlayerInterior(playerid) == 7) { return 10; }
	return 0;
}

stock SendtoEquipment(playerid, alet, mod) // Set Anims pos.
{
	new Float:aX, Float:aY, Float:aZ, Float:aA, Float:pA;
    switch(alet)
    {
    	case 1: { aX = 772.6419; aY = 8.891200; aZ = 1000.7067; aA = 90; }
    	case 2: { aX = 769.6946; aY = -48.4113; aZ = 1000.6559; aA = 90; }
    	case 3: { aX = 775.1604; aY = -69.1313; aZ = 1000.6539; aA = 90; }
    	case 4: { aX = 773.4711; aY = -1.19060; aZ = 1000.7262; aA = 180; }//
   		case 5: { aX = 759.6171; aY = -46.7707; aZ = 1000.5859; aA = 180; }
    	case 6: { aX = 758.3710; aY = -64.0923; aZ = 1000.6528; aA = 180; }
		case 7: { aX = 772.9553; aY = 1.461400; aZ = 1000.7209; aA = 270; }//
    	case 8: { aX = 766.3169; aY = -47.3577; aZ = 1000.5859; aA = 180; }
    	case 9: { aX = 764.8354; aY = -60.5658; aZ = 1000.6563; aA = 0; }
    	case 10:{ aX = 768.5437; aY = -60.4008; aZ = 1000.6563; aA = 0; }
	}
	if(mod == 1) { SetPlayerPos(playerid, aX, aY, aZ); SetPlayerFacingAngle(playerid, aA); }
	else
	{
		if(!IsPlayerInRangeOfPoint(playerid, 1.5, aX, aY, aZ)) { SetPlayerPos(playerid, aX, aY, aZ); }
		GetPlayerFacingAngle(playerid, pA); if(pA != aA) { SetPlayerFacingAngle(playerid, aA); }
	}
}

stock user_ini_file(playerid)
{
    new
		string[ 128 ],
		user_name[ MAX_PLAYER_NAME ]
	;

    GetPlayerName( playerid, user_name, MAX_PLAYER_NAME );
    format( string, sizeof ( string ), "gym/%s.ini", user_name );
    return
		string;
}

stock GetPlayerNamee(playerid)
{
      new name[MAX_PLAYER_NAME];
      GetPlayerName(playerid, name, MAX_PLAYER_NAME);
      return name;
}
// =========== [ END ] ============== //
