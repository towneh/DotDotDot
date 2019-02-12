# DotDotDot
DotDotDot is a DoT tracker using a different display model than standard DoT timers.  Rather than have bar width represent a fixed percentage of the total time of the DoT remaining, bar width represents a fixed amount of time.  Since it uses the new debuff time methods provided in patch 2.1, the time remaining isn't estimated and resists/removals are handled by default.

_Credit goes to Kalven who was the original author of this addon and maintained it up to 2.4_

## Features
- Fixed relationship between time and bar width - a shorter bar is ALWAYS going to end first.
- GetDebuffInfo method for debuff info provides accurate knowledge of presence and timing.
- GUID based methods for mob tracking allow for accurate multimob tracking
- Configurable window width - look at the next 5, 10, 15, 60, 13, 17.5, 20 seconds: whatever makes you happy.  DoTs that have more time remaining than the window will simply show as full bars.
- Other than that?  It's a DoT timer.  You know how this works.

## Known Issues
- Mouseover-targeted (or targeting by unitid suffixed by N target statements) DoTs are not tracked until you either target or focus the unit you dotted. - untested, but should be working for mouseovers now.  targettarget and similar will still need to be targeted to be tracked.

![Example](https://i.imgur.com/AEYOfFn.png)

_Example showing same named mobs. Green bars indicate currently selected target_
