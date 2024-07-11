#include <amxmodx>
#include <csx>
#include <colorchat>

public plugin_init()
{
	register_plugin("plg :P","0.1","emblaze")
	set_task(180.0, "showTimer",0,"",0,"b")
	return PLUGIN_CONTINUE
}

public showTimer(id){
	ColorChat(id,GREEN, "[4FUN] ^x01 Witamy na serwerze ^x03> 4FUN");
	new nextmap[32]
	get_cvar_string("amx_nextmap",nextmap,31)
	ColorChat(id,GREEN, "[4FUN] ^x01 Nastepna mapa ^x03> %s", nextmap)
	if (get_cvar_float("mp_timelimit"))
	{
		new a = get_timeleft()
       
		if (get_cvar_num("amx_time_voice"))
		{
		}
		ColorChat(id,GREEN, "[4FUN] ^x01 Czas do konca mapy: ^x03%d^x04:^x03%02d", (a / 60), (a % 60))
		
	}
	//Delay for order
	set_task(0.1, "showRank", 1);
}
public showRank(id){
	new izStats[8], izBody[8]
	new iRankPos, iRankMax
	
	new Players[32], playerCount;
	get_players(Players, playerCount);
	new id2;
	for (new i=0; i<playerCount; i++){
		id2 = Players[i]; 
		iRankPos = get_user_stats(id2, izStats, izBody)
		iRankMax = get_statsnum()
	
		ColorChat(id2, GREEN, "[4FUN] ^x01 Twoj ranking wynosi:^x04 %d^x01/^x04%d", iRankPos, iRankMax)
	}

}
