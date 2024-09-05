#if !defined ALERTS_PLAYER_BIRTHDAYS
    #endinput
#endif

static int LastAlertTime[MAX_PLAYERS_BIRTHDAYS];

static ConVar Cooldown;

void AlertsPlayersBirthdaysInit()
{
    Cooldown = CreateConVar("sm_notable_events_alerts_pbdays_cooldown", "300");
}

void AlertsPlayersBirthdaysClear()
{
    for(int i = 0; i < PlayersBirthdays_Count; ++i)
        LastAlertTime[i] = 0;
}

public bool AlertPlayersBirthdays()
{
    if(PlayersBirthdays_Count == 0)
        return false;

    if(PlayersBirthdays_Count == 1)
        return AlertPlayerBirthday(0);

    int index;

    for(int i = 1; i < PlayersBirthdays_Count; ++i)
        if(LastAlertTime[index] > LastAlertTime[i])
            index = i;

    return AlertPlayerBirthday(index);
}

bool AlertPlayerBirthday(int player_id)
{
    int time = GetTime();

    if(time - LastAlertTime[player_id] < Cooldown.IntValue)
        return false;

    LastAlertTime[player_id] = time;

    char info[256];

    bool country = (PlayersBirthdays[player_id].Country[0] != 0);
    bool tags = (PlayersBirthdays[player_id].Tags[0] != 0);


    if(country)
    {
        StrCat(info, sizeof(info), PlayersBirthdays[player_id].Country);
        
        if(tags)
        {
            StrCat(info, sizeof(info), " | ");
            StrCat(info, sizeof(info), PlayersBirthdays[player_id].Tags);
        }
    }
    else if(tags)
    {
        StrCat(info, sizeof(info), PlayersBirthdays[player_id].Tags);
    }

    if(info[0])
    {
        Format(info, sizeof(info), " (%s)", info);
    }

    ChatPrintToChatAll("%s celebrates today his birthday!%s", PlayersBirthdays[player_id].Name, info);
    return true;
}