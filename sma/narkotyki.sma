#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <colorchat>

#define TASK 666
#define CZAS_GODMODA 10 //SEKUND
#define CZAS_NOWY 30 //SEKUND
#define CZAS_AMFASPEED 10 //SEKUND
#define CZAS_ADRESPEED 30 //SEKUND

#if cellbits == 32
#define OFFSET_CSMONEY  115
#else
#define OFFSET_CSMONEY  140
#endif

#define OFFSET_LINUX      5

new gmsgScreenFade;

public plugin_init ()
{
	register_plugin("Narkotyki", "1.1", "[AvP] ELOS");
	
	register_clcmd("say /diler", "menu_diler");
	register_clcmd("say_team /diler", "menu_diler");
    
	register_clcmd("say /dilerpomoc", "menu_diler_pomoc");
	register_clcmd("say_team /dilerpomoc", "menu_diler_pomoc");
	
	gmsgScreenFade = get_user_msgid("ScreenFade");
}

public plugin_precache()
{
	precache_sound("misc/hb.wav")
}

public Serce(id)
{
	client_cmd(id, "spk misc/hb");
}

public menu_diler(id) 
{
	new menu = menu_create("\r[4FUN] \yWybierz narkotyk \w", "menu_diler_wybor");
	menu_additem(menu, "\rAspiryna \d» \w(2000$)", "1", 0);
	menu_additem(menu, "\rAdrenalina \d» \w(2000$)", "2", 0);
	menu_additem(menu, "\rMarihuana \d» \w(2000$)", "3", 0);
	menu_additem(menu, "\rAmfetamina \d» \w(2000$)", "4", 0);
	menu_additem(menu, "\rHeroina \d» \w(2000$)", "5", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	ColorChat(id,GREEN,"[4FUN]^x01 Eee, mordo! Kupujesz cos?");
}

public menu_diler_wybor(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new kasa = fm_get_user_money(id);
	
	
	new data[6], iName[64];
	new zaccess, callback;
	menu_item_getinfo(menu, item, zaccess, data,5, iName, 64, callback);
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
			if(kasa >= 2000)
			{
				fm_set_user_money(id, kasa-2000);
				Aspiryna(id)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
				client_print(id, print_chat, "[4FUN] Masz za malo kasy!");
		}
		case 2:
		{
			if(kasa >= 2000)
			{
				fm_set_user_money(id, kasa-2000);
				Adre(id)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
				client_print(id, print_chat, "[4FUN] Masz za malo kasy!");
		}
		
		case 3:
		{
			if(kasa >= 2000)
			{
				fm_set_user_money(id, kasa-2000);
				Marycha(id)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
				client_print(id, print_chat, "[4FUN] Masz za malo kasy!");
		}
		case 4:
		{
			if(kasa >= 2000)
			{
				fm_set_user_money(id, kasa-2000);
				Amfa(id)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
				client_print(id, print_chat, "[4FUN] Masz za malo kasy!");
		}
		case 5:
		{
			if(kasa >= 2000)
			{
				fm_set_user_money(id, kasa-2000);
				Hero(id)
				menu_destroy(menu);
				return PLUGIN_HANDLED;
			}
			else
				client_print(id, print_chat, "[4FUN] Masz za malo kasy!");
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public menu_diler_pomoc(id) 
{
	new menu = menu_create("\r[4FUN] \yWybierz narkotyk \w", "menu_diler_pomoc_wybor");
	menu_additem(menu, "\rAspiryna \d» \w(2000$)", "1", 0);
	menu_additem(menu, "\rAdrenalina \d» \w(2000$)", "2", 0);
	menu_additem(menu, "\rMarihuana \d» \w(2000$)", "3", 0);
	menu_additem(menu, "\rAmfetamina \d» \w(2000$)", "4", 0);
	menu_additem(menu, "\rHeroina \d» \w(2000$)", "5", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	ColorChat(id,GREEN,"[4FUN]^x01 Bier do japy albo wpier...");
}

public menu_diler_pomoc_wybor(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	
	new data[6], iName[64];
	new zaccess, callback;
	menu_item_getinfo(menu, item, zaccess, data,5, iName, 64, callback);
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
			ColorChat(id,GREEN,"[Aspiryna] Ustawia zycie do 150");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			ColorChat(id,GREEN,"[Adrenalina] Mmniejsza gravitacja, wieksza szybkosc, szybki bicie serca na 30sekund.");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			ColorChat(id,GREEN,"[Marihuana] Super zmniejszona gravitacja, wolniejszcze tempo ruchu na 30sekund.");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			ColorChat(id,GREEN,"[Amfetamina] Super szybkosc na 10sekund.");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			ColorChat(id,GREEN,"[Heroina] Nie czujesz bolu, krecenie w glowie, amnezja na 10sekund.");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Hero(id)
{
	fm_set_user_godmode(id, 1);
	fm_set_user_rendering(id, kRenderFxGlowShell,255,0,0,kRenderNormal, 1)
	set_task(CZAS_GODMODA.0, "HeroOff", id);
	new param[1]
	param[0] = id
	set_task(0.5,"fade",TASK + id,param,1,"a", 20)
	set_task(1.0,"fadeg",TASK + id,param,1,"a", 10)
	set_task(1.5,"fadey",TASK + id,param,1,"a", 7)
	set_task(0.5,"trzes",TASK + id,param,1,"a", 20)
	return PLUGIN_HANDLED;
}

public Marycha(id)
{
	new param[1]
	param[0] = id
	set_task(0.1,"fadeg",TASK + id,param,1,"a", 300)	;
	set_task(CZAS_NOWY.0, "MarychaOff", id);
	fm_set_user_gravity(id, 0.5);
	fm_set_user_maxspeed(id, 150.0);
	return PLUGIN_CONTINUE;
	
}

public Amfa(id)
{
	set_task(CZAS_AMFASPEED.0, "AmfaOff", id);
	fm_set_user_maxspeed(id, 500.0);
	return PLUGIN_CONTINUE;
}

public Adre(id)
{
	set_task(CZAS_ADRESPEED.0, "MarychaOff", id);
	fm_set_user_gravity(id, 0.8);
	fm_set_user_maxspeed(id, 320.0);
	new param[1]
	param[0] = id
	set_task(0.6,"fade",TASK + id,param,1,"a", 66);
	set_task(0.6,"Serce", _, _, _, "a", 66);
	return PLUGIN_CONTINUE;
}

public Aspiryna(id)
{
	fm_set_user_health(id, 150)
	message_begin(MSG_ONE, gmsgScreenFade, {0,0,0},id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0x0000)
	write_byte(0)
	write_byte(0)
	write_byte(200)
	write_byte(75)
	message_end()
}

public HeroOff(id)
{
	fm_set_user_godmode(id, 0)
	fm_set_user_rendering(id, kRenderFxGlowShell,255,0,0,kRenderNormal, 0)
}

public MarychaOff(id)
{
	fm_set_user_gravity(id, 1.0);
	fm_set_user_maxspeed(id, 250.0);
	return PLUGIN_HANDLED;
}

public AmfaOff(id)
{
	fm_set_user_maxspeed(id, 250.0);
	return PLUGIN_HANDLED;
}

public AdreOff(id)
{
	fm_set_user_maxspeed(id, 250.0);
	fm_set_user_gravity(id, 1.0);
	return PLUGIN_HANDLED;
}

public fade(param[])
{
	message_begin(MSG_ONE,gmsgScreenFade,{0,0,0},param[0]);
	write_short(1<<10) // duration
	write_short(1<<10) // hold time
	write_short(0x0000) // flags
	write_byte(255) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(100) // alpha
	message_end()    
}

public fadeg(param[])
{
	message_begin(MSG_ONE,gmsgScreenFade,{0,0,0},param[0]);
	write_short(1<<10) // duration
	write_short(1<<10) // hold time
	write_short(0x0000) // flags
	write_byte(0) // red
	write_byte(255) // green
	write_byte(0) // blue
	write_byte(100) // alpha
	message_end()    
}

public fadey(param[])
{
	message_begin(MSG_ONE,gmsgScreenFade,{0,0,0},param[0]);
	write_short(1<<10) // duration
	write_short(1<<10) // hold time
	write_short(0x0000) // flags
	write_byte(255) // red
	write_byte(255) // green
	write_byte(0) // blue
	write_byte(100) // alpha
	message_end()    
}

public trzes(param[])
{
	message_begin(MSG_ONE,gmsgScreenFade,{0,0,0},param[0]);
	write_short(7<<14); 
	write_short(1<<13); 
	write_short(1<<14); 
	message_end()    
}

stock fm_set_user_money(id,money,flash=0)
{
	set_pdata_int(id,OFFSET_CSMONEY,money,OFFSET_LINUX);
	
	message_begin(MSG_ONE,get_user_msgid("Money"),{0,0,0},id);
	write_long(money);
	write_byte(flash);
	message_end();
}

stock fm_get_user_money(id)
{
	return get_pdata_int(id,OFFSET_CSMONEY,OFFSET_LINUX);
}
