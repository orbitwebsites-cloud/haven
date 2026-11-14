extends Area2D

@export var strength := 900.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		# shoots out the way the pad is facing, so rotate it to aim
		body.linear_velocity = -global_transform.y.normalized() * strength
