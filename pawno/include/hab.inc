/*  hab.inc
 *
 *  (c) Copyright 2012, Emilijo "Correlli" Lovrich
 *
 *  Credits: - Y_Less for foreach & GetBalloonXYInFrontOfPlayer functions,
			 - ZeeX for zcmd command processor.
*/

#if defined _hab_included
	#endinput
#endif
#define _hab_included

#if !defined _samp_included
	#error "You'll need to include the a_samp.inc include file before the hab.inc file!"
#endif

/* ----- */

#if !defined MAX_HOT_AIR_BALLOONS
	#define MAX_HOT_AIR_BALLOONS (6)
#endif

#if !defined MAX_HOT_AIR_BALLOON_SPEED
	#define MAX_HOT_AIR_BALLOON_SPEED (10.0)
#endif

#if !defined INVALID_HOT_AIR_BALLOON_ID
	#define INVALID_HOT_AIR_BALLOON_ID (-1)
#endif

/* ----- */

static
		bool:gOPF[3] = false;

/* ----- */

enum dataBalloon
{
	modelID,
	objectID,
	Float:speed,
	Float:position[8]
}

new
		balloonID = INVALID_HOT_AIR_BALLOON_ID, balloonData[MAX_HOT_AIR_BALLOONS][dataBalloon],
		Float:balloonGoTo[MAX_HOT_AIR_BALLOONS][3], bool:firstBalloon = false, habTimer;

/* ----- */

stock CreateHotAirBalloon(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz = 0.0)
{
	balloonID++;
	if(balloonID == MAX_HOT_AIR_BALLOONS)
	{
		printf("Limit of hot air balloons exceeded. Open the hab.inc and change the \"MAX_HOT_AIR_BALLOONS\" define to bigger value if you want to have more hot air balloons.\
				\nDon't forget that object limit in the current SA:MP version (0.3e) is 1000, so it's a good thing to use an object-streamer if you're having many hot air balloons on server.");
		balloonID--;
		return INVALID_HOT_AIR_BALLOON_ID;
	}
	new
			toBalloonID = GetFreeHotAirBalloonID();
	if(toBalloonID == INVALID_HOT_AIR_BALLOON_ID)
	{
		print("Error: There are no hot air balloon IDs free.");
		balloonID--;
		return INVALID_HOT_AIR_BALLOON_ID;
	}
	if(modelid < 1 || modelid > 7)
	{
		printf("Invalid model-ID at function \"CreateHotAirBalloon\". Valid model-IDs are from 1 to 7.");
		balloonID--;
		return INVALID_HOT_AIR_BALLOON_ID;
	}
	balloonData[toBalloonID][modelID] = modelid;
	balloonData[toBalloonID][position][0] = x;
	balloonData[toBalloonID][position][1] = y;
	balloonData[toBalloonID][position][2] = z;
	balloonData[toBalloonID][position][3] = rx;
	balloonData[toBalloonID][position][4] = ry;
	balloonData[toBalloonID][position][5] = rz;
	balloonData[toBalloonID][position][6] = z;
	balloonData[toBalloonID][position][7] = rz;
	balloonData[toBalloonID][speed] = 0.0;
	balloonData[toBalloonID][objectID] = CreateObject(19331 + modelid, x, y, z, rx, ry, rz);
	if(!firstBalloon)
	{
		firstBalloon = true;
		habTimer = SetTimer("hab_Timer", 1800000, true);
	}
	return toBalloonID;
}

stock DestroyHotAirBalloon(habid)
{
	if(IsHotAirBalloonCreated(habid))
	{
		balloonID--;
		balloonData[habid][modelID] = 0;
		balloonData[habid][position][0] = 0.0;
		balloonData[habid][position][1] = 0.0;
		balloonData[habid][position][2] = 0.0;
		balloonData[habid][position][3] = 0.0;
		balloonData[habid][position][4] = 0.0;
		balloonData[habid][position][5] = 0.0;
		balloonData[habid][position][6] = 0.0;
		balloonData[habid][position][7] = 0.0;
		balloonData[habid][speed] = 0.0;
		DestroyObject(balloonData[habid][objectID]);
		if(balloonID == INVALID_HOT_AIR_BALLOON_ID)
		{
			firstBalloon = false;
			KillTimer(habTimer);
		}
		foreach(Player, u)
		{
			if((GetPVarInt(u, "balloonID") - 1) == habid)
			{
				SetPVarInt(u, "balloonID", 0);
				ClearAnimations(u);
				SendClientMessage(u, 0xFFFFFFFF, "Flying with hot air balloon stopped - hot air balloon was deleted by the script.");
				SetPlayerPosFindZ(u, GetPlayerPosX(u), GetPlayerPosY(u), GetPlayerPosZ(u));
				break;
			}
		}
		return true;
	}
	return false;
}

stock IsHotAirBalloonCreated(habid)
{
	if(balloonData[habid][modelID]) return true;
	return false;
}

stock GetNumberOfHotAirBalloons() return balloonID;

stock GetFreeHotAirBalloonID()
{
	new
			habid = INVALID_HOT_AIR_BALLOON_ID;
	for(new a = 0; a < MAX_HOT_AIR_BALLOONS; a++)
	{
		if(!IsHotAirBalloonCreated(a))
		{
			habid = a;
			break;
		}
	}
	return habid;
}

stock StopHotAirBalloon(habid)
{
	if(!IsHotAirBalloonCreated(habid)) return false;
	balloonData[habid][speed] = 0.0;
	StopObject(balloonData[habid][objectID]);
	return true;
}

stock RespawnHotAirBalloon(habid)
{
	if(!IsHotAirBalloonCreated(habid)) return false;
	DestroyObject(balloonData[habid][objectID]);
	balloonData[habid][position][2] = balloonData[habid][position][6];
	balloonData[habid][position][5] = balloonData[habid][position][7];
	balloonData[habid][objectID] = CreateObject(19331 + balloonData[habid][modelID], balloonData[habid][position][0], balloonData[habid][position][1], balloonData[habid][position][2], balloonData[habid][position][3], balloonData[habid][position][4], balloonData[habid][position][5]);
	return true;
}

stock SetHotAirBalloonSpeed(habid, Float:balloonspeed = MAX_HOT_AIR_BALLOON_SPEED)
{
	if(!IsHotAirBalloonCreated(habid)) return false;
	if(balloonspeed > MAX_HOT_AIR_BALLOON_SPEED) balloonData[habid][speed] = MAX_HOT_AIR_BALLOON_SPEED;
	else balloonData[habid][speed] = balloonspeed;
	return true;
}

stock IsPlayerAtHotAirBalloon(playerid, habid)
{
	new
			Float:pos[3];
	GetObjectPos(balloonData[habid][objectID], pos[0], pos[1], pos[2]);
	if(IsPlayerInRangeOfPoint(playerid, 1.5, pos[0], pos[1], pos[2])) return true;
	return false;
}

stock IsPlayerAtAnyHotAirBalloon(playerid)
{
	new
			a = 0;
	for(a = 0; a < MAX_HOT_AIR_BALLOONS; a++)
	{
		if(IsPlayerAtHotAirBalloon(playerid, a)) return a;
	}
	return INVALID_HOT_AIR_BALLOON_ID;
}

stock IsHotAirBalloonOccupied(habid)
{
	if(!IsHotAirBalloonCreated(habid)) return INVALID_PLAYER_ID;
	foreach(Player, u)
	{
		if((GetPVarInt(u, "balloonID") - 1) == habid) return u;
	}
	return INVALID_PLAYER_ID;
}

/* ----- */

stock GetBalloonXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new
			Float:angle;
	GetPlayerPos(playerid, x, y, angle);
	GetPlayerFacingAngle(playerid, angle);
	x += (distance * floatsin(-angle, degrees));
	y += (distance * floatcos(-angle, degrees));
}

forward Float:GetPlayerPosX(playerid);
Float:GetPlayerPosX(playerid)
{
	new
			Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	return Float:pos[0];
}

forward Float:GetPlayerPosY(playerid);
Float:GetPlayerPosY(playerid)
{
	new
			Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	return Float:pos[1];
}

forward Float:GetPlayerPosZ(playerid);
Float:GetPlayerPosZ(playerid)
{
	new
			Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	return Float:pos[2];
}

/* ----- */

forward hab_Timer();
public hab_Timer()
{
	foreach(Player, u)
	{
		new
				habid = GetPVarInt(u, "balloonID") - 1;
		if(habid != INVALID_HOT_AIR_BALLOON_ID)
		{
			if(!IsPlayerAtHotAirBalloon(u, habid))
			{
				StopHotAirBalloon(habid);
				RespawnHotAirBalloon(habid);
				SetPVarInt(u, "balloonID", 0);
				ClearAnimations(u);
				SendClientMessage(u, 0xFFFFFFFF, "Flying with hot air balloon stopped - hot air balloon is re-spawned.");
				SetPlayerPosFindZ(u, GetPlayerPosX(u), GetPlayerPosY(u), GetPlayerPosZ(u));
			}
		}
	}
	return true;
}

/* ----- */

command(balloon, playerid, params[])
{
	new
			Float:objPos[3];
	if(!GetPVarInt(playerid, "balloonID"))
	{
		new
				habid = IsPlayerAtAnyHotAirBalloon(playerid);
		if(habid != INVALID_HOT_AIR_BALLOON_ID)
		{
			new
					isOccupied = IsHotAirBalloonOccupied(habid);
			if(isOccupied != INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFFFFFFFF, "(balloon) Someone is already flying on this hot air balloon!");
			SetPVarInt(playerid, "balloonID", habid + 1);
			GetObjectPos(balloonData[habid][objectID], objPos[0], objPos[1], objPos[2]);
			SetPlayerPos(playerid, objPos[0], objPos[1], objPos[2] + 1.0);
			SetPlayerFacingAngle(playerid, balloonData[habid][position][5]);
			ApplyAnimation(playerid, "ped", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0);
			SendClientMessage(playerid, 0xFFFFFFFF, "Flying started. Use \"/balloon\" command to stop with the flying.");
		}
		else SendClientMessage(playerid, 0xFFFFFFFF, "You're not near any hot air balloon or you're not close enough to it.");
	}
	else
	{
		StopHotAirBalloon(GetPVarInt(playerid, "balloonID") - 1);
		SetPVarInt(playerid, "balloonID", 0);
		ClearAnimations(playerid);
		SendClientMessage(playerid, 0xFFFFFFFF, "Flying stopped. Use \"/balloon\" command to start with the flying again.");
	}
	return true;
}

/* ----- */

public OnPlayerConnect(playerid)
{
	ApplyAnimation(playerid, "ped", "null", 0.0, 0, 0, 0, 0, 0);

	if(gOPF[0]) CallLocalFunction("hab_OnPlayerConnect", "i", playerid);
	return true;
}

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect hab_OnPlayerConnect

forward hab_OnPlayerConnect(playerid);



public OnPlayerDisconnect(playerid, reason)
{
	new
			habid = GetPVarInt(playerid, "balloonID") - 1;
	if(habid != INVALID_HOT_AIR_BALLOON_ID)
	{
		StopHotAirBalloon(habid);
		RespawnHotAirBalloon(habid);
	}

	if(gOPF[1]) CallLocalFunction("hab_OnPlayerDisconnect", "ii", playerid, reason);
	return true;
}

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect hab_OnPlayerDisconnect

forward hab_OnPlayerDisconnect(playerid, reason);



public OnPlayerUpdate(playerid)
{
	new
			habid = GetPVarInt(playerid, "balloonID") - 1;
	if(habid != INVALID_HOT_AIR_BALLOON_ID)
	{
		new
				keys[3], Float:floatVal[4];
		GetPlayerPos(playerid, floatVal[0], floatVal[1], floatVal[2]);
		floatVal[3] = balloonData[habid][speed];
		GetPlayerKeys(playerid, keys[0], keys[1], keys[2]);
		GetBalloonXYInFrontOfPlayer(playerid, floatVal[0], floatVal[1], 50.0);
		balloonGoTo[habid][0] = floatVal[0];
		balloonGoTo[habid][1] = floatVal[1];
		balloonGoTo[habid][2] = balloonData[habid][position][2];
		if(keys[0] == KEY_YES)
		{
			if(balloonData[habid][position][2] < 700.0) balloonData[habid][position][2] += 0.3;
			else balloonData[habid][position][2] = 700.0;
		}
		else if(keys[0] == KEY_NO)
		{
			if(balloonData[habid][position][2] > 2.0) balloonData[habid][position][2] -= 0.3;
			else balloonData[habid][position][2] = 2.0;
		}
		if(keys[1] == KEY_UP)
		{
			if(floatVal[3] >= 0.0 && floatVal[3] < MAX_HOT_AIR_BALLOON_SPEED) balloonData[habid][speed] += 0.2;
			if(floatVal[3] >= MAX_HOT_AIR_BALLOON_SPEED) balloonData[habid][speed] = MAX_HOT_AIR_BALLOON_SPEED;
		}
		else if(keys[1] == KEY_DOWN)
		{
			if(floatVal[3] >= 0.0 && floatVal[3] < MAX_HOT_AIR_BALLOON_SPEED) balloonData[habid][speed] -= 0.2;
			if(floatVal[3] >= MAX_HOT_AIR_BALLOON_SPEED) balloonData[habid][speed] = MAX_HOT_AIR_BALLOON_SPEED;
		}
		if(keys[2] == KEY_LEFT)
		{
			balloonData[habid][speed] -= 0.01;
			balloonData[habid][position][5] += 1.5;
			SetObjectRot(balloonData[habid][objectID], balloonData[habid][position][3], balloonData[habid][position][4], balloonData[habid][position][5]);
			SetPlayerFacingAngle(playerid, balloonData[habid][position][5]);
			balloonGoTo[habid][0] = floatVal[0];
			balloonGoTo[habid][1] = floatVal[1];
			balloonGoTo[habid][2] = balloonData[habid][position][2];
		}
		else if(keys[2] == KEY_RIGHT)
		{
			balloonData[habid][speed] -= 0.01;
			balloonData[habid][position][5] -= 1.5;
			SetObjectRot(balloonData[habid][objectID], balloonData[habid][position][3], balloonData[habid][position][4], balloonData[habid][position][5]);
			SetPlayerFacingAngle(playerid, balloonData[habid][position][5]);
			balloonGoTo[habid][0] = floatVal[0];
			balloonGoTo[habid][1] = floatVal[1];
			balloonGoTo[habid][2] = balloonData[habid][position][2];
		}
		if(balloonData[habid][speed] > 0.1)
		{
			balloonData[habid][speed] -= 0.1;
			MoveObject(balloonData[habid][objectID], balloonGoTo[habid][0], balloonGoTo[habid][1], balloonGoTo[habid][2], balloonData[habid][speed]);
		}
		else StopHotAirBalloon(habid);
		new
				string[72];
		format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Speed: ~w~%0.1f ~r~/ ~w~%0.1f", balloonData[habid][speed], MAX_HOT_AIR_BALLOON_SPEED);
		GameTextForPlayer(playerid, string, 1000, 3);
	}

	if(gOPF[2]) CallLocalFunction("hab_OnPlayerUpdate", "i", playerid);
	return true;
}

#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate hab_OnPlayerUpdate

forward hab_OnPlayerUpdate(playerid);



public OnGameModeInit()
{
	gOPF[0] = (funcidx("hab_OnPlayerConnect") != -1);
	gOPF[1] = (funcidx("hab_OnPlayerDisconnect") != -1);
	gOPF[2] = (funcidx("hab_OnPlayerUpdate") != -1);
	CallLocalFunction("hab_OnGameModeInit", "");
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit hab_OnGameModeInit

forward hab_OnGameModeInit();
