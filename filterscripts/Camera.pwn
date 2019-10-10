#include <a_samp>

#define FILERSCRIPT 1
#define COLOR_SAMP 0xA9C4E4FF

new Float:CameraSet[6];
new Float:Val;
new SetPos = 0;
new SetAt = 0;
#define KEY_RMB 4
#define KEY_LMB 128
#define KEY_Num6 16384
#define KEY_Num4 8192
#define KEY_SPACE 8
#define KEY_ALT 1024


strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' ')) { index++; }
	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Camera Position setup v1.0 by Ikey07");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[256];
    new idx;
	cmd = strtok(cmdtext, idx);
	new string[256];
    new tmp[256];
    if(strcmp(cmd, "/camcmd", true) == 0)
	{
		SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  /setcam /mocam /lookatcam /setvalcam /endcam.");
		return 1;
	}
 	if(strcmp(cmd, "/setcam", true) == 0)
	{
	    TogglePlayerControllable(playerid,0);
	    GetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
		GetPlayerPos(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
		SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		Val = 1.0;
		SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  /mocam /lookatcam /setvalcam /endcam");
		return 1;
	}
	if(strcmp(cmd, "/mocam", true) == 0)
	{
	    SetPos = 1; SetAt = 0;
	    SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  Now you can move the camera, to change moving rate use /setvalcam");
		SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  Num4/Num6: X-Axis, RMB/LMB: Y-Axis, Space/Alt: Z-Axis");
		return 1;
	}
	if(strcmp(cmd, "/lookatcam", true) == 0)
	{
	    SetPos = 0; SetAt = 1;
	    SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  Now you can set where camera look at, to change moving rate use /setvalcam");
		SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  Num4/Num6: X-Axis, RMB/LMB: Y-Axis, Space/Alt: Z-Axis");
		return 1;
	}
	if(strcmp(cmd, "/setvalcam", true) == 0)
	{
	    tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid,COLOR_SAMP,"/sevalcam [value].");
			return 1;
		}
		Val = floatstr(tmp);
		format(string,256,"Camera Editor:  Camera move value is now %.3f",Val);
		SendClientMessage(playerid,COLOR_SAMP,string);
		return 1;
	}
	if(strcmp(cmd, "/endcam", true) == 0)
	{
	    SetPos = 0; SetAt = 0;
	    SendClientMessage(playerid,COLOR_SAMP,"Camera Editor:  Now you can save Camera setup to file /savecam");
	    TogglePlayerControllable(playerid,1);
	    SetCameraBehindPlayer(playerid);
		return 1;
	}
	if(strcmp(cmd, "/savecam", true) == 0)
	{
		new entry[256];
		format(entry, sizeof(entry), "SetPlayerCameraPos(playerid,%.3f,%.3f,%.3f); \nSetPlayerCameraLookAt(playerid,%.3f,%.3f,%.3f); \n",CameraSet[0],CameraSet[1],CameraSet[2],CameraSet[3],CameraSet[4],CameraSet[5]);
		new File:hFile; hFile = fopen("Cameras.cfg", io_append); fwrite(hFile, entry); fclose(hFile);
		SendClientMessage(playerid,COLOR_SAMP,entry);
		return 1;
	}
	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_Num6)
	{
	    if(SetPos == 1)
		{
		    CameraSet[0] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[3] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	else if(newkeys == KEY_Num4)
	{
     	if(SetPos == 1)
		{
		    CameraSet[0] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[3] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	else if(newkeys == KEY_RMB)
	{
		if(SetPos == 1)
		{
		    CameraSet[1] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[4] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	else if(newkeys == KEY_LMB)
	{
		if(SetPos == 1)
		{
		    CameraSet[1] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[4] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	else if(newkeys == KEY_ALT)
	{
		if(SetPos == 1)
		{
		    CameraSet[2] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[5] -= Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	else if(newkeys == KEY_SPACE)
	{
		if(SetPos == 1)
		{
		    CameraSet[2] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	    else if(SetAt == 1)
		{
		    CameraSet[5] += Val;
			SetPlayerCameraPos(playerid,CameraSet[0],CameraSet[1],CameraSet[2]);
			SetPlayerCameraLookAt(playerid,CameraSet[3],CameraSet[4],CameraSet[5]);
		}
	}
	return 1;
}



