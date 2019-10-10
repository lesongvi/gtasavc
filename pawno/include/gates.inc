public OnPlayerEditDynamicObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    if(response == EDIT_RESPONSE_FINAL)
    {
		new Float:X, Float:Y, Float:Z;
		new Float:X2, Float:Y2, Float:Z2;
		new x_job[128], gateid, Float:ofloat, string[128];
		new Float:value = ofloat;
		for(new i;i<MAX_GATES;i++)
		SetDynamicObjectPos(GateInfo[gateid][gGATE], GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ]);
  		GateInfo[gateid][gPosX] = value;
  		GateInfo[gateid][gPosY] = value;
  		GateInfo[gateid][gPosZ] = value;
  		format(string, sizeof(string), "Gate Pos moved to %f %f %f, VW: %d INT: %d", GateInfo[gateid][gPosX], GateInfo[gateid][gPosY], GateInfo[gateid][gPosZ], GateInfo[gateid][gVW], GateInfo[gateid][gInt]);
		SendClientMessageEx(playerid, COLOR_WHITE, string);
        SaveGates();
    }
    return 1;
}