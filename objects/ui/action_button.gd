class_name ActionButton
extends Control


signal button_down()
signal button_up()
signal pressed()
signal toggled(toggled_on: bool)


@export var frame_texture: Texture2D
@export var inner_texture_normal: Texture2D
@export var inner_texture_pressed: Texture2D
@export var inner_texture_hover: Texture2D
@export var inner_texture_disabled: Texture2D
@export var inner_texture_selected_normal: Texture2D
@export var inner_texture_selected_pressed: Texture2D
@export var inner_texture_selected_hover: Texture2D
@export var background_texture: Texture2D

var icon: TextureRect:
	get: return $Icon
var frame: TextureRect:
	get: return $Frame
var button: TextureButton:
	get: return $InnerButton
var background: TextureRect:
	get: return $Background

var action: Action

var tooltip_header: String:
	get: return action.name if action else ''
var tooltip_description: String:
	get: return action.description if action else ''


func _ready() -> void:
	button.button_down.connect(button_down.emit)
	button.button_up.connect(button_up.emit)
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit)

	button.mouse_entered.connect(_on_mouse_enter)
	button.mouse_exited.connect(_on_mouse_exit)

	frame.texture = frame_texture
	background.texture = background_texture

	set_selected(false)
	
	button.disabled = true


func setup(new_action: Action) -> void:
	if action:
		if action.uses_expended.is_connected(refresh):
			action.uses_expended.disconnect(refresh)
		
		if action.uses_restored.is_connected(refresh):
			action.uses_restored.disconnect(refresh)
	
	for connection: Dictionary in pressed.get_connections():
		pressed.disconnect(connection['callable'])

	action = new_action
	
	if not action:
		icon.texture = null
		return
	
	icon.texture = action.icon

	action.uses_expended.connect(refresh)
	action.uses_restored.connect(refresh)

	## TODO: Replace with the commented-out callable after Wwise migration
	pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	pressed.connect(Game.level.selector_component.select_action.bind(action))

	refresh()


func set_selected(selected: bool = false):
	if selected:
		button.texture_normal = inner_texture_selected_normal
		button.texture_pressed = inner_texture_selected_pressed
		button.texture_hover = inner_texture_selected_hover
	else:
		button.texture_normal = inner_texture_normal
		button.texture_pressed = inner_texture_pressed
		button.texture_hover = inner_texture_hover
	
	button.texture_disabled = inner_texture_disabled


func _on_mouse_enter() -> void:
	if button.disabled:
		return
	
	if Game.pointer.type in [Enums.PointerType.DEFAULT, Enums.PointerType.PRESSING]:
		Game.pointer.switch_to(Enums.PointerType.CLICKABLE)


func _on_mouse_exit() -> void:
	if button.disabled:
		return
	
	if Game.pointer.type in [Enums.PointerType.CLICKABLE, Enums.PointerType.CLICKING]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)


func refresh() -> void:
	if not action:
		return
	
	button.disabled = not action.uses_left
