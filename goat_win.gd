extends Control

# u beat the secret level so ur literally him. this is the victory lap

var can_leave := false

@onready var goat: Node2D = $Center/Goat
@onready var shades: Node2D = $Center/Goat/Shades
@onready var title: Label = $Center/Title
@onready var hint: Label = $Hint


func _ready() -> void:
	# the goat goes over this guy in sharpie. he's permanent now
	Game.sharpie = true

	# goat vibing on loop, bobbing and swaying
	var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	bob.tween_property(goat, "position:y", goat.position.y - 18, 0.35)
	bob.tween_property(goat, "position:y", goat.position.y, 0.35)
	var sway := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	sway.tween_property(goat, "rotation", 0.08, 0.7)
	sway.tween_property(goat, "rotation", -0.08, 0.7)

	# shades drop outta the sky. deal with it
	var shades_spot := shades.position
	shades.position.y -= 500
	var drop := create_tween()
	drop.tween_interval(0.6)
	drop.tween_property(shades, "position", shades_spot, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# title pops in once the shades land, then keeps pulsing bc why not
	title.scale = Vector2.ZERO
	var pop := create_tween()
	pop.tween_interval(1.1)
	pop.tween_property(title, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_callback(pulse_title)

	# wait a sec before clicks count, so the winning click doesn't skip the whole thing
	hint.modulate.a = 0.0
	var show_hint := create_tween()
	show_hint.tween_interval(2.0)
	show_hint.tween_property(hint, "modulate:a", 0.7, 0.5)
	show_hint.tween_callback(func(): can_leave = true)


func pulse_title() -> void:
	var pulse := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	pulse.tween_property(title, "scale", Vector2(1.08, 1.08), 0.35)
	pulse.tween_property(title, "scale", Vector2.ONE, 0.35)
	var flash := create_tween().set_loops()
	flash.tween_property(title, "modulate", Color(1, 0.85, 0.2), 0.5)
	flash.tween_property(title, "modulate", Color.WHITE, 0.5)


func _input(event: InputEvent) -> void:
	# click or press anything and he heads to haven
	if can_leave and event.is_pressed() and not event.is_echo():
		get_tree().change_scene_to_file("res://haven.tscn")
