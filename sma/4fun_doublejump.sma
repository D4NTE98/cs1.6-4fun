#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
 
new skoki[33];
 
 
public plugin_init()
{
    register_plugin("4fun_doublejump", "1.0", "D4NTE");
    register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
}
 
public fwCmdStart_MultiJump(id, uc_handle)
{
    if(!is_user_alive(id))
    return FMRES_IGNORED;
    
    new flags = pev(id, pev_flags);
    
    if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
    {
        skoki[id]--;
        new Float:velocity[3];
        pev(id, pev_velocity,velocity);
        velocity[2] = random_float(265.0,285.0);
        set_pev(id, pev_velocity,velocity);
    }
    else if(flags & FL_ONGROUND)
    skoki[id] = 1;
    
    return FMRES_IGNORED;
}