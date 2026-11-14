extends Area2D

# leave empty to go to the next level. the secret level uses this for the goat screen
@export_file("*.tscn") var next_scene := ""

const CHEERS := ["NICE!", "CLEAN!", "SAFE!", "BOING!", "YES!"]

var won := false

@onready var win_label: Label = $WinLabel
@onready var star: Polygon2D = $Star
@onready var burst: Polygon2D = $Burst


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# star spins and the spiky bit behind it pulses so u literally can't miss it
	var spin := create_tween().set_loops()
	spin.tween_property(star, "rotation", TAU, 3.0).from(0.0)
	var pulse := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	pulse.tween_property(burst, "scale", Vector2(1.2, 1.2), 0.6)
	pulse.tween_property(burst, "scale", Vector2.ONE, 0.6)


func _on_body_entered(body: Node2D) -> void:
	if won or not body is RigidBody2D:
		return
	won = true

	# big W. freeze em, flex the text for a sec, then dip
	win_label.text = CHEERS.pick_random()
	win_label.show()
	body.set_deferred("freeze", true)
	Game.play("win")
	var path := get_tree().current_scene.scene_file_path
	Game.level_won(path)
	await get_tree().create_timer(0.8).timeout
	Game.go(next_scene if next_scene else Game.next_after(path))
