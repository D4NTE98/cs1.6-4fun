#include <amxmodx>
#include <colorchat>
#include <fakemeta>
#include <csx>
#include <fun>

#define PLUGIN "4fun_ranks"
#define AUTHOR "D4NTE"

#pragma semicolon 1

#define DEBUG_MODE

#define MAX_PLAYERS 32
#define MAX_CHARS 33
#define MAX_RANK_NAME_LENGTH 60

#define TASK_HUD 1337

#define ForRange(%1,%2,%3) for(new %1 = %2; %1 <= %3; %1++)
#define ForArray(%1,%2) for(new %1 = 0; %1 < sizeof %2; %1++)
#define ForDynamicArray(%1,%2) for(new %1 = 0; %1 < ArraySize(%2); %1++)
#define ForFile(%1,%2,%3,%4,%5) for(new %1 = 0; read_file(%2, %1, %3, %4, %5); %1++)

new const configFilePath[] = "addons/amxmodx/configs/RanksConfig.ini";
new const configFileDataSeparator = '=';
new const configFileKillsSeparator = '-';
new const configFileForbiddenChars[] =
{
	'/',
	';',
	'\'
};

new const chatPrefix[] = "^x04[4FUN]^x01";

new const Float:hudInterval = 1.0;

new const nativesData[][][] =
{
	{ "ranks_get_user_rank", "native_get_user_rank", 0 },
	{ "ranks_get_rank_name", "native_get_rank_name", 0 },
	{ "ranks_get_rank_kills", "native_get_rank_frags", 0 }
};

enum dataEnumerator (+= 1)
{
	dataRank,
	dataRankName[MAX_RANK_NAME_LENGTH],
	bool:dataHudEnabled,
	dataKills,
	dataKillsRequired
};


new Array:rankNames,
	Array:rankFrags[2],

	userData[MAX_PLAYERS + 1][dataEnumerator],

	hudObject;


new gWlascicielFlaga[32], gHeadAdminFlaga[32], gAdminFlaga[32], gVipFlaga[32], gSVipFlaga[32];
new gWlascicielPrefix[32], gHeadAdminPrefix[32], gAdminPrefix[32], gVipPrefix[32], gSVipPrefix[32];

public plugin_init()
{
	register_plugin(PLUGIN, "v2.2", AUTHOR);

	register_message(get_user_msgid("SayText"), "handleSayText");

	register_event("DeathMsg", "deathMessage", "a");

	hudObject = CreateHudSyncObj();

		/* Cvary */
	register_cvar("wlasciciel_flaga", "abcdefghijklmnopqrstuwvxy");	
	register_cvar("headadmin_flaga", "abcdefghijklmnopqrstuwvy");
	register_cvar("admin_flaga", "bcdefghijklmnopqrstu");
	register_cvar("vip_flaga", "t");
	register_cvar("svip_flaga", "s");
	
	get_cvar_string("wlasciciel_flaga", gWlascicielFlaga, sizeof gWlascicielFlaga -1);
	get_cvar_string("headadmin_flaga", gHeadAdminFlaga, sizeof gHeadAdminFlaga -1);
	get_cvar_string("admin_flaga", gAdminFlaga, sizeof gAdminFlaga -1);
	get_cvar_string("vip_flaga", gVipFlaga, sizeof gVipFlaga -1);
	get_cvar_string("svip_flaga", gSVipFlaga, sizeof gSVipFlaga -1);
	
	/* Prefixy */
	register_cvar("wlasciciel_prefix", "Wlasciciel");
	register_cvar("headadmin_prefix", "Opiekun");
	register_cvar("admin_prefix", "Admin");
	register_cvar("vip_prefix", "VIP");
	register_cvar("svip_prefix", "SVIP");
	
	get_cvar_string("wlasciciel_prefix", gWlascicielPrefix , sizeof gWlascicielPrefix  -1);
	get_cvar_string("headadmin_prefix", gHeadAdminPrefix , sizeof gHeadAdminFlaga  -1);
	get_cvar_string("admin_prefix", gAdminPrefix , sizeof gAdminPrefix  -1);
	get_cvar_string("vip_prefix", gVipPrefix , sizeof gVipPrefix  -1);
	get_cvar_string("svip_prefix", gSVipPrefix , sizeof gSVipPrefix  -1);
}

public toggleHud(index)
{
	toggle_hud(index, !userData[index][dataHudEnabled]);
}

public plugin_natives()
{
	ForArray(i, nativesData)
	{
		register_native(nativesData[i][0], nativesData[i][1], nativesData[i][2][0]);
	}
}

public plugin_precache()
{
	loadConfigFile();
}

public client_authorized(index)
{
	get_user_rank(index, true);

	toggle_hud(index, true);
}

public has_flags(id,string[])
{
	new ret=1;
	new byte;
	
	new len = strlen(string);
	new p_flag = get_user_flags(id);
	
	for(new i=0;i<=len;i++)
	{
		if(string[i]>='a' && string[i]<='z') byte = (1<<(string[i]-'a'));
		else if(string[i]>='A' && string[i]<='Z') byte = (1<<(string[i]-'A'));
		else if(string[i]==',' && ret==1) return 1;
		else if(string[i]==',') ret=1;
		if(byte!=0 && !(p_flag & byte)) ret=0;
		
		byte=0;
	}
	
	return ret;
}

public handleSayText(msgId, msgDest, msgEnt)
{
	new index = get_msg_arg_int(1);

	if(!is_user_connected(index))
	{
		return PLUGIN_CONTINUE;
	}

	new chatString[2][192];

	get_msg_arg_string(2, chatString[0], charsmax(chatString[]));

	if(!equal(chatString[0], "#Cstrike_Chat_All"))
	{
		if (has_flags(index, gWlascicielFlaga)) {
			formatex(chatString[1], charsmax(chatString[]), "^x04 [%s] [%s] ^x03%s", gWlascicielPrefix, userData[index][dataRankName], chatString[0]);
		}
		else if(has_flags(index, gHeadAdminFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04 [%s] [%s] ^x03%s", gHeadAdminPrefix, userData[index][dataRankName], chatString[0]);
		}
		else if(has_flags(index, gAdminFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04 [%s] [%s] ^x03%s", gAdminPrefix, userData[index][dataRankName], chatString[0]);
		}
		else if(has_flags(index, gVipFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04 [%s] [%s] ^x03%s", gVipPrefix, userData[index][dataRankName], chatString[0]);
		}
		else if(has_flags(index, gSVipFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04 [%s] [%s] ^x03%s", gSVipPrefix, userData[index][dataRankName], chatString[0]);
		}
		else
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] ^x03%s", userData[index][dataRankName], chatString[0]);
		}
	}
	else
	{
		get_msg_arg_string(4, chatString[0], charsmax(chatString[]));
		set_msg_arg_string(4, "");

		if (has_flags(index, gWlascicielFlaga)) {
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] [%s] ^x03%n^x01: %s", gWlascicielPrefix, userData[index][dataRankName], index, chatString[0]);
		}
		else if(has_flags(index, gHeadAdminFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] [%s] ^x03%n^x01: %s", gHeadAdminPrefix, userData[index][dataRankName], index, chatString[0]);
		}
		else if(has_flags(index, gAdminFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] [%s] ^x03%n^x01: %s", gAdminPrefix, userData[index][dataRankName], index, chatString[0]);
		}
		else if(has_flags(index, gVipFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] [%s] ^x03%n^x01: %s", gVipPrefix, userData[index][dataRankName], index, chatString[0]);
		}
		else if(has_flags(index, gSVipFlaga))
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] [%s] ^x03%n^x01: %s", gSVipPrefix, userData[index][dataRankName], index, chatString[0]);
		}
		else
		{
			formatex(chatString[1], charsmax(chatString[]), "^x04[%s] ^x03%n^x01: %s", userData[index][dataRankName], index, chatString[0]);
		}

		//formatex(chatString[1], charsmax(chatString[]), "^x04[%s] ^x03%n^x01: %s", userData[index][dataRankName], index, chatString[0]);
	}

	set_msg_arg_string(2, chatString[1]);

	return PLUGIN_CONTINUE;
}

public deathMessage()
{
	new killer = read_data(1),
		victim = read_data(2);

	// Return if the kill-event doesnt matter.
	if(killer == victim || !is_user_connected(victim) || !is_user_connected(killer))
	{
		return;
	}

	get_user_rank(killer);
}

public displayHud(taskIndex)
{
	new index = taskIndex - TASK_HUD;

	if(!is_user_connected(index))
	{
		return;
	}

	new message[2 << 7];

	// Format hud message.
	formatex(message, charsmax(message), "Twoja ranga: %s (%i / %i)", userData[index][dataRankName], userData[index][dataRank] + 1, ArraySize(rankNames));

	if(userData[index][dataKillsRequired])
	{
		format(message, charsmax(message), "%s^nFragi: %i / %i", message, userData[index][dataKills], userData[index][dataKillsRequired]);
	}

	if(userData[index][dataRank] < ArraySize(rankNames) - 1)
	{
		new nextrankNames[MAX_RANK_NAME_LENGTH];

		ArrayGetString(rankNames, userData[index][dataRank] + 1, nextrankNames, charsmax(nextrankNames));

		format(message, charsmax(message), "%s^nNastepna ranga: %s", message, nextrankNames);
	}

	// Display the message.
	set_hudmessage(129, 96, 255, -1.0, 0.02, 0, 1.0, hudInterval + 0.1);
	ShowSyncHudMsg(index, hudObject, message);
}

toggle_hud(index, bool:status)
{
	userData[index][dataHudEnabled] = status;

	if(userData[index][dataHudEnabled])
	{
		set_task(hudInterval, "displayHud", index + TASK_HUD, .flags = "b");
	}
	else
	{
		// Remove task if it exists.
		if(task_exists(index + TASK_HUD))
		{
			remove_task(index + TASK_HUD);
		}
	}
}

loadConfigFile()
{
	// Initiate dynamic arrays.
	rankNames = ArrayCreate(MAX_RANK_NAME_LENGTH, 1);

	ForRange(i, 0, 1)
	{
		rankFrags[i] = ArrayCreate(1, 1);
	}

	new currentLine[MAX_RANK_NAME_LENGTH * 3],

		lineLength,

		readrankNames[MAX_RANK_NAME_LENGTH],
		readRankKills[2][MAX_CHARS],

		key[MAX_CHARS],
		value[MAX_CHARS * 2],

		bool:continueLine;

	ForFile(i, configFilePath, currentLine, charsmax(currentLine), lineLength)
	{
		// Continue if it's an empty line.
		if(!currentLine[0])
		{
			continue;
		}

		// Continue if found forbidden char (ex. comment) 
		ForArray(j, configFileForbiddenChars)
		{
			if(currentLine[0] == configFileForbiddenChars[j])
			{
				continueLine = true;
				
				break;
			}
		}

		if(continueLine)
		{
			continueLine = false;

			continue;
		}

		// Read line data.
		parse(currentLine, readrankNames, charsmax(readrankNames));

		// Divide line data into key and value.
		strtok(currentLine, key, charsmax(key), value, charsmax(value), configFileDataSeparator);
		
		// Get rid of white-characters.
		trim(value);
		
		// Divide remaining line data into kills range.
		strtok(value, readRankKills[0], charsmax(readRankKills[]), readRankKills[1], charsmax(readRankKills[]), configFileKillsSeparator);
	
		// Add rank name.
		ArrayPushString(rankNames, readrankNames);

		// Add rank kills.
		ForRange(j, 0, 1)
		{
			ArrayPushCell(rankFrags[j], str_to_num(readRankKills[j]));
		}

		#if defined DEBUG_MODE

		log_amx("Registered rank: (name = %s) (kills: %i-%i)", readrankNames, ArrayGetCell(rankFrags[0], ArraySize(rankFrags[0]) - 1), ArrayGetCell(rankFrags[1], ArraySize(rankFrags[1]) - 1));
	
		#endif
	}

	// Pause plugin if no ranks were loaded.
	if(!ArraySize(rankNames))
	{
		set_fail_state("Nie znaleziono zadnych rang.");

		return;
	}

	#if defined DEBUG_MODE

	log_amx("Zaladowano: %i rang(i) w zakresie (%i - %i).", ArraySize(rankNames), ArrayGetCell(rankFrags[0], 0), ArrayGetCell(rankFrags[1], ArraySize(rankNames) - 1));

	#endif
}

get_user_rank(index, bool:connect = false, bool:notify = true)
{
	new userStats[8],
		blank[8];

	get_user_stats(index, userStats, blank);

	// Update player's kills.
	userData[index][dataKills] = userStats[0];

	// Make sure player's rank is not bugged.
	// If so, make it right.
	if(userData[index][dataRank] >= ArraySize(rankNames))
	{
		userData[index][dataRank] = ArraySize(rankNames);

		return;
	}

	new oldRank = userData[index][dataRank];

	ForDynamicArray(i, rankNames)
	{
		// Break the loop if user kills is lower than required.
		// Ranks should be sorted in ascending order, so if the player
		// Has less kills than required, he's surely not gonna
		// Get a rank higher than the one currently proccessed.
		if(userStats[0] < ArrayGetCell(rankFrags[0], i))
		{
			break;
		}

		// Continue if he's got more kills than required.
		if(userStats[0] > ArrayGetCell(rankFrags[1], i) && i < ArraySize(rankNames) - 1)
		{
			continue;
		}

		// Set new rank
		userData[index][dataRank] = userData[index][dataRank] + 1 >= ArraySize(rankNames) ? ArraySize(rankNames) - 1 : i;
		
		// Set kills required for the next rank.
		userData[index][dataKillsRequired] = ArrayGetCell(rankFrags[1], userData[index][dataRank]);

		// Update user rank name.
		ArrayGetString(rankNames, userData[index][dataRank], userData[index][dataRankName], MAX_RANK_NAME_LENGTH);

		// We dont want to show messages when getting the rank for the first time.
		if(connect)
		{
			break;
		}

		// Break the loop if player's rank was not updated.
		if(userData[index][dataRank] <= oldRank)
		{
			break;
		}

		// Format messages if enabled.
		if(notify)
		{
			new message[2 << 7];

			formatex(message, charsmax(message), "%s^x01 Awansowales na range ^"^x03%s^x01^".", chatPrefix, userData[index][dataRankName]);

			if(userData[index][dataRank] + 1 >= ArraySize(rankNames))
			{
				format(message, charsmax(message), "%s Nastepna ranga:^x03 Brak^x01.", message);
			}
			else
			{
				new nextrankNames[MAX_RANK_NAME_LENGTH],
					nextRankFrags[2];

				ArrayGetString(rankNames, userData[index][dataRank] + 1, nextrankNames, charsmax(nextrankNames));

				nextRankFrags[0] = ArrayGetCell(rankFrags[0], userData[index][dataRank] + 1);
				nextRankFrags[1] = ArrayGetCell(rankFrags[1], userData[index][dataRank] + 1);

				format(message, charsmax(message), "%s Nastepna ranga: ^"^x03%s^x01^" (^x03%i^x01 - ^x03%i^x01).", message, nextrankNames, nextRankFrags[0], nextRankFrags[1]);
			}

			ColorChat(index, GREEN, message);
		}
		break;
	}
}

public native_get_user_rank(plugin, params)
{
	// Invalid amount of parameters.
	if(params != 1)
	{
		return -1;
	}

	new index = get_param(1);

	// Return error value if player is not connected.
	if(!is_user_connected(index))
	{
		return -1;
	}

	return userData[index][dataRank];
}

public native_get_rank_name(plugin, params)
{
	// Invalid amount of parameters.
	if(params != 3)
	{
		return;
	}

	new index = get_param(1);

	// Return if invalid rank index was given.
	if(index < 0 || index >= ArraySize(rankNames))
	{
		return;
	}

	new length = get_param(3);

	// Return if invalid length was given.
	if(!length)
	{
		return;
	}

	set_string(2, userData[index][dataRankName], length);
}

public native_get_rank_frags(plugin, params)
{
	// Invalid amount of parameters.
	if(params != 2)
	{
		return -1;
	}

	new index = get_param(1);

	// Invalid index?
	if(index < 0 || index >= ArraySize(rankNames))
	{
		return -1;
	}

	new which = get_param(2);

	// Invalid index?
	if(which < 0 || which > 2)
	{
		return -1;
	}

	return ArrayGetCell(rankFrags[which], index);
}