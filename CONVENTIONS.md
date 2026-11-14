# Haven notes

Slingshot bounce platformer, Godot 4.7.

- You can't walk. You get one slingshot shot per try (drag away from where you want to go, let go), then pads and bouncy walls have to carry you to the goal.
- Player is a RigidBody2D called `Player` with lock_rotation on and a Line2D child called `AimLine`.
- Drag-in scenes: `bounce_pad.tscn` (the white arrow is the launch direction, rotate to aim, Strength sets how hard), `spikes.tscn` (restarts the level), `goal.tscn`.
- Bouncy walls: put a PhysicsMaterial on the wall. Godot adds the player's bounce to the wall's, capped at 1.
- player.gd uses `_input` because the ColorRects were eating clicks. If we add menu buttons, look at this again.
- ball.svg and spikes.svg are placeholders until the real art is done.
- Scripts and scenes sit in the root for now. Tabs, snake_case.
- Levels: level.tscn -> level_2.tscn -> level_3.tscn -> ending.tscn. The order lives in `LEVELS` at the top of game.gd. After the last one you get ending.tscn. A goal with `next_scene` set goes there instead.
- Secret: the faint shimmer by the "LEVEL 3" title (secret_portal.tscn) leads to secret_level.tscn, whose goal opens goat_win.tscn.
- player.tscn is the player with the character art. Levels 2, 3 and the secret level use it. Level 1 still has its own copy of the player.
- Gray walls bounce now: they use a PhysicsMaterial with bounce 0.6 (teal walls are 1.0, the start platform has none). bounce_pad.tscn keeps its art under a `Visual` node so the pad can squish when hit.
- Look: hand-drawn notebook doodle. background.tscn (in every scene) is the paper plus a full-screen sketch.gdshader that adds the wobbly pen outlines, marker streaks and ruled lines, so just use flat colours and the shader does the rest. To change the mood, change the shader's paper_color / ink_color / rule_color.
- Text uses patrick_hand.woff2 (Patrick Hand, SIL Open Font License, see patrick_hand_license.txt), set as the project's custom font. It ships with the game so web and Mac/Linux builds look the same as Windows.
- start_screen.tscn is the main scene (PLAY goes to level.tscn). trail.tscn + trail.gd is the player's speed line.
- The intro lives in start_screen.gd `play_intro()`: one Tween that types the rules, launches the mascot and ends on the normal menu. Any click or key skips it (`custom_step`). Intro-only props sit under `Center/Intro` and get hidden at the end.
- game.gd is an autoload called `Game`. It owns the level order, the save file (`user://save.cfg`, just how many levels are unlocked), the shot counter, the sounds, the HUD in the corner and the paper fade between scenes. Change scenes with `Game.go(path)` so the fade plays.
- Sounds are built in code in `Game.make_sounds()`, there are no audio files. `Game.play("boing")` etc. To swap in real audio, load the file into the `sounds` dictionary instead.
- Player keys: R restarts straight away, Esc goes back to the menu. Dying fades the player out first (`restart()`), R skips that (`restart(true)`).
- The dotted aim preview only shows on the first level in `LEVELS`.
- Renderer is Compatibility (OpenGL) so the game can export to web. The Quit button hides itself in web builds.
- The intro plays once per session (`Game.intro_seen`). The page-number buttons on the menu are built in `make_level_row()` from `Game.unlocked`.
