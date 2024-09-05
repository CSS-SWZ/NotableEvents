#if !defined ALERTS
    #endinput
#endif

#define ALERTS_PLAYER_BIRTHDAYS

static const char AlertsKeys[][] =
{
    #if defined ALERTS_PLAYER_BIRTHDAYS
    "PlayersBirthdays"
    #endif
}

#if !defined ALERTS_PLAYER_BIRTHDAYS
#endinput
#endif

#include "alerts/alert_player_birthdays.sp"

static ConVar Cooldown;
static Handle Timer;

void AlertsInit()
{
    Cooldown = CreateConVar("sm_notable_events_alerts_cooldown", "60");

    #if defined ALERTS_PLAYER_BIRTHDAYS
    AlertsPlayersBirthdaysInit();
    #endif
}

void AlertsOnMapStart()
{
    AlertsStart();
}

void AlertsStart()
{
    AlertsStop();
    Timer = CreateTimer(Cooldown.FloatValue, Timer_Alerts, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Alerts(Handle timer)
{
    CallAdvertFunction(sizeof(AlertsKeys));
    return Plugin_Continue;
}

void CallAdvertFunction(int hops)
{
    if(hops == 0)
        return;

    static int AdvertKey;
    static Handle plugin;

    if(plugin == null)
        plugin = GetMyHandle();

    if(++AdvertKey >= sizeof(AlertsKeys))
        AdvertKey = 0;

    char function_name[256];
    FormatEx(function_name, sizeof(function_name), "%Alert%s", AlertsKeys[AdvertKey]);
    Function func = GetFunctionByName(plugin, function_name);

    bool result;
    Call_StartFunction(plugin, func)
    Call_Finish(result);

    if(!result)
        CallAdvertFunction(--hops);
}

void AlertsStop()
{
    delete Timer;
}

void AlertsOnMapEnd()
{
    Timer = null;
}

void AlertsClear()
{
    #if defined ALERTS_PLAYER_BIRTHDAYS
    AlertsPlayersBirthdaysClear();
    #endif
}