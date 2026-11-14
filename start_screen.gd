extends Control

# first thing u see. a lil intro plays (any click or key skips it), then hit play or press enter

# intro spots, measured from the middle of the screen
const START := Vector2(400, 208)  # sitting on the launcher
const PAD_HIT := Vector2(68, 246)  # where he smacks the intro pad
const TITLE_SPOT := Vector2(0, -210)  # dead centre of the title

var intro: Tween
var level_row: HBoxContainer

@onready var center: Control = $Center
@onready var title: Label = $Center/Title
@onready var underline: Line2D = $Center/Underline
@onready var tagline: Label = $Center/Tagline
@onready var buttons: VBoxContainer = $Center/Buttons
@onready var play_button: Button = $Center/Buttons/Play
@onready var quit_button: Button = $Center/Buttons/Quit
@onready var hint: Label = $Center/Hint
@onready var pad = $Center/Pad
@onready var mascot: Node2D = $Center/Mascot
@onready var trail = $Center/Mascot/Trail
@onready var goal: Node2D = $Center/Goal
@onready var props: Node2D = $Center/Intro
@onready var intro_pad = $Center/Intro/IntroPad
@onready var aim_line: Line2D = $Center/Intro/AimLine
@onready var story: Label = $Center/Intro/Story

# where stuff ends up on the menu, saved before the intro moves it all around
@onready var hop_spot: Vector2 = mascot.position
@onready var underline_points: PackedVector2Array = underline.points


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# a browser tab can't quit, so the button would just sit there doing nothing
	quit_button.visible = not OS.has_feature("web")
	make_level_row()

	# title rocks side to side a bit so the screen isn't dead
	var rock := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	rock.tween_property(title, "rotation", 0.04, 1.2)
	rock.tween_property(title, "rotation", -0.04, 1.2)

	play_intro()
	# seen it already this session? jump straight to the menu
	if Game.intro_seen:
		intro.custom_step(60.0)
	Game.intro_seen = true


func _input(event: InputEvent) -> void:
	# any click or key = skip. it just fast forwards the intro to the end
	if intro.is_running() and event.is_pressed() and (event is InputEventMouseButton or event is InputEventKey):
		intro.custom_step(60.0)
		# eat the press so it doesn't smack the play button too
		get_viewport().set_input_as_handled()


func play_intro() -> void:
	# stash the menu, the intro brings it all back
	title.scale = Vector2.ZERO
	underline.clear_points()
	tagline.visible_ratio = 0.0
	buttons.hide()
	if level_row:
		level_row.hide()
	hint.hide()
	goal.hide()
	mascot.position = START
	aim_line.scale = Vector2.ZERO

	intro = create_tween()
	say("this page is all spikes.")
	say("the star is your haven.")
	say("no walking.")
	say("one shot.")

	# pull it baaack
	intro.tween_property(aim_line, "scale", Vector2.ONE, 0.5)
	intro.parallel().tween_property(mascot, "scale", Vector2(1.2, 0.8), 0.5)
	intro.tween_interval(0.2)

	# yeet. off the pad and straight up into the title
	intro.tween_callback(launch)
	fly(START, PAD_HIT, 60.0, 0.4)
	intro.tween_callback(intro_pad.boing)
	fly(PAD_HIT, TITLE_SPOT, 0.0, 0.3)

	# BONK. title pops out, the page shakes, and the lil guy gets sent over to his pad
	intro.tween_property(title, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	intro.parallel().tween_method(shake, 1.0, 0.0, 0.4)
	intro.parallel()
	fly(TITLE_SPOT, hop_spot, 50.0, 0.55)
	intro.tween_callback(start_hopping)

	# rest of the menu shows up
	intro.tween_method(draw_underline, 0, underline_points.size(), 0.3)
	intro.tween_property(tagline, "visible_ratio", 1.0, 0.7)
	intro.tween_property(props, "modulate:a", 0.0, 0.3)
	intro.tween_callback(show_menu)
	intro.tween_property(buttons, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.parallel().tween_property(goal, "scale", goal.scale, 0.3).from(goal.scale * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# scribbles a line onto the page, then leaves it up for a sec
func say(line: String) -> void:
	intro.tween_callback(story.set_text.bind(line))
	intro.tween_property(story, "visible_ratio", 1.0, line.length() * 0.04).from(0.0)
	intro.tween_interval(0.45)


# chucks the mascot from one spot to another. arc = how high the throw loops
func fly(from: Vector2, to: Vector2, arc: float, time: float) -> void:
	intro.tween_method(move_on_arc.bind(from, to, arc), 0.0, 1.0, time)


func move_on_arc(t: float, from: Vector2, to: Vector2, arc: float) -> void:
	mascot.position = from.lerp(to, t) + Vector2.UP * arc * 4.0 * t * (1.0 - t)


func launch() -> void:
	story.hide()
	aim_line.hide()
	mascot.scale = Vector2.ONE
	trail.active = true


# rattles the whole page. amount goes from 1 down to 0 so it settles
func shake(amount: float) -> void:
	center.rotation = randf_range(-0.04, 0.04) * amount


# the squiggle under the title gets drawn in a bit at a time
func draw_underline(count: int) -> void:
	underline.points = underline_points.slice(0, count)


# lil guy hops on the pad forever, just vibing
func start_hopping() -> void:
	trail.active = false
	pad.boing()
	var hop := create_tween().set_loops()
	hop.tween_property(mascot, "position:y", hop_spot.y - 170.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(mascot, "position:y", hop_spot.y, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	hop.tween_callback(pad.boing)


func show_menu() -> void:
	props.hide()
	buttons.show()
	if level_row:
		level_row.show()
	hint.show()
	goal.show()
	# focus on play so enter works straight away
	play_button.grab_focus()


# row of page numbers under the buttons, one for every level u've reached
func make_level_row() -> void:
	if Game.unlocked < 2:
		return
	level_row = HBoxContainer.new()
	level_row.position = Vector2(-150, 158)
	level_row.size = Vector2(300, 44)
	level_row.alignment = BoxContainer.ALIGNMENT_CENTER
	level_row.add_theme_constant_override("separation", 12)
	center.add_child(level_row)

	var label := Label.new()
	label.text = "page"
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Game.INK)
	level_row.add_child(label)

	var box := StyleBoxFlat.new()
	box.bg_color = Color(1, 0.84, 0.3)
	box.set_corner_radius_all(8)
	var box_hover := box.duplicate()
	box_hover.bg_color = Color(1, 0.66, 0.25)

	for i in Game.unlocked:
		var button := Button.new()
		button.text = str(i + 1)
		button.custom_minimum_size = Vector2(48, 44)
		button.add_theme_font_size_override("font_size", 26)
		for colour in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			button.add_theme_color_override(colour, Game.INK)
		button.add_theme_stylebox_override("normal", box)
		button.add_theme_stylebox_override("hover", box_hover)
		button.add_theme_stylebox_override("pressed", box_hover)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.pressed.connect(_on_level_pressed.bind(Game.LEVELS[i]))
		level_row.add_child(button)


func _on_play_pressed() -> void:
	Game.new_run()
	_on_level_pressed(Game.LEVELS[0])


func _on_level_pressed(level: String) -> void:
	Game.play("click")
	Game.go(level)


func _on_quit_pressed() -> void:
	get_tree().quit()
