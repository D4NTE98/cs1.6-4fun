#include <amxmodx>
#include <amxmisc>

#define PLUGIN "serwery"
#define VERSION "1.0.0"
#define AUTHOR "FragArena"


#define SERVERS_FILE "serwery.ini"
#define MAX_SERVERS 32
#define MAX_CHARACTERS 63

new g_servers[MAX_SERVERS][2][MAX_CHARACTERS+1],
	g_number_server,
	cvar_pokaz_ip;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /serwery", "show_server");
	register_clcmd("say_team /serwery", "show_server");

	cvar_pokaz_ip = register_cvar("serwery_pokazip", "1");

	set_task(4.0, "load_servers");
}

public load_servers() {
	new file_serwers[64];
	get_configsdir(file_serwers, 63);
	formatex(file_serwers, 63, "%s/%s", file_serwers, SERVERS_FILE);

	g_number_server = 0;

	new fHandle = fopen(file_serwers, "rt");

	if(fHandle) {
		new data_server[128];

		while(g_number_server<MAX_SERVERS && !feof(fHandle)) {
			fgets(fHandle, data_server, 127);

			if(!data_server[0] || data_server[0] == ' ' || data_server[0] == ';')
				continue;

			if(parse(data_server, g_servers[g_number_server][0], MAX_CHARACTERS, g_servers[g_number_server][1], MAX_CHARACTERS) != 2)
				continue;

			++g_number_server;
		}
		fclose(fHandle);
	}
	else
		log_amx("Brak '%s' na serwerze", file_serwers);
}

public show_server(id) {
	new menu = menu_create("\rLista serwerow FragArena.pl", "show_server_handle");

	for(new i=0,formats[256],pokaz=get_pcvar_num(cvar_pokaz_ip); i<g_number_server; ++i) {
		formatex(formats, 255, "%s%s%s", g_servers[i][0], pokaz ? " - \r" : "", pokaz ? g_servers[i][1] : "");
		menu_additem(menu, formats);
	}
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public show_server_handle(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	client_cmd(id, "echo ^"Zostales przekierowany^";^"Connect^"%s", g_servers[item][1]);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
