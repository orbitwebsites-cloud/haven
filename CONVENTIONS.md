# Haven notes

Slingshot bounce platformer, Godot 4.7.

- You can't walk. You get one slingshot shot per try (drag away from where you want to go, let go), then pads and bouncy walls have to carry you to the goal.
- Player is a RigidBody2D called `Player` with lock_rotation on and a Line2D child called `AimLine`.
- Drag-in scenes: `bounce_pad.tscn` (the white arrow is the launch direction, rotate to aim, Strength sets how hard), `spikes.tscn` (restarts the level), `goal.tscn`.
- Bouncy walls: put a PhysicsMaterial on the wall. Godot adds the player's bounce to the wall's, capped at 1.
- player.gd uses `_input` because the ColorRects were eating clicks. If we add menu buttons, look at this again.
- ball.svg and spikes.svg are placeholders until the real art is done.
- Scripts and scenes sit in the root for now. Tabs, snake_case.
- Levels: level.tscn -> level_2.tscn -> level_3.tscn -> back to level 1. The order lives in `LEVELS` at the top of goal.gd. A goal with `next_scene` set goes there instead.
- Secret: the faint shimmer by the "LEVEL 3" title (secret_portal.tscn) leads to secret_level.tscn, whose goal opens goat_win.tscn.
- player.tscn is the player with the character art. Levels 2, 3 and the secret level use it. Level 1 still has its own copy of the player.
