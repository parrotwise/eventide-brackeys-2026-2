class_name ActionButton
extends Control


signal button_down()
signal button_up()
signal pressed()
signal toggled(toggled_on: bool)


@export var icon_texture: Texture2D
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


func _ready() -> void:
	button.button_down.connect(button_down.emit)
	button.button_up.connect(button_up.emit)
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit)

	button.mouse_entered.connect(show_tooltip)
	button.mouse_entered.connect(Game.pointer.switch_to.bind(Enums.PointerType.CLICKABLE))
	button.mouse_exited.connect(hide_tooltip)
	button.mouse_exited.connect(Game.pointer.switch_to.bind(Enums.PointerType.DEFAULT))

	icon.texture = icon_texture
	frame.texture = frame_texture
	background.texture = background_texture

	set_selected(false)


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


## TODO: implement!
func show_tooltip() -> void:
	pass


## TODO: implement!
func hide_tooltip() -> void:
	pass
