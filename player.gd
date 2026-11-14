extends RigidBody2D

@export var power := 6.0
@export var max_pull := 200.0
@export var fall_limit := 2000.0
@export var stuck_restart_time := 1.0

var aiming := false
var has_shot := false
var still_timer := 0.0
var restarting := false

@onready var aim_line: Line2D = $AimLine


func _input(event: InputEvent) -> void:
	# not _unhandled_input, the ColorRects in the level were eating the clicks
	if has_shot or not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return

	if event.pressed:
		aiming = true
	elif aiming:
		aiming = false
		has_shot = true
		aim_line.clear_points()
		linear_velocity = get_pull() * power


func _process(_delta: float) -> void:
	if aiming:
		aim_line.points = PackedVector2Array([Vector2.ZERO, get_pull()])

	if global_position.y > fall_limit:
		restart()


func _physics_process(delta: float) -> void:
	# the goal freezes us, don't restart while the win text is up
	if not has_shot or freeze:
		return

	if linear_velocity.length() < 10.0:
		still_timer += delta
		if still_timer >= stuck_restart_time:
			restart()
	else:
		still_timer = 0.0


# drag away from where you want to go, like pulling back a slingshot
func get_pull() -> Vector2:
	return (global_position - get_global_mouse_position()).limit_length(max_pull)


# spikes call this too, and you can touch two of them in the same frame
func restart() -> void:
	if restarting:
		return
	restarting = true
	get_tree().reload_current_scene.call_deferred()
