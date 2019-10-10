
	}
	else if(GetVehicleModel(vehicleid) == 602)// The Huntley
	{
		tune[playerid] = 1;
		new huntley1 = CreateObject( 1169,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( huntley1, GetPlayerVehicleID(playerid), 1.100000, 1.700000, 0.000000, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new huntley2 = CreateObject( 1140,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( huntley2, GetPlayerVehicleID(playerid), -1.000000, -2.100000, -0.100000, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new huntley3 = CreateObject( 1030,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( huntley3, GetPlayerVehicleID(playerid), 1.100000, -0.900000, -0.499999, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new huntley4 = CreateObject( 1030,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( huntley4, GetPlayerVehicleID(playerid), -1.100000, 0.900000, -0.499999, 0.000000, 0.000000, 180.000000 ); // <iVO>

		new huntley5 = CreateObject( 1079,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( huntley5, GetPlayerVehicleID(playerid), 0.299999, -2.899999, 0.300000, 0.000000, 0.000000, 270.000000 ); // <iVO>
		ChangeVehicleColor(vehicleid,0,0);
	}
	else if(GetVehicleModel(vehicleid) == 602)// The FBI Rancher
	{
		tune[playerid] = 1;
		new FBIRancher1 = CreateObject( 1170,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher1, GetPlayerVehicleID(playerid), 1.100000, 2.500000, -0.399999, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new FBIRancher2 = CreateObject( 1168,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher2, GetPlayerVehicleID(playerid), -1.100000, -2.399999, -0.299999, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new FBIRancher3 = CreateObject( 1100,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher3, GetPlayerVehicleID(playerid), 0.000000, 0.200000, 0.100000, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new FBIRancher4 = CreateObject( 1005,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher4, GetPlayerVehicleID(playerid), 0.000000, 0.700000, 1.000000, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new FBIRancher5 = CreateObject( 1030,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher5, GetPlayerVehicleID(playerid), 1.100000, -0.900000, -0.699999, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new FBIRancher6 = CreateObject( 1030,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( FBIRancher6, GetPlayerVehicleID(playerid), -1.199999, 0.800000, -0.599999, 0.000000, 0.000000, 180.000000 ); // <iVO>
		ChangeVehicleColor(vehicleid,0,0);
	}
	else if(GetVehicleModel(vehicleid) == 602)// Admiral
	{
		tune[playerid] = 1;
		new Admiral1 = CreateObject( 1100,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( Admiral1, GetPlayerVehicleID(playerid), 0.000000, -0.499999, 0.000000, 0.000000, 0.000000, 0.000000 ); // <iVO>

		new Admiral2 = CreateObject( 1115,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( Admiral2, GetPlayerVehicleID(playerid), 0.000000, 2.499999, -0.299999, 7.000000, 0.000000, 0.000000 ); // <iVO>
		ChangeVehicleColor(vehicleid,0,0);
	}
	else if(GetVehicleModel(vehicleid) == 602)// Feltzer
	{
		tune[playerid] = 1;
		new Feltzer1 = CreateObject( 1128,0,0,0,0,0,0,80 ); // <iVO>
		AttachObjectToVehicle( Feltzer1, GetPlayerVehicleID(playerid), 0.000000, -0.100000, 0.100000, 1.000000, 0.000000, 0.000000 ); // <iVO>
		ChangeVehicleColor(vehicleid,0,0);
	}




