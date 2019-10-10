#include <a_samp>

new FirstPerson[MAX_PLAYERS];
new FirstPersonObject[MAX_PLAYERS];

stock StartFPS(playerid)
{
    FirstPersonObject[playerid] = CreateObject(19300, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    AttachObjectToPlayer(FirstPersonObject[playerid],playerid, 0.0, 0.12, 0.7, 0.0, 0.0, 0.0);
    AttachCameraToObject(playerid, FirstPersonObject[playerid]);
    FirstPerson[playerid] = 1;
    CallLocalFunction("OnPlayerHaveFirstPerson", "i", playerid);
    return 1;
}

stock StopFPS(playerid)
{
	SetCameraBehindPlayer(playerid);
	DestroyObject(FirstPersonObject[playerid]);
	FirstPerson[playerid] = 0;
	CallLocalFunction("OnPlayerDoNotHaveFirstPerson", "i", playerid);
	return 1;
}

stock Reset(playerid)
{
	FirstPerson[playerid] = 0;
}