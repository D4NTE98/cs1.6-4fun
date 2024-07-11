#include <amxmodx>
#include <4fun_quests>
#include <cstrike>
#include <hamsandwich>

new g_questHandler1;

public plugin_init(){
    register_plugin("4fun_quests_quest1", "1.0", "D4NTE");
    RegisterHam(Ham_TakeDamage, "player", "ham_td", 1);
    g_questHandler1 = register_quest("Brutal 1", "Zadaj 10000 obrazen wrogom", 10000, "1000$");
}

public ham_td(this, idinflict, idattacker, Float:damage, damagebits)
{
    if(this == idattacker)
        return 1;
    if(get_user_team(this) == get_user_team(idattacker))
        return 1;
    if(!idattacker)
        return 1;
    quest_add_status(idattacker, g_questHandler1, floatround(damage));
        return 1;
}

public quest_give_reward(id, qid)
{
    if(qid == g_questHandler1 && id)
        cs_set_user_money(id, cs_get_user_money(id)+1000, 1);
}