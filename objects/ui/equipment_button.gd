class_name EquipmentButton
extends Control


@export var frame_texture_normal: Texture2D
@export var frame_texture_disabled: Texture2D
@export var inner_texture_normal: Texture2D
@export var inner_texture_pressed: Texture2D
@export var inner_texture_hover: Texture2D
@export var inner_texture_focused: Texture2D
@export var inner_texture_disabled: Texture2D
@export var inner_texture_equipped_normal: Texture2D
@export var inner_texture_equipped_pressed: Texture2D
@export var inner_texture_equipped_hover: Texture2D
@export var inner_texture_equipped_focused: Texture2D
@export var background_texture: Texture2D

var button: TextureButton:
	get: return $ButtonBG/TextureButton
var frame: TextureRect:
	get: return $ButtonBG/TextureButton/ButtonFrame
var icon: TextureRect:
	get: return $ButtonBG/TextureButton/MarginContainer/Icon

var tooltip_header: String:
	get: return tr(equipment.name) if equipment else ''
var tooltip_description: String:
	get: return tr(equipment.description) if equipment else ''

var equipment: Equipment


func _ready() -> void:
	set_equipped(false)
	setup(equipment)


func setup(new_equipment: Equipment) -> void:
	if not new_equipment:
		hide()
		return
	
	equipment = new_equipment

	for connection: Dictionary in button.pressed.get_connections():
		button.pressed.disconnect(connection['callable'])
	
	button.pressed.connect(Game.loadout.toggle_equipment.bind(equipment))
	
	icon.texture = equipment.icon

	show()


func set_equipped(equipped: bool = true) -> void:
	if equipped:
		button.texture_normal = inner_texture_equipped_normal
		button.texture_pressed = inner_texture_equipped_pressed
		button.texture_hover = inner_texture_equipped_hover
		button.texture_focused = inner_texture_equipped_focused
	else:
		button.texture_normal = inner_texture_normal
		button.texture_pressed = inner_texture_pressed
		button.texture_hover = inner_texture_hover
		button.texture_focused = inner_texture_hover
	
	button.texture_disabled = inner_texture_disabled


func set_responsive(responsive: bool = true) -> void:
	if responsive:
		button.disabled = false
		frame.texture = frame_texture_normal
	else:
		button.disabled = true
		frame.texture = frame_texture_disabled


func set_pressed(pressed: bool = true) -> void:
	button.set_pressed_no_signal(pressed)
