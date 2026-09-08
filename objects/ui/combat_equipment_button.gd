class_name CombatEquipmentButton
extends Control


signal button_down()
signal button_up()
signal pressed()
signal toggled(toggled_on: bool)


@export var passive_frame_texture: Texture2D
@export var passive_inner_texture_normal: Texture2D
@export var passive_inner_texture_hover: Texture2D
@export var passive_background_texture: Texture2D

@export var activated_frame_texture: Texture2D
@export var activated_inner_texture_normal: Texture2D
@export var activated_inner_texture_pressed: Texture2D
@export var activated_inner_texture_hover: Texture2D
@export var activated_inner_texture_disabled: Texture2D
@export var activated_inner_texture_selected_normal: Texture2D
@export var activated_inner_texture_selected_pressed: Texture2D
@export var activated_inner_texture_selected_hover: Texture2D
@export var activated_background_texture: Texture2D

var icon: TextureRect:
	get: return $Icon
var frame: TextureRect:
	get: return $Frame
var button: TextureButton:
	get: return $InnerButton
var background: TextureRect:
	get: return $Background

var equipment: Equipment

var tooltip_header: String:
	get: return equipment.name if equipment else ''
var tooltip_description: String:
	get: return equipment.description if equipment else ''


func _ready() -> void:
	button.button_down.connect(button_down.emit)
	button.button_up.connect(button_up.emit)
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit)

	button.mouse_entered.connect(_on_mouse_enter)
	button.mouse_exited.connect(_on_mouse_exit)

	setup(null)


func setup(new_equipment: Equipment) -> void:
	equipment = new_equipment

	for connection: Dictionary in focus_entered.get_connections():
		focus_entered.disconnect(connection['callable'])

	if not equipment:
		icon.texture = null
		frame.texture = null
		button.texture_normal = null
		button.texture_hover = null
		background.texture = null

		hide()
		return
	
	icon.texture = equipment.icon
	
	if equipment.activated_ability:
		frame.texture = activated_frame_texture
		background.texture = activated_background_texture

		button.focus_mode = Control.FOCUS_CLICK

		## TODO: Replace with the commented-out callable after Wwise migration
		focus_entered.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
		# focus_entered.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
		focus_entered.connect(Game.level.selector_component.select_action.bind(equipment.activated_ability))

		set_selected(false)
	
	else:
		frame.texture = passive_frame_texture
		background.texture = passive_background_texture

		button.texture_normal = passive_inner_texture_normal
		button.texture_pressed = null
		button.texture_hover = passive_inner_texture_hover

		button.focus_mode = Control.FOCUS_NONE
	
	show()


func set_selected(selected: bool = false):
	if not equipment or not equipment.activated_ability:
		return
	
	if selected:
		button.texture_normal = activated_inner_texture_normal
		button.texture_pressed = activated_inner_texture_pressed
		button.texture_hover = activated_inner_texture_hover
	else:
		button.texture_normal = activated_inner_texture_selected_normal
		button.texture_pressed = activated_inner_texture_selected_pressed
		button.texture_hover = activated_inner_texture_selected_hover
	
	button.texture_disabled = activated_inner_texture_disabled


func _on_mouse_enter() -> void:
	if not equipment.activated_ability:
		return
	
	if Game.pointer.type in [Enums.PointerType.DEFAULT, Enums.PointerType.PRESSING]:
		Game.pointer.switch_to(Enums.PointerType.CLICKABLE)

func _on_mouse_exit() -> void:
	if not equipment.activated_ability:
		return
	
	if Game.pointer.type in [Enums.PointerType.CLICKABLE, Enums.PointerType.CLICKING]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)
