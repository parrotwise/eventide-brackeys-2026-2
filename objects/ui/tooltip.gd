extends Control


@export_enum("NE", "SE", "SW", "NW") var growth_direction: String = "NE"
@export var header: String
@export_multiline() var description: String
@export var popup_delay_time: float = 1.0
@export var text_speed: float = 100

var nine_patch_rect: NinePatchRect:
	get: return $NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	# TESTING
	grow_tooltip(Vector2.ZERO)
	hide()
	await get_tree().create_timer(3).timeout
	grow_tooltip(Vector2(800,380))
	# TESTING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# TODO: Determine tooltip size by input text size?? Think if necessary when refreshed.
# TODO: Add and integrate timer.
# TODO: Add scaling mouse event detection (Full Rect no-alpha button?)


func grow_tooltip(tooltip_size: Vector2) -> void:
	show()
	var move_to: Vector2
	match growth_direction:
		"NE":
			move_to.y = -tooltip_size.y
		"SE":
			move_to = Vector2.ZERO
		"SW":
			move_to = -tooltip_size
		"NW":
			move_to.x = -tooltip_size.x
	
	var tooltip_tween = create_tween()
	tooltip_tween.tween_property(self, "size:x", tooltip_size.x, 0.2)
	tooltip_tween.parallel().tween_property(self, "position:x", move_to.x, 0.2)
	tooltip_tween.tween_property(self, "size:y", tooltip_size.y, 0.3)
	tooltip_tween.parallel().tween_property(self, "position:y", move_to.y, 0.3)
