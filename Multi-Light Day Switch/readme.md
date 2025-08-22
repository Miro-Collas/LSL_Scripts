LICENSE

This is a free and open source script, under a CC0 license:
https://creativecommons.org/public-domain/cc0/
That means that if you paid for this script, you were scammed; if you're reselling it, may the fleas of a thousand camels infest your armpits.

HOW TO USE

This script serves to control multiple lights, linked together, from a single script. Lights will turn on at nightfall, and off at the start of the day. They will also toggle their state on touch, staying that way until the next day/night change.

Naturally, any lights you want to add this to, need to be moddable. If you like, you can use one script for each light, without linking them. However, fewer scripts means reduced region lag. It may not make much difference, but every bit helps.

You should remove all scripts in the lights before starting, so that they don't conflict with this one. Therefore, I *strongly* suggest working on a copy of the lights to make sure you get all the data right, before adding the notecard and script to your placed lights.

Light info should be specified in the lights.config notecard. Edit this as needed (see below), place it into the light linkset, then drop in the script. The script will parse the notecard and is then ready to go. Lights will turn on/off automagically based on time of day, and also on touch.

Format for lights.config notecard:
- lines starting with # are treated as comments and ignored when parsing
- each non-comment line MUST start with with a keyword, followed by a = and then parameters. These are:
- toggletimer: how often to check whether day has changed to night, or vice versa, in seconds. Shouldn't be too low, so as not to be checking too often. If this keyword isn't present in the notecard, it defaults to 60secs
- delay: pause between turning lights on/off, in seconds, to add some "realism". Defaults to 0 (no delay).
- light=integer link_num, vector linear_color, float intensity, float radius, float falloff
- glow=integer link_num, integer face, float intensity
- fullbright=integer link, integer face
- projector=integer link_num, string texture, float fov, float focus, float ambiance
- Ref. https://wiki.secondlife.com/wiki/LlSetPrimitiveParams
See the supplied notecard for examples.

IMPORTANT NOTES

Remember, if you're testing during SL daytime, at startup the script will turn the lights off, since it is daytime. Don't let this fool you into thinking it all doesn't work (as happened to me during a testing phase). Simply touch the object to turn the lights on.

color vectors *must* be given in standard LSL format, such as:
<0.258, 0.804, 0.638>
including the angle brackets.

lights.config may have as many light, glow fullbright and projector entries as you wish. However, there are limits to script memory so don't overdo it. It should only have one each of toggletimer and delay.

Entries may be in any order, but when the script is running, they are  processed in this order: light, glow, full bright, projector.

For type glow and full bright, if you want it applied to all faces on the link, set the face value to -1. Ref. https://wiki.secondlife.com/wiki/ALL_SIDES

Note that for projectors, you MUST also have a light entry for the same link number. Also , they don't actually need to be turned on/off *IF* the projector has been set up before using this script. However, if you know what you're doing, you can use this script to set it up (texture, etc), so I am leaving in the code to handle them.

Why full bright support? Because it can add to the effect of a light being turned on, depending on how the light itself is made. No need to use it if you don't want to.

If you want to view and/or modify the code, you will need to enable the LSL Preprocessor (Firestorm).

I have included a script, Utility: Dump Light Info, which will attempt to detect all the lights in a linkset, and dump them to local. You can copy/paste the info into a lights.config notecard. To use it, first make sure that all the lights you plan to use are turned on. Then drop the script into the linkset. It will output several lines. Copy these, paste into a notecard named lights.config. This script will self delete itself from object contents once it has finished.

Please note that due to script limitations, projectors are NOT detected. 
Ref https://community.secondlife.com/forums/topic/486118-only-set-ambiance-on-prim_projector/#comment-2446570

There is also a small script, Utility: Detect Link and Face Numbers, which will report to local the link and face number touched. Useful for items you wish to use as lights, but which are not currently set up as such. Since the script can be used multiple times, it doesn't self-delete, so remember to remove it from the object once you have finished.

If you find bugs, let me know, but I am not offering support of any kind, sorry.

----------

CHANGE LOG

v1.0 - 2025-08-16
- Initial non-public release

v2.0 - 2025-08-17
- remove code to turn off projectors, it made no sense.
- add configs for delay between lights on/off, and day/night check timer.
- added utility scripts
- internal changes for legibility, and to handle the output of Utility: Dump Light Info

v2.1 - 2025-08-21
- If multiple notecards are present in the object, the code wasn't handling it properly; fixed.
- Minor code clean-up.
- First public release.

