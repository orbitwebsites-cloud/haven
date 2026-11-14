extends Area2D

# how hard it sends u. crank it up for a bigger launch
@export var strength := 900.0

var squish_tween: Tween

@onready var visual: Node2D = $Visual
@onready var arrow: Polygon2D = $Visual/Arrow
@onready var sparks: CPUParticles2D = $Sparks


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# arrow bobs a lil so u can tell which way it's gonna send u
	var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	bob.tween_property(arrow, "position:y", -4.0, 0.5)
	bob.tween_property(arrow, "position:y", 0.0, 0.5)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		# sends u wherever the pad is facing, so rotate it to aim. no cap
		body.linear_velocity = -global_transform.y.normalized() * strength
		boing()


# sparks fly, then squish down and spring back up all wobbly. pure boing energy
func boing() -> void:
	sparks.restart()
	if squish_tween:
		squish_tween.kill()
	squish_tween = create_tween()
	squish_tween.tween_property(visual, "scale", Vector2(1.2, 0.45), 0.05)
	squish_tween.tween_property(visual, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
