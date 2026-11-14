extends RigidBody2D

# the main guy. no walking, u get ONE slingshot shot per try. miss it = skill issue

@export var power := 6.0
@export var max_pull := 200.0
@export var fall_limit := 2000.0
@export var stuck_restart_time := 1.0

var aiming := false
var has_shot := false
var still_timer := 0.0
var restarting := false

@onready var aim_line: Line2D = $AimLine
@onready var trail = $Trail


func _ready() -> void:
	# wear whatever got picked on the customize screen, and match the speed line to it
	Wardrobe.dress($Body, Game.color, Game.hat)
	trail.default_color = $Body.color.lightened(0.35)

	# so we hear about it when we smack a wall. paper walls rip when we hit em
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_bump)



func _input(event: InputEvent) -> void:
	# gotta be _input not _unhandled_input, the ColorRects were lowkey stealing every click
	if has_shot or not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return

	if event.pressed:
		aiming = true
	elif aiming:
		# let go = we yeet
		aiming = false
		has_shot = true
		aim_line.clear_points()
		linear_velocity = get_pull() * power


func _process(_delta: float) -> void:
	if aiming:
		aim_line.points = PackedVector2Array([Vector2.ZERO, get_pull()])

	# speed line behind us while we're flying
	trail.active = has_shot and linear_velocity.length() > 60.0

	# fell off the map, that's crazy. run it back
	if global_position.y > fall_limit:
		restart()


func _physics_process(delta: float) -> void:
	# the goal freezes us, so don't reset while we're busy winning
	if not has_shot or freeze:
		return

	# shot's gone and we're just chilling there? it's over, reset
	if linear_velocity.length() < 10.0:
		still_timer += delta
		if still_timer >= stuck_restart_time:
			restart()
	else:
		still_timer = 0.0


# pull back away from where u wanna go, like a real slingshot
func get_pull() -> Vector2:
	# measured from where the aim line starts, bc level 1's ball is drawn a bit below its body
	return (aim_line.global_position - get_global_mouse_position()).limit_length(max_pull)


# spikes call this too and u can hit two at once, so only reset one time fr
func restart() -> void:
	if restarting:
		return
	restarting = true
	# that guy's done for. u draw the next one
	Game.guy += 1
	get_tree().reload_current_scene.call_deferred()


func _on_bump(body: Node) -> void:
	if body.has_method("smash"):
		body.smash()
