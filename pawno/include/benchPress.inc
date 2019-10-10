/*
	@project_name
		Cyanide's Bench-Press System
	@project_author
		Cyanide
	@license
   		Mozilla Public License 1.1
	@description
	    Cyanide's Bench-Press System allows players to bench press just like in
	    singleplayer.
	@functions (Scripters Only)
        getClosestBarBell( clientid ) - Gets the closest barbell.
        getClosestBarBellEx( clientid ) - Gets the closest barbell and returns the index.

        OnPlayerBenchPress( playerid, reps ) - Called when a player completes a bench press.
        OnPlayerStartBenchPress( playerid, result ) - Called when a player stops bench pressing.
        OnPlayerExitBenchPress( playerid, reps ) - Called when a player stops bench pressing.
	@codes
	    OnPlayerStartBenchPress ( result )
	        0 - Failure
	        1 - Succeed
	@commands

	@credits
	    Cyanide - Project Launcher & Developer
	    Grim_ - Testing.
	    Y_Less - YSI.
	    Toribio - Progress Bar.
	    SA-MP Team - San Andreas Multiplayer Modification.

*/
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
forward OnPlayerBenchPress( playerid, reps );
forward OnPlayerExitBenchPress( playerid, reps );
forward OnPlayerStartBenchPress( playerid, result );
