extends StaticBody2D

# a wall drawn in pencil. first smack rips it and bounces u back, after that it's gone

var ripped := false

@onready var panel: Panel = $Panel
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var scraps: CPUParticles2D = $Scraps


# the player calls this when it bumps into us
func smash() -> void:
	if ripped:
		return
	ripped = true
	Game.play("rip")
	shape.set_deferred("disabled", true)
	panel.hide()
	scraps.restart()
