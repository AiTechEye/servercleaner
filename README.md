# servercleaner

Version: 1

License: code: LGPL-2.1, media: CC BY-SA-4

servers cleaner

This mod works with minetest 5.0.0 or newer


To keep the server working for a long time and its quality you need to maintenance it.

One thing that makes the maintenancing harder is are inactive players, they plays for a time, maybe just choosing another name or never returns, especially guests.

Old protected areas can be annoying for players, some small and doesn't protects anything useful at all or takes space that other players need, just messing up for the recurrent players, locked doors, chests takes less space, but are still annoying.

This mod will delete old players from the world database, auth, locked things like chests and doors, protected areas etc...

The current mod does:
Delete player: account, auth/privileges, areas, bed, unified_inventory-home, protectors
Unlock players locked chests/doors/trapdoor/bones
Cleans unknown blocks and entities automatically.
Giving you full power over your staff.
Removes nodes & objects you dont want

Supported/locked blocks are unlocked by lbm (when the blocks are loaded)

Commands:

/delplayer <name> delete a player requeres ban (and scadmin to moderators...)
/delme delete your self, type "/delme delete me" again to confirm
/delmod<name> Downgrade <name> to player requeres ban, scadmin or scmoderator privs...
/advm (manage "advanced members")
/clobjectschecks for unknown entities around you
/clonf nodes/entities filter

Privileges:
scguest (Guest) to all new players
scmoderator Can be downgraded to players by /delmod
scadmin Can downgrad moderators, but cant be downgraded/deleted by moderators
dont_delete Cant be deleted by commands or system

Time: event on server startup.
All new players gets scguest (Guest), will be deleted after 7 days if they hasn't returned.
Players will deleted after 365 days if they hasn't returned.
Moderators (has the scmoderator privilege) will be downgraded to players if they hasent returned in 90 days.

Auto cleaner
The mod lists all registered entities and nodes, if these are missing then those will be removed.
Players can also punch unknown nodes to add or do the /clobjects to add entities

ADVM
Just type /advm and you can see, and in a really easy way handle all of your staff.
It will show all players with odd privileges (compare with basic_privs)
Anyone that has the kick privilege can see this, but not all buttons.


CLONF
Type /clonf and you can see and remove, all unknown nodes/entities.
You can also add existing to the filter.
unknown items removes from the filter, if those hasn't been been detected in 150 days (as default)
Requires scadmin to see this
