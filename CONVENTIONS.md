# Bounce notes

Slingshot bounce platformer, Godot 4.7. The game is called Bounce. The folder and the repo are still called haven, and "haven" is also the back page of the notebook in the story (the ending screen).

## How it plays

- You can't walk. You get one slingshot shot per try (drag away from where you want to go, let go), then pads and bouncy walls have to carry you to the goal.
- Player is a RigidBody2D called `Player` with lock_rotation on and a Line2D child called `AimLine`. The pull is measured from the AimLine, so keep that node on the ball.
- Drag-in scenes: `bounce_pad.tscn` (the red arrow is the launch direction, rotate to aim, Strength sets how hard), `spikes.tscn` (restarts the level), `goal.tscn`.
- Bouncy walls: put a PhysicsMaterial on the wall. Godot adds the player's bounce to the wall's, capped at 1. Gray walls are 0.6, teal walls are 1.0, the start platform has none.
- player.gd uses `_input` because the ColorRects were eating clicks.
- player.tscn is the player with the character art. Every level uses it except level 1, which still has its own copy of the player (drawn 90 px below its body, which is why the pull is measured from the AimLine).

## Story (Next Guy Up)

- You drew a lil guy in math and forgot his legs. Notebook check is today and doodle pages get ripped out. The only safe spot is haven: hidden at the very end of the notebook.
- Every restart you draw a new guy, so the corner of each level says `lil guy #N`. Lower is better.
- The last level's star opens haven.tscn. Every guy who made it lives there in a row with his number, wearing what he wore. A guy who went through the secret level is drawn in sharpie with the goat's shades, and the goat moves in too.
- Each level has one note in the bottom corner. They live in `NOTES` at the top of game.gd.

## Where things live

- game.tscn + game.gd is the `Game` autoload: the run (`guy`, `sharpie`), the look (`color`, `hat`), who lives in haven (`citizens`, `record`), the save file (`user://save.cfg`) and the corner text. Only runs started from PLAY get saved, so testing a level with F6 doesn't count.
- Level order lives in `LEVELS` at the top of goal.gd. A goal with `next_scene` set goes there instead. A new level needs a line in `LEVELS` and a note in `NOTES`.
- Secret: the faint shimmer by the "LEVEL 3" title (secret_portal.tscn) leads to secret_level.tscn, whose goal opens goat_win.tscn, which leads to haven.
- start_screen.tscn is the main scene. `play_intro()` in start_screen.gd is one Tween that types the story, launches the mascot and ends on the menu. Any click or key skips it (`custom_step`), and it only plays once per launch. Intro-only props sit under `Center/Intro`.
- customize.tscn (UR GUY on the menu) picks a marker colour and a hat. wardrobe.gd holds the colours and `Wardrobe.dress()`, which every guy uses. To add a hat, draw it in hats.tscn: the node name is the hat name. The shades unlock after the goat.
- lil_guy.tscn is the character with no physics, used by the menu, the customize screen and the haven row.
- trail.tscn + trail.gd is the speed line behind the player.
- More drag-in pieces: `paper_wall.tscn` (pink, rips on the first hit and bounces you back, gone after that). Any pad with `One Use` ticked turns purple and only fires once. `mover.gd` on a plain Node child slides its parent back and forth (`Travel`, `Period`).
- Sounds are built in code in `Game.make_sounds()`, there are no audio files. `Game.play("boing")` etc. Only the pad boing and the paper rip are hooked up so far.
- press/ holds the itch.io cover gif, screenshots and page text (itch_page.md). The `.gdignore` in there keeps Godot from importing them.
- Scripts and scenes sit in the root for now. Tabs, snake_case.

## Look

- Hand-drawn notebook doodle. background.tscn (in every scene) is the paper plus a full-screen sketch.gdshader that adds the wobbly pen outlines, marker streaks and ruled lines, so just use flat colours and the shader does the rest.
- To change the paper colour, change three things together: the shader's `paper_color`, the Paper rect in background.tscn and the clear colour in Project Settings. `ink_color` and `rule_color` can change on their own.
- Text uses patrick_hand.woff2 (Patrick Hand, SIL Open Font License, see patrick_hand_license.txt), set as the project's custom font. It ships with the game so web and Mac/Linux builds look the same as Windows.
- Renderer is Compatibility (OpenGL) so the game can export to web. The Quit button hides itself in web builds.
- bounce_pad.tscn keeps its art under a `Visual` node so the pad can squish when hit.
- spikes.svg is a placeholder until the real art is done. ball.svg isn't used by anything right now.
