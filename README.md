# servercleaner

Version: 1

License: code: LGPL-2.1, media: CC BY-SA-4


cleans servers

Commands:

/delplayer <name> delete a player requeres ban (and scadmin to moderators)
/delme delete your self, type "/delme delete me" again to confirm
/delmod<name> Downgrades
moderator to player (if the moderator has the scmoderator privilege) requeres scadmin
/advm (manage "advanced members")
/clobjectschecks for unknown entities around you

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
