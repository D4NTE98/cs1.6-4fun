#include <amxmodx> 
#include <amxmisc> 
#include <engine> 

#define SPEED 800.0

public plugin_init() { 
    register_plugin("4fun_he", "1.0", "D4NTE")
    register_event("Damage", "hedamage_event", "b", "2!0", "4!0", "5!0", "6!0")
    register_cvar("he_push","2.0")
} 

stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
    new Float:fEntOrigin[3];
    entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

    // Velocity = Distance / Time

    new Float:fDistance[3];
    fDistance[0] = fEntOrigin[0] - fOrigin[0];
    fDistance[1] = fEntOrigin[1] - fOrigin[1];
    fDistance[2] = fEntOrigin[2] - fOrigin[2];

    new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

    fVelocity[0] = fDistance[0] / fTime;
    fVelocity[1] = fDistance[1] / fTime;
    fVelocity[2] = fDistance[2] / fTime;

    return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}


// Sets velocity of an entity (ent) away from origin with speed (speed)

stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
    new Float:fVelocity[3];
    get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

    entity_set_vector( ent, EV_VEC_velocity, fVelocity );

    return ( 1 );
} 

public hedamage_event(id) {
    new MAXPLAYERS
    MAXPLAYERS = get_maxplayers()

    new inflictor = entity_get_edict(id, EV_ENT_dmg_inflictor)
    if (inflictor <= MAXPLAYERS)
        return PLUGIN_CONTINUE

    new classname2[8]
    entity_get_string(inflictor, EV_SZ_classname, classname2, 7)
    if (!equal(classname2, "grenade"))
        return PLUGIN_CONTINUE

    new Float:upVector[3]
    upVector[0] = float(read_data(4))
    upVector[1] = float(read_data(5))
    upVector[2] = float(read_data(6))

    new damagerept = read_data(2)
    set_velocity_from_origin(id, upVector, get_cvar_float("he_push")*damagerept)

    return PLUGIN_CONTINUE
}

