extends Area2D

# touch these and ur cooked


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# only the player has restart(), so random stuff can't set these off
	if body.has_method("restart"):
		body.restart()
