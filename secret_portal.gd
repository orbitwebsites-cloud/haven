extends Area2D

# the hidden one. only real ones find this
@export_file("*.tscn") var secret_scene := "res://secret_level.tscn"


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# slow shimmer so it's barely there. gotta squint fr
	var shimmer := create_tween().set_loops()
	shimmer.tween_property(self, "modulate:a", 0.14, 1.4)
	shimmer.tween_property(self, "modulate:a", 0.05, 1.4)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		get_tree().change_scene_to_file.call_deferred(secret_scene)
