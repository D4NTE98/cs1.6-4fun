#include <amxmodx>
#include <amxmisc>
#include <csx>

#define PLUGIN "Ranga"
#define VERSION "1.0"
#define AUTHOR "spiderman"
#define TASK 666

//new g_msgsync;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)

    //g_msgsync = CreateHudSyncObj();
}
public client_connect(id)
{
    if(is_user_bot(id))
        return
 
    new param[1]
    param[0] = id
 
    set_task(1.0,"rank",TASK+id,param,1,"b")
}
public client_disconnect(id)
    if(task_exists(TASK+id))
    remove_task(TASK+id)
public rank(param[])
{
    new id = param[0]
 
    static stats[8], body[8]
    get_user_stats(id, stats, body)
 
    new ranga[30]
 
    if ( stats[0] >= 0 && stats[0] <= 29)
        format(ranga,29,"Srebro I")
    else if ( stats[0] >= 30 && stats[0] <= 59)
        format(ranga,29,"Srebro II")
    else if ( stats[0] >= 60 && stats[0] <= 119)
        format(ranga,29,"Srebro III")
    else if ( stats[0] >= 120 && stats[0] <= 209)
        format(ranga,29,"Srebro IV")
    else if ( stats[0] >= 210 && stats[0] <= 324)
        format(ranga,29,"Elitarne srebro")
    else if ( stats[0] >= 325 && stats[0] <= 499)
        format(ranga,29,"Mistrzowskie Elitarne srebro")
    else if ( stats[0] >= 500 && stats[0] <= 729)
        format(ranga,29,"Złoty laur I")
    else if ( stats[0] >= 730 && stats[0] <= 999)
        format(ranga,29,"Złoty laur II")
    else if ( stats[0] >= 100 && stats[0] <= 1399)
        format(ranga,29,"Złoty laur III")
    else if ( stats[0] >= 1400 && stats[0] <= 1849)
        format(ranga,29,"Mistrzowski złoty laur")
    else if ( stats[0] >= 1850 && stats[0] <= 2299)
        format(ranga,29,"Mistrzowski obrońca I")
    else if ( stats[0] >= 2300 && stats[0] <= 2899)
        format(ranga,29,"Mistrzowski obrońca II")
    else if ( stats[0] >= 2900 && stats[0] <= 3549)
        format(ranga,29,"Elitarny mistrzowski obrońca")
    else if ( stats[0] >= 4200 && stats[0] <= 4999)
        format(ranga,29,"Wybitny mistrzowski obrońca")
    else if ( stats[0] >= 5000 && stats[0] <= 5899)
        format(ranga,29,"Legendarny orzeł")
    else if ( stats[0] >= 5900 && stats[0] <= 6899)
        format(ranga,29,"Mistrzowski legendarny orzeł")
    else if ( stats[0] >= 6900 && stats[0] <= 7999)
        format(ranga,29,"Mistrzowska pierwsza klasa")
    else if ( stats[0] >= 8000 && stats[0] <= 9299)
        format(ranga,29,"Elita światowa")
    else if ( stats[0] >= 9300 && stats[0] <= 1999)
        format(ranga,29,"Elita światowa")
    else if ( stats[0] >= 1000 )
        format(ranga,29,"Gaben")
 
    set_hudmessage(129, 96, 255, 0.01, 0.74, 0, 1.0, 1.0, 0.01, 0.01, -1) // 163, 169, 204
    //ShowSyncHudMsg(0, g_msgsync, "Ranga: %s^nK/D: %d/%d^nHS: %d", ranga, stats[0], stats[1], stats[2]);
    show_hudmessage(id, "Pozycja w rankingu: %d^nAktualna ranga: %s^nK/D: %d/%d^nHS: %d", stats[7], ranga, stats[0], stats[1], stats[2])
}  