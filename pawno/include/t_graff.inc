/*
					Graffiti System by Tavi (2012)
					==============================
		
Functions
================================================================================
		
native CreateGraffiti(playerid, Float:gX, Float:gy, Float:gZ, Float:gA, gText[], gFont[], gSize, gBold, gColor[]);
native DeleteGraffiti(graffid);

================================================================================

*/

#include <a_samp>

#define MAX_GRAFFS 100

enum t_GraffSystem
{
	t_gObject,
	Float:t_gX,
	Float:t_gY,
	Float:t_gZ,
};
new Graff[MAX_GRAFFS][t_GraffSystem];
new t_gCurrent[MAX_PLAYERS];

stock CreateGraffiti(playerid, Float:gX, Float:gY, Float:gZ, Float:gA, gText[], gFont[], gSize, gBold, gColor[])
{
	new t_gID = EmptyGraff();
	if(t_gID == -1) { print("MAX_GRAFFS too small"); return -1; }
	//
	Graff[t_gID][t_gObject] = CreateObject(19353, gX, gY, gZ, 0.0, 0.0, gA-90.0);
	//SetObjectMaterial(Graff[t_gID][t_gObject], 0, 0, "none", "none", 0);
	SetObjectMaterialText(Graff[t_gID][t_gObject], gText, 0, OBJECT_MATERIAL_SIZE_256x128,\
	gFont, gSize, gBold, HexToInt(gColor), 0x00000000, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);
	//
	Graff[t_gID][t_gX] = gX;
	Graff[t_gID][t_gY] = gY;
	Graff[t_gID][t_gZ] = gZ;
	t_gCurrent[playerid] = t_gID;
	EditObject(playerid, Graff[t_gID][t_gObject]);
	//printf("%s - %d", gColor, HexToInt(gColor));
	return t_gID;
}

stock DeleteGraffiti(graffid)
{
	DestroyObject(Graff[graffid][t_gObject]);
	Graff[t_gObject] = 0;
	Graff[t_gX] = 0;
	Graff[t_gY] = 0;
	Graff[t_gZ] = 0;
}

stock EmptyGraff()
{
	for(new i = 0; i != MAX_GRAFFS; i++)
	{
		if(Graff[i][t_gObject] == 0)
		{
			return i;
		}
	}
	return -1;
}

HexToInt(string[]){
   if (string[0]==0) return 0;
   new i;
   new cur=1;
   new res=0;
   for (i=strlen(string);i>0;i--) {
     if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
     cur=cur*16;
   }
   return res;
 }

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    if(response == EDIT_RESPONSE_FINAL)
	{
		new g = t_gCurrent[playerid];
		MoveObject(objectid, fX, fY, fZ, 10.0, fRotX, fRotY, fRotZ);
		Graff[g][t_gX] = fX;
		Graff[g][t_gY] = fY;
		Graff[g][t_gZ] = fZ;
 	}
 	CallLocalFunction("t_gOnPlayerEditObject", "iiiiffffff", playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ);
 	return 1;
}

#if defined _ALS_OnPlayerEditObject
    #undef OnPlayerEditObject
#else
    #define _ALS_OnPlayerEditObject
#endif

#define OnPlayerEditObject t_gOnPlayerEditObject

forward t_gOnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ);
