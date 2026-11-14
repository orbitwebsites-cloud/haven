extends Node

# autoload, so it sticks around between scenes. keeps the level order, the save,
# the shot counter, the sounds, the lil hud in the corner and the fade between pages

# level order lives here. add a new level to the list and it just works
const LEVELS := [
	"res://level.tscn", "res://level_2.tscn", "res://level_3.tscn",
	"res://level_4.tscn", "res://level_5.tscn", "res://level_6.tscn",
]
const START_SCREEN := "res://start_screen.tscn"
const ENDING := "res://ending.tscn"
const SAVE_PATH := "user://save.cfg"
const INK := Color(0.13, 0.13, 0.2)
const PAPER := Color(0.96, 0.93, 0.84)
const RATE := 22050

# how many levels u can pick from the menu. saved to disk
var unlocked := 1
# the intro only plays the first time u see the menu
var intro_seen := false
# shots fired per level this run, scene path -> count
var shots := {}

var sounds := {}
var speakers: Array[AudioStreamPlayer] = []
var next_speaker := 0
var fading := false

var hud: CanvasLayer
var hud_label: Label
var fade: ColorRect


func _ready() -> void:
	# keep going while the tree is paused or mid scene change
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save()
	make_sounds()
	make_hud()


func _process(_delta: float) -> void:
	# only levels have a Player, so that's how we know to show the hud
	var scene := get_tree().current_scene
	hud.visible = scene != null and scene.has_node("Player")
	if hud.visible:
		hud_label.text = hud_text(scene.scene_file_path)


# ---- levels and progress ----

func level_won(path: String) -> void:
	var i := LEVELS.find(path)
	if i >= 0 and i + 2 > unlocked:
		unlocked = mini(i + 2, LEVELS.size())
		save()


# beat the last level? that's the ending. not in the list? back to level 1
func next_after(path: String) -> String:
	var i := LEVELS.find(path)
	if i == LEVELS.size() - 1:
		return ENDING
	return LEVELS[i + 1]


func new_run() -> void:
	shots.clear()


func shot_fired() -> void:
	var path := get_tree().current_scene.scene_file_path
	shots[path] = shots.get(path, 0) + 1


func total_shots() -> int:
	var total := 0
	for count in shots.values():
		total += count
	return total


func load_save() -> void:
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) == OK:
		unlocked = clampi(file.get_value("progress", "unlocked", 1), 1, LEVELS.size())


func save() -> void:
	var file := ConfigFile.new()
	file.set_value("progress", "unlocked", unlocked)
	file.save(SAVE_PATH)


# ---- changing scenes ----

# a blank sheet slides in from the right, the scene swaps behind it, then it slides off
# the left. like turning the page
func go(path: String) -> void:
	if fading:
		return
	fading = true
	var width := fade.size.x + 20.0
	fade.position.x = width
	fade.show()
	var turn := create_tween()
	turn.tween_property(fade, "position:x", 0.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	turn.tween_callback(get_tree().change_scene_to_file.bind(path))
	turn.tween_interval(0.05)
	turn.tween_property(fade, "position:x", -width, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	turn.tween_callback(func():
		fade.hide()
		fading = false)


# ---- hud ----

func make_hud() -> void:
	# layer 10 sits under the sketch shader (layer 50) so the text gets the pen look too
	hud = CanvasLayer.new()
	hud.layer = 10
	hud.hide()
	add_child(hud)

	hud_label = Label.new()
	hud_label.position = Vector2(24, 14)
	hud_label.add_theme_font_size_override("font_size", 28)
	hud_label.add_theme_color_override("font_color", INK)
	hud.add_child(hud_label)

	var keys := Label.new()
	keys.text = "R = retry    Esc = menu"
	keys.position = Vector2(24, 50)
	keys.add_theme_font_size_override("font_size", 20)
	keys.add_theme_color_override("font_color", Color(INK, 0.6))
	hud.add_child(keys)

	# the page-turn sheet goes on top of everything, shader included
	var top := CanvasLayer.new()
	top.layer = 60
	add_child(top)
	fade = ColorRect.new()
	fade.color = PAPER
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.hide()
	top.add_child(fade)
	# inky edges so u can see the sheet moving
	for side in [Control.PRESET_LEFT_WIDE, Control.PRESET_RIGHT_WIDE]:
		var edge := ColorRect.new()
		edge.color = Color(INK, 0.7)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		edge.set_anchors_preset(side)
		edge.custom_minimum_size.x = 5
		fade.add_child(edge)


func hud_text(path: String) -> String:
	var i := LEVELS.find(path)
	var page := "page %d" % (i + 1) if i >= 0 else "page ??"
	var count: int = shots.get(path, 0)
	var text := "%s  -  shots: %d" % [page, count]

	# scribbles in the margin when it's going badly
	if count >= 40:
		text += "   (ok this one's just hard)"
	elif count >= 20:
		text += "   (the star believes in u)"
	elif count >= 10:
		text += "   (it's fine. everyone's fine)"
	return text


# ---- sounds ----

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
