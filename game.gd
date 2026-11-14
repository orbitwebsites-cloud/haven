extends CanvasLayer

# keeps score for the whole run: which lil guy we're on, what he looks like, who made it to haven,
# and the save file. also draws the corner text in levels.
# it's an autoload, so any script can just say Game.whatever

const SAVE_PATH := "user://save.cfg"
# only this many fit in the row on the haven page
const MAX_CITIZENS := 20
# sample rate for the sounds we build in code
const RATE := 22050

# the note scribbled in the corner of each level. new level = new line here
const NOTES := {
	"res://level.tscn": "if he stops moving he's just a drawing.",
	"res://level_2.tscn": "teacher's two rows away. be so normal.",
	"res://level_3.tscn": "one row away. she can smell doodles. climb.",
	"res://level_4.tscn": "she's at ur desk. do not look up.",
	"res://level_5.tscn": "she picked up the notebook. hang on.",
	"res://level_6.tscn": "she's flipping pages. hold on.",
	"res://level_7.tscn": "she's on the page before urs.",
	"res://level_8.tscn": "she's on ur page. be a math problem.",
	"res://level_9.tscn": "last page. go go go.",
	"res://secret_level.tscn": "u fell through the goat's sunglasses. his page. his rules.",
}

# which lil guy we're on. every restart = u drew a brand new guy
var guy := 1
# true once the goat went over this guy in sharpie
var sharpie := false
# only runs that start from PLAY get to move in, so testing one level with F6 doesn't count
var on_a_run := false

# the look from the customize screen. color is a spot in Wardrobe.COLORS, hat is a name from hats.tscn
var color := 0
var hat := ""

# lowest guy number that ever made it. 0 = nobody yet
var record := 0
# everybody living in haven, oldest first. each one is {"number": 12, "sharpie": false, "color": 0, "hat": ""}
var citizens: Array = []

var sounds := {}
var speakers: Array[AudioStreamPlayer] = []
var next_speaker := 0

@onready var guy_label: Label = $GuyLabel
@onready var note_label: Label = $NoteLabel


func _ready() -> void:
	load_game()
	make_sounds()
	get_tree().scene_changed.connect(update_corner_text)
	# that signal skips the very first scene, so check that one by hand once it's in
	update_corner_text.call_deferred()


# fresh run: lil guy #1, page one. PLAY and "draw another guy" both land here
func start_run() -> void:
	guy = 1
	sharpie = false
	on_a_run = true
	get_tree().change_scene_to_file("res://level.tscn")


# he made it, so he lives in haven now
func move_in() -> void:
	if not on_a_run:
		return
	on_a_run = false

	citizens.append({"number": guy, "sharpie": sharpie, "color": color, "hat": hat})
	if citizens.size() > MAX_CITIZENS:
		# shortcut: the row only fits 20 so the oldest guy gets bumped. give haven a second row if that ever matters
		citizens.pop_front()
	if record == 0 or guy < record:
		record = guy
	save_game()


# the goat's shades unlock once one of ur guys got sharpie'd
func beat_the_goat() -> bool:
	return citizens.any(func(c): return c.get("sharpie", false))


# runs every time a scene loads (restarts too). only levels get the corner text
func update_corner_text() -> void:
	var level := get_tree().current_scene.scene_file_path
	visible = NOTES.has(level)
	if visible:
		guy_label.text = "lil guy #%d" % guy
		note_label.text = NOTES[level]


func save_game() -> void:
	var file := ConfigFile.new()
	file.set_value("haven", "record", record)
	file.set_value("haven", "citizens", citizens)
	file.set_value("look", "color", color)
	file.set_value("look", "hat", hat)
	file.save(SAVE_PATH)


func load_game() -> void:
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) != OK:
		return  # no save yet, first time playing

	var saved_record = file.get_value("haven", "record", 0)
	var saved_citizens = file.get_value("haven", "citizens", [])
	var saved_color = file.get_value("look", "color", 0)
	var saved_hat = file.get_value("look", "hat", "")
	# somebody might've messed with the file by hand, so only take what looks right
	if saved_record is int and saved_citizens is Array:
		record = saved_record
		citizens = saved_citizens.filter(is_a_guy)
	if saved_color is int and saved_hat is String:
		color = saved_color
		hat = saved_hat


# a saved guy only counts if nothing's missing or the wrong type
func is_a_guy(c) -> bool:
	return c is Dictionary and c.get("number") is int and c.get("sharpie") is bool and c.get("color") is int and c.get("hat") is String


# no audio files, every sound is built from maths when the game boots
func make_sounds() -> void:
	sounds["launch"] = make_sound(0.18, func(t, p): return sweep(t, 0.18, 520.0, 160.0) * (1.0 - p))
	sounds["boing"] = make_sound(0.28, func(t, p): return sweep(t, 0.28, 170.0, 560.0) * (1.0 - p))
	sounds["tick"] = make_sound(0.06, func(t, p): return sin(TAU * 240.0 * t) * (1.0 - p) * (1.0 - p))
	sounds["click"] = make_sound(0.05, func(t, p): return sin(TAU * 660.0 * t) * (1.0 - p))
	sounds["rip"] = make_sound(0.16, func(_t, p): return randf_range(-1.0, 1.0) * (1.0 - p))
	sounds["die"] = make_sound(0.3, func(t, p):
		return (randf_range(-1.0, 1.0) * 0.6 + sweep(t, 0.3, 220.0, 50.0) * 0.6) * (1.0 - p) * (1.0 - p))
	sounds["win"] = make_sound(0.5, func(t, p):
		var notes := [523.0, 659.0, 784.0, 1047.0]
		return sin(TAU * notes[mini(int(t / 0.1), 3)] * t) * (1.0 - p * 0.7))

	for i in 4:
		var speaker := AudioStreamPlayer.new()
		add_child(speaker)
		speakers.append(speaker)


# a sine that slides from one pitch to another over the length of the sound
func sweep(t: float, length: float, from: float, to: float) -> float:
	return sin(TAU * (from * t + (to - from) * t * t / (2.0 * length)))


# wave gets (seconds in, 0..1 progress) and gives back a sample between -1 and 1
func make_sound(length: float, wave: Callable) -> AudioStreamWAV:
	var count := int(length * RATE)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var t := float(i) / RATE
		var sample: float = clampf(wave.call(t, t / length), -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample * 32767.0 * 0.4))

	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = RATE
	sound.data = bytes
	return sound


func play(sound: String) -> void:
	var speaker := speakers[next_speaker]
	next_speaker = (next_speaker + 1) % speakers.size()
	speaker.stream = sounds[sound]
	speaker.play()
