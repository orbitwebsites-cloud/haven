extends Control

# the back page. hidden at the very end of the notebook, and the one place a doodle's allowed to stop

const LIL_GUY := preload("res://lil_guy.tscn")
# the row of guys along the bottom: where the first one stands, the gap between them, how small they are
const ROW_START := -494.0
const ROW_GAP := 52.0
const GUY_SIZE := 0.55

var ending: Tween

@onready var sketch: ColorRect = $Background/SketchLayer/Sketch
@onready var row: Node2D = $Center/Row
@onready var goat: Node2D = $Center/Goat
@onready var lines: VBoxContainer = $Center/Lines
@onready var buttons: HBoxContainer = $Center/Buttons
@onready var again_button: Button = $Center/Buttons/Again
@onready var menu_button: Button = $Center/Buttons/Menu
@onready var quit_button: Button = $Center/Buttons/Quit


func _ready() -> void:
	again_button.pressed.connect(Game.start_run)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# no lines and no margin back here. copy the material first so the other pages keep theirs
	sketch.material = sketch.material.duplicate()
	sketch.material.set_shader_parameter("rule_strength", 0.0)

	# grab these before move_in() wraps the run up
	var just_arrived := Game.on_a_run
	var number := Game.guy
	var sharpie := Game.sharpie
	Game.move_in()

	# everybody who ever made it, lined up with their numbers, wearing what they wore
	for citizen in Game.citizens:
		var guy := LIL_GUY.instantiate()
		row.add_child(guy)
		guy.scale *= GUY_SIZE
		guy.position.x = ROW_START + ROW_GAP * guy.get_index()
		guy.set_number(citizen.number)
		if citizen.sharpie:
			# sharpie guys always rock the goat's shades, and the goat moves in with them
			guy.go_sharpie()
			guy.dress(citizen.color, "shades")
			goat.show()
		else:
			guy.dress(citizen.color, citizen.hat)

	var story := [
		"he stopped moving.",
		"it's fine. back here that's allowed.",
		"teacher checked the notebook. saw only math.",
		"took %d lil guys. worth it." % number,
		"still no legs. doesn't need em.",
	]
	if number == 1:
		story[3] = "lil guy #1 did it. first try. unreal."
	if sharpie:
		story[4] = "sharpie'd by the goat. he's permanent now."

	play_ending(story, just_arrived)


func _input(event: InputEvent) -> void:
	# any click or key fast forwards to the buttons, same trick as the intro
	if ending.is_running() and not buttons.visible and event.is_pressed() and (event is InputEventMouseButton or event is InputEventKey):
		ending.custom_step(60.0)
		get_viewport().set_input_as_handled()


func play_ending(story: Array, just_arrived: bool) -> void:
	buttons.hide()
	ending = create_tween()

	if just_arrived:
		# the new guy drops in, boings a couple times and rolls up to the end of the row
		var guy = row.get_child(-1)
		var spot: float = guy.position.x
		ending.tween_property(guy, "position:y", 0.0, 1.2).from(-700.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		ending.parallel().tween_property(guy, "position:x", spot, 1.7).from(spot - 260.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		ending.parallel().tween_property(guy.face, "rotation", 0.0, 1.7).from(-2.0 * TAU).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		# ...and nothing happens. stopping was game over this whole time, so let that sit for a sec
		ending.tween_interval(1.0)

	for i in story.size():
		var line: Label = lines.get_child(i)
		line.text = story[i]
		line.visible_ratio = 0.0
		ending.tween_property(line, "visible_ratio", 1.0, story[i].length() * 0.03)
		ending.tween_interval(0.4)

	ending.tween_callback(show_buttons)
	ending.tween_property(buttons, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func show_buttons() -> void:
	buttons.show()
	again_button.grab_focus()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://start_screen.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
