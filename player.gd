extends RigidBody2D

# the main guy. no walking, u get ONE slingshot shot per try. miss it = skill issue

@export var power := 6.0
@export var max_pull := 200.0
@export var fall_limit := 2000.0
@export var stuck_restart_time := 0.5

var aiming := false
var has_shot := false
var still_timer := 0.0
var restarting := false
var show_preview := false
var preview: Node2D

@onready var aim_line: Line2D = $AimLine
@onready var trail = $Trail


func _ready() -> void:
	# so we hear about it when we smack a wall
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_bump)

	# dotted arc that shows where the shot starts off. level 1 only, it's the tutorial
	show_preview = owner != null and owner.scene_file_path == Game.LEVELS[0]
	preview = Node2D.new()
	preview.draw.connect(_draw_preview)
	# level 1's copy of the player has its art shifted down, so line up with the aim line
	preview.position = aim_line.position
	add_child(preview)


func _input(event: InputEvent) -> void:
	# gotta be _input not _unhandled_input, the ColorRects were lowkey stealing every click
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and not freeze:
			restart(true)
		elif event.keycode == KEY_ESCAPE:
			Game.go(Game.START_SCREEN)
		return

	if has_shot or restarting or not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return

	if event.pressed:
		aiming = true
	elif aiming:
		# let go = we yeet
		aiming = false
		has_shot = true
		aim_line.clear_points()
		preview.queue_redraw()
		linear_velocity = get_pull() * power
		Game.shot_fired()
		Game.play("launch")


func _process(_delta: float) -> void:
	if aiming:
		aim_line.points = PackedVector2Array([Vector2.ZERO, get_pull()])
		preview.queue_redraw()

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
	# measured from the aim line, bc level 1's player has its art sitting lower than the body
	return (aim_line.global_position - get_global_mouse_position()).limit_length(max_pull)


# first bit of the arc as a row of shrinking dots
func _draw_preview() -> void:
	if not aiming or not show_preview:
		return
	var speed := get_pull() * power
	var gravity := Vector2.DOWN * float(ProjectSettings.get_setting("physics/2d/default_gravity")) * gravity_scale
	for i in range(1, 9):
		var t := i * 0.06
		preview.draw_circle(speed * t + gravity * t * t * 0.5, 6.0 - i * 0.5, Color(0.13, 0.13, 0.2, 0.5))


func _on_bump(_body: Node) -> void:
	if has_shot and not freeze:
		Game.play("tick")


# spikes call this too and u can hit two at once, so only reset one time fr.
# quick = the R key, skips the sad little fade
func restart(quick := false) -> void:
	if restarting:
		return
	restarting = true
	if quick:
		get_tree().reload_current_scene.call_deferred()
		return

	# go red, fade out, then run it back
	Game.play("die")
	set_deferred("freeze", true)
	var fade := create_tween()
	fade.tween_property(self, "modulate", Color(1, 0.3, 0.3, 0), 0.25)
	fade.tween_callback(get_tree().reload_current_scene)
