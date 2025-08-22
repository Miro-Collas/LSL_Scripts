// *********************************************************
// Dump info one lights in a linkset
// Note that projectors cannot be detected.
//
// This is a free and open source script, under a CC0 license:
// https://creativecommons.org/public-domain/cc0/
// That means that if you paid for this script, you were scammed;
// if you're reselling it, may the fleas of a thousand camels
// infest your armpits.
// *********************************************************

// *********************************************************
// Defines
// *********************************************************

// Keywords recognised:
#define TAG_LIGHT "light="
#define TAG_GLOW "glow="
#define TAG_FULLBRIGHT "fullbright="
#define TAG_PROJECTOR "projector="

// Simple replacements for leggibility
#define PARAM_LIGHT_ON llList2Integer(lLights, 0)
#define PARAM_GLOW_INTENSITY llList2Float(lGlows, 0)
#define PARAM_FULLBRIGHT_ON llList2Integer(lFullBrights, 0)

// *********************************************************
// Variables
// *********************************************************

integer NumLinks;
integer NumFaces;

// List for light info
list lLights;
list lGlows;
list lFullBrights;
// list lProjectors

default
{
    state_entry()
    {
        integer i;
        integer j;
        
        llOwnerSay("Checking links for lights, etc...");
        llOwnerSay("If there is valid output, you can copy/paste to a lights.config notecard.");
        llOwnerSay("===== Start copying below this line =====");
        NumLinks = llGetNumberOfPrims();
        for(i=1;i<=NumLinks;i++)
        {
            // [ integer boolean, vector linear_color, float intensity, float radius, float falloff ] 
            lLights = llGetLinkPrimitiveParams(i, [ PRIM_POINT_LIGHT ]);
            if(PARAM_LIGHT_ON != 0)
            {
                // we don't need the boolean
                lLights = llList2List(lLights, 1, -1);
                llOwnerSay(TAG_LIGHT + (string)i + ", " + llList2CSV(lLights));
            }
            for(j=0;j<llGetLinkNumberOfSides(i);j++)
            {
                lGlows = llGetLinkPrimitiveParams(i, [ PRIM_GLOW, j ]);
                lFullBrights = llGetLinkPrimitiveParams(i, [ PRIM_FULLBRIGHT, j ]);
                if(PARAM_GLOW_INTENSITY > 0.0)
                {
                    llOwnerSay(TAG_GLOW + (string)i + ", " + (string)j + ", " + (string)PARAM_GLOW_INTENSITY);
                }
                if(PARAM_FULLBRIGHT_ON != 0)
                {
                    llOwnerSay(TAG_FULLBRIGHT + (string)i + ", " + (string)j + ", " + (string)PARAM_FULLBRIGHT_ON);
                }
            }
        }
        llOwnerSay("===== Stop copying above this line =====");
        llOwnerSay("Deleting this script");
        llRemoveInventory(llGetScriptName());
    }

}
