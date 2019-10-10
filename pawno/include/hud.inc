#include <a_samp>

//------------------------------------------------------------------------------

#define hud_red -16776961
#define hud_green 16711935
#define hud_fuchsia -16711681
#define hud_cyan 16777215
#define hud_orange -5963521
#define hud_maroon -2147483393
#define hud_yellow -65281
#define hud_blue 65535
#define hud_brown -1523963137
#define hud_lightblue -1378294017
#define hud_purple -2147450625
#define hud_grey -2139062017
#define hud_lime 16711935

//------------------------------------------------------------------------------

#define hud_fist 1
#define hud_cash 2
#define hud_cashicon 3

//------------------------------------------------------------------------------

new Text:Fist, Text:Cash, Text:CashIcon, Hud[MAX_PLAYERS];

//------------------------------------------------------------------------------

stock SetPlayerHudColor(playerid, hud, hud_colors)
{
	if(hud == hud_fist)
	{
		TextDrawColor(Fist, hud_colors);
		TextDrawShowForPlayer(playerid, Fist);
	}
	else if(hud == hud_cash)
	{
        TextDrawColor(Cash, hud_colors);
		TextDrawShowForPlayer(playerid, Cash);
		Hud[playerid] = 1;
	}
	else if(hud == hud_cashicon)
	{
		TextDrawColor(CashIcon, hud_colors);
		TextDrawShowForPlayer(playerid, CashIcon);
	}
}

//------------------------------------------------------------------------------

stock RemovePlayerFistHud(playerid)
{
	TextDrawHideForPlayer(playerid, Fist);
}

//------------------------------------------------------------------------------

stock RemovePlayerCashHud(playerid)
{
	TextDrawHideForPlayer(playerid, Cash);
                Hud[playerid] = 0;
}

//------------------------------------------------------------------------------

stock RemovePlayerCashIconHud(playerid)
{
    TextDrawHideForPlayer(playerid, CashIcon);
}

//------------------------------------------------------------------------------

stock RemovePlayerHuds(playerid)
{
    TextDrawHideForPlayer(playerid, Cash);
    TextDrawHideForPlayer(playerid, Fist);
    TextDrawHideForPlayer(playerid, CashIcon);
	Hud[playerid] = 0;
}

//------------------------------------------------------------------------------

public OnFilterScriptInit()
{
    Fist = TextDrawCreate(496.799957, 20.159988, "hud:fist");
	TextDrawLetterSize(Fist, 0.000000, 0.000000);
	TextDrawTextSize(Fist, 47.200027, 56.000022);
	TextDrawAlignment(Fist, 1);
	TextDrawColor(Fist, -65281);
	TextDrawSetShadow(Fist, 0);
	TextDrawSetOutline(Fist, 0);
	TextDrawFont(Fist, 4);

	//--------------------------------------------------------------------------

	Cash = TextDrawCreate(511.199951, 75.413330, "00000000");
	TextDrawLetterSize(Cash, 0.579600, 2.510933);
	TextDrawAlignment(Cash, 1);
	TextDrawColor(Cash, 8388863);
	TextDrawSetShadow(Cash, 0);
	TextDrawSetOutline(Cash, 1);
	TextDrawBackgroundColor(Cash, 51);
	TextDrawFont(Cash, 3);
	TextDrawSetProportional(Cash, 1);
	
	//--------------------------------------------------------------------------
	
	CashIcon = TextDrawCreate(495.999969, 73.920028, "$");
	TextDrawLetterSize(CashIcon, 0.571600, 2.772265);
	TextDrawAlignment(CashIcon, 1);
	TextDrawColor(CashIcon, 41215);
	TextDrawSetShadow(CashIcon, 0);
	TextDrawSetOutline(CashIcon, 1);
	TextDrawBackgroundColor(CashIcon, 51);
	TextDrawFont(CashIcon, 2);
	TextDrawSetProportional(CashIcon, 1);
	return 1;
}

//------------------------------------------------------------------------------

public OnPlayerUpdate(playerid)
{
	new string[20];
	if(Hud[playerid] == 1)
	{
        format(string, sizeof(string), "%08d", GetPlayerMoney(playerid));
        TextDrawSetString(Cash, string);
        TextDrawShowForPlayer(playerid, Cash);
	}
	return 1;
}

//------------------------------------------------------------------------------