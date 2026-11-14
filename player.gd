extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	# Fall when in the air
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump with Space / Enter
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move with the left/right arrow keys
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
