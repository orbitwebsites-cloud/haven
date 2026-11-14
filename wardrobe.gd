class_name Wardrobe

# the lil guy's closet: marker colours + hats, and how to put them on a guy.
# to add a hat, draw it in hats.tscn. the node's name is the hat's name

const HATS := preload("res://hats.tscn")

const COLORS := [
	Color(0.3, 0.6, 1),  # blue, the og
	Color(0.45, 0.82, 0.42),  # green
	Color(1, 0.6, 0.15),  # orange
	Color(0.7, 0.45, 0.95),  # purple
	Color(1, 0.55, 0.75),  # pink
	Color(1, 0.84, 0.3),  # yellow
	Color(0.25, 0.82, 0.78),  # teal
]


# colours in a guy's body and puts a hat on him. hat "" = no hat.
# works on anything with a Body polygon, so the player and the menu guys share it
static func dress(body: Polygon2D, color: int, hat: String) -> void:
	body.color = COLORS[clampi(color, 0, COLORS.size() - 1)]

	# every guy carries the whole hat rack around, we just show the one he's wearing
	var rack := body.get_parent().get_node_or_null("Hats")
	if not rack:
		rack = HATS.instantiate()
		rack.position = body.position
		body.get_parent().add_child(rack)
	for h in rack.get_children():
		h.visible = h.name == hat


# every hat u can pick, starting with "" for no hat
static func hat_names() -> Array[String]:
	var names: Array[String] = [""]
	var rack := HATS.instantiate()
	for h in rack.get_children():
		names.append(String(h.name))
	rack.free()
	return names
