class_name Tooltip
extends Control

@export var hover_area_control: Control

@export_group("Text")
@export var header: String
@export_multiline() var description: String
@export var text_speed: float = 40
@export var text_chunk_size: int = 7

@export_group("NinePatchRect Vars")
@export var nine_patch_texture: Texture2D
@export_subgroup("Margins", "margin_")
@export var margin_left: int = 45
@export var margin_top: int = 40
@export var margin_right: int = 45
@export var margin_bottom: int = 40
@export var tooltip_rect_size: Vector2 = Vector2(480, 280)

@export_group("")
@export_enum("NE", "SE", "SW", "NW") var growth_direction: String = "NE"
@export var popup_delay_time: float = 0.4

const open_close_margin: int = 2
const full_margin: int = 38

var is_expanded: bool = false

var parent: Control:
	get:
		if $".." is Control:
			return $".."
		else:
			Debug.error("Tooltip parent is not derived from Control.", Debug.Verbosity.CALLER)
			return
var hover_timer: Timer:
	get: return $HoverTimer
var background: NinePatchRect:
	get: return $NinePatchRect
var name_label: RichTextLabel:
	get: return $NinePatchRect/MarginContainer/VBoxContainer/NameLabel
var divider: ColorRect:
	get: return $NinePatchRect/MarginContainer/VBoxContainer/ColorRect
var description_label: RichTextLabel:
	get: return $NinePatchRect/MarginContainer/VBoxContainer/DescriptionLabel
var hover_detection: Control:
	get: return self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = 256
	
	hide_components()
	shrink_tooltip()
	
	if is_instance_valid(hover_area_control):
		hover_area_control.mouse_entered.connect(_on_hover_detection_mouse_entered)
		hover_area_control.mouse_exited.connect(_on_hover_detection_mouse_exited)
	
	hover_detection.size = parent.size
	hover_timer.wait_time = popup_delay_time
	
	if nine_patch_texture:
		background.texture = nine_patch_texture
	background.patch_margin_left = margin_left
	background.patch_margin_top = margin_top
	background.patch_margin_right = margin_right
	background.patch_margin_bottom = margin_bottom


func grow_tooltip(tooltip_size: Vector2) -> void:
	# Make sure the text is hidden to prevent odd behavior.
	name_label.text = ""
	description_label.text = ""
	
	background.patch_margin_top = open_close_margin
	background.patch_margin_bottom = open_close_margin
	background.patch_margin_left = full_margin
	background.patch_margin_right = full_margin
	
	show_components()
	
	var move_to: Vector2 = Vector2.ZERO
	match growth_direction:
		"NE":
			move_to.x = parent.size.x
			move_to.y = -tooltip_size.y
			background.position.x = parent.size.x
			background.position.y = 0
		"SE":
			move_to = parent.size
			background.position = parent.size
		"SW":
			move_to.x = -tooltip_size.x
			move_to.y = parent.size.y
			background.position.x = -size.x
			background.position.y = parent.size.y
		"NW":
			move_to = -tooltip_size
			background.position = -size
	
	var tooltip_tween = create_tween()
	tooltip_tween.tween_property(background, "size:x", tooltip_size.x, 0.2)
	tooltip_tween.parallel().tween_property(background, "position:x", move_to.x, 0.2)
	
	tooltip_tween.tween_property(background, "size:y", tooltip_size.y, 0.3)
	tooltip_tween.parallel().tween_property(background, "position:y", move_to.y, 0.3)
	
	tooltip_tween.tween_property(background, "patch_margin_top", full_margin, 0.15)
	tooltip_tween.parallel().tween_property(background, "patch_margin_bottom", full_margin, 0.15)
	
	# Now that the box is the right size, populate it with text.
	await tooltip_tween.finished
	is_expanded = true
	fill_text()


func shrink_tooltip() -> void:
	remove_text()
	
	var move_to: Vector2 = Vector2.ZERO
	match growth_direction:
		"NE":
			move_to.x = parent.size.x
			#move_to.y = -tooltip_size.y
		"SE":
			move_to = parent.size
		"SW":
			#move_to.x = -tooltip_size.x
			move_to.x = -parent.size.x
			move_to.y = parent.size.y
		"NW":
			#move_to = -tooltip_size
			background.position = -size
	
	var tooltip_tween = create_tween()
	tooltip_tween.tween_property(background, "size:y", 2 * open_close_margin, 0.3)
	tooltip_tween.parallel().tween_property(background, "position:y", move_to.y, 0.3)
	
	tooltip_tween.tween_property(background, "size:x", 0, 0.2)
	tooltip_tween.parallel().tween_property(background, "position:x", move_to.x, 0.2)
	
	await tooltip_tween.finished
	background.patch_margin_top = 0
	background.patch_margin_bottom = 0
	background.patch_margin_left = 0
	background.patch_margin_right = 0
	
	hide_components()
	is_expanded = false


func fill_text() -> void:
	for chunk in range(0, header.length() + text_chunk_size, text_chunk_size):
		name_label.text = header.substr(0, chunk)
		await get_tree().create_timer(1/text_speed).timeout
	for chunk in range(0, description.length() + text_chunk_size, text_chunk_size):
		description_label.text = description.substr(0, chunk)
		await get_tree().create_timer(1/text_speed).timeout


func remove_text() -> void:
	name_label.text = ""
	divider.hide()
	description_label.text = ""


func hide_components() -> void:
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
	size = parent.size
	position = Vector2.ZERO

func show_components() -> void:
	for child in get_children():
		if child.has_method("show"):
			child.show()


func _on_hover_detection_mouse_entered() -> void:
	#Debug.debug("Tooltip triggered.")
	hover_timer.start()

	if 'button_tooltip_text' in get_parent() and get_parent().button_tooltip_text:
		header = ''
		description = get_parent().button_tooltip_text


func _on_hover_detection_mouse_exited() -> void:
	#Debug.debug("Tooltip exited.")
	hover_timer.stop()
	shrink_tooltip()


func _on_hover_timer_timeout() -> void:
	grow_tooltip(tooltip_rect_size)
