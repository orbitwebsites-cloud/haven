extends Control

# first thing u see. a lil intro plays (any click or key skips it), then hit play or press enter

# intro spots, measured from the middle of the screen
const START := Vector2(400, 208)  # sitting on the launcher
const PAD_HIT := Vector2(68, 246)  # where he smacks the intro pad
const TITLE_SPOT := Vector2(0, -210)  # dead centre of the title

var intro: Tween

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

	# title rocks side to side a bit so the screen isn't dead
	var rock := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	rock.tween_property(title, "rotation", 0.04, 1.2)
	rock.tween_property(title, "rotation", -0.04, 1.2)

	play_intro()


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
	hint.hide()
	goal.hide()
	mascot.position = START
	aim_line.scale = Vector2.ZERO

	intro = create_tween()
	say("no walking.")
	say("no second tries.")
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
	hint.show()
	goal.show()
	# focus on play so enter works straight away
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
