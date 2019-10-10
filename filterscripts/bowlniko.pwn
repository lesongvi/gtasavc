/*
********************************************************************************
The Script: San Fierro Bowling. || 29.01.2012 Last Tested by Nexotronix
********************************************************************************
						CREDITS:
********************************************************************************
Author: 												Nexotronix ( Dmitry Nedoseko ).

Zcmd: 													Zeex
DJSon: 													DracoBlue
Sscanf2: 												Y_Less
Streamer plugin: 										Incognito

Biggest Thanks For Testing: 							Vandersexxx
First Testing: 											SamS, Vlad, Snoop
Thanks for testing everytime: 							Serega
Spetial Thanks for video and first public Test to: 		Michael@Belgium
********************************************************************************
						CONTACT ME:
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Skype: 													nexotronix.
MSN: 													nexotronix@hotmail.com
Website:                                                gta-megaplay.ru
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
					>>> CHANGELOG <<<
--------------------------------------------------------------------------------
						v 1.3
--------------------------------------------------------------------------------
Now Script using PlayAudioStreamForPlayer audio streaming function wiothout audio plugin.
You can throw the ball by pressing "Y"
--------------------------------------------------------------------------------
						v 1.2
--------------------------------------------------------------------------------
Fixed Some little bugs!
Added StreamerUpdateEx(playerid,X,Y,Z); - to Update More :)
Edited file system, now it's no dini, it's DJson
AccountSystem Adited, and builded on DJson functions!
New Command:
/setbowlingplace - For RCON Admin ONLY!
to change the place of enterpickup, icon, and 3dtext, so you can place bowling
anywhere you want =)
New Functions of Account System and Coordinates Saving:
BAccParamName(playerid,paramname[]) //typing param name (Using for other functions)
SetBAccInt(playerid,param[],value) //setting integer value in Account file
SetBAccString(playerid,param[],value[]) //setting string in Account file
GetBAccInt(playerid,param[]) //getting the integer value in Account file
GetBAccString(playerid,param[]) //getting string in Account file
IsBAccParamExists(playerid,param[]) //checking is exists param in account file
IsBAccExists(accname[]) //checking is exists account
CreateBCoordFile() //creating the file with coordinates
BCoordType(coordtype[],coordname[]) //settin the type of coord (Using for other functions)
Float:GetBCoord(coordtype[],coordname[]) //getting the coordinates
SetBCoord(coordtype[],coordname[],Float:value) //ssetting the coordinates
BCoordsInit() //starting Coordinate config, and loading pickup, 3dtext and mapicon!
BAccSysInit(); //starting Account File
--------------------------------------------------------------------------------
						v 1.1
--------------------------------------------------------------------------------
Added 3 NPCs: bar girl, dj, adminisrator
Added sounds in club!
Added Cmds: /dancing, /stopanim
--------------------------------------------------------------------------------
						v 1.0 U-1
--------------------------------------------------------------------------------
Now ball have better speed and sync. with player:
Added Streamer_Update();
--------------------------------------------------------------------------------
*/
#include a_samp
#include streamer
#include zcmd
#include sscanf2
#include djson
//version
#define VERSION "1.3"
//max values
#define MAX_PINS 10
#define MAX_BOWLING_ROADS 5
//files
#define B_ACC_FILE "Bowling/BowlingAccounts.bowling"
#define B_COORD_FILE "Bowling/BowlingCoordinates.bowling"
//dialogs
#define DIALOG_BOWLING 			1000
#define DIALOG_BOWLING_TIME 	1001
#define DIALOG_ADD_TIME 		1002
#define DIALOG_ROAD 			1003
#define DIALOG_BOWLING_STATS 	1004
//colors
#define COLOR_CMDERROR 	0xB13434AA
//bowling
//pins status
#define PIN_GOAWAY 	0
#define PIN_LAST 	1
//players status
#define F_BOWLING_THROW 0
#define S_BOWLING_THROW 1
#define N_BOWLING_THROW 2
//roads status
#define ROAD_EMPTY 0
#define ROAD_BUSY 1
#define ROAD_NONE 255
//Y Coordinate for roads
#define Y_ROAD_2 1.43993652586
#define Y_ROAD_3 3.11993652586
#define Y_ROAD_4 4.55993652586
#define Y_ROAD_5 6.10243269586
//speed of ball
#define BALL_SPEED 5.0
#define BALL_RUN_TIME 1950
//bowling
new Text3D:BowlingMainLabel;
new BowlingMapIcon;
new BowlingPins[MAX_BOWLING_ROADS][MAX_PINS];//pins
new BowlingMinutes[MAX_PLAYERS];
new BowlingSeconds[MAX_PLAYERS];
new BowlingPinsWaitEndTimer[MAX_PLAYERS];
new BowlingPinsWaitTimer[MAX_PLAYERS];
new BowlingTimer[MAX_BOWLING_ROADS];//timer
new BowlingStatus[MAX_PLAYERS];//statusof playing player
new PinsLeft[MAX_BOWLING_ROADS][MAX_PLAYERS];//how much pins left after first try
new LastPin[MAX_BOWLING_ROADS][MAX_PINS][MAX_PLAYERS];//how much pins left after second try
new AbleToPlay[MAX_PLAYERS];//players able to play
new PlayersBowlingRoad[MAX_PLAYERS];//road what player using
new BowlingRoadStatus[MAX_BOWLING_ROADS];//status of th road
new Text3D:BowlingRoadScreen[MAX_BOWLING_ROADS];//the screens
new BowlingBall[MAX_BOWLING_ROADS];
new BallGoing[MAX_PLAYERS];
new BallRun[MAX_PLAYERS];
new PlayersBowlingScore[MAX_PLAYERS];
new BowlingCP1;
new PlayerOrder[MAX_PLAYERS][128];
new Text3D:DDJ;
new BowlingEnterPickup;
new BowlingExitPickup;
//forwards

forward PinsWaitTimer(playerid);
forward PinsWaitEnd(playerid);
forward BowlingCountDown(playerid);
forward BallGoingTimer(playerid);
forward BallRunTimer(playerid);
forward Float:GetBCoord(coordtype[],coordname[]);
forward BCoordsInit();
forward GetClosestPlayer(p1);
forward Float:GetDistanceBetweenPlayers(p1,p2);
forward SetBCoord(coordtype[],coordname[],Float:value);
forward CreateBCoordFile();
forward BAccSysInit();
forward IsBAccExists(accname[]);
forward IsBAccParamExists(playerid,param[]);
forward SetBAccString(playerid,param[],value[]);
forward SetBAccInt(playerid,param[],value);

public OnFilterScriptInit()
{
    print("\n\n\n---------------------------------------------------------");
	print("  The Script: 		San Fierro Bowling.		");
	print("  Author: 		Nexotronix ( Dmitry Nedoseko ). ");
	print("  Authors Skype: 	nexotronix.			");
	print("  Date of Start: 	January 29, 2011.		");
	printf("  Version: 		%s.				",VERSION);
	print("---------------------------------------------------------\n\n\n");
	//other
	djson_GameModeInit();
	BAccSysInit();
	BCoordsInit();
 	//3dTexts
	BowlingRoadScreen[0] = CreateDynamic3DTextLabel("{008800}[{FFFFFF} Road 1{008800} ]\n Empty",0xffffffff,-1974.7992,417.17291259766,4.7010, 15.0);
	BowlingRoadScreen[1] = CreateDynamic3DTextLabel("{008800}[{FFFFFF} Road 2{008800} ]\n Empty",0xffffffff,-1974.7992,415.69528198242,4.7010, 15.0);
	BowlingRoadScreen[2] = CreateDynamic3DTextLabel("{008800}[{FFFFFF} Road 3{008800} ]\n Empty",0xffffffff,-1974.7992,414.19616699219,4.7010, 15.0);
	BowlingRoadScreen[3] = CreateDynamic3DTextLabel("{008800}[{FFFFFF} Road 4{008800} ]\n Empty",0xffffffff,-1974.7992,412.72177124023,4.7010, 15.0);
	BowlingRoadScreen[4] = CreateDynamic3DTextLabel("{008800}[{FFFFFF} Road 5{008800} ]\n Empty",0xffffffff,-1974.7992,411.2473449707,4.7010, 15.0);
    //bowling club
	CreateDynamicObject(3305, -1988.21680, 409.67578, 3.48275,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1970.30737, 398.48526, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1969.63330, 403.06885, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1973.96973, 400.88071, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1973.36218, 405.84259, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1966.74902, 407.34863, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2148, -1974.79187, 417.17291, 4.84897,   22.00000, 0.00000, 270.00000);
	CreateDynamicObject(2148, -1974.79285, 415.69528, 4.84897,   21.99463, 0.00000, 270.00000);
	CreateDynamicObject(2148, -1974.79138, 414.19617, 4.84897,   21.99463, 0.00000, 270.00000);
	CreateDynamicObject(2148, -1974.79163, 412.72177, 4.84897,   21.99463, 0.00000, 270.00000);
	CreateDynamicObject(2148, -1974.79041, 411.24734, 4.84897,   21.99463, 0.00000, 270.00000);
	CreateDynamicObject(3104, -1981.04077, 416.99365, 2.09871,   0.00000, 0.00000, 90.50000);
	CreateDynamicObject(3104, -1981.02393, 415.54788, 2.09871,   0.00000, 0.00000, 90.49988);
	CreateDynamicObject(3104, -1981.02441, 413.97348, 2.09871,   0.00000, 0.00000, 90.49988);
	CreateDynamicObject(3104, -1981.02026, 412.41013, 2.09871,   0.00000, 0.00000, 90.49988);
	CreateDynamicObject(3104, -1980.99951, 410.86880, 2.09871,   0.00000, 0.00000, 90.49988);
	CreateDynamicObject(3119, -1979.17871, 410.35504, 1.90615,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3119, -1979.17871, 412.01337, 1.90615,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3119, -1979.17871, 413.81100, 1.90615,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3119, -1979.17871, 417.39871, 1.90615,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3119, -1979.17871, 415.60202, 1.90615,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3452, -1986.83862, 403.52499, 3.05480,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2232, -1963.27112, 417.94244, 4.82137,   0.00000, 179.99994, 315.50000);
	CreateDynamicObject(1590, -1976.69604, 404.03070, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1980.65112, 402.00287, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1980.81201, 405.61914, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1590, -1976.61096, 407.31570, 1.97796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1652, -1974.78381, 416.22281, 1.63934,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1652, -1974.78381, 417.70560, 1.63934,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1652, -1974.78064, 414.61548, 1.63934,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1652, -1974.78271, 413.08093, 1.63934,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1652, -1974.78564, 411.56622, 1.63934,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.61511, 417.68079, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.91211, 417.68668, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.59570, 416.26126, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.90430, 416.25293, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.20020, 416.25146, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.72449, 414.64627, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.07568, 414.65039, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.06470, 413.09952, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.34717, 413.12375, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.59473, 413.08887, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1974.77441, 411.65021, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.04773, 411.61264, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1985, -1975.30554, 411.56717, 1.79999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19379, -1959.30298, 414.75790, 2.54090,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19379, -1969.25476, 410.04279, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 413.08389, -2.74320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 410.04279, -2.72590,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1969.25476, 413.08389, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1969.25476, 411.58801, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 411.58801, -2.73460,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1993.49927, 419.85556, 1.49500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19376, -2127.43530, 376.78613, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1993.50732, 410.28180, 1.49500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19379, -1968.90454, 414.76300, 1.42580,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19379, -1969.25476, 417.74200, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1969.25476, 416.20270, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1969.25476, 414.63681, -3.60260,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 417.74200, -2.74320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 416.20270, -2.73460,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, -1959.72375, 414.63681, -2.72590,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1993.50732, 400.87076, 1.49501,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19376, -1962.90076, 419.17139, 1.49500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19376, -1994.30713, 417.80270, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1979.30579, 396.30569, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1988.88867, 396.30573, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1960.77795, 396.30569, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1962.90076, 400.89371, 1.49500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19376, -1962.90076, 410.13300, 1.49500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19376, -1970.17908, 396.30569, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1967.68066, 417.80273, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1976.27112, 417.80270, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19376, -1985.60535, 417.80270, 1.49500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1536,-1993.4000000,403.9200000,1.4600000,0.0000000,0.0000000,90.0000000); //
	CreateDynamicObject(1536,-1993.4300000,406.9400000,1.4600000,0.0000000,0.0000000,-90.0000000); //
	CreateDynamicObject(8991,-2007.1900000,411.8800000,19.5100000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-1945.5900000,371.1600000,-5.4800000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-1920.0600000,410.2000000,-0.4800000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-2016.9100000,344.2800000,0.5100000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-2070.7100000,380.7400000,1.5100000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-2054.0100000,456.6400000,-2.6500000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-1979.8200000,485.7900000,2.8500000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8991,-1929.1900000,422.2800000,-8.1400000,0.0000000,0.0000000,0.0000000); //
	CreateDynamicObject(8971,-1953.4200000,502.2500000,6.9800000,0.0000000,0.0000000,90.0000000); //
	CreateDynamicObject(8991,-1940.5700000,454.9500000,-11.6700000,0.0000000,0.0000000,0.0000000); //




	return 1;
}
public OnFilterScriptExit()
{
    djson_GameModeExit();
    return 1;
}
public OnPlayerConnect(playerid)
{
    //player variables
    new mxPRds = MAX_BOWLING_ROADS+1;
    BowlingMinutes[playerid] = 0;
    BowlingSeconds[playerid] = 0;
	BowlingStatus[playerid] = F_BOWLING_THROW;
	AbleToPlay[playerid] = 0;
	PlayersBowlingScore[playerid] = 0;
	for(new pl=0; pl<mxPRds; pl++) PinsLeft[pl][playerid] = 0;
	return 1;
}



public OnPlayerDisconnect(playerid, reason)
{
    new mxPRds = MAX_BOWLING_ROADS+1;
    BowlingMinutes[playerid] = 0;
    BowlingSeconds[playerid] = 0;
	BowlingStatus[playerid] = F_BOWLING_THROW;
	AbleToPlay[playerid] = 0;
	KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
 	BowlingRoadStatus[PlayersBowlingRoad[playerid]] = ROAD_EMPTY;
 	if(PlayersBowlingRoad[playerid]==0)
  	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,"{008800}[{FFFFFF} Road 1{008800} ]\n Empty");
		DestroyPins(0);
  	}
	else if(PlayersBowlingRoad[playerid]==1)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,"{008800}[{FFFFFF} Road 2{008800} ]\n Empty");
		DestroyPins(1);
	}
	else if(PlayersBowlingRoad[playerid]==2)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,"{008800}[{FFFFFF} Road 3{008800} ]\n Empty");
		DestroyPins(2);
  	}
  	else if(PlayersBowlingRoad[playerid]==3)
   	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,"{008800}[{FFFFFF} Road 4{008800} ]\n Empty");
		DestroyPins(3);
   	}
	else if(PlayersBowlingRoad[playerid]==4)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,"{008800}[{FFFFFF} Road 5{008800} ]\n Empty");
		DestroyPins(4);
	}
 	PlayersBowlingRoad[playerid] = ROAD_NONE;
 	for(new pl=0; pl<mxPRds; pl++) PinsLeft[pl][playerid] = 0;
	return 1;
}




public OnPlayerDeath(playerid, killerid, reason)
{
    StopAudioStreamForPlayer(playerid);
    BowlingMinutes[playerid] = 0;
    BowlingSeconds[playerid] = 0;
	BowlingStatus[playerid] = F_BOWLING_THROW;
	PinsLeft[1][playerid] = 0;
	AbleToPlay[playerid] = 0;
	KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
 	BowlingRoadStatus[PlayersBowlingRoad[playerid]] = ROAD_EMPTY;
 	if(PlayersBowlingRoad[playerid]==0)
  	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,"{008800}[{FFFFFF} Road 1{008800} ]\n Empty");
		DestroyPins(0);
  	}
	else if(PlayersBowlingRoad[playerid]==1)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,"{008800}[{FFFFFF} Road 2{008800} ]\n Empty");
		DestroyPins(1);
	}
	else if(PlayersBowlingRoad[playerid]==2)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,"{008800}[{FFFFFF} Road 3{008800} ]\n Empty");
		DestroyPins(2);
  	}
  	else if(PlayersBowlingRoad[playerid]==3)
   	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,"{008800}[{FFFFFF} Road 4{008800} ]\n Empty");
		DestroyPins(3);
   	}
	else if(PlayersBowlingRoad[playerid]==4)
	{
		UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,"{008800}[{FFFFFF} Road 5{008800} ]\n Empty");
		DestroyPins(4);
	}
 	PlayersBowlingRoad[playerid] = ROAD_NONE;
	return 1;
}
stock Float:GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	if (IsPlayerInAnyVehicle(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else GetPlayerFacingAngle(playerid, a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
	return a;
}

CMD:setupbowling(playerid, params[])
{
    if(!IsPlayerInRangeOfPoint(playerid,2.0,-1989.5709,414.7065,2.5010))
	{
        SendClientMessage(playerid,0xD92626AA,"You are not at the Bowling Alley Counter!");
        return 1;
    }
    ShowPlayerDialog(playerid,DIALOG_BOWLING, DIALOG_STYLE_LIST, "Bowling", "{00AA00}1. {FFFFFF}Take a road \n{00AA00}2. {FFFFFF}End the game \n{00AA00}3. {FFFFFF}Add more time ", "Ok", "Exit");
    return 1;
}

CMD:rollball(playerid, params[])
{
	cmd_bowling(playerid,"");
	return 1;
}

CMD:bowling(playerid,params[])
{
 	if(AbleToPlay[playerid] == 1)
	{  
 		if(IsAtBowlingRoad(playerid))
 		{
       		if(BowlingStatus[playerid] != N_BOWLING_THROW)
 			{
 			    CreateBall(playerid);
				BallGoing[playerid] = SetTimerEx("BallGoingTimer",1000,false,"d",playerid);
				ApplyAnimation(playerid,"GRENADE","WEAPON_throwu",2.2,0,0,0,0,0,1);
    		}
    		else
    		{
    		    SendClientMessage(playerid,0xAA0000FF,"Wait for pins!.");
    		}
		}
		else
		{
		    SendClientMessage(playerid,0xD92626AA,"You too away from road!");
		}
	}
	else
	{
	    SendClientMessage(playerid,0xD92626AA,"You didn't start game yet!");
	}
	return 1;
}
CMD:bowlingstats(playerid,params[])
{
	new str[128];
	format(str,128,"{00CC00}Best result: {EEEEEE}%i\n{00CC00}Strikes: {EEEEEE}%i\n{00CC00}Date of Last game: {EEEEEE}%s ",GetBAccInt(playerid,"BestScore"),GetBAccInt(playerid,"Strikes"),GetBAccString(playerid,"LastTimePlayed"));
	ShowPlayerDialog(playerid, DIALOG_BOWLING_STATS, DIALOG_STYLE_MSGBOX, "My Bowling Stats", str, "Ok", "");
	return 1;
}

//bowling functions
stock IsAtBowlingRoad(playerid)
{
	if(PlayersBowlingRoad[playerid]==0)
	{
	    if(IsPlayerInRangeOfPoint(playerid,0.5,-1975.0587,416.9655,2.5090))
	    {
	        return 1;
	    }
 	}
 	else if(PlayersBowlingRoad[playerid]==1)
	{
	    if(IsPlayerInRangeOfPoint(playerid,0.5,-1975.0587,415.4035,2.5090))
	    {
	        return 1;
	    }
 	}
 	else if(PlayersBowlingRoad[playerid]==2)
	{
	    if(IsPlayerInRangeOfPoint(playerid,0.5,-1975.0587,413.8728,2.5090))
	    {
	        return 1;
	    }
 	}
 	else if(PlayersBowlingRoad[playerid]==3)
	{
	    if(IsPlayerInRangeOfPoint(playerid,0.5,-1975.0587,412.2807,2.5090))
	    {
	        return 1;
	    }
 	}
 	else if(PlayersBowlingRoad[playerid]==4)
	{
	    if(IsPlayerInRangeOfPoint(playerid,0.5,-1975.0587,410.7207,2.5090))
	    {
	        return 1;
	    }
 	}
	return 0;
}
stock MoveBall(playerid)
{
    if(PlayersBowlingRoad[playerid] == 0)
	{
    	MoveDynamicObject(BowlingBall[0],-1962.90368652,416.9655,1.64401352,BALL_SPEED);
	}
	else if(PlayersBowlingRoad[playerid] == 1)
	{
    	MoveDynamicObject(BowlingBall[1],-1962.90368652,415.4035,1.64401352,BALL_SPEED);
	}
	else if(PlayersBowlingRoad[playerid] == 2)
	{
    	MoveDynamicObject(BowlingBall[2],-1962.90368652,413.8728,1.64401352,BALL_SPEED);
	}
	else if(PlayersBowlingRoad[playerid] == 3)
	{
    	MoveDynamicObject(BowlingBall[3],-1962.90368652,412.2807,1.64401352,BALL_SPEED);
	}
	else if(PlayersBowlingRoad[playerid] == 4)
	{
    	MoveDynamicObject(BowlingBall[4],-1962.90368652,410.7207,1.64401352,BALL_SPEED);
	}
	return 1;
}
stock CreateBall(playerid)
{
    if(PlayersBowlingRoad[playerid]==0)
	{
	    BowlingBall[0] = CreateDynamicObject(1985,-1975.0587+1,416.9655,1.64401352,0.0,0.0,0.0);
	}
	else if(PlayersBowlingRoad[playerid]==1)
	{
	    BowlingBall[1] = CreateDynamicObject(1985,-1975.0587+1,415.4035,1.64401352,0.0,0.0,0.0);
	}
	else if(PlayersBowlingRoad[playerid]==2)
	{
	    BowlingBall[2] = CreateDynamicObject(1985,-1975.0587+1,413.8728,1.64401352,0.0,0.0,0.0);
	}
	else if(PlayersBowlingRoad[playerid]==3)
	{
	    BowlingBall[3] = CreateDynamicObject(1985,-1975.0587+1,412.2807,1.64401352,0.0,0.0,0.0);
	}
	else if(PlayersBowlingRoad[playerid]==4)
	{
	    BowlingBall[4] = CreateDynamicObject(1985,-1975.0587+1,410.7207,1.64401352,0.0,0.0,0.0);
	}
	return 1;
}
stock DestroyBall(playerid)
{
    if(PlayersBowlingRoad[playerid]==0)
	{
	    DestroyDynamicObject(BowlingBall[0]);
	}
	else if(PlayersBowlingRoad[playerid]==1)
	{
	    DestroyDynamicObject(BowlingBall[1]);
	}
	else if(PlayersBowlingRoad[playerid]==2)
	{
	    DestroyDynamicObject(BowlingBall[2]);
	}
	else if(PlayersBowlingRoad[playerid]==3)
	{
	    DestroyDynamicObject(BowlingBall[3]);
	}
	else if(PlayersBowlingRoad[playerid]==4)
	{
	    DestroyDynamicObject(BowlingBall[4]);
	}
	return 1;
}

stock DestroyPins(roadid)
{
	
	for(new pin = 0; pin<=MAX_PINS; pin++)
	{
	    DestroyDynamicObject(BowlingPins[roadid][pin]);
	}
    return 1;
}
stock CreatePins(playerid)
{
	if(PlayersBowlingRoad[playerid]==0)
	{
		BowlingPins[0][9] = CreateDynamicObject(1484, -1963.1579589844, 417.12506103516, 1.7151190042496, 349.04943847656, 24.473388671875, 6.1903991699219);
		BowlingPins[0][8] = CreateDynamicObject(1484, -1963.1511230469, 416.96856689453, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][7] = CreateDynamicObject(1484, -1963.1798095703, 416.78656005859, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][6] = CreateDynamicObject(1484, -1963.1925048828, 416.59609985352, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][5] = CreateDynamicObject(1484, -1963.3796386719, 416.69662475586, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][4] = CreateDynamicObject(1484, -1963.3446044922, 416.86737060547, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][3] = CreateDynamicObject(1484, -1963.3403320313, 417.02703857422, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][2] = CreateDynamicObject(1484, -1963.5046386719, 416.95327758789, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][1] = CreateDynamicObject(1484, -1963.5002441406, 416.77334594727, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[0][0] = CreateDynamicObject(1484, -1963.6495361328, 416.86196899414, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
	}
	else if(PlayersBowlingRoad[playerid]==1)
	{
	    BowlingPins[1][9] = CreateDynamicObject(1484, -1963.1579589844, 417.12506103516-Y_ROAD_2, 1.7151190042496, 349.04943847656, 24.473388671875, 6.1903991699219);
		BowlingPins[1][8] = CreateDynamicObject(1484, -1963.1511230469, 416.96856689453-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][7] = CreateDynamicObject(1484, -1963.1798095703, 416.78656005859-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][6] = CreateDynamicObject(1484, -1963.1925048828, 416.59609985352-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][5] = CreateDynamicObject(1484, -1963.3796386719, 416.69662475586-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][4] = CreateDynamicObject(1484, -1963.3446044922, 416.86737060547-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][3] = CreateDynamicObject(1484, -1963.3403320313, 417.02703857422-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][2] = CreateDynamicObject(1484, -1963.5046386719, 416.95327758789-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][1] = CreateDynamicObject(1484, -1963.5002441406, 416.77334594727-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[1][0] = CreateDynamicObject(1484, -1963.6495361328, 416.86196899414-Y_ROAD_2, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
	}
	else if(PlayersBowlingRoad[playerid]==2)
	{
	    BowlingPins[2][9] = CreateDynamicObject(1484, -1963.1579589844, 417.12506103516-Y_ROAD_3, 1.7151190042496, 349.04943847656, 24.473388671875, 6.1903991699219);
		BowlingPins[2][8] = CreateDynamicObject(1484, -1963.1511230469, 416.96856689453-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][7] = CreateDynamicObject(1484, -1963.1798095703, 416.78656005859-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][6] = CreateDynamicObject(1484, -1963.1925048828, 416.59609985352-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][5] = CreateDynamicObject(1484, -1963.3796386719, 416.69662475586-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][4] = CreateDynamicObject(1484, -1963.3446044922, 416.86737060547-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][3] = CreateDynamicObject(1484, -1963.3403320313, 417.02703857422-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][2] = CreateDynamicObject(1484, -1963.5046386719, 416.95327758789-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][1] = CreateDynamicObject(1484, -1963.5002441406, 416.77334594727-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[2][0] = CreateDynamicObject(1484, -1963.6495361328, 416.86196899414-Y_ROAD_3, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
	}
	else if(PlayersBowlingRoad[playerid]==3)
	{
	    BowlingPins[3][9] = CreateDynamicObject(1484, -1963.1579589844, 417.12506103516-Y_ROAD_4, 1.7151190042496, 349.04943847656, 24.473388671875, 6.1903991699219);
		BowlingPins[3][8] = CreateDynamicObject(1484, -1963.1511230469, 416.96856689453-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][7] = CreateDynamicObject(1484, -1963.1798095703, 416.78656005859-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][6] = CreateDynamicObject(1484, -1963.1925048828, 416.59609985352-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][5] = CreateDynamicObject(1484, -1963.3796386719, 416.69662475586-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][4] = CreateDynamicObject(1484, -1963.3446044922, 416.86737060547-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][3] = CreateDynamicObject(1484, -1963.3403320313, 417.02703857422-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][2] = CreateDynamicObject(1484, -1963.5046386719, 416.95327758789-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][1] = CreateDynamicObject(1484, -1963.5002441406, 416.77334594727-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[3][0] = CreateDynamicObject(1484, -1963.6495361328, 416.86196899414-Y_ROAD_4, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
	}
	else if(PlayersBowlingRoad[playerid]==4)
	{
	    BowlingPins[4][9] = CreateDynamicObject(1484, -1963.1579589844, 417.12506103516-Y_ROAD_5, 1.7151190042496, 349.04943847656, 24.473388671875, 6.1903991699219);
		BowlingPins[4][8] = CreateDynamicObject(1484, -1963.1511230469, 416.96856689453-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][7] = CreateDynamicObject(1484, -1963.1798095703, 416.78656005859-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][6] = CreateDynamicObject(1484, -1963.1925048828, 416.59609985352-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][5] = CreateDynamicObject(1484, -1963.3796386719, 416.69662475586-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][4] = CreateDynamicObject(1484, -1963.3446044922, 416.86737060547-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][3] = CreateDynamicObject(1484, -1963.3403320313, 417.02703857422-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][2] = CreateDynamicObject(1484, -1963.5046386719, 416.95327758789-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][1] = CreateDynamicObject(1484, -1963.5002441406, 416.77334594727-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
		BowlingPins[4][0] = CreateDynamicObject(1484, -1963.6495361328, 416.86196899414-Y_ROAD_5, 1.7151190042496, 349.04663085938, 24.472045898438, 6.185302734375);
	}
    return 1;
}
stock PinsKnocked(playerid)
{
    if(AbleToPlay[playerid] == 0) return SendClientMessage(playerid,0xD92626AA,"You didn't start game yet!");
	new Float:x,Float:y,Float:z;
	new knock = random(10);
	switch(knock)
	{
	    case 0:
	    {
	    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][0],x,y,z);
			MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][0],x,y,z-1,2.0);
			LastPin[PlayersBowlingRoad[playerid]][0][playerid] = PIN_GOAWAY;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~1 ~w~pin", 3000, 4);
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 9;
			PlayersBowlingScore[playerid] += 1;
		}
	    case 1:
	    {

    		for(new pin=0; pin<=1; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 8;
			PlayersBowlingScore[playerid] += 2;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~2 ~w~pins", 3000, 4);
	    }
	    case 2:
	    {
  			for(new pin=0; pin<=2; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 7;
			PlayersBowlingScore[playerid] += 3;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~3 ~w~pins", 3000, 4);
	    }
	    case 3:
	    {
  			for(new pin=0; pin<=3; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 4;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 6;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~4 ~w~pins", 3000, 4);

	    }
	    case 4:
	    {
  			for(new pin=0; pin<=4; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 5;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 5;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~5 ~w~pins", 3000, 4);
	    }
	    case 5:
	    {
  			for(new pin=0; pin<=5; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 6;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 4;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~6 ~w~pins", 3000, 4);
	    }
	    case 6:
	    {
  			for(new pin=0; pin<=6; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 7;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 3;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~7 ~w~pins", 3000, 4);
	    }
	    case 7:
	    {
	        for(new pin=0; pin<=7; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 8;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 2;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~8 ~w~pins", 3000, 4);

	    }
	    case 8:
	    {
	        for(new pin=0; pin<=8; pin++)
	    	{
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PlayersBowlingScore[playerid] += 9;
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 1;
			GameTextForPlayer(playerid,"~w~You have knocked~n~ ~g~9 ~w~pins", 3000, 4);

	    }
	    case 9:
	    {
	    	for(new pin=0; pin<=9; pin++)
	    	{
	    	    
     			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][pin][playerid] = PIN_GOAWAY;
			}
			PinsLeft[PlayersBowlingRoad[playerid]][playerid] = 0;
			BowlingStatus[playerid]=N_BOWLING_THROW;
			SetBAccInt(playerid,"Strikes",GetBAccInt(playerid,"Strikes")+1);
			PlayersBowlingScore[playerid] += 15;
			BowlingPinsWaitTimer[playerid] = SetTimerEx("PinsWaitTimer",3000,false,"d",playerid);
			GameTextForPlayer(playerid,"~y~STRIKE!!!", 3000, 4);
	    }
	}
	return 1;
}
stock LastPinsKnocked(playerid)
{
    if(AbleToPlay[playerid] == 0) return SendClientMessage(playerid,0xD92626AA,"You didn't start the game yet!");
    new Float:x,Float:y,Float:z;
	if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 1)
	{
	    new knock = random(2);
		switch(knock)
		{
		    case 0:
		    {
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
				PlayersBowlingScore[playerid] += 1;
			}
		    case 1:
			{
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
			}
		}
		
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 2)
	{
	    new knock = random(4);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
				PlayersBowlingScore[playerid] += 1;
				
			}
			case 1:
		    {
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
				PlayersBowlingScore[playerid] += 1;
				
			}
			case 2:
			{
			    GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
			    GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
			    
			    LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
			    PlayersBowlingScore[playerid] += 2;
			}
			case 3:
			{
			    GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
			    
			    LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
			}
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 3)
	{
	    new knock = random(6);
		switch(knock)
		{
		    case 0:
		    {
   				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				PlayersBowlingScore[playerid] += 3;
				
			}
			case 1:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
			    LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
			    PlayersBowlingScore[playerid] += 1;
			    
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
			    LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
			    PlayersBowlingScore[playerid] += 1;
			    
		    }
		    case 3:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
			    PlayersBowlingScore[playerid] += 2;
			    
		    }
			case 4:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
			    LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
			    PlayersBowlingScore[playerid] += 2;
			    
			}
			case 5:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		}
		    
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 4)
	{
		new knock = random(8);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
			}
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 1;
		    	

		    }
		    case 3:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 1;
		    	
			}
			case 4:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 2;
		    	
			}
			case 5:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 2;
		    	
			}
			case 6:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    	
			}
			case 7:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 3;
			}
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 5)
	{
	    new knock = random(8);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 5;
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				
			}
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
       			LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 1;
		    }
		    case 3:
		    {
            	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 2;
		    }
		    case 4:
		    {
                GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 1;

		    }
		    case 5:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    }
		    case 6:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 3;
		    }
		    case 7:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
		    }
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 6)
	{
		new knock = random(10);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				PlayersBowlingScore[playerid] += 6;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
			}
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
		        LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 1;

		    }
		    case 3:
		    {
            	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 2;
		    	
		    }
		    case 4:
		    {
                GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 1;
		    	

		    }
		    case 5:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    	
		    }
		    case 6:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
		    	
		    }
		    case 7:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~5 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 5;
		    }
		    case 8:
		    {
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 3;
		    
		    }
		    case 9:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
		    
		    }
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 7)
	{
	    new knock = random(13);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 7;
			}
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		        LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 1;
		    	

		    }
		    case 3:
		    {
            	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~2 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 2;
		    }
		    case 4:
		    {
                GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		        LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 1;

		    }
		    case 5:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    }
		    case 6:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
		    }
		    case 7:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~5 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 5;
		    }
		    case 8:
		    {
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 3;

		    }
		    case 9:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;

		    }
		    case 10:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;

		    }
		    case 11:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~5 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 5;
		    }
		    case 12:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~5 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 5;
		    }
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 8)
	{
	    new knock = random(8);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				
		    	LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 8;
		    }
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		    case 2:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 1;
		    	
		    }
		    case 3:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~1 ~w~pin!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 1;
		    	
		    }
		    case 4:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    	
		    }
		    case 5:
		    {
		    	GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 3;

		    }
		    case 6:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~4 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 4;
		    }
		    case 7:
		    {
		        GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~r~You have knocked only ~y~3 ~w~pins!", 3000, 4);
				LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    	PlayersBowlingScore[playerid] += 3;
		    }
		}
	}
	else if(PinsLeft[PlayersBowlingRoad[playerid]][playerid] == 9)
	{
	    new knock = random(2);
		switch(knock)
		{
		    case 0:
		    {
	    		GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][9],x,y,z-1,2.0);
	 			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][8],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][7],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][6],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][5],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][4],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][3],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][2],x,y,z-1,2.0);
				GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][1],x,y,z);
				MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][1],x,y,z-1,2.0);
				GameTextForPlayer(playerid,"~g~SPARE!", 3000, 4);
				
				LastPin[PlayersBowlingRoad[playerid]][1][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_GOAWAY;
				LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_GOAWAY;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_GOAWAY;
		    	PlayersBowlingScore[playerid] += 9;
			}
			case 1:
		    {
		    	GameTextForPlayer(playerid,"~r~You missed!", 3000, 4);
		    	
		    	LastPin[PlayersBowlingRoad[playerid]][1][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][2][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][3][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][4][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][5][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][6][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][7][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][8][playerid] = PIN_LAST;
		    	LastPin[PlayersBowlingRoad[playerid]][9][playerid] = PIN_LAST;
		    }
		}
	}
	return 1;
}
//bowling timers


public PinsWaitTimer(playerid)
{
    new Float:x,Float:y,Float:z;
    for(new pin=0; pin<=MAX_PINS; pin++)
   	{
   	    if(LastPin[PlayersBowlingRoad[playerid]][pin][playerid] == PIN_GOAWAY)
   	    {
			GetDynamicObjectPos(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,z);
			MoveDynamicObject(BowlingPins[PlayersBowlingRoad[playerid]][pin],x,y,1.7151190042496,1.0);
			BowlingPinsWaitEndTimer[playerid] = SetTimerEx("PinsWaitEnd",2000,false,"d",playerid);
		}
	}
}
public PinsWaitEnd(playerid)
{
	BowlingStatus[playerid]=F_BOWLING_THROW;
}
public BowlingCountDown(playerid)
{
	    
	        BowlingSeconds[playerid] -= 1;
	    	new str[150];
			if(PlayersBowlingRoad[playerid]==0)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 1{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,str);
			}
			if(PlayersBowlingRoad[playerid]==1)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 2{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,str);
			}
			if(PlayersBowlingRoad[playerid]==2)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 3{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,str);
			}
			if(PlayersBowlingRoad[playerid]==3)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 4{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,str);
			}
			if(PlayersBowlingRoad[playerid]==4)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,str);
			}
			if(BowlingSeconds[playerid] == 0 && BowlingMinutes[playerid] > 0 )
	    	{
	        	BowlingSeconds[playerid] = 59;
        		BowlingMinutes[playerid] -= 1;
        	}
	        else if(BowlingMinutes[playerid] == 0 && BowlingSeconds[playerid] == 0)
			{
				BowlingSeconds[playerid] = 0;
				BowlingMinutes[playerid] = 0;
				AbleToPlay[playerid] = 0;
				BowlingRoadStatus[PlayersBowlingRoad[playerid]] = ROAD_EMPTY;
				KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
				SendClientMessage(playerid,COLOR_CMDERROR,"Time of your game ended.");
				scmf(playerid,COLOR_CMDERROR,"{FFFFFF}You scored {00CC00}%i {FFFFFF}points!",PlayersBowlingScore[playerid],PlayersBowlingScore[playerid]*10);
				if(PlayersBowlingScore[playerid] > GetBAccInt(playerid,"BestScore"))
				{
    				scmf(playerid,0xD92626AA,"{00CC00}You beated your best score: {FFFFFF}%i!",GetBAccInt(playerid,"BestScore"));
 					scmf(playerid,0xFFFFFF,"{00CC00}New best score is: {FFFFFF}%i!",PlayersBowlingScore[playerid]);
					SetBAccInt(playerid,"BestScore",PlayersBowlingScore[playerid]);
				}
				else
				{
					scmf(playerid,0xD92626AA,"{00CC00}Your best score is: {FFFFFF}%i!",GetBAccInt(playerid,"BestScore"));
				}
				PlayersBowlingScore[playerid] = 0;
				DestroyBall(playerid);

 				if(PlayersBowlingRoad[playerid]==0)
 				{
			 		UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,"{008800}[{FFFFFF} Road 1{008800} ]\n Empty");
			 		PlayersBowlingRoad[playerid] = ROAD_NONE;
			 		DestroyPins(0);
	 			}
 				else if(PlayersBowlingRoad[playerid]==1)
 				{
			 		UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,"{008800}[{FFFFFF} Road 2{008800} ]\n Empty");
			 		PlayersBowlingRoad[playerid] = ROAD_NONE;
			 		DestroyPins(1);
			 	}
				else if(PlayersBowlingRoad[playerid]==2)
				{
					UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,"{008800}[{FFFFFF} Road 3{008800} ]\n Empty");
					PlayersBowlingRoad[playerid] = ROAD_NONE;
					DestroyPins(2);
				}
				else if(PlayersBowlingRoad[playerid]==3)
				{
					UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,"{008800}[{FFFFFF} Road 4{008800} ]\n Empty");
					PlayersBowlingRoad[playerid] = ROAD_NONE;
					DestroyPins(3);
				}
				else if(PlayersBowlingRoad[playerid]==4)
				{
					UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,"{008800}[{FFFFFF} Road 5{008800} ]\n Empty");
					PlayersBowlingRoad[playerid] = ROAD_NONE;
					DestroyPins(4);
				}
				
			}
			return 1;
}
public BallGoingTimer(playerid)
{
    MoveBall(playerid);
    BallRun[playerid] = SetTimerEx("BallRunTimer",BALL_RUN_TIME,false,"d",playerid);
	return 1;
}
public BallRunTimer(playerid)
{
	if(BowlingStatus[playerid]==F_BOWLING_THROW)
    {
    	PinsKnocked(playerid);
    	BowlingStatus[playerid]=S_BOWLING_THROW;
	}
	else if(BowlingStatus[playerid]==S_BOWLING_THROW)
	{
	    LastPinsKnocked(playerid);
	    BowlingStatus[playerid]=N_BOWLING_THROW;
	    BowlingPinsWaitTimer[playerid] = SetTimerEx("PinsWaitTimer",4000,false,"d",playerid);
	}
	DestroyDynamicObject(BowlingBall[PlayersBowlingRoad[playerid]]);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_BOWLING_STATS)
	{
	    if(response) return 1;
	}
    if(dialogid == DIALOG_BOWLING)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                if(AbleToPlay[playerid] == 1) return SendClientMessage(playerid,0xD92626AA,"You are already playing!");
	                ShowPlayerDialog(playerid,DIALOG_ROAD, DIALOG_STYLE_LIST, "Choose the road", "{00AA00}1. {FFFFFF}Road 1 \n{00AA00}2. {FFFFFF}Road 2 \n{00AA00}3. {FFFFFF}Road 3 \n{00AA00}4. {FFFFFF}Road 4 \n{00AA00}5. {FFFFFF}Road 5  ", "Ok", "Back");
	            }
	            case 1:
	            {
	                if(AbleToPlay[playerid] == 0) return SendClientMessage(playerid,0xD92626AA,"You didn't start the game!");
	                AbleToPlay[playerid] = 0;
	                BowlingRoadStatus[PlayersBowlingRoad[playerid]] = ROAD_EMPTY;
	                KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
	                BowlingMinutes[playerid] = 0;
	                BowlingSeconds[playerid] = 0;
	                SendClientMessage(playerid,0xD92626AA,"You ended the game!");
	                scmf(playerid,COLOR_CMDERROR,"{FFFFFF}You scored {00CC00}%i {FFFFFF}points!",PlayersBowlingScore[playerid],PlayersBowlingScore[playerid]*10);
					DestroyBall(playerid);
					
					if(PlayersBowlingScore[playerid] > GetBAccInt(playerid,"BestScore"))
					{
					    scmf(playerid,0xD92626AA,"{00CC00}You beated your best score: {FFFFFF}%i!",GetBAccInt(playerid,"BestScore"));
            			scmf(playerid,0xFFFFFF,"{00CC00}New best score is: {FFFFFF}%i!",PlayersBowlingScore[playerid]);
						SetBAccInt(playerid,"BestScore",PlayersBowlingScore[playerid]) ;
					}
					else
					{
      					scmf(playerid,0xD92626AA,"{00CC00}Your best score is: {FFFFFF}%i!",GetBAccInt(playerid,"BestScore"));
					}
                    PlayersBowlingScore[playerid] = 0;
	                if(PlayersBowlingRoad[playerid]==0)
	                {
						UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,"{008800}[{FFFFFF} Road 1{008800} ]\n Empty");
						PlayersBowlingRoad[playerid] = ROAD_NONE;
	                	DestroyPins(0);
	                }
					else if(PlayersBowlingRoad[playerid]==1)
					{
						UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,"{008800}[{FFFFFF} Road 2{008800} ]\n Empty");
						PlayersBowlingRoad[playerid] = ROAD_NONE;
						DestroyPins(1);
					}
					else if(PlayersBowlingRoad[playerid]==2)
					{
						UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,"{008800}[{FFFFFF} Road 3{008800} ]\n Empty");
						PlayersBowlingRoad[playerid] = ROAD_NONE;
						DestroyPins(2);
                    }
					else if(PlayersBowlingRoad[playerid]==3)
                    {
						UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,"{008800}[{FFFFFF} Road 4{008800} ]\n Empty");
						PlayersBowlingRoad[playerid] = ROAD_NONE;
						DestroyPins(3);
                    }
					else if(PlayersBowlingRoad[playerid]==4)
					{
						UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,"{008800}[{FFFFFF} Road 5{008800} ]\n Empty");
						PlayersBowlingRoad[playerid] = ROAD_NONE;
						DestroyPins(4);
					}
	                
	                return 1;
	            }
	            case 2:
	            {
	                if(AbleToPlay[playerid] == 0) return SendClientMessage(playerid,0xD92626AA,"You didn't start game yet!");
                    ShowPlayerDialog(playerid,DIALOG_ADD_TIME, DIALOG_STYLE_LIST, "Add time","{00AA00}+3 {FFFFFF}minutes {00AA00} 30$ \n{00AA00}+5 {FFFFFF}minutes {00AA00} 50$ \n{00AA00}+10 {FFFFFF}minutes{00AA00} 100$ \n{00AA00}+25 {FFFFFF}minutes{00AA00} 250$ \n{00AA00}+30 {FFFFFF}minutes{00AA00} 300$ ","Ok","Back");
	            }
	        }
	    }
	    return 1;
	}
	if(dialogid == DIALOG_ROAD)
	{
    	if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                if(BowlingRoadStatus[0] == ROAD_EMPTY)
	                {
						PlayersBowlingRoad[playerid] = 0;
						ShowPlayerDialog(playerid,DIALOG_BOWLING_TIME, DIALOG_STYLE_LIST, "Time","{BBBB00}3 {FFFFFF}minutes {00AA00} 30$ \n{BBBB00}5 {FFFFFF}minutes {00AA00} 50$ \n{BBBB00}10 {FFFFFF}minutes{00AA00} 100$ \n{BBBB00}25 {FFFFFF}minutes{00AA00} 250$ \n{BBBB00}30 {FFFFFF}minutes{00AA00} 300$ ","Ok","Back");
					}
					else if(BowlingRoadStatus[0] == ROAD_BUSY) return SendClientMessage(playerid,COLOR_CMDERROR,"Road занята.");
				}
				case 1:
	            {
	                if(BowlingRoadStatus[1] == ROAD_EMPTY)
					{
					    PlayersBowlingRoad[playerid] = 1;
						ShowPlayerDialog(playerid,DIALOG_BOWLING_TIME, DIALOG_STYLE_LIST, "Time","{BBBB00}3 {FFFFFF}minutes {00AA00} 30$ \n{BBBB00}5 {FFFFFF}minutes {00AA00} 50$ \n{BBBB00}10 {FFFFFF}minutes{00AA00} 100$ \n{BBBB00}25 {FFFFFF}minutes{00AA00} 250$ \n{BBBB00}30 {FFFFFF}minutes{00AA00} 300$ ","Ok","Back");
					}
					else if(BowlingRoadStatus[1] == ROAD_BUSY) return SendClientMessage(playerid,COLOR_CMDERROR,"Road занята.");
				}
				case 2:
	            {
	                if(BowlingRoadStatus[2] == ROAD_EMPTY)
	                {
						PlayersBowlingRoad[playerid] = 2;
						ShowPlayerDialog(playerid,DIALOG_BOWLING_TIME, DIALOG_STYLE_LIST, "Time","{BBBB00}3 {FFFFFF}minutes {00AA00} 30$ \n{BBBB00}5 {FFFFFF}minutes {00AA00} 50$ \n{BBBB00}10 {FFFFFF}minutes{00AA00} 100$ \n{BBBB00}25 {FFFFFF}minutes{00AA00} 250$ \n{BBBB00}30 {FFFFFF}minutes{00AA00} 300$ ","Ok","Back");
					}
					else if(BowlingRoadStatus[2] == ROAD_BUSY) return SendClientMessage(playerid,COLOR_CMDERROR,"Road занята.");
				}
				case 3:
	            {
	                if(BowlingRoadStatus[3] == ROAD_EMPTY)
	                {
						PlayersBowlingRoad[playerid] = 3;
						ShowPlayerDialog(playerid,DIALOG_BOWLING_TIME, DIALOG_STYLE_LIST, "Time","{BBBB00}3 {FFFFFF}minutes {00AA00} 30$ \n{BBBB00}5 {FFFFFF}minutes {00AA00} 50$ \n{BBBB00}10 {FFFFFF}minutes{00AA00} 100$ \n{BBBB00}25 {FFFFFF}minutes{00AA00} 250$ \n{BBBB00}30 {FFFFFF}minutes{00AA00} 300$ ","Ok","Back");
					}
					else if(BowlingRoadStatus[3] == ROAD_BUSY) return SendClientMessage(playerid,COLOR_CMDERROR,"Road занята.");
				}
				case 4:
	            {
	                if(BowlingRoadStatus[4] == ROAD_EMPTY)
	                {
						PlayersBowlingRoad[playerid] = 4;
						ShowPlayerDialog(playerid,DIALOG_BOWLING_TIME, DIALOG_STYLE_LIST, "Time","{BBBB00}3 {FFFFFF}minutes {00AA00} 30$ \n{BBBB00}5 {FFFFFF}minutes {00AA00} 50$ \n{BBBB00}10 {FFFFFF}minutes{00AA00} 100$ \n{BBBB00}25 {FFFFFF}minutes{00AA00} 250$ \n{BBBB00}30 {FFFFFF}minutes{00AA00} 300$","Ok","Back");
					}
					else if(BowlingRoadStatus[4] == ROAD_BUSY) return SendClientMessage(playerid,COLOR_CMDERROR,"Road busy.");
				}
			}
		}
  		else if(!response)
  		{
  	 		PlayersBowlingRoad[playerid] = ROAD_NONE;
   			ShowPlayerDialog(playerid,DIALOG_BOWLING, DIALOG_STYLE_LIST, "Bowling", "{00AA00}1. {FFFFFF}Take a road \n{00AA00}2. {FFFFFF}End your game \n{00AA00}3. {FFFFFF}Add more time ", "Ok", "Exit");
		}
	}
	if(dialogid == DIALOG_BOWLING_TIME)
	{
		if(response)
	    {
	        switch(listitem)
	        {
	        	case 0:
	        	{
					GameTextForPlayer(playerid,"~y~+3 ~w~minutes",3000,1);
					BowlingMinutes[playerid] = 2;
					GivePlayerCash(playerid,-30);
	        	}
	        	case 1:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+5 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] = 4;
	        	    GivePlayerCash(playerid,-50);
	        	}
	        	case 2:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+10 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] = 9;
	        	    GivePlayerCash(playerid,-100);
	        	}
	        	case 3:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+25 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] = 24;
	        	    GivePlayerCash(playerid,-250);
	        	}
	        	case 4:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+30 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] = 29;
	        	    GivePlayerCash(playerid,-300);
	        	}
			}
			new str[150];
			BowlingSeconds[playerid]=59;
			KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
			BowlingTimer[PlayersBowlingRoad[playerid]] = SetTimerEx("BowlingCountDown",1000,true,"d",playerid);
			CreatePins(playerid);
			if(PlayersBowlingRoad[playerid]==0)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[0], 0xFFFFFF,str);
			}
			else if(PlayersBowlingRoad[playerid]==1)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[1], 0xFFFFFF,str);
			}
			else if(PlayersBowlingRoad[playerid]==2)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[2], 0xFFFFFF,str);
			}
			else if(PlayersBowlingRoad[playerid]==3)
			{
				format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[3], 0xFFFFFF,str);
			}
			else if(PlayersBowlingRoad[playerid]==4)
			{
			    format(str,150,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d \n {BBBB00} Points:{FFFFFF} %i",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid],PlayersBowlingScore[playerid]);
				UpdateDynamic3DTextLabelText(BowlingRoadScreen[4], 0xFFFFFF,str);
			}
	
			BowlingRoadStatus[PlayersBowlingRoad[playerid]] = ROAD_BUSY;
			AbleToPlay[playerid] = 1;
			SendClientMessage(playerid,0xFFFFFF,"{00CC00}You started the game!");
			scmf(playerid,0xFFFFFF,"{00CC00}Last time you played: {FFFFFF}%s.",GetBAccString(playerid,"LastTimePlayed"));
            scmf(playerid,0xFFFFFF,"{00CC00}Your best score is: {FFFFFF}%i.",GetBAccInt(playerid,"BestScore"));
            new year,month,day;	getdate(year, month, day);
			new strdate[128];
			format(strdate,128,"%02d.%02d.%02d", day, month, year);
			SetBAccString(playerid,"LastTimePlayed", strdate);
			return 1;
		}
        else if(!response)
        {
            ShowPlayerDialog(playerid,DIALOG_ROAD, DIALOG_STYLE_LIST, "Choose the road", "{00AA00}1. {FFFFFF}Road 1 \n{00AA00}2. {FFFFFF}Road 2 \n{00AA00}3. {FFFFFF}Road 3 \n{00AA00}4. {FFFFFF}Road 4 \n{00AA00}5. {FFFFFF}Road 5  ", "Ok", "Back");
		}
	}
	if(dialogid == DIALOG_ADD_TIME)
	{
		if(response)
	    {
     		switch(listitem)
	        {
	        	case 0:
	        	{
					GameTextForPlayer(playerid,"~y~+3 ~w~minutes",3000,1);
					BowlingMinutes[playerid] += 3;
					GivePlayerCash(playerid,-30);
	        	}
	        	case 1:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+5 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] += 5;
	        	    GivePlayerCash(playerid,-50);
	        	}
	        	case 2:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+10 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] += 10;
	        	    GivePlayerCash(playerid,-100);
	        	}
	        	case 3:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+25 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] += 25;
	        	    GivePlayerCash(playerid,-250);
	        	}
	        	case 4:
	        	{
	        	    GameTextForPlayer(playerid,"~y~+30 ~w~minutes",3000,1);
	        	    BowlingMinutes[playerid] += 30;
	        	    GivePlayerCash(playerid,-300);
	        	}
			}
			new str[128];
			KillTimer(BowlingTimer[PlayersBowlingRoad[playerid]]);
			BowlingTimer[PlayersBowlingRoad[playerid]] = SetTimerEx("BowlingCountDown",1000,true,"d",playerid);
			format(str,128,"{E32A2A}[{FFFFFF} Road 5{E32A2A} ]\n Busy \n {BBBB00}Player: {FFFFFF}%s\n {BBBB00} Time:{FFFFFF} %02d : %02d ",PlayerName(playerid),BowlingMinutes[playerid],BowlingSeconds[playerid]);
			UpdateDynamic3DTextLabelText(BowlingRoadScreen[PlayersBowlingRoad[playerid]], 0xFFFFFF,str);
		}
        else if(!response)
        {
            ShowPlayerDialog(playerid,DIALOG_BOWLING, DIALOG_STYLE_LIST, "Bowling {B0020B}({ffffff}$15{B0020B})", "{00AA00}1. {FFFFFF}Take a road \n {00AA00}2. {FFFFFF}End the game \n {00AA00}3. {FFFFFF}Add more time ", "Ok", "Exit");
        }
	}
	return 0;
}
public GetClosestPlayer(p1)
{
    new x,Float:dis,Float:dis2,player;
    player = -1;
    dis = 99999.99;
    for (x=0;x<MAX_PLAYERS;x++)
    {
        if(IsPlayerConnected(x))
        {
            if(x != p1)
            {
                dis2 = GetDistanceBetweenPlayers(x,p1);
                if(dis2 < dis && dis2 != -1.00)
                {
                    dis = dis2;
                    player = x;
                }
            }
        }
    }
    return player;
}
public Float:GetDistanceBetweenPlayers(p1,p2)
{
    new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
    if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2))
    {
        return -1.00;
    }
    GetPlayerPos(p1,x1,y1,z1);
    GetPlayerPos(p2,x2,y2,z2);
    return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}
stock PlayerName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,MAX_PLAYER_NAME);
    return name;
}
//formated message
#define scm(%0,%1,%2) SendClientMessage(%0,%1,%2)
scmf(playerid,color,fstring[],{Float, _}:...) {
   new n=(numargs()-3)*4;
   if(n) {
      new message[255],arg_start,arg_end;
      #emit CONST.alt                fstring
      #emit LCTRL                    5
      #emit ADD
      #emit STOR.S.pri               arg_start
      #emit LOAD.S.alt               n
      #emit ADD
      #emit STOR.S.pri               arg_end
      do {
         #emit LOAD.I
         #emit PUSH.pri
         arg_end-=4;
         #emit LOAD.S.pri           arg_end
      }
      while(arg_end>arg_start);
      #emit PUSH.S                   fstring
      #emit PUSH.C                   255
      #emit PUSH.ADR                 message
      n+=4*3;
      #emit PUSH.S                   n
      #emit SYSREQ.C                 format
      n+=4;
      #emit LCTRL                    4
      #emit LOAD.S.alt               n
      #emit ADD
      #emit SCTRL                    4
      return scm(playerid,color,message);
   } else return scm(playerid,color,fstring);
}
stock BAccParamName(playerid,paramname[])
{
    new fParam[128];
	format(fParam, sizeof fParam, "%s/%s",PlayerName(playerid),paramname);
	return fParam;
}
public SetBAccInt(playerid,param[],value)
{
    djSetInt(B_ACC_FILE,BAccParamName(playerid,param),value);
    return 1;
}
public SetBAccString(playerid,param[],value[])
{
    djSet(B_ACC_FILE,BAccParamName(playerid,param),value);
    return 1;
}
stock GetBAccInt(playerid,param[])
{
	new intParam;
	intParam = djInt(B_ACC_FILE,BAccParamName(playerid,param));
 	return intParam;
}
stock GetBAccString(playerid,param[])
{
	new strParam[128];
	format(strParam, sizeof strParam, "%s", dj(B_ACC_FILE,BAccParamName(playerid,param)));
 	return strParam;
}
public IsBAccParamExists(playerid,param[])
{
    return djIsSet(B_ACC_FILE,BAccParamName(playerid,param),false);
}
public IsBAccExists(accname[])
{
    return djIsSet(B_ACC_FILE,accname,false);
}
public BAccSysInit()
{
    if(!fexist(B_ACC_FILE)) djCreateFile(B_ACC_FILE);
    else return 1;
	return 1;
}
public CreateBCoordFile()
{
    djCreateFile(B_COORD_FILE);
    return 1;
}
stock BCoordType(coordtype[],coordname[])
{
	new fCoord[128];
	format(fCoord, sizeof fCoord, "%s/%s",coordtype,coordname);
	return fCoord;
}
public Float:GetBCoord(coordtype[],coordname[])
{
	new Float:floatParam;
	floatParam = djFloat(B_COORD_FILE,BCoordType(coordtype,coordname));
	return floatParam;
}
public SetBCoord(coordtype[],coordname[],Float:value)
{
    djSetFloat(B_COORD_FILE,BCoordType(coordtype,coordname),value);
	return 1;
}
public BCoordsInit()
{
    BowlingEnterPickup = CreateDynamicPickup(1318,23, GetBCoord("pickup","CoordX"),GetBCoord("pickup","CoordY"),GetBCoord("pickup","CoordZ"),-1);//last edit adding "," after "GetBCoord("pickup","CoordZ")"
    BowlingMainLabel = CreateDynamic3DTextLabel("[* {FFFFFF}Bowling {0C9BCB}*]",0x0C9BCBFF, GetBCoord("pickup","CoordX"),GetBCoord("pickup","CoordY"),GetBCoord("pickup","CoordZ")+1,40.0);
	BowlingMapIcon = CreateDynamicMapIcon(GetBCoord("pickup","CoordX"),GetBCoord("pickup","CoordY"),GetBCoord("pickup","CoordZ"), 48, -1, 0, 0, -1, 50.0);
	return 1;
}

stock GivePlayerCash(playerid, money)
{
	SetPVarInt(playerid, "Cash", GetPVarInt(playerid, "Cash")+money);
	GivePlayerMoney(playerid, money);
	return 1;
}
