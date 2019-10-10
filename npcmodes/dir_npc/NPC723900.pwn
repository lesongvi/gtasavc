#include <a_npc>

main() {}

public OnRecordingPlaybackEnd()
{
	StartPlayback();
}

public OnNPCSpawn()
{
	StartPlayback();
}

StartPlayback()
{
	StartRecordingPlayback(2, "dir_rec\\NPC723900");
}