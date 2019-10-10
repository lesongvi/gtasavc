/*-

	OnPlayerPause - Another release by Steve "$teVe" 2011,
	Please leave the credits.
	
	I know, there are other releases, but when i look at them, I think they are to big.
	My version is very small.
	
	Installation:
	Put "OnPlayerPause.inc" to your ServerDirectory/pawno/include folder.
	Open your GAMEMODE and include "OnPlayerPause" in it (#include <OnPlayerPause>).
	Add PAUSE_OnGameModeInit() to your OnGameModeInit() callback.
	Add PAUSE_OnPlayerConnect(playerid) to your PAUSE_OnPlayerConnect(playerid) callback.
	Add PAUSE_OnPlayerDisconnect(playerid, reason) to your PAUSE_OnPlayerDisconnect(playerid, reason) callback.
	Add PAUSE_OnPlayerUpdate(playerid) to your PAUSE_OnPlayerUpdate(playerid) callback.
	
-*/


/*----------: Includes :----------*/
#include <a_samp>

/*----------: Defines :----------*/
#define MAX_AFK_TIME 20000

/*----------: Enums :----------*/
enum e_STATE
{
	e_STATE_UPDATING,
	e_STATE_NONE,
 	e_STATE_CONNECTED
};

/*----------: Veriables :----------*/
new gLastUpdate[MAX_PLAYERS], e_STATE:gState[MAX_PLAYERS] = {e_STATE_NONE, ...};

/*----------: Forwards :-----------*/
forward PAUSE_CheckPlayers();
forward OnPlayerPause(playerid);
forward PAUSE_OnGameModeInit();
forward PAUSE_OnPlayerConnect(playerid);
forward PAUSE_OnPlayerDisconnect(playerid, reason);
forward PAUSE_OnPlayerUpdate(playerid);

/*-----: OnGameModeInit :-----*/
public PAUSE_OnGameModeInit()
{
    SetTimer("CheckPlayers", 1000, 1);
	return 1;
}

/*-----: OnPlayerConnect :-----*/
public PAUSE_OnPlayerConnect(playerid)
{
    gState[playerid] = e_STATE_CONNECTED;
	return 1;
}

/*-----: OnPlayerDisconnect :-----*/
public PAUSE_OnPlayerDisconnect(playerid, reason)
{
	gState[playerid] = e_STATE_NONE;
	return 1;
}

/*-----: OnPlayerUpdate(playerid) :-----*/
public PAUSE_OnPlayerUpdate(playerid)
{
	gLastUpdate[playerid] = GetTickCount();
 	gState[playerid] = e_STATE_UPDATING;
	return 1;
}

/*-----: CheckPlayers() :-----*/
public PAUSE_CheckPlayers()
{
	for(new i; i < MAX_PLAYERS; ++i)
	{
		if((gState[i] == e_STATE_UPDATING) && (GetTickCount() - MAX_AFK_TIME >= gLastUpdate[i]))
		{
			CallLocalFunction("OnPlayerPause", "d", i);
		}
	}
	return 1;
}
