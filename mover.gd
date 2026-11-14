extends Node

# slides whatever it's a child of back and forth. stick one under a pad, spikes, anything

# how far it goes from where u placed it, and how long a full there-and-back takes
@export var travel := Vector2(200, 0)
@export var period := 3.0

var time := 0.0

@onready var target: Node2D = get_parent()
@onready var start: Vector2 = target.position


# physics tick so it moves the same way every try
func _physics_process(delta: float) -> void:
	time += delta
	target.position = start + travel * (0.5 - 0.5 * cos(time / period * TAU))
