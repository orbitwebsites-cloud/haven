extends Control

# first thing u see. hit play (or just press enter) to start the run

@onready var title: Label = $Center/Title
@onready var mascot: Node2D = $Center/Mascot
@onready var pad = $Center/Pad
@onready var play_button: Button = $Center/Buttons/Play
@onready var quit_button: Button = $Center/Buttons/Quit


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# focus on play so enter works straight away
	play_button.grab_focus()

	# lil guy hops on the pad forever, just vibing
	var floor_y := mascot.position.y
	var hop := create_tween().set_loops()
	hop.tween_property(mascot, "position:y", floor_y - 170.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(mascot, "position:y", floor_y, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	hop.tween_callback(pad.boing)

	# title rocks side to side a bit so the screen isn't dead
	var rock := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	rock.tween_property(title, "rotation", 0.04, 1.2)
	rock.tween_property(title, "rotation", -0.04, 1.2)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
