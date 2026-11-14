extends Control

# pick ur guy's marker colour and hat. UR GUY on the start screen sends u here

var hats := Wardrobe.hat_names()
# the hat we're looking at right now. might be one that's still locked
var hat_spot := 0

@onready var guy = $Center/Guy
@onready var hat_label: Label = $Center/HatLabel
@onready var lock_note: Label = $Center/LockNote


func _ready() -> void:
	$Center/ColorLeft.pressed.connect(change_color.bind(-1))
	$Center/ColorRight.pressed.connect(change_color.bind(1))
	$Center/HatLeft.pressed.connect(change_hat.bind(-1))
	$Center/HatRight.pressed.connect(change_hat.bind(1))
	$Center/Done.pressed.connect(_on_done_pressed)

	# start on whatever he's wearing now
	hat_spot = maxi(hats.find(Game.hat), 0)
	show_look()


func change_color(step: int) -> void:
	Game.color = posmod(Game.color + step, Wardrobe.COLORS.size())
	show_look()


func change_hat(step: int) -> void:
	hat_spot = posmod(hat_spot + step, hats.size())
	show_look()


func show_look() -> void:
	var hat := hats[hat_spot]
	# the shades are the goat's. u can look, but u only keep em once he's sharpie'd one of ur guys
	var locked := hat == "shades" and not Game.beat_the_goat()
	if not locked:
		Game.hat = hat

	guy.dress(Game.color, hat)
	hat_label.text = "hat: " + (hat if hat else "none")
	lock_note.visible = locked


func _on_done_pressed() -> void:
	Game.save_game()
	get_tree().change_scene_to_file("res://start_screen.tscn")
