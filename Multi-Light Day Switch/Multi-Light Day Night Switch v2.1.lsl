// *********************************************************
// Multi-Light Day/Night Switch
// Control multiple light sources in a link set from a
// single script, using a notecard with light infomation
//
// This is a free and open source script, under a CC0 license:
// https://creativecommons.org/public-domain/cc0/
// That means that if you paid for this script, you were scammed;
// if you're reselling it, may the fleas of a thousand camels
// infest your armpits.
// *********************************************************

// *********************************************************
// Defines - Constants
// *********************************************************

// Debugging
// #define DEBUG

#ifdef DEBUG
#define DebugSay(s) llOwnerSay(s);
#else
#define DebugSay(s) ;
#endif

// Name of the config notecard to load
#define CONFIG_FILE "lights.config"

// Defaults:
// How often to check for day/night transition, in seconds
#ifdef DEBUG
#define TIMER 5.0
#else
#define TIMER 60.0
#endif
// Max delay between lights switching on/off
#define DELAY 0.0

// Keywords recognised:
#define TAG_LIGHT "light="
#define TAG_GLOW "glow="
#define TAG_FULLBRIGHT "fullbright="
#define TAG_PROJECTOR "projector="
#define TAG_TOGGLE_TIMER "toggletimer="
#define TAG_DELAY "delay="
#define TAG_AUTO_DAY_NIGHT_SWITCH "autodaynightswitch="

#define SEPARATOR "="

// Constant strings, in case someone wants to translate
#define STR_MISSING_NOTECARD "No config notecard found; abort."
#define STR_LOADING_NOTECARD "Loading notecard..."
#define STR_NOTECARD_LOADED "Finished reading notecard."

// Simple replacements for leggibility
#define PARAM_LINKNUM llList2Integer(temp_list, 0)
#define PARAM_COLOR (vector)llList2String(temp_list, 1)
#define PARAM_INTENSITY llList2Float(temp_list, 2)
#define PARAM_RADIUS llList2Float(temp_list, 3)
#define PARAM_FALLOFF llList2Float(temp_list, 4)
#define PARAM_FACE llList2Integer(temp_list, 1)
#define PARAM_TEXTURE llList2String(temp_list, 1)
#define PARAM_FOV llList2Float(temp_list, 2)
#define PARAM_FOCUS llList2Float(temp_list, 3)
#define PARAM_AMBIANCE llList2Float(temp_list, 4)

#define DO_DELAY if(delay > 0.0) llSleep(llFrand(delay));

// *********************************************************
// Variables
// *********************************************************

// Lists of values
list lLights;
list lGlows;
list lFullBright;
list lProjectors;

// delays, timers
float toggle_timer;
float delay;
integer autodaynightswitch;

integer done_processing;
integer iNoteCardLine;
key     kCurrentDataRequest;
integer switch;
integer day;
integer dayLast;
vector  sunDirection;

// *********************************************************
// Extract value from config notecard line
// *********************************************************

string GetValue(string sString)
{
    integer iStart;
    string sValue = "";
    string sbValue = "";
 
    iStart = llSubStringIndex(sString, SEPARATOR) + 1;
    if(iStart)
    {
        sValue = llGetSubString(sString, iStart, llStringLength(sString) - 1);
        if(sValue)
        {
            sbValue = llToLower(sValue);
            if(sbValue == "true")
                sValue = "1";
            if(sbValue == "false")
                sValue = "0";
            return(sValue);
        }
    }
    return(NULL_KEY);
}

// *********************************************************
// Toggle lights on/off
// Switch=TRUE, toggle on
// *********************************************************

lightToggle(integer toggle)
{
    string current_light = "";
    list temp_list = [];
    integer i;

    // Handle point lights
    for(i=0;i<llGetListLength(lLights);i++)
    {
        // [ PRIM_POINT_LIGHT, integer boolean, vector linear_color, float intensity, float radius, float falloff ] 
        current_light = llList2String(lLights, i);
        temp_list = llCSV2List(current_light);
        if(toggle)
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_POINT_LIGHT, TRUE, PARAM_COLOR, PARAM_INTENSITY, PARAM_RADIUS, PARAM_FALLOFF]);
        else
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_POINT_LIGHT, FALSE, <1.000, 1.000, 1.000>, 0.0, 0.0, 0.0]);
        DO_DELAY;
    }
    // Handle glow
    for(i=0;i<llGetListLength(lGlows);i++)
    {
        // [ PRIM_GLOW, integer face, float intensity ] 
        current_light = llList2String(lGlows, i);
        temp_list = llCSV2List(current_light);
        if(toggle)
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_GLOW, PARAM_FACE, PARAM_INTENSITY]);
        else
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_GLOW, PARAM_FACE, 0.0]);
        DO_DELAY;
    }
    
    // Handle full bright
    for(i=0;i<llGetListLength(lFullBright);i++)
    {
        // [ PRIM_FULLBRIGHT, integer face, integer boolean ] 
        current_light = llList2String(lFullBright, i);
        temp_list = llCSV2List(current_light);
        if(toggle)
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_FULLBRIGHT, PARAM_FACE, TRUE]);
        else
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_FULLBRIGHT, PARAM_FACE, FALSE]);
        DO_DELAY;
    }

    // Handle projectors
    for(i=0;i<llGetListLength(lProjectors);i++)
    {
        // [ PRIM_PROJECTOR, string texture, float fov, float focus, float ambiance ] 
        current_light = llList2String(lProjectors, i);
        temp_list = llCSV2List(current_light);
        if(toggle)
            llSetLinkPrimitiveParamsFast(PARAM_LINKNUM, [PRIM_PROJECTOR, PARAM_TEXTURE, PARAM_FOV, PARAM_FOCUS,PARAM_AMBIANCE]);
        DO_DELAY;
    }
}

default
{
    on_rez(integer param)
    {
        llResetScript();
    }
    
    state_entry()
    {
        integer iNotecardIndex;
        integer iNotecardCount;
        string  sSettingsNotecard;
        done_processing = FALSE;
        toggle_timer = TIMER;
        delay = DELAY;
        autodaynightswitch = TRUE;
 
        lLights = [];
        lGlows = [];
        lFullBright = [];
        lProjectors = []; 
        switch = FALSE;
        sunDirection = llGetSunDirection();
        iNotecardCount = llGetInventoryNumber(INVENTORY_NOTECARD);
        if(iNotecardCount < 1)
        {
            llOwnerSay(STR_MISSING_NOTECARD);
            return;
        }
        for(iNotecardIndex=0;iNotecardIndex<iNotecardCount;iNotecardIndex++)
        {
            sSettingsNotecard = llGetInventoryName(INVENTORY_NOTECARD, iNotecardIndex);
            if(sSettingsNotecard == CONFIG_FILE)
            {  
                llOwnerSay(STR_LOADING_NOTECARD);
                iNoteCardLine = 0;
                kCurrentDataRequest = llGetNotecardLine(CONFIG_FILE, iNoteCardLine);
                return;
            }
        }
        llOwnerSay(STR_MISSING_NOTECARD);
    }

    changed(integer change)
    {
        if (change & (CHANGED_LINK | CHANGED_INVENTORY))
            llResetScript();
    }

    dataserver(key kQuery, string sData)
    {
        kCurrentDataRequest = "";
        if(sData != EOF)
        {
            sData = llStringTrim(sData, STRING_TRIM);
            // Don't parse lines starting with a "#"
            if((llStringLength(sData) > 0) && (llSubStringIndex(sData, "#") == -1))
            {
                if(llSubStringIndex(llToLower(sData), llToLower(TAG_LIGHT)) > -1)
                {
                    lLights += GetValue(sData);
                }
 
                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_GLOW)) > -1)
                {
                    lGlows += GetValue(sData);
                }
 
                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_FULLBRIGHT)) > -1)
                {
                    lFullBright += GetValue(sData);
                }

                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_PROJECTOR)) > -1)
                {
                    lProjectors += GetValue(sData);
                }

                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_TOGGLE_TIMER)) > -1)
                {
                    toggle_timer += (float)GetValue(sData);
                }

                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_DELAY)) > -1)
                {
                    delay += (float)GetValue(sData);
                }
                
                else if(llSubStringIndex(llToLower(sData), llToLower(TAG_AUTO_DAY_NIGHT_SWITCH)) > -1)
                {
                    autodaynightswitch = (integer)GetValue(sData);
                }

            }
 
            kCurrentDataRequest = llGetNotecardLine(CONFIG_FILE, ++iNoteCardLine );
        }
        else
        {
            // Start main loop
            llOwnerSay(STR_NOTECARD_LOADED);
            switch = FALSE;
            // This only needed if auto day/night is enabled
            if(autodaynightswitch)
            {
                sunDirection = llGetSunDirection();
                if (sunDirection.z <= 0)
                    day = 0;
                else
                    day = 1;
                if(!day)
                    switch = TRUE;
                lightToggle(switch);
                done_processing = TRUE;
                llSetTimerEvent(0.1);
            }
        }
    }
    
    timer()
    {
        llSetTimerEvent(toggle_timer);
        sunDirection = llGetSunDirection();
        dayLast = day;
        if (sunDirection.z <= 0)
            day = 0;
        else
            day = 1;
        if(dayLast == day)
            return;
        else {
            if ((!day & !switch) || (day && switch))
                switch = !switch;
        }        
        lightToggle(switch);
    }

    touch_start(integer total_number) 
    {
        // Ignore if NC still being read
        if(done_processing)
        {
            switch = !switch;
            lightToggle(switch);
        }
    }
}
