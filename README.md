# Bounce

![The lil guy gets slingshotted off a pad and bonks the title into existence](press/cover.gif)

A slingshot bounce platformer drawn like a doodle in a school notebook. You can't walk and you can't jump. You get one shot per try, and after that the bounce pads and walls decide where you end up.

You drew a lil guy in math class and forgot his legs. Notebook check is today, and doodle pages get ripped out. The only safe spot is haven: the back page no teacher has ever flipped to. Every time a guy doesn't make it, you draw the next one.

Made with Godot 4.7.

## How to play

Hold the left mouse button, drag away from where you want to go, and let go. The further you pull, the harder the launch. That is your only input for the whole attempt.

- Reach the spinning star to finish the level.
- Bounce pads fire you in the direction their arrow points.
- Teal walls bounce you back at full speed. Gray walls take some of your speed away.
- Pink paper walls rip the first time you hit them and bounce you back. After that they are gone.
- Purple pads only fire once.
- Some pads slide back and forth, so when you launch matters.
- Spikes restart the level. So does falling off the page, or coming to a stop anywhere that isn't the goal.
- Every restart is a new guy. The corner of the screen says which one you're on (`lil guy #7`). Lower is better.

There are nine levels: a warm-up, Bank Shot, The Climb, Pinball, The Drop, Home Stretch, Paper Walls, Moving Day and The Last Page. Level 3 also hides a way into a secret one, if you look closely at the page.

Beat the last level and your guy moves into haven. Everyone who ever made it lives there in a row, each with his number and whatever he was wearing. That, your record and your look are saved between sessions.

On the start screen, any click or key skips the intro, and Enter starts the game. UR GUY opens the customize screen, where you pick a marker colour and a hat. One of the hats stays locked until you beat the secret level.

## Running it from source

1. Install [Godot 4.7](https://godotengine.org/download) (standard build, no .NET needed).
2. Clone this repo.
3. Open Godot, choose Import, and pick `project.godot`.
4. Press F5.

## Exporting for itch.io

The project uses the Compatibility renderer and ships its own font, so it can be exported to web.

1. In Godot, open Project > Export, add a Web preset, and install the export templates if asked.
2. Export to a folder with the file named `index.html`.
3. Zip the contents of that folder and upload the zip to itch.io with "This file will be played in the browser" ticked.

`press/` has the cover GIF, the screenshots and `itch_page.md`, which is the text for the itch.io page.

## Project layout

Everything sits in the project root.

| File | What it is |
| --- | --- |
| `start_screen.tscn`, `start_screen.gd` | Main scene: title, intro animation, Play, UR GUY and Quit |
| `level.tscn`, `level_2.tscn` ... `level_9.tscn` | The nine levels, in order |
| `secret_level.tscn`, `secret_portal.tscn` | The hidden level and the way into it |
| `goat_win.tscn`, `goat_win.gd` | Win screen for the hidden level |
| `haven.tscn`, `haven.gd` | The ending: the back page with everyone who made it |
| `customize.tscn`, `customize.gd` | The UR GUY screen |
| `wardrobe.gd`, `hats.tscn` | Marker colours, hats, and the code that puts them on a guy |
| `lil_guy.tscn`, `lil_guy.gd` | The character with no physics, for menus and the haven row |
| `game.tscn`, `game.gd` | Autoload: the run counter, the look, the save file, the corner text, the sounds |
| `player.tscn`, `player.gd` | The ball: aiming, launching, restart rules |
| `goal.gd` | The star, and the level order |
| `bounce_pad.tscn`, `spikes.tscn`, `goal.tscn`, `paper_wall.tscn` | Pieces you drag into a level |
| `mover.gd` | Slides its parent node back and forth (moving pads) |
| `press/` | Cover GIF, screenshots and page text for itch.io |
| `background.tscn`, `sketch.gdshader` | Paper background and the full-screen shader that draws the pen outlines and ruled lines |
| `trail.tscn`, `trail.gd` | The speed line behind the ball |

## Making a level

1. Duplicate an existing level scene and rearrange it.
2. Drag in `bounce_pad.tscn`, `spikes.tscn`, `paper_wall.tscn` and `goal.tscn` as needed. Rotate a pad to aim it; its `Strength` property sets the launch speed, and `One Use` makes it a purple single-use pad. To make something move, add a plain Node under it with `mover.gd` attached.
3. For a bouncy wall, give the wall a PhysicsMaterial with `bounce` set (1.0 for teal walls, 0.6 for gray).
4. Add the scene path to the `LEVELS` list at the top of `goal.gd`, and give it a note in `NOTES` at the top of `game.gd`. Levels play in list order.

Use flat colours for new art. The sketch shader adds the hand-drawn look on top.

## Credits

The font is [Patrick Hand](https://fonts.google.com/specimen/Patrick+Hand) by Patrick Wagesreiter, used under the SIL Open Font License (`patrick_hand_license.txt`). The sound effects are generated in code.

`CONVENTIONS.md` has more detailed notes on how the scenes and scripts fit together.
#AI USAGE
AI was used for code review to find bugs and basic movment logic and to move the sprite between scenes

