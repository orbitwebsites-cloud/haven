extends Area2D

# how hard it sends u. crank it up for a bigger launch
@export var strength := 900.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		# sends u wherever the pad is facing, so rotate it to aim. no cap
		body.linear_velocity = -global_transform.y.normalized() * strength
