extends Line2D

# scribbly speed line that follows the player around

@export var max_points := 12

var active := false
var spots: Array[Vector2] = []


func _physics_process(_delta: float) -> void:
	if active:
		spots.append(global_position)
	# too long, or we stopped flying? eat the oldest bit so it shrinks away
	if spots.size() > max_points or (not active and not spots.is_empty()):
		spots.pop_front()

	clear_points()
	for spot in spots:
		add_point(to_local(spot))
