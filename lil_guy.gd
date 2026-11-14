extends Node2D

# one lil guy, no physics. the start screen, the customize screen and the haven page all use him

# the part that rolls. his number stays put underneath
@onready var face: Node2D = $Face


func dress(color: int, hat: String) -> void:
	Wardrobe.dress($Face/Body, color, hat)


# writes his number under him, like #48
func set_number(number: int) -> void:
	$Number.text = "#%d" % number
	$Number.show()


# the goat went over him in sharpie, so he gets the thick outline. he's permanent now
func go_sharpie() -> void:
	$Face/Sharpie.show()
