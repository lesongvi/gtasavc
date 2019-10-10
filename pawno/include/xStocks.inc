// Use Full Functions, by XtremeR

#include <a_samp>

stock GiveHealth(playerid,Float:Health)
{
new Float:health; GetPlayerHealth(playerid,health);
SetPlayerHealth(playerid,health+Health);
}

stock TakeHealth(playerid, Float:Health)
{
	new Float:hp;
	GetPlayerHealth(playerid, hp);
	new calc = floatsub(hp, Health);
	SetPlayerHealth(playerid, calc);
	return 1;
}

stock GivePlayerArmour(playerid,Float:Armour)
{
new Float:armour; GetPlayerHealth(playerid,armour);
SetPlayerArmour(playerid,armour+Armour);
}

stock Slap(playerid)
{
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2] );
	SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]+10);
	return 1;
}

stock Explode(playerid)
{
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2] );
	CreateExplosion(Pos[0], Pos[1], Pos[2], 8, 5.0);
	return 1;
}

stock TakeArmour(playerid, Float:Armour)
{
	new Float:ar;
	GetPlayerArmour(playerid, ar);
	new calc = floatsub(ar, Armour);
	SetPlayerArmour(playerid, calc);
	return 1;
}
stock GivePlayerScore(playerid,Float:Score)
{
    SetPlayerScore(playerid,GetPlayerScore(playerid)+Score);
}

stock IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
    new Float:X, Float:Y, Float:Z;

    GetPlayerPos(playerid, X, Y, Z);
    if(X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) {
        return 1;
    }
    return 0;
}

stock GetVehicleSpeed(vehicleid)
{
        if(vehicleid != INVALID_VEHICLE_ID)
        {
                new Float:Pos[3],Float:VS ;
                GetVehicleVelocity(vehicleid, Pos[0], Pos[1], Pos[2]);
                VS = floatsqroot(Pos[0]*Pos[0] + Pos[1]*Pos[1] + Pos[2]*Pos[2])*200;
                return floatround(VS,floatround_round);
        }
        return INVALID_VEHICLE_ID;
}

stock GetPlayerSpeed(playerid)
{
        if(playerid != INVALID_PLAYER_ID)
        {
                new Float:Pos[3],Float:PS;
                GetPlayerVelocity(playerid, Pos[0], Pos[1], Pos[2]);
                PS = floatsqroot(Pos[0]*Pos[0] + Pos[1]*Pos[1] + Pos[2]*Pos[2])*200;
                return floatround(PS,floatround_round);
        }
        return INVALID_PLAYER_ID;
}

stock IsPlayerInWater(playerid)
    {
    new Float:x,Float:y,Float:pz;
    GetPlayerPos(playerid,x,y,pz);
    if ((IsPlayerInArea(playerid, 2032.1371, 1841.2656, 1703.1653, 1467.1099) && pz <= 9.0484)
    || (IsPlayerInArea(playerid, 2109.0725, 2065.8232, 1962.5355, 10.8547) && pz <= 10.0792)
    || (IsPlayerInArea(playerid, -492.5810, -1424.7122, 2836.8284, 2001.8235) && pz <= 41.06)
    || (IsPlayerInArea(playerid, -2675.1492, -2762.1792, -413.3973, -514.3894) && pz <= 4.24)
    || (IsPlayerInArea(playerid, -453.9256, -825.7167, -1869.9600, -2072.8215) && pz <= 5.72)
    || (IsPlayerInArea(playerid, 1281.0251, 1202.2368, -2346.7451, -2414.4492) && pz <= 9.3145)
    || (IsPlayerInArea(playerid, 2012.6154, 1928.9028, -1178.6207, -1221.4043) && pz <= 18.45)
    || (IsPlayerInArea(playerid, 2326.4858, 2295.7471, -1400.2797, -1431.1266) && pz <= 22.615)
    || (IsPlayerInArea(playerid, 2550.0454, 2513.7588, 1583.3751, 1553.0753) && pz <= 9.4171)
    || (IsPlayerInArea(playerid, 1102.3634, 1087.3705, -663.1653, -682.5446) && pz <= 112.45)
    || (IsPlayerInArea(playerid, 1287.7906, 1270.4369, -801.3882, -810.0527) && pz <= 87.123)
    || (pz < 1.5)
    )
    {
    return 1;
    }
    return 0;
    }
    
stock IsPlayerSkydiving(playerid)
{
    new index = GetPlayerAnimationIndex(playerid)
    return (index >= 958 && index <= 962);
}

stock IsPlayerUsingParachute(playerid)
{
    new index = GetPlayerAnimationIndex(playerid)
    return (index >= 963 && index <= 979);
}
stock IsPlayerAiming(playerid)
{
    new anim = GetPlayerAnimationIndex(playerid);
    switch(anim)
    {
        case 1167, 1365, 1643, 1453, 220: return true;
    }
    return false;
}
stock GetWeather(weatherid)
{
	new wName[80];
	switch(weatherid)
	{
	    case 0..7: wName = "Clear skies";
	    case 8: wName = "Stormy";
	    case 9: wName = "Cloudy";
	    case 10: wName = "Clear skies";
	    case 11: wName = "Heatwave";
	    case 12..15: wName = "Cloudy/Clear";
	    case 16: wName = "Cloudy/Rainy";
	    case 17, 18: wName = "Heatwave";
	    case 19: wName = "Sandstorm";
	    case 20: wName = "Foggy/Greenish";
	    case 21,22: wName = "Dark clouds";
	    case 23..26: wName = "Heatwave";
	    case 27..29: wName = "Clear skies";
	    case 30: wName = "Cloudy";
		case default: wName = "Unknown";
	}
	return wName;
}
stock HealAll()
{
	for(new i; i < MAX_PLAYERS; i++) SetPlayerHealth(i, 100);
	return 1;
}

stock ArmourAll()
{
	for(new i; i < MAX_PLAYERS; i++) SetPlayerArmour(playerid, 100);
	return 1;
}

stock GiveAllCash(cash)
{
	for(new i; i < MAX_PLAYERS; i++) GivePlayerMoney(i, cash);
	return 1;
}

stock GiveAllScore(score)
{
	for(new i; i < MAX_PLAYERS; i++) GivePlayerMoney(i, score);
	return 1;
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name) );
	return name;
}

stock FreezeAll()
{
	for(new i; i < MAX_PLAYERS; i++) TogglePlayerControllable(i, false);
	return 1;
}

stock DisarmAll()
{
	for(new i; i < MAX_PLAYERS; i++) ResetPlayerWeapons(i);
	return 1;
}

stock UnfreezeAll()
{
	for(new i; i < MAX_PLAYERS; i++) TogglePlayerControllable(i, true);
	return 1;
}


stock GetAmmo(playerid)
{
	new weapon[3];
	weapon[0] = GetWeaponSlot(GetPlayerWeapon(playerid) );
	GetPlayerWeaponData(playerid, weapon[0], weapon[1], weapon[2]);
	return weapon[2];
}


stock SendMessageToAdmins(color,const msg[])
{
   for (new i=0; i<MAX_PLAYERS; i++)
   {
      if (IsPlayerConnected(i) && IsPlayerAdmin(i)) SendClientMessage(i,color,msg);
   }
}
