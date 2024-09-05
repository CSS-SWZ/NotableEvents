#if !defined PLAYERS_BIRTHDAYS
    #endinput
#endif

//#define DUMP
#define PLAYERS_BIRTHDAYS_FILE "players_birthdays.txt"
#define MAX_PLAYERS_BIRTHDAYS 10

enum struct PlayerBirthday
{
    char Name[128];
    char SteamID64[64];
    char Country[64];
    char Tags[64];
    int Year;
}

PlayerBirthday PlayersBirthdays[MAX_PLAYERS_BIRTHDAYS];
int PlayersBirthdays_Count;

stock void PlayersBirthdaysInit()
{
    #if defined DUMP
    RegAdminCmd("sm_playerbdays_dump", Command_PlayerBirthdaysDump, ADMFLAG_RCON);
    #endif

    PlayersBirthdays_Count = 0;
}

void PlayersBirthdaysLoadFile()
{
    char path[PLATFORM_MAX_PATH];
    BuildEventsPath(path, sizeof(path));
    StrCat(path, sizeof(path), PLAYERS_BIRTHDAYS_FILE);

    KeyValues kv = new KeyValues("PlayersBirthdays");

    if(!kv.ImportFromFile(path))
    {
        LogError("Keyvalues.ImportFromFile(path = %s)", path);
        return;
    }

    PlayersBirthdaysLoadPlayers(kv);

    delete kv;
}

bool PlayersBirthdaysLoadPlayers(KeyValues kv)
{
    if(!kv.JumpToKey(sDate))
        return false;

    if(!kv.GotoFirstSubKey())
        return false;

    PlayersBirthdays_Count = 0;
    
    do
    {
        PlayersBirthdaysLoadPlayer(kv);
    }
    while(kv.GotoNextKey());

    return true;
}

void PlayersBirthdaysLoadPlayer(KeyValues kv)
{
    char name[128];
    char steamid64[64];
    char country[64];
    char tags[64];
    int year;

    kv.GetString("nickname", name, sizeof(name))
    kv.GetString("steamid64", steamid64, sizeof(steamid64));
    kv.GetString("country", country, sizeof(country));
    kv.GetString("tags", tags, sizeof(tags));
    year = kv.GetNum("year");

    int player_id = PlayersBirthdays_Count;
    PlayersBirthdays[player_id].Name = name;
    PlayersBirthdays[player_id].SteamID64 = steamid64;
    PlayersBirthdays[player_id].Country = country;
    PlayersBirthdays[player_id].Tags = tags;
    PlayersBirthdays[player_id].Year = year;
    ++PlayersBirthdays_Count;
}

#if defined DUMP
public Action Command_PlayerBirthdaysDump(int client, int args)
{
    PlayersBirthdaysDump()
    return Plugin_Handled;
}

stock void PlayersBirthdaysDump()
{
    PrintToConsoleAll("PlayersBirthdaysDump() : Today is %s", sDate);

    if(PlayersBirthdays_Count == 0)
    {
        PrintToConsoleAll("No one is celebrating a birthday today");
        return;
    }
    
    PrintToConsoleAll("Total birthday celebrations today: %i player%c", PlayersBirthdays_Count, PlayersBirthdays_Count == 1 ? ' ':'s');

    for(int i = 0; i < PlayersBirthdays_Count; ++i)
        PrintToConsoleAll("#%i Nickname: %s, Steamid64 = %s, Country = %s, Tags = %s, Year = %i", i + 1, PlayersBirthdays[i].Name, PlayersBirthdays[i].SteamID64, PlayersBirthdays[i].Country, PlayersBirthdays[i].Tags, PlayersBirthdays[i].Year)
}
#endif

/*
MIGRATION
void PlayersBirthdaysLoadFileMigration()
{
    return;
    char path[PLATFORM_MAX_PATH];
    BuildEventsPath(path, sizeof(path));
    StrCat(path, sizeof(path), PLAYERS_BIRTHDAYS_FILE);

    KeyValues kv = new KeyValues("PlayersBirthdays");

    if(!kv.ImportFromFile(path))
    {
        LogError("Keyvalues.ImportFromFile(path = %s)", path);
        return;
    }

    if(!kv.GotoFirstSubKey())
    {
        LogError("Keyvalues.GotoFirstSubKey()", path);
        return;
    }

    char date[32];
    char buffers[3][16];
    int count;
    do
    {
        kv.GetString("date", date, sizeof(date));
        count = ExplodeString(date, "/", buffers, sizeof(buffers), sizeof(buffers[]));
        
        FormatEx(date, sizeof(date), "%s.%s", buffers[0], buffers[1]);

        if(count == 3)
            kv.SetString("year", buffers[2]);

        kv.SetSectionName(date);
    }
    while(kv.GotoNextKey());
    kv.Rewind();
    kv.ExportToFile(path);
    delete kv;
}

stock void PlayersBirthdaysLoadFileMigration2()
{
    char path[PLATFORM_MAX_PATH];
    BuildEventsPath(path, sizeof(path));
    StrCat(path, sizeof(path), PLAYERS_BIRTHDAYS_FILE);

    KeyValues kv = new KeyValues("PlayersBirthdays");
    KeyValues kv2 = new KeyValues("PlayersBirthdays");

    if(!kv.ImportFromFile(path))
    {
        LogError("Keyvalues.ImportFromFile(path = %s)", path);
        return;
    }

    if(!kv.GotoFirstSubKey())
    {
        LogError("Keyvalues.GotoFirstSubKey()", path);
        return;
    }

    char date[32];
    char buffer[256];
    char buffers[3][16];
    int year;
    int count;
    do
    {
        kv.GetSectionName(date, 32);
        ExplodeString(date, ".", buffers, 2, 16);
        FormatEx(date, 32, "%s.%s", buffers[1], buffers[0]);
        kv2.JumpToKey(date, true);
        FormatEx(date, 32, "Player %i", GetRandomInt(1, 9999999));
        kv2.JumpToKey(date, true);
        year = kv.GetNum("year");

        if(year != 0)
            kv2.SetNum("year", year);

        kv.GetString("nickname", buffer, 256);
        kv2.SetString("nickname", buffer);
        
        kv.GetString("date", buffer, 256);
        kv2.SetString("date", buffer);

        kv.GetString("tags", buffer, 256);
        kv2.SetString("tags", buffer);

        kv.GetString("country", buffer, 256);
        kv2.SetString("country", buffer);

        kv.GetString("profile", buffer, 256);
        kv2.SetString("profile", buffer);
        kv2.Rewind();
    }
    while(kv.GotoNextKey());
    delete kv;
    kv2.ExportToFile(path);
    delete kv2;
}
*/