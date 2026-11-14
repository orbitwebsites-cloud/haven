extends Area2D

@onready var win_label: Label = $WinLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return

	win_label.show()
	body.set_deferred("freeze", true)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
