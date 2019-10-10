#define RECORDING "stripper"
#define RECORDING_TYPE 2

#include <a_npc>
main(){}
public OnRecordingPlaybackEnd() StartRecordingPlayback(RECORDING_TYPE, RECORDING);

public OnPlayerStreamIn(playerid);

