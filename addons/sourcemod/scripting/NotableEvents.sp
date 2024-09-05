#include <sourcemod>
#include <unixtime_sourcemod>

#define TIMEZONE UT_TIMEZONE_AGT

//#define DEBUG

#define ALERTS
#define PLAYERS_BIRTHDAYS


#pragma newdecls required

static int Day;
static int Month;
static int Year;

static ConVar Path;
static ConVar Timezone;

char sDate[32];

#include "notable_events/chat.sp"
#include "notable_events/players_birthdays.sp"
#include "notable_events/alerts.sp"

public Plugin myinfo =
{
	name = "NotableEvents",
	author = "hEl",
	description = "Notification of notable events",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
    #if defined ALERTS
    AlertsInit();
    #endif
    Path = CreateConVar("sm_notable_events_path", "{SM_PATH}data/notable_events/");
    Timezone = CreateConVar("sm_notable_events_timezone", "15");

    Path.AddChangeHook(OnConVarChanged);
    Timezone.AddChangeHook(OnConVarChanged);

    AutoExecConfig(true, "plugin.NotableEvents");

    #if defined PLAYERS_BIRTHDAYS
    PlayersBirthdaysInit();
    #endif
}

public void OnConVarChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    Day = 0;
    OnConfigsExecuted();
}

public void OnConfigsExecuted()
{
    if(!GetNewDate())
        return;

    #if defined ALERTS
    AlertsClear();
    #endif
    #if defined PLAYERS_BIRTHDAYS
    PlayersBirthdaysLoadFile();
    #endif
}

public void OnMapStart()
{
    #if defined ALERTS
    AlertsOnMapStart();
    #endif
}


public void OnMapEnd()
{
    #if defined ALERTS
    AlertsOnMapEnd();
    #endif
}

bool GetNewDate()
{
    int unix_time = GetTime();

    int year, month, day, hour, minute, second;

    UnixToTime(unix_time, year, month, day, hour, minute, second, Timezone.IntValue);

    #if defined DEBUG
    PrintToConsoleAll("%iy %im %id %ih %is", year, month, day, hour, minute);
    #endif

    if(Day == day && Month == month && Year == year)
        return false;

    Day = day;
    Month = month;
    Year = year;

    FormatEx(sDate, sizeof(sDate), "%i.%i", day, month);
    return true;
}

int BuildEventsPath(char[] buffer, int size)
{
    char sm_path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sm_path, sizeof(sm_path), "");

    char path[PLATFORM_MAX_PATH];
    Path.GetString(path, sizeof(path));

    ReplaceString(path, sizeof(path), "{SM_PATH}", sm_path, false);

    if(!DirExists(path) && !CreateDirectory(path, 511))
    {
        LogError("Cant load/create directory \"%s\"", path);
        return 0;
    }

    return strcopy(buffer, size, path);
}