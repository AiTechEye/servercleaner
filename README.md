# servercleaner

Version: 0.8

License: code: LGPL-2.1, media: CC BY-SA-4.


cleans servers

## Commands:<br>
/delplayer <name> delete a player requeres ban (and scadmin to moderators)<br>
/delme delete your self, type "/delme delete me" again to confirm<br>
/delmod<name> Downgrades<br>
moderator to player (if the moderator has the scmoderator privilege) requeres scadmin<br>

## Privileges:<br>
scguest (Guest) to all new players<br>
scmoderator Can be downgraded to players by /delmod<br>
scadmin Can downgrad moderators, but cant be downgraded/deleted by moderators<br>
dont_delete Cant be deleted by commands or system<br>

## Time: event on server startup.<br>
All new players gets scguest (Guest), will be deleted after 7 days if they hasn't returned.<br>
Players will deleted after 365 days if they hasn't returned.<br>
Moderators (has the scmoderator privilege) will be downgraded to players if they hasent returned in 90 days.<br>
