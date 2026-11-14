extends Area2D

@export_file("*.tscn") var secret_scene := "res://secret_level.tscn"


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# slow shimmer so it's only just noticeable
	var shimmer := create_tween().set_loops()
	shimmer.tween_property(self, "modulate:a", 0.2, 1.4)
	shimmer.tween_property(self, "modulate:a", 0.05, 1.4)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		get_tree().change_scene_to_file.call_deferred(secret_scene)
