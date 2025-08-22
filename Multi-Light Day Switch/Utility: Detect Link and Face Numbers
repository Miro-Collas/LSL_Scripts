// *********************************************************
// Quick script to report which link and face are clicked
//
// This is a free and open source script, under a CC0 license:
// https://creativecommons.org/public-domain/cc0/
// That means that if you paid for this script, you were scammed;
// if you're reselling it, may the fleas of a thousand camels
// infest your armpits.
// *********************************************************

default
{
    state_entry()
    {
        llOwnerSay("Remember to remove me from the object's contents when you're done.");
    }

    touch_start(integer total_number)
    {
        llOwnerSay("Link #: " + (string)llDetectedLinkNumber(0) + " - Face #: " + (string)llDetectedTouchFace(0));
    }
}
