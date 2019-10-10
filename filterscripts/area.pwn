#include 	<a_samp>
#include 	<YSI\y_commands>

#define 	DIALOG_IPIA_MAKER    (10212)
#define     DIALOG_IPIA_SAVE     (10213)

enum
	aInfo
{
	Float:aMin_X,
	Float:aMin_Y,
	Float:aMax_X,
	Float:aMax_Y,
	bool:UsedSaveOne,
 	bool:UsedSaveTwo
};

new AreaInfo[MAX_PLAYERS][aInfo];

YCMD:area(playerid, params[], help)
{
	#pragma unused params, help
	return ShowPlayerDialog(playerid, DIALOG_IPIA_MAKER, DIALOG_STYLE_LIST, "IsPlayerInArea Maker", "Save the first point\nSave the second point\n{F58282}Create IsPlayerInArea\nReset All points, and Save Again", "Select", "Cancel"), 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(AreaInfo[playerid][UsedSaveOne] || AreaInfo[playerid][UsedSaveTwo] || AreaInfo[playerid][UsedSaveOne] != AreaInfo[playerid][UsedSaveTwo])
	{
	    AreaInfo[playerid][aMin_X] = 0.0;
	 	AreaInfo[playerid][aMin_Y] = 0.0;
		AreaInfo[playerid][aMax_X] = 0.0;
		AreaInfo[playerid][aMax_Y] = 0.0;
	    AreaInfo[playerid][UsedSaveOne] = false;
		AreaInfo[playerid][UsedSaveTwo] = false;
    }
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
	    case DIALOG_IPIA_MAKER:
	    {
	    	if(!response) return 0;
			switch(listitem)
			{
				case 0:
				{
				    if(AreaInfo[playerid][UsedSaveOne]) return SendClientMessage(playerid, 0xFF0000FF, "This points alredy exist!"), 0;
				    new Float:X,Float:Y,Float:Z;
				    GetPlayerPos(playerid, X, Y, Z);
				    AreaInfo[playerid][aMin_X] = X;
				    AreaInfo[playerid][aMin_Y] = Y;
				    AreaInfo[playerid][UsedSaveOne] = true;
				    SendClientMessage(playerid, 0xCC9900FF, "Minimum X and Y created.");
				}
				case 1:
				{
				    if(AreaInfo[playerid][UsedSaveTwo]) return SendClientMessage(playerid, 0xFF0000FF, "This points alredy exist!"), 0;
				    new Float:X,Float:Y,Float:Z;
				    GetPlayerPos(playerid, X, Y, Z);
				    AreaInfo[playerid][aMax_X] = X;
				    AreaInfo[playerid][aMax_Y] = Y;
				    AreaInfo[playerid][UsedSaveTwo] = true;
				    SendClientMessage(playerid, 0xCC9900FF, "Maximum X and Y created.");
				}
				case 2:	ShowPlayerDialog(playerid, DIALOG_IPIA_SAVE, DIALOG_STYLE_INPUT, " ", "{F58282}Type the file name inside the box", "Save", "Cancel");
				default:
				{
					if(AreaInfo[playerid][UsedSaveOne] || AreaInfo[playerid][UsedSaveTwo] || AreaInfo[playerid][UsedSaveOne] != AreaInfo[playerid][UsedSaveTwo])
	  				{
					    AreaInfo[playerid][aMin_X] = 0.0;
		   			 	AreaInfo[playerid][aMin_Y] = 0.0;
		        		AreaInfo[playerid][aMax_X] = 0.0;
		    			AreaInfo[playerid][aMax_Y] = 0.0;
		    		    AreaInfo[playerid][UsedSaveOne] = false;
			  			AreaInfo[playerid][UsedSaveTwo] = false;
		    		    SendClientMessage(playerid, 0xCC9900FF, "The points has reseted successfully!");
	    		    }
	    		    else SendClientMessage(playerid, 0xFF0000FF, "you cannot reset the point until you save some point!");
				}
			}
	    }
		case DIALOG_IPIA_SAVE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_IPIA_MAKER, DIALOG_STYLE_LIST, "IsPlayerInArea Maker", "Save the first point\nSave the second point\n{F58282}Create IsPlayerInArea\nReset All points, and Save Again", "Select", "Cancel"), 1;
			if(AreaInfo[playerid][UsedSaveOne] && AreaInfo[playerid][UsedSaveTwo])
			{
		  	  	if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IPIA_SAVE, DIALOG_STYLE_INPUT, " ", "{F58282}Type the file name inside the box", "Save", "Cancel");
				new string[128];
				new filename[64];
				format(filename, sizeof(filename), "IsPlayerInArea_%s.ini", inputtext);
			    format(string, sizeof(string), "IsPlayerInArea(playerid, %f, %f, %f, %f);\r\n",
					(AreaInfo[playerid][aMin_X] < AreaInfo[playerid][aMax_X]) ? AreaInfo[playerid][aMin_X] : AreaInfo[playerid][aMax_X],
					(AreaInfo[playerid][aMin_Y] < AreaInfo[playerid][aMax_Y]) ? AreaInfo[playerid][aMin_Y] : AreaInfo[playerid][aMax_Y],
					(AreaInfo[playerid][aMin_X] > AreaInfo[playerid][aMax_X]) ? AreaInfo[playerid][aMin_X] : AreaInfo[playerid][aMax_X],
					(AreaInfo[playerid][aMin_Y] > AreaInfo[playerid][aMax_Y]) ? AreaInfo[playerid][aMin_Y] : AreaInfo[playerid][aMax_Y]
				);
				new File:pos=fopen(filename, io_append);
			    fwrite(pos, string);
			    fclose(pos);
			    new dialogstring[128];
			    format(dialogstring, sizeof(dialogstring), "\nIsPlayerInArea saved under the name {F58282}IsPlayerInArea_%s.ini {a9c4e4}inside the scriptfiles folder!\n", inputtext);
			    ShowPlayerDialog(playerid, 206, DIALOG_STYLE_MSGBOX, " ", dialogstring, "Exit", "");
				AreaInfo[playerid][aMin_X] = 0.0;
				AreaInfo[playerid][aMin_Y] = 0.0;
				AreaInfo[playerid][aMax_X] = 0.0;
				AreaInfo[playerid][aMax_Y] = 0.0;
			    AreaInfo[playerid][UsedSaveOne] = false;
			  	AreaInfo[playerid][UsedSaveTwo] = false;
		 	}
		 	else SendClientMessage(playerid, 0xFF0000FF, "You have to save two points!");
		}
	}
	return 1;
}

IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
    new Float:x, Float:Y, Float:Z;
    GetPlayerPos(playerid, X, Y, Z);
    return (X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) ? 1 : 0;
}
