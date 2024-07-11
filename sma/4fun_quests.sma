#include <amxmodx>
#include <hamsandwich>
#include <nvault>
#include <ColorChat>

#define PLUGIN "4fun_quests"
#define VERSION "1.0"
#define AUTHOR "D4NTE"

//#define SQL

//#if defined SQL
//#include <sqlx>
//#endif

new g_QuestsSave;
new Array:g_QuestsStatus[33];
new Array:g_QuestsProgress[33];
new Array:g_QuestsGot[33];
new Array:g_QuestsID[33];

new Array:g_QuestsTarget;
new Array:g_QuestsName;
new Array:g_QuestsDesc;
new Array:g_QuestsReward;

new gCvarDisplay;
new gCvarMaxGotQ;
#if defined SQL
new gCvarSqlHost;
new gCvarSqlLogin;
new gCvarSqlPassword;
new gCvarSqlDbName;

new g_SqlHost[64];
new g_SqlLogin[64];
new g_SqlPassword[64];
new g_SqlDbName[64];

new Handle:g_SqlHandle;

#endif

new g_ItemID[33];
new g_ForwardOne;
new g_ForwardTwo;
new g_ForwardThree;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say /quest", "Main_QuestMenu");
	register_clcmd("say_team /quest", "Main_QuestMenu");
	
	RegisterHam(Ham_Killed, "player", "HamCheck", 0);
	RegisterHam(Ham_Spawn, "player", "HamSpawn", 1);

	gCvarDisplay = register_cvar("quest_display_gz", "1"); // czy wyswietlac gratulacje zdobyles %s ?
	gCvarMaxGotQ = register_cvar("quest_maxgot", "2"); // ile max mozna miec przyjetych zadan na raz ?
	#if defined SQL
	gCvarSqlHost = register_cvar("quest_sql_host", "localhost"); // host do bazy danych
	gCvarSqlLogin = register_cvar("quest_sql_login", "root"); // login do sql
	gCvarSqlPassword = register_cvar("quest_sql_password", ""); // haslo do sql
	gCvarSqlDbName = register_cvar("quest_sql_dbname", "quests"); // nazwa bazy danych
	#endif
	
	g_QuestsTarget = ArrayCreate(1, 1);
	g_QuestsName = ArrayCreate(32, 1);
	g_QuestsReward = ArrayCreate(64, 1);
	g_QuestsDesc = ArrayCreate(256, 1);
	
	g_ForwardOne = CreateMultiForward("quest_give_reward", ET_CONTINUE, FP_CELL, FP_CELL);
	g_ForwardTwo = CreateMultiForward("quest_user_accept", ET_CONTINUE, FP_CELL, FP_CELL);
	g_ForwardThree = CreateMultiForward("quest_user_abandon", ET_CONTINUE, FP_CELL, FP_CELL);
		
	#if defined SQL
	get_pcvar_string(gCvarSqlHost, g_SqlHost, 63);
	get_pcvar_string(gCvarSqlLogin, g_SqlLogin, 63);
	get_pcvar_string(gCvarSqlPassword, g_SqlPassword, 63);
	get_pcvar_string(gCvarSqlDbName, g_SqlDbName, 63);
	
	g_SqlHandle = SQL_MakeDbTuple(g_SqlHost, g_SqlLogin, g_SqlPassword, g_SqlDbName);
	#else
	g_QuestsSave = nvault_open("Quests");
	
	if (g_QuestsSave == INVALID_HANDLE)
                set_fail_state( "Nie moge otworzyc pliku!");
	#endif
}
public plugin_natives()
{
	register_library("quests");
	
	register_native("quest_get_status", "_quest_get_status"); 
	register_native("quest_get_progress", "_quest_get_progress"); 
	register_native("quest_get_desc", "_quest_get_desc");
	register_native("quest_get_name", "_quest_get_name"); 
	register_native("quest_get_target", "_quest_get_target");
	register_native("quest_get_got", "_quest_get_got");
	register_native("quest_get_max", "_quest_get_max"); 
	register_native("quest_set_name", "_quest_set_name");
	register_native("quest_set_desc", "_quest_set_desc"); 
	register_native("quest_set_target", "_quest_set_target"); 
	register_native("quest_set_progress", "_quest_set_progress"); 
	register_native("quest_set_status", "_quest_set_status"); 
	register_native("quest_set_got", "_quest_set_got");
	register_native("register_quest", "_register_quest"); 
	register_native("quest_reset_status", "_quest_reset_status");
	register_native("quest_add_status", "_quest_add_status");
}
public plugin_end() 
{
	#if defined SQL
	#else
	nvault_close(g_QuestsSave);
	#endif
	ArrayDestroy(g_QuestsDesc);
	ArrayDestroy(g_QuestsName);
	ArrayDestroy(g_QuestsTarget);
	ArrayDestroy(g_QuestsReward);
}
public client_authorized(id)
{
	g_QuestsStatus[id]=ArrayCreate(1,1);
	g_QuestsProgress[id]=ArrayCreate(1,1);
	g_QuestsGot[id]=ArrayCreate(1,1);
	g_QuestsID[id]=ArrayCreate(1,1);
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		ArrayPushCell(g_QuestsStatus[id], 0);
		ArrayPushCell(g_QuestsProgress[id], 0);
		ArrayPushCell(g_QuestsGot[id], 0);
	}
	
}
public client_disconnect(id)
{
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		#if defined SQL
		sql_save(id, i);
		#else
		save_nvault(id, i);
		#endif
	}
	ArrayDestroy(g_QuestsStatus[id]);
	ArrayDestroy(g_QuestsProgress[id]);
	ArrayDestroy(g_QuestsGot[id]);
	ArrayDestroy(g_QuestsID[id]);
}
public Main_QuestMenu(id)
{
	new MQmenu=menu_create("\r[4FUN] \yMenu zadan", "Main_QuestMenu_Handle");
	new disabled=menu_makecallback("Main_QuestMenu_Callback");
	new ileMa[33],ileEnd[33];
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(ArrayGetCell(g_QuestsGot[id], i))
			ileMa[id]++;
	}
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(ArrayGetCell(g_QuestsStatus[id], i))
			ileEnd[id]++;
	}
	if(ileMa[id]==ArraySize(g_QuestsTarget) || ileEnd[id]==ArraySize(g_QuestsTarget) || ileMa[id] >= get_pcvar_num(gCvarMaxGotQ))
		menu_additem(MQmenu, "Nowe Zadania", "", 0, disabled);
	else
		menu_additem(MQmenu, "Nowe Zadania");
	if(ileMa[id]==0)
		menu_additem(MQmenu, "Obecne Zadania","",0,disabled);
	else
		menu_additem(MQmenu, "Obecne Zadania");
	ileMa[id]=0;
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(ArrayGetCell(g_QuestsStatus[id], i))
			ileMa[id]++;
	}
	if(ileMa[id]==0)
		menu_additem(MQmenu, "Ukonczone Zadania","",0,disabled);
	else
		menu_additem(MQmenu, "Ukonczone Zadania");
		
	
		
	menu_display(id, MQmenu);
	return PLUGIN_HANDLED;
}
public Add_QuestMenu(id)
{
	new QuestM = menu_create("\r[4FUN] \yWybierz nowe zadanie", "Add_QuestMenu_Handle");
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(is_user_connected(id) && !ArrayGetCell(g_QuestsGot[id], i))
		{
			new message[128];
			new iQuestName[32];
			new iQuestStatus[33];
			iQuestStatus[id] = ArrayGetCell(g_QuestsStatus[id], i);
			//new iQuestProgress = ArrayGetCell(g_QuestsProgress[id], i);
			ArrayGetString(g_QuestsName, i, iQuestName, 31);
			if(!iQuestStatus[id])
			{
				format(message, 127, "\w%s", iQuestName)
				menu_additem(QuestM, message, "");
				ArrayPushCell(g_QuestsID[id], i);
			}
		}
	}
	menu_display(id, QuestM);
	return PLUGIN_HANDLED;
}
public My_QuestMenu(id)
{
	new QuestM = menu_create("Wybierz swoje zadania", "My_QuestMenu_Handle");
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(is_user_connected(id) && ArrayGetCell(g_QuestsGot[id], i))
		{
			new message[128];
			new iQuestName[32];
			new iQuestStatus[33];
			iQuestStatus[id] = ArrayGetCell(g_QuestsStatus[id], i);
			//new iQuestProgress = ArrayGetCell(g_QuestsProgress[id], i);
			ArrayGetString(g_QuestsName, i, iQuestName, 31);
			if(!iQuestStatus[id])
			{
				format(message, 127, "\w%s", iQuestName)
				menu_additem(QuestM, message, "");
				ArrayPushCell(g_QuestsID[id], i);
			}
		}
	}
	menu_display(id, QuestM);
	return PLUGIN_HANDLED;
}
public End_QuestMenu(id)
{
	new QuestM = menu_create("Wybierz ukonczone zadanie", "End_QuestMenu_Handle");
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		if(is_user_connected(id) && !ArrayGetCell(g_QuestsGot[id], i))
		{
			new message[128];
			new iQuestName[32];
			new iQuestStatus[33];
			iQuestStatus[id] = ArrayGetCell(g_QuestsStatus[id], i);
			//new iQuestProgress = ArrayGetCell(g_QuestsProgress[id], i);
			ArrayGetString(g_QuestsName, i, iQuestName, 31);
			if(iQuestStatus[id])
			{
				format(message, 127, "\w%s", iQuestName)
				menu_additem(QuestM, message, "");
				ArrayPushCell(g_QuestsID[id], i);
			}
		}
	}
	menu_display(id, QuestM);
	return PLUGIN_HANDLED;
}
public Info_QuestMenu(id, qid)
{
	new IQuest=menu_create("Decyzja","Info_QuestMenu_Handle");
	menu_additem(IQuest,"Przyjmuje Quest");
	menu_additem(IQuest,"Nie przyjmuje Questa");
	new message[128];
	new iName[32], iRew[64], iOpis[256];
	ArrayGetString(g_QuestsDesc, qid, iOpis, 255);
	ArrayGetString(g_QuestsReward, qid, iRew, 63);
	ArrayGetString(g_QuestsName, qid, iName, 31);
	if(equal("-1", iRew, 2))
		format(message, 63, "^n\rNazwa: \y%s^n\rOpis: \y%s", iName, iOpis)
	else
		format(message, 63, "^n\rNazwa: \y%s^n\rOpis: \y%s^n\rNagroda: \y%s", iName, iOpis, iRew)
	
	menu_addtext(IQuest, message);
	g_ItemID[id]=qid;
	menu_setprop(IQuest,MPROP_EXIT,MEXIT_NEVER);
	menu_display(id, IQuest);
	return PLUGIN_HANDLED;
}
public MyInfo_QuestMenu(id, qid)
{
	new IQuest=menu_create("\r[4FUN] \yDecyzja","MyInfo_QuestMenu_Handle");
	menu_additem(IQuest,"Rezygnuje z Questa");
	menu_additem(IQuest,"Nie rezygnuje z Questa");
	new message[128];
	new iName[32], iRew[64], iOpis[256];
	ArrayGetString(g_QuestsDesc, qid, iOpis, 255);
	ArrayGetString(g_QuestsReward, qid, iRew, 63);
	ArrayGetString(g_QuestsName, qid, iName, 31);
	if(equal("-1", iRew, 2))
		format(message, 127, "^n\rNazwa: \y%s^n\rOpis: \y%s^n\rPostep: \y%d/%d", iName, iOpis, ArrayGetCell(g_QuestsProgress[id], qid), ArrayGetCell(g_QuestsTarget, qid));
	else
		format(message, 127, "^n\rNazwa: \y%s^n\rOpis: \y%s^n\rPostep: \y%d/%d^n\rNagroda: \y%s", iName, iOpis, ArrayGetCell(g_QuestsProgress[id], qid), ArrayGetCell(g_QuestsTarget, qid), iRew);
		
	menu_addtext(IQuest, message);
	g_ItemID[id]=qid;
	menu_setprop(IQuest,MPROP_EXIT,MEXIT_NEVER);
	menu_display(id, IQuest);
	return PLUGIN_HANDLED;
}
public EndInfo_QuestMenu(id, qid)
{
	new IQuest=menu_create("\r[4FUN] \yZadanie","EndInfo_QuestMenu_Handle");
	menu_additem(IQuest,"Powrot");
	new message[128];
	new iName[32], iRew[64], iOpis[256];
	ArrayGetString(g_QuestsDesc, qid, iOpis, 255);
	ArrayGetString(g_QuestsReward, qid, iRew, 63);
	ArrayGetString(g_QuestsName, qid, iName, 31);
	if(equal("-1", iRew, 2))
		format(message, 127, "^n\rNazwa: \y%s^n\rOpis: \y%s^n\rCel: \y%d", iName, iOpis, ArrayGetCell(g_QuestsTarget, qid));
	else
		format(message, 127, "^n\rNazwa: \y%s^n\rOpis: \y%s^n\rCel: \y%d^n\rNagroda: \y%s", iName, iOpis, ArrayGetCell(g_QuestsTarget, qid), iRew);
	
	menu_addtext(IQuest, message);
	g_ItemID[id]=qid;
	menu_setprop(IQuest,MPROP_EXIT,MEXIT_NEVER);
	menu_display(id, IQuest);
	return PLUGIN_HANDLED;
}
public Main_QuestMenu_Handle(id, menu, item)
{
	if(item==0)
	{
		Add_QuestMenu(id);
	}
	if(item==1)
	{
		My_QuestMenu(id);
	}
	if(item==2)
	{
		End_QuestMenu(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Add_QuestMenu_Handle(id, menu, item)
{
	if(item==-3)
	{
		ArrayClear(g_QuestsID[id]);
	}
	if(item>0||item==0)
	{
		Info_QuestMenu(id, ArrayGetCell(g_QuestsID[id], item));
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public End_QuestMenu_Handle(id, menu, item)
{
	if(item==-3)
	{
		ArrayClear(g_QuestsID[id]);
	}
	if(item>0||item==0)
	{
		EndInfo_QuestMenu(id, ArrayGetCell(g_QuestsID[id], item));
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;

}
public My_QuestMenu_Handle(id, menu, item)
{
	if(item==-3)
	{
		ArrayClear(g_QuestsID[id]);
	}
	if(item>0||item==0)
	{
		MyInfo_QuestMenu(id, ArrayGetCell(g_QuestsID[id], item));
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Info_QuestMenu_Handle(id, menu, item)
{
	if(item==0)
	{
		ArraySetCell(g_QuestsGot[id],g_ItemID[id],1);
		ColorChat(id, GREEN, "[4FUN] [ZADANIA] ^x01Przyjales zadanie!");
		new iRet;
		ExecuteForward(g_ForwardTwo, iRet, id, g_ItemID[id]);
	}
	if(item==1)
	{
		ColorChat(id, GREEN, "[4FUN] [ZADANIA] ^x01Nie przyjales zadania!");
	}
	ArrayClear(g_QuestsID[id]);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public EndInfo_QuestMenu_Handle(id, menu, item)
{
	ArrayClear(g_QuestsID[id]);
	if(item==0)
	{
		End_QuestMenu(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public MyInfo_QuestMenu_Handle(id, menu, item)
{
	if(item==0)
	{
		ArraySetCell(g_QuestsGot[id],g_ItemID[id],0);
		ColorChat(id, GREEN, "[4FUN] [ZADANIA] ^x01Zrezygnowales z zadania!");
		new iRet;
		ExecuteForward(g_ForwardThree, iRet, id, g_ItemID[id]);
	}
	ArrayClear(g_QuestsID[id]);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Main_QuestMenu_Callback(id, menu, item)
{
	return ITEM_DISABLED;
}
// ham
public HamSpawn(id)
{
	if(is_user_connected(id))
	{
		for(new i=0; i<ArraySize(g_QuestsTarget); i++)
		{
			#if defined SQL
			sql_load(id, i);
			#else
			load_nvault(id, i);
			#endif
		}
	}
}
public HamCheck(id)
{	
	if(is_user_connected(id))
	{
			check_all_quests(id);
		for(new i=0; i<ArraySize(g_QuestsTarget); i++)
		{
			#if defined SQL
			sql_save(id, i);
			#else
			save_nvault(id, i);
			#endif
		}
	}
}
//natywy
public _quest_get_max(plugin, params)
{
	if(params != 0)
		return 0;
		
	return ArraySize(g_QuestsTarget);
}
public _quest_get_status(plugin, params)
{
	if(params != 2)
	{
		return 0;
	}
	new id = get_param(1);
	new q_id = get_param(2);
	return ArrayGetCell(g_QuestsStatus[id],q_id);
}
public _quest_get_progress(plugin, params)
{
	if(params != 2)
	{
		return 0;
	}
	new id = get_param(1);
	new q_id = get_param(2);
	return ArrayGetCell(g_QuestsProgress[id],q_id);
}
public _quest_get_target(plugin, params)
{
	if(params != 1)
	{
		return 0;
	}
	new q_id = get_param(1);
	return ArrayGetCell(g_QuestsTarget, q_id);
}
public _quest_get_name(plugin, params)
{
	if(params != 3)
	{
		return 0;
	}
	new q_id = get_param(1);
	new iQuestName[64];
	ArrayGetString(g_QuestsName, q_id, iQuestName, 63);
	set_string(2, iQuestName, get_param(3));
	return 1;
}
public _quest_get_desc(plugin, params)
{
	if(params != 3)
	{
		return 0;
	}
	new q_id = get_param(1);
	new iQuestDesc[256];
	ArrayGetString(g_QuestsDesc, q_id, iQuestDesc, 255);
	set_string(2, iQuestDesc, get_param(3));
	return 1;
}
public _quest_get_got(plugin, params)
{
	return ArrayGetCell(g_QuestsGot[get_param(1)], get_param(2));
}
public _quest_set_name(plugins, params)
{
	if(params != 2)
	{
		return 0;
	}
	new q_id = get_param(1);
	new q_name[32];
	get_string(2, q_name, 31);
	ArraySetString(g_QuestsName, q_id, q_name);
	return 1;
}
public _quest_set_desc(plugins, params)
{
	if(params != 2)
	{
		return 0;
	}
	new q_id = get_param(1);
	new q_desc[256];
	get_string(2, q_desc, 255);
	ArraySetString(g_QuestsDesc, q_id, q_desc);
	return 1;
}
public _quest_set_target(plugins, params)
{
	if(params != 2)
	{
		return 0;
	}
	new q_id = get_param(1);
	new q_target = get_param(2);
	ArraySetCell(g_QuestsTarget,q_id,q_target);
	return 1;
}
public _quest_set_status(plugin, params)
{
	if(params != 3)
	{
		return 0;
	}
	new id = get_param(1);
	new q_id = get_param(2);
	new value = get_param(3);
	if(value!=0 && value!=1)
	{
		log_amx("Value musi byc rowne 0 lub 1");
		return 0;
	}
	ArraySetCell(g_QuestsStatus[id],q_id, value);	
	return 1;
}
public _quest_set_progress(plugin, params)
{
	if(params != 3)
	{
		return 0;
	}
	new id = get_param(1);
	new q_id = get_param(2);
	new value = get_param(3);
	if(value<0)
	{
		return 0;	
	}
	ArraySetCell(g_QuestsProgress[id], q_id, value);
	return 1;
}
public _quest_set_got(plugin, params)
{
	ArraySetCell(g_QuestsGot[get_param(1)], get_param(2), get_param(3));
	return 1;
}
public _register_quest(plugin, params)
{
	new szQuestName[32];
	new szQuestReward[64];
	new szQuestDesc[256];
	new iQuestTarget = get_param(3);
	get_string(1, szQuestName, 31);
	get_string(2, szQuestDesc, 255);
	get_string(4, szQuestReward, 63);
	ArrayPushString(g_QuestsName, szQuestName);
	ArrayPushString(g_QuestsDesc, szQuestDesc);
	ArrayPushString(g_QuestsReward, szQuestReward);
	ArrayPushCell(g_QuestsTarget, iQuestTarget);
	return ArraySize(g_QuestsTarget)-1;
}
public _quest_reset_status(plugin, params)
{
	if(params != 2)
	{
		return 0;
	}
	ArraySetCell(g_QuestsProgress[get_param(1)], get_param(2), 0);
	return 1;
}
public _quest_add_status(plugin, params)
{
	new arg1 = get_param(1);
	new arg2 = get_param(2);
	new arg3 = get_param(3);
	ArraySetCell(g_QuestsProgress[arg1], arg2, ArrayGetCell(g_QuestsProgress[arg1], arg2) + arg3);
	return 1;
}
// stocki
stock check_quests(pid, qid)
{
	if(!ArrayGetCell(g_QuestsGot[pid], qid) && !ArrayGetCell(g_QuestsStatus[pid], qid))
	{
		ArraySetCell(g_QuestsProgress[pid], qid, 0);
	}
	if(ArrayGetCell(g_QuestsProgress[pid], qid) >= ArrayGetCell(g_QuestsTarget, qid) && !ArrayGetCell(g_QuestsStatus[pid], qid) && is_user_connected(pid) && ArrayGetCell(g_QuestsGot[pid], qid))
	{
		new name[33];
		get_user_name(pid, name, 32);
		ArraySetCell(g_QuestsStatus[pid], qid, 1);
		ArraySetCell(g_QuestsGot[pid], qid, 0);
		new iQuestName[32];
		ArrayGetString(g_QuestsName, qid, iQuestName, 31);
		if(get_pcvar_num(gCvarDisplay))
			ColorChat(pid, YELLOW, "^x04[4FUN] [ZADANIA] ^x01Gratulacje ^x04%s^x01! Ukonczyles zadanie ^x04^"%s^"^x01!", name, iQuestName)
		new iRet;
		ExecuteForward(g_ForwardOne, iRet, pid, qid);
	}
}
stock check_all_quests(pid)
{
	for(new i=0; i<ArraySize(g_QuestsTarget); i++)
	{
		check_quests(pid, i);
	}
}
#if defined SQL
public plugin_cfg()
{
	SQL_ThreadQuery(g_SqlHandle, "CreateTable_Handle",
	"CREATE TABLE IF NOT EXISTS `quests` (`id` int(11) NOT NULL AUTO_INCREMENT,`qid` int(11) NOT NULL,`name` varchar(32) NOT NULL,`player_got_quest` tinyint(1) NOT NULL,`player_end_quest` tinyint(1) NOT NULL,`player_progress_quest` int(11) NOT NULL,PRIMARY KEY (`id`)) AUTO_INCREMENT=1 ;");
}
public CreateTable_Handle(FailState, Handle:Query, Errorcode, Error[])
{
	if(Errorcode)
                log_amx("Blad w zapytaniu: %s [CheckData]", Error)
        
	if(FailState == TQUERY_CONNECT_FAILED)
         {
                log_amx("Nie mozna podlaczyc sie do bazy danych.")
                return PLUGIN_CONTINUE
         }
         else if(FailState == TQUERY_QUERY_FAILED)
         {
                log_amx("Zapytanie anulowane [CheckData]")
                return PLUGIN_CONTINUE
         }
	return PLUGIN_CONTINUE;
}
public sql_load(id, qid)
{
	// zapis z bf2 rank moda by pRED ;]]]]
	new index[2];
	index[0] = id;
	index [1] = qid;
	new szNick[64];
	new g_Cache[256];
	get_user_name(id, szNick, 63);
	replace_all(szNick, charsmax(szNick), "'", "\'" );
	formatex(g_Cache, charsmax(g_Cache), "SELECT qid, player_got_quest, player_end_quest, player_progress_quest FROM quests WHERE name='%s' AND qid='%i'", szNick, qid);
	SQL_ThreadQuery(g_SqlHandle, "SelectHandle", g_Cache, index, 2);
}
public SelectHandle(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	//Check for errors and then process loading from table queries
	if ( FailState )
	{
		if ( FailState == TQUERY_CONNECT_FAILED )
		{
			log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error);
		}
		else if ( FailState == TQUERY_QUERY_FAILED )
		{
			log_amx("Load Query failed. [%d] %s", Errcode, Error);
		}

		return;
	}

	new id = Data[0];
	new qid = Data[1];

	if ( !SQL_NumResults(Query) ) // No more results - User not found, create them a blank entry in the table. and zero their variables
	{
		ArraySetCell(g_QuestsGot[id], qid, 0);
		ArraySetCell(g_QuestsStatus[id], qid, 0);
		ArraySetCell(g_QuestsProgress[id], qid, 0);
		//Escape ' character incase save key is a name
		new szNick[64];
		new g_Cache[256];
		get_user_name(id, szNick, charsmax(szNick))
		replace_all(szNick, charsmax(szNick), "'", "\'" );
		formatex(g_Cache, charsmax(g_Cache), "INSERT INTO quests VALUES('', '%i', '%s', '0', '0', '0')", qid,szNick);
		SQL_ThreadQuery(g_SqlHandle, "QueryHandle", g_Cache);
	}
	else
	{
		ArraySetCell(g_QuestsGot[id], qid, SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_got_quest")));
		ArraySetCell(g_QuestsStatus[id], qid, SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_end_quest")));
		ArraySetCell(g_QuestsProgress[id], qid, SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "player_progress_quest")));
	}
}
public QueryHandle(FailState, Handle:Query, Error[], Errcode,Data[], DataSize)
{
	//Check for errors when making a write to table query
	if ( FailState )
	{
		if ( FailState == TQUERY_CONNECT_FAILED )
		{
			log_amx("Save - Could not connect to SQL database.  [%d] %s", Errcode, Error);
		}
		else if ( FailState == TQUERY_QUERY_FAILED )
		{
			log_amx("Save Query failed. [%d] %s", Errcode, Error);
		}

		return;
	}
}
public sql_save(id, qid)
{
	new szNick[64];
	new g_Cache[256];
	get_user_name(id, szNick, 63);
	replace_all(szNick, charsmax(szNick), "'", "\'" );

	formatex(g_Cache, charsmax(g_Cache), "UPDATE quests SET player_got_quest='%d', player_end_quest='%d', player_progress_quest='%d'  WHERE name=^"%s^" AND qid='%i'",
	ArrayGetCell(g_QuestsGot[id], qid), ArrayGetCell(g_QuestsStatus[id], qid), ArrayGetCell(g_QuestsProgress[id], qid) ,szNick, qid);
	SQL_ThreadQuery(g_SqlHandle, "QueryHandle", g_Cache);
}
#else
stock save_nvault(index, q_id)
{
	if(is_user_connected(index) && index > 0 && index <= get_maxplayers())
	{
		new name[35]
		get_user_name(index,name,34)
		new vaultkey[64],vaultdata[256] 
		format(vaultkey,63,"%s-%d-quest",name, q_id) 
		format(vaultdata,255,"%d#%d#%d#", ArrayGetCell(g_QuestsProgress[index], q_id), ArrayGetCell(g_QuestsStatus[index], q_id), ArrayGetCell(g_QuestsGot[index], q_id)) 

		nvault_set(g_QuestsSave,vaultkey,vaultdata)   
	}
}
stock load_nvault(index, q_id)
{
	if(is_user_connected(index) && index > 0 && index <= get_maxplayers())
	{
    new name[35]
    get_user_name(index,name,34)
    new vaultkey[64],vaultdata[256]
    format(vaultkey,63,"%s-%d-quest",name, q_id)
    format(vaultdata,255,"%d#%d#%d#",ArrayGetCell(g_QuestsProgress[index], q_id) , ArrayGetCell(g_QuestsStatus[index], q_id), ArrayGetCell(g_QuestsGot[index], q_id));
    nvault_get(g_QuestsSave,vaultkey,vaultdata,255) 
 
    replace_all(vaultdata, 255, "#", " ") 
        
    new q_progress[33], q_status[33], q_got[33];
    parse(vaultdata,q_progress,32,q_status,32,q_got,32) 
    
    ArraySetCell(g_QuestsProgress[index], q_id, str_to_num(q_progress));
    ArraySetCell(g_QuestsStatus[index], q_id, str_to_num(q_status));
    ArraySetCell(g_QuestsGot[index], q_id, str_to_num(q_got));
  // return PLUGIN_CONTINUE;
 }
}  
#endif
