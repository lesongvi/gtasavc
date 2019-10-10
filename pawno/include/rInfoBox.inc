#if defined _rInfoBox_included
    #endinput
#endif
#define _rInfoBox_included
#define X_DIFF 2
/*
native CreateTDboxForPlayer(playerid, title[], titlecolor, string[]);
native ShowTDboxToPlayer(playerid, boxid);
native HideTDboxForPlayer(playerid, boxid);
native ResetTDboxes();
native IsPlayerViewingTDBox(playerid, boxid);
native IsPlayerViewingAnyTDBox(playerid);
*/

#define FILTERSCRIPT
#define MAX_TMENUS 10
#include <a_samp>
#include <YSI\y_hooks>

new PlayerText:Textdraw0;
new PlayerText:Textdraw1;
new PlayerText:Textdraw2;
new PlayerText:Textdraw3;
new PlayerText:Textdraw4;


enum iBox
{
	bool:mCreated,
	mString[1024],
	mTitle[50],
	mtColor,
	bool:mShown,
	Float:iX,
	Float:iY
}
new InfoBox[MAX_TMENUS][iBox];


stock CreateTDboxForPlayer(playerid, title[], titlecolor, string[])
{
for(new i = 0; i<MAX_TMENUS; i++)
{
if(InfoBox[i][mCreated] == false)
{

format(InfoBox[i][mString], 1024, "%s", string);
format(InfoBox[i][mTitle], 50, "%s", title);
InfoBox[i][mtColor] = titlecolor;
InfoBox[i][mCreated] = true;
Textdraw0 = CreatePlayerTextDraw(playerid, 247.505126, 176.500000, "usebox");
PlayerTextDrawLetterSize(playerid, Textdraw0, 0.000000, 17.118520);
PlayerTextDrawTextSize(playerid, Textdraw0, 37.355781, 0.000000);
PlayerTextDrawAlignment(playerid, Textdraw0, 1);
PlayerTextDrawColor(playerid, Textdraw0, 0);
PlayerTextDrawUseBox(playerid, Textdraw0, true);
PlayerTextDrawBoxColor(playerid, Textdraw0, 302450784);
PlayerTextDrawSetShadow(playerid, Textdraw0, 0);
PlayerTextDrawSetOutline(playerid, Textdraw0, 0);
PlayerTextDrawFont(playerid, Textdraw0, 0);

Textdraw1 = CreatePlayerTextDraw(playerid, 115.724731, 179.666656, "Title");
PlayerTextDrawLetterSize(playerid, Textdraw1, 0.449999, 1.600000);
PlayerTextDrawAlignment(playerid, Textdraw1, 1);
PlayerTextDrawColor(playerid, Textdraw1, -1);
PlayerTextDrawSetShadow(playerid, Textdraw1, 0);
PlayerTextDrawSetOutline(playerid, Textdraw1, 1);
PlayerTextDrawBackgroundColor(playerid, Textdraw1, 51);
PlayerTextDrawFont(playerid, Textdraw1, 2);
PlayerTextDrawSetProportional(playerid, Textdraw1, 1);

Textdraw2 = CreatePlayerTextDraw(playerid, 41.935429, 197.750000, "LD_SPAC:white");
PlayerTextDrawLetterSize(playerid, Textdraw2, 0.000000, 0.000000);
PlayerTextDrawTextSize(playerid, Textdraw2, 197.715972, 1.166656);
PlayerTextDrawAlignment(playerid, Textdraw2, 1);
PlayerTextDrawColor(playerid, Textdraw2, -1);
PlayerTextDrawSetShadow(playerid, Textdraw2, 0);
PlayerTextDrawSetOutline(playerid, Textdraw2, 0);
PlayerTextDrawFont(playerid, Textdraw2, 4);

Textdraw3 = CreatePlayerTextDraw(playerid, 47.320648, 212.333328, "First string");
PlayerTextDrawLetterSize(playerid, Textdraw3, 0.301000, 1.220800);
PlayerTextDrawAlignment(playerid, Textdraw3, 1);
PlayerTextDrawColor(playerid, Textdraw3, -5963521);
PlayerTextDrawSetShadow(playerid, Textdraw3, 0);
PlayerTextDrawSetOutline(playerid, Textdraw3, 1);
PlayerTextDrawBackgroundColor(playerid, Textdraw3, 255);
PlayerTextDrawFont(playerid, Textdraw3, 1);
PlayerTextDrawSetProportional(playerid, Textdraw3, 1);

Textdraw4 = CreatePlayerTextDraw(playerid, 247.036605, 176.500000, "usebox");
PlayerTextDrawLetterSize(playerid, Textdraw4, 0.000000, 2.146295);
PlayerTextDrawTextSize(playerid, Textdraw4, 36.887260, 0.000000);
PlayerTextDrawAlignment(playerid, Textdraw4, 1);
PlayerTextDrawColor(playerid, Textdraw4, 0);
PlayerTextDrawUseBox(playerid, Textdraw4, true);
PlayerTextDrawBoxColor(playerid, Textdraw4, 102);
PlayerTextDrawSetShadow(playerid, Textdraw4, 0);
PlayerTextDrawSetOutline(playerid, Textdraw4, 0);
PlayerTextDrawFont(playerid, Textdraw4, 0);
return i;
}
else continue;
}
return 0;
}

stock ShowTDboxToPlayer(playerid, boxid)
{
	PlayerTextDrawSetString(playerid, Textdraw1, InfoBox[boxid][mTitle]);
	PlayerTextDrawSetString(playerid, Textdraw3, InfoBox[boxid][mString]);
	PlayerTextDrawColor(playerid, Textdraw2, InfoBox[boxid][mtColor]);
	InfoBox[boxid][mShown] = true;
 	PlayerTextDrawShow(playerid, Textdraw0);
 	PlayerTextDrawShow(playerid, Textdraw1);
	PlayerTextDrawShow(playerid, Textdraw2);
	PlayerTextDrawShow(playerid, Textdraw3);
	PlayerTextDrawShow(playerid, Textdraw4);
	return 1;
}

stock HideTDboxForPlayer(playerid, boxid)
{
    InfoBox[boxid][mShown] = false;
	PlayerTextDrawHide(playerid, Textdraw0);
 	PlayerTextDrawHide(playerid, Textdraw1);
	PlayerTextDrawHide(playerid, Textdraw2);
	PlayerTextDrawHide(playerid, Textdraw3);
	PlayerTextDrawHide(playerid, Textdraw4);
	return 1;
}
stock IsPlayerViewingTDBox(playerid, boxid)
{
	if(InfoBox[boxid][mShown] == true) return 1;
	else return 0;
}

stock IsPlayerViewingAnyTDBox(playerid)
{
	for(new i; i < MAX_TMENUS; i++){
	if(InfoBox[i][mShown] = true) return true;}
	return 0;
}

stock ResetTDboxes()
{
	for(new i; i = MAX_TMENUS; i++)
	{
		InfoBox[i][mCreated] = 0;
		InfoBox[i][mString] = " ";
		InfoBox[i][mTitle] = " ";
		InfoBox[i][mtColor] = " ";
	}
	return 1;
}