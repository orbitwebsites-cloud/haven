extends Area2D

const LEVELS := ["res://level.tscn", "res://level_2.tscn", "res://level_3.tscn"]

# leave empty to go to the next level in LEVELS
@export_file("*.tscn") var next_scene := ""

@onready var win_label: Label = $WinLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return

	win_label.show()
	body.set_deferred("freeze", true)
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file(get_next_scene())


func get_next_scene() -> String:
	if next_scene:
		return next_scene
	# after the last level (or one that isn't in the list) you go back to level 1
	var i := LEVELS.find(get_tree().current_scene.scene_file_path)
	return LEVELS[(i + 1) % LEVELS.size()]
