# servercleaner

License: CC0
Version: 0.8

cleans servers

## Commands:

/delplayer <name> delete a player requeres ban (and scadmin to moderators)
/delme delete your self, type "/delme delete me" again to confirm
/delmod<name> Downgrades
moderator to player (if the moderator has the scmoderator privilege) requeres scadmin

## Privileges:

scguest (Guest) to all new players
scmoderator Can be downgraded to players by /delmod
scadmin Can downgrad moderators, but cant be downgraded/deleted by moderators
dont_delete Cant be deleted by commands or system

## Time: event on server startup.

All new players gets scguest (Guest), will be deleted after 7 days if they hasn't returned.
Players will deleted after 365 days if they hasn't returned.
Moderators (has the scmoderator privilege) will be downgraded to players if they hasent returned in 90 days.
