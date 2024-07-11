#include <amxmodx>
#include <amxmisc>
#include <colorchat>

#define PLUGIN "4fun_rules"
#define VERSION "1.0"
#define AUTHOR "D4NTE"


public plugin_init()

{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /zasady", "motd1")
	register_clcmd("say_team /zasady", "motd1")
	set_task(45.0, "reklama", _, _, _, "b");
}

public motd1(id)

{
	show_motd( id,"regulamin.txt","Regulamin")
}

public reklama()

{
	ColorChat(0,GREEN,"[4FUN]^x01 Kazdy gracz musi znac regulamin! Wpisz ^x02/zasady ^x01i przeczytaj go.")
}
