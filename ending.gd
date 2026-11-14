extends Control

# u beat the last page. the lil guy made it to the haven

@onready var title: Label = $Title
@onready var story: Label = $Story
@onready var secret: Label = $Secret
@onready var hint: Label = $Hint
@onready var star: Node2D = $Star

var can_leave := false


func _ready() -> void:
	var screen := get_viewport_rect().size
	star.position = Vector2(screen.x / 2, screen.y / 2 - 40)

	var total := Game.total_shots()
	story.text = "the doodle reached the star. nothing on this page can get it now."
	if total > 0:
		story.text += "\nit took %d %s." % [total, "shot" if total == 1 else "shots"]
	Game.play("win")

	# title pops, then the rest fades in one line at a time
	title.pivot_offset = Vector2(screen.x / 2, 70)
	title.scale = Vector2.ZERO
	story.modulate.a = 0.0
	secret.modulate.a = 0.0
	hint.modulate.a = 0.0
	var show := create_tween()
	show.tween_property(title, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show.tween_property(story, "modulate:a", 1.0, 0.5)
	show.tween_interval(0.8)
	show.tween_property(secret, "modulate:a", 0.75, 0.5)
	show.tween_property(hint, "modulate:a", 0.7, 0.4)
	# wait before clicks count, so the winning click doesn't skip the whole thing
	show.tween_callback(func(): can_leave = true)


func _input(event: InputEvent) -> void:
	if can_leave and event.is_pressed() and not event.is_echo() and (event is InputEventMouseButton or event is InputEventKey):
		Game.go(Game.START_SCREEN)
