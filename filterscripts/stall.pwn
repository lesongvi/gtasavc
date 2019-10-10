// Quioscos de Hotdog dinamicos por Zume-Zero

#include <a_samp>
#include <zcmd>
#include <dini>
#include <sscanf2>
#include <streamer>

// Pragma :3
#pragma tabsize 0

// Defines <3
#define 			DIR_HOTDOG 					"QHotDog/Quiosco%d.ini"
#define 			QUIOSCOSHD_MAX 						100
#define 			DISTANCIA_QUIOSCO 					3.0 // Desde donde se podrá usar el comando.
#define 			COLOR_GENERALFS 					0xCECECEFF
#define             Q_H_DIALOGO                         128 // Dialogo ID
#define             NODINERO_HD                     	"You don't have enough!"
#define             LABEL_INFORMACION                   "\t {DEE613}Hotdog Stand\n{FFFFFF}ID:  {DEE613}%d\n{FFFFFF}Use {DEE613}/buyhotdog!"
#define             ID_QUIOSCO_OB                       1340
// Precios de las comidas :3 pueden aumentar más!
#define             PRECIO_COMIDA1                      5
#define             PRECIO_COMIDA2                      10
#define             PRECIO_COMIDA3                      15

// :3 Zume-Zero <3
#define CREADORFS3 "e"
#define CREADORFS "Z"
#define CREADORFS4 "r"
#define CREADORFS1 "u"
#define CREADORFS2 "m"
#define CREADORFS5 "o"
#define CREADORFS6 "-"

enum INFOHD
{
	// ID del Quiosco.
    IDObjetoHD,
    // Posiciones del Quiosco.
	Float:PosicionHotdog[4],
};

// News
new Text3D:QuioscoLabel[QUIOSCOSHD_MAX], QuioscosActuales, DeNuevo[MAX_PLAYERS],
	HotDogInfo[QUIOSCOSHD_MAX][INFOHD];

public OnFilterScriptInit(){
	CargarQuioscos();
	printf( "\n\n\tQuioscos de HotDog dinámicos creado por %s%s%s%s%s%s%s%s%s", CREADORFS,CREADORFS1,CREADORFS2,CREADORFS3,CREADORFS6,CREADORFS,CREADORFS3,CREADORFS4,CREADORFS5);
	printf( "\tQuioscos de HotDog %d cargados.\n", QuioscosActuales);
	return 1;
}

public OnFilterScriptExit(){
    GuardarQuioscos();
	return 1;
}

// Crear Quiosco
CMD:createstand(playerid, params[]){
	// New
	if(IsPlayerAdmin(playerid))
	{
	new string[256],Float:X,Float:Y,Float:Z,Float:A,Float:MOVER_X, Float:MOVER_Y, Float:MOVER_Z, NuevoHotdog = QuioscosActuales+1,
		mStr[50];
 	if(NuevoHotdog >= QUIOSCOSHD_MAX) return SendClientMessage(playerid, COLOR_GENERALFS, "Ya hay el limite de Quioscos, no puedes poner más!");
 	format(string, sizeof(string), DIR_HOTDOG, NuevoHotdog);
 	if(dini_Exists(string))
 	{
	AumentarQuiosco();
	format(string, sizeof(string), "/createstand", NuevoHotdog);
	SendClientMessage( playerid, COLOR_GENERALFS, string);
	}
	else
 	{
	GetPlayerPos(playerid, MOVER_X, MOVER_Y, MOVER_Z),GetPlayerPos(playerid, X,Y,Z),GetPlayerFacingAngle(playerid, A);

	HotDogInfo[NuevoHotdog][PosicionHotdog][0] = X;
	HotDogInfo[NuevoHotdog][PosicionHotdog][1] = Y;
	HotDogInfo[NuevoHotdog][PosicionHotdog][2] = Z;
	HotDogInfo[NuevoHotdog][PosicionHotdog][3] = A;
	dini_Create(string);
	// Archivos

	dini_IntSet(string, "IDObjetoHD", HotDogInfo[NuevoHotdog][IDObjetoHD]);
	for(new m = 0; m < 4; m++){
		format(mStr,sizeof(mStr), "HotDogPos%d", m);
 		dini_FloatSet(string,mStr, HotDogInfo[NuevoHotdog][PosicionHotdog][m]);
	}

	DeNuevo[playerid] = 0;
	AumentarQuiosco();
	HotDogInfo[NuevoHotdog][IDObjetoHD] = CreateDynamicObject(ID_QUIOSCO_OB, HotDogInfo[NuevoHotdog][PosicionHotdog][0], HotDogInfo[NuevoHotdog][PosicionHotdog][1], HotDogInfo[NuevoHotdog][PosicionHotdog][2]+0.2, 0, 0, HotDogInfo[NuevoHotdog][PosicionHotdog][3]+90);
	format(string, sizeof(string), LABEL_INFORMACION, NuevoHotdog);
    QuioscoLabel[NuevoHotdog] = CreateDynamic3DTextLabel(string, COLOR_GENERALFS, HotDogInfo[NuevoHotdog][PosicionHotdog][0], HotDogInfo[NuevoHotdog][PosicionHotdog][1], HotDogInfo[NuevoHotdog][PosicionHotdog][2]+0.5,10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1, 100.0);

	SendClientMessage(playerid, COLOR_GENERALFS, "Hotdog Stand created!");
	SetPlayerPos(playerid, MOVER_X, MOVER_Y+1.0, MOVER_Z);
	}
	}
	return 1;
}

// Eliminar Quiosco
CMD:deletestand(playerid, params[]){
    if(IsPlayerAdmin(playerid))
	{
	new QUIOSCOHDID, string[127], ArchivoASD[128];
	if(sscanf(params, "d", QUIOSCOHDID) )return SendClientMessage(playerid,-1,"{FFFFFF}* USA: {DEE613}/deletestand [ID Quiosco]");

	    format(string, sizeof(string), DIR_HOTDOG, QUIOSCOHDID);
		if(!fexist(string)) return SendClientMessage(playerid, COLOR_GENERALFS, "This Hotdog Stand doesn't exist!");

		HotDogInfo[QUIOSCOHDID][PosicionHotdog][0] = 0;
		HotDogInfo[QUIOSCOHDID][PosicionHotdog][1] = 0;
		HotDogInfo[QUIOSCOHDID][PosicionHotdog][2] = 0;
		HotDogInfo[QUIOSCOHDID][PosicionHotdog][3] = 0;
    	DestroyDynamicObject(HotDogInfo[QUIOSCOHDID][IDObjetoHD]);
    	DestroyDynamic3DTextLabel(QuioscoLabel[QUIOSCOHDID]);

		format(string, sizeof(string), "{FFFFFF}* Has deleted Hotdog Stand {DEE613}ID: %d.", QUIOSCOHDID);
   		SendClientMessage(playerid, COLOR_GENERALFS, string);
   	  	format(ArchivoASD, sizeof(ArchivoASD), DIR_HOTDOG, QUIOSCOHDID);
    	dini_Remove(ArchivoASD);
     	DisminuirQuiosco();
     	}
		return 1;
}

CMD:buyhotdog(playerid, params[]){
	for(new i = 0; i < sizeof(HotDogInfo); i++){
		if(IsPlayerInRangeOfPoint(playerid, DISTANCIA_QUIOSCO, HotDogInfo[i][PosicionHotdog][0], HotDogInfo[i][PosicionHotdog][1], HotDogInfo[i][PosicionHotdog][2])){
 		MostrarQuiosco(playerid);
 		}
   	}
 	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	switch(dialogid){
		case Q_H_DIALOGO:{
		    new string[156];
		    new Float:VidaActual;
		    if(response == 1){
	        	switch(listitem){
					case 0:{
						if(GetPlayerMoney(playerid) > PRECIO_COMIDA1){
						GetPlayerHealth(playerid, VidaActual),SetPlayerHealth(playerid, VidaActual+10);
						GivePlayerCash(playerid, -PRECIO_COMIDA1);
						format(string, sizeof(string), "%s hands over his money and get's a Hotdog Pequeño in return.", NombreJugador(playerid));
						ProxDetector(20.0, playerid,string,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
						ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
	                    SendClientMessage(playerid, COLOR_GENERALFS, "{FFFFFF}* You just bought a {40B6FF}Hotdog Pequeño{FFFFFF} from the stall!");
						} else SendClientMessage(playerid, COLOR_GENERALFS, NODINERO_HD);
					}
					case 1:{
						if(GetPlayerMoney(playerid) > PRECIO_COMIDA2){
						GetPlayerHealth(playerid, VidaActual),SetPlayerHealth(playerid, VidaActual+10);
						GivePlayerCash(playerid, -PRECIO_COMIDA2);
						format(string, sizeof(string), "%s hands over his money and get's a Hotdog Mediano in return.", NombreJugador(playerid));
						ProxDetector(20.0, playerid,string,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
						ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
	                    SendClientMessage(playerid, COLOR_GENERALFS, "{FFFFFF}* You just bought a {40B6FF}Hotdog Mediano{FFFFFF} from the stall! ");
						} else SendClientMessage(playerid, COLOR_GENERALFS, NODINERO_HD);
					}
					case 2:{
						if(GetPlayerMoney(playerid) > PRECIO_COMIDA3){
						GetPlayerHealth(playerid, VidaActual),SetPlayerHealth(playerid, VidaActual+10);
						GivePlayerCash(playerid, -PRECIO_COMIDA3);
						format(string, sizeof(string), "%s hands over his money and get's a Franky Chili Dog in return.", NombreJugador(playerid));
						ProxDetector(20.0, playerid,string,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
						ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
	                    SendClientMessage(playerid, COLOR_GENERALFS, "{FFFFFF}* You just bought a {40B6FF}Franky Chili Dog{FFFFFF} from the stall!");
						} else SendClientMessage(playerid, COLOR_GENERALFS, NODINERO_HD);
					}

				}
			}
			else{
			SendClientMessage(playerid, COLOR_GENERALFS, "You left the stand without getting a hotdog!");
			}
		}
	}
 	return 0;
}


stock NombreJugador(playerid)
{
    new NombrePJ[24];
    GetPlayerName(playerid,NombrePJ,24);
    new N[24];
    strmid(N,NombrePJ,0,strlen(NombrePJ),24);
    for(new i = 0; i < MAX_PLAYER_NAME; i++)
    {
        if (N[i] == '_') N[i] = ' ';
    }
    return N;
}

// ProxDetector
stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i=0; i<MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
                {
                    SendClientMessage(i, col1, string);
                }
                else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
                {
                    SendClientMessage(i, col2, string);
                }
                else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
                {
                    SendClientMessage(i, col3, string);
                }
                else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
                {
                    SendClientMessage(i, col4, string);
                }
                else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
                {
                    SendClientMessage(i, col5, string);
                }
            }
        }
    }
    return 1;
}

// Stocks
stock AumentarQuiosco(){
	QuioscosActuales++;
 	return 1;
}

stock DisminuirQuiosco(){
	QuioscosActuales--;
 	return 1;
}

stock MostrarQuiosco(playerid){
	new string[150];
	format(string, sizeof(string), "Hotdog pequeño\t(%d$)\nHotdog mediano\t(%d$)\nFranky Chili Dog\t\t(%d$)", PRECIO_COMIDA1,PRECIO_COMIDA2,PRECIO_COMIDA3);
	ShowPlayerDialog(playerid, Q_H_DIALOGO, DIALOG_STYLE_LIST, "{92DA04}Hotdog Stand", string, "Buy", "Leave");
 	return 1;
}

stock CargarQuioscos(){
	new Archivo[128], string[256], mStr[60];
    for(new i = 0; i < QUIOSCOSHD_MAX; i++){
        format(Archivo, sizeof(Archivo), DIR_HOTDOG, i);
        if(dini_Exists(Archivo)){
            HotDogInfo[i][IDObjetoHD] 	= dini_Int(Archivo, "IDObjetoHD");

			for(new m = 0; m < 4; m++){
				format(mStr,sizeof(mStr), "HotDogPos%d", m);
		 		HotDogInfo[i][PosicionHotdog][m] 	= dini_Float(Archivo, mStr);
			}
            HotDogInfo[i][IDObjetoHD] 	= CreateDynamicObject(ID_QUIOSCO_OB, HotDogInfo[i][PosicionHotdog][0], HotDogInfo[i][PosicionHotdog][1], HotDogInfo[i][PosicionHotdog][2]+0.2, 0, 0, HotDogInfo[i][PosicionHotdog][3]+90);
            AumentarQuiosco();

			format(string, sizeof(string), LABEL_INFORMACION, i);
    		QuioscoLabel[i] = CreateDynamic3DTextLabel(string, COLOR_GENERALFS, HotDogInfo[i][PosicionHotdog][0], HotDogInfo[i][PosicionHotdog][1], HotDogInfo[i][PosicionHotdog][2]+0.5,10.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1, 100.0);
	    }
    }
	return 1;
}

stock GuardarQuioscoHD(i){
    new Archivo[128], mStr[60];
    format(Archivo, sizeof(Archivo), DIR_HOTDOG, i);
    if(dini_Exists(Archivo)){
        dini_IntSet(Archivo, "IDObjetoHD", 	HotDogInfo[i][IDObjetoHD]);
		for(new m = 0; m < 4; m++){
			format(mStr,sizeof(mStr), "HotDogPos%d", m);
			HotDogInfo[i][PosicionHotdog][m] 	= dini_Float(Archivo, mStr);
		}
    }
	return 1;
}

stock GuardarQuioscos(){
    for(new i = 0; i < QUIOSCOSHD_MAX; i++){
		GuardarQuioscoHD(i);
    }
	return 1;
}

stock GivePlayerCash(playerid, money)
{
	SetPVarInt(playerid, "Cash", GetPVarInt(playerid, "Cash")+money);
	GivePlayerMoney(playerid, money);
	return 1;
}

