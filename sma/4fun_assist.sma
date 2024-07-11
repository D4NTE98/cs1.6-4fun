#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
 
#define VERSION "0.1"
 
#define MAX 32
#define IsPlayer(%1) (1 <= %1 <= MAX && is_user_connected(%1))
 
new g_iZemsta[MAX+1];
new bool:g_bAsysta[MAX+1][MAX+1];
 
new g_pCvarAsysta;
new g_pCvarZemsta;
 
public plugin_init() {
	register_plugin("4fun_assist", VERSION, "D4NTE")
 
	g_pCvarAsysta = register_cvar("assist_frags", "1");
	g_pCvarZemsta = register_cvar("assist_frags2", "1");
 
	register_event("DeathMsg", "eventDeath", "a");
	register_event("HLTV", "newRound", "a", "1=0", "2=0") 
 
	RegisterHam(Ham_TakeDamage, "player", "fwDamage", 1);
}
 
public newRound()
{
	for(new i = 0;i <= MAX;i++){
		for(new j = 0;j <= MAX;j++)
			g_bAsysta[i][j] = false;
	}
}

public client_connect(id){
	for(new j = 0;j <= MAX;j++)	g_bAsysta[id][j] = false;
	g_iZemsta[id] = 0;
}
 
public fwDamage(iVictim, iInflicter, iAttacker, Float:fDamage, iBitDamage){
	if( (IsPlayer(iAttacker) && IsPlayer(iVictim)) && !g_bAsysta[iAttacker][iVictim] && get_user_team(iVictim) != get_user_team(iAttacker) && iVictim != iAttacker)
		g_bAsysta[iAttacker][iVictim] = true;
 
	return HAM_IGNORED;
}
 
public eventDeath(){
	new iKiller = read_data(1);
	new iVictim = read_data(2);
 
 
	if(IsPlayer(iKiller) && IsPlayer(iVictim) && iKiller != iVictim){
		g_iZemsta[iVictim] = iKiller;
 
		new iXp = get_pcvar_num(g_pCvarZemsta);
		
		new sName[32];
		get_user_name(iVictim, sName, sizeof sName - 1);
 
		if(g_iZemsta[iKiller] && g_iZemsta[iKiller] == iVictim){
 
			set_hudmessage(255, 16, 255, -1.0, 0.30, 0, 2.0, 2.0, 0.05, 0.05, 4)
			show_hudmessage(iKiller, "Zemsciles sie na graczu %s^n^n+ %d Fragow", sName, iXp);
 
			set_user_frags(iKiller, get_user_frags(iKiller) + iXp);
 
			g_iZemsta[iKiller] = 0;
		}
 
		iXp = get_pcvar_num(g_pCvarAsysta);
 
		for(new i = 0 ; i <= MAX; i ++){
			if(i == iKiller)	continue;
 
			if(g_bAsysta[i][iVictim]){		
 
				set_hudmessage(255, 16, 255, -1.0, 0.30, 0, 2.0, 2.0, 0.05, 0.05, 4)
				show_hudmessage(i, "Asystowales w zabiciu gracza %s^n^n+ %d Fragow", sName, iXp);
 
				set_user_frags(i, get_user_frags(i) + iXp);
			}
 
			g_bAsysta[i][iVictim] = false;
		}
	}
}