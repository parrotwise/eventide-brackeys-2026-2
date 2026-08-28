extends NinePatchRect


@export_enum("NE", "SE", "SW", "NW") var growth_direction: String = "NE"
@export var header: String
@export_multiline() var description: String
@export var popup_delay_time: float = 1.0
@export var text_speed: float = 100

const open_close_margin: int = 2
const full_margin: int = 38

var parent: Control:
	get:
		if $".." is Control:
			return $".."
		else:
			Debug.error("Tooltip parent is not derived from Control.", Debug.Verbosity.CALLER)
			return
var name_label: RichTextLabel:
	get: return $MarginContainer/VBoxContainer/NameLabel
var description_label: RichTextLabel:
	get: return $MarginContainer/VBoxContainer/DescriptionLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	name_label.text = ""
	description_label.text = ""
	
	# TESTING
	grow_tooltip(Vector2.ZERO)
	hide()
	await get_tree().create_timer(3).timeout
	grow_tooltip(Vector2(500,380))
	# TESTING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# TODO: Determine tooltip size by input text size?? Think if necessary when refreshed.
# TODO: Add and integrate timer.
# TODO: Add scaling mouse event detection (Full Rect no-alpha button?)


func grow_tooltip(tooltip_size: Vector2) -> void:
	patch_margin_top = open_close_margin
	patch_margin_bottom = open_close_margin
	show()
	var move_to: Vector2 = Vector2.ZERO
	match growth_direction:
		"NE":
			move_to.x = parent.size.x
			move_to.y = -tooltip_size.y
			position.x = parent.size.x
			position.y = -size.y
		"SE":
			move_to = parent.size
			position = parent.size
		"SW":
			move_to.x = -tooltip_size.x
			move_to.x = -parent.size.x
			move_to.y = parent.size.y
			position.x = -size.x
			position.y = parent.size.y
		"NW":
			move_to = -tooltip_size
			position = -size
	
	var tooltip_tween = create_tween()
	tooltip_tween.tween_property(self, "size:x", tooltip_size.x, 0.2)
	tooltip_tween.parallel().tween_property(self, "position:x", move_to.x, 0.2)
	
	tooltip_tween.tween_property(self, "size:y", tooltip_size.y, 0.3)
	tooltip_tween.parallel().tween_property(self, "position:y", move_to.y, 0.3)
	
	tooltip_tween.tween_property(self, "patch_margin_top", full_margin, 0.15)
	tooltip_tween.parallel().tween_property(self, "patch_margin_bottom", full_margin, 0.15)


func fill_text() -> void:
	pass
